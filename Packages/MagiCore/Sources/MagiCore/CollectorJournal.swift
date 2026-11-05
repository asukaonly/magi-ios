import Foundation
import CryptoKit

public struct HealthCheckpoint: Codable, Sendable, Equatable {
    public var anchors: [String: Data] = [:]
    public var stepDates: [String: Double] = [:]
    public var fingerprints: [String: String] = [:]
    public init() {}
}

public struct CollectorState: Codable, Sendable {
    public var connectionID: String?
    public var connectionEpoch: String?
    public var dataEpoch: String?
    public var producerID = UUID().uuidString.lowercased()
    public var sequence: Int64 = 0
    public var pending: [Wire.BackgroundEvent] = []
    public var checkpoint = HealthCheckpoint()
    public var paused = true
    public var start: Date?
    public var timezone = TimeZone.current.identifier
    public var types: [String] = []
    public var lastSent: Date?
    public var createRequestID: String?
    public var createBody: JSONValue?
    public init() {}
}

/// One protected snapshot owns both checkpoints and the exact unacknowledged events.
public actor CollectorJournal {
    private let url: URL
    public init(root: URL, credential: ConnectionCredential) {
        let identity = "\(credential.address.baseURL)|\(credential.serverID)|\(credential.clientID)"
        let key = SHA256.hash(data: Data(identity.utf8)).map { String(format: "%02x", $0) }.joined()
        url = root.appendingPathComponent("health-\(key).json")
    }
    public func read() throws -> CollectorState {
        guard FileManager.default.fileExists(atPath: url.path) else { return CollectorState() }
        guard (try url.resourceValues(forKeys: [.fileSizeKey])).fileSize ?? 0 <= 32 * 1024 * 1024 else { throw ClientError.storage }
        return try JSONDecoder().decode(CollectorState.self, from: Data(contentsOf: url))
    }
    public func save(_ state: CollectorState) throws {
        guard state.pending.count <= 10000 else { throw ClientError.responseTooLarge }
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        var directory = url.deletingLastPathComponent()
        var values = URLResourceValues(); values.isExcludedFromBackup = true
        try directory.setResourceValues(values)
        let bytes = try JSONEncoder().encode(state)
        guard bytes.count <= 32 * 1024 * 1024 else { throw ClientError.responseTooLarge }
        #if os(iOS)
        try bytes.write(to: url, options: [.atomic, .completeFileProtection])
        #else
        try bytes.write(to: url, options: .atomic)
        #endif
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: url.path)
    }
    public func erase() throws {
        if FileManager.default.fileExists(atPath: url.path) { try FileManager.default.removeItem(at: url) }
    }
    public static func enqueue(changes: [Wire.ObservationChange], checkpoint: HealthCheckpoint, into state: inout CollectorState) throws {
        guard let connection = state.connectionID, let epoch = state.connectionEpoch, state.dataEpoch != nil else { throw ClientError.invalidContract }
        guard state.pending.count + changes.count <= 10000 else { throw ClientError.responseTooLarge }
        for change in changes {
            state.sequence += 1
            let payload = Wire.SourceObservation(capability_id: "apple_health.observe", change: change, connection_epoch: epoch,
                connection_id: connection, kind: "source_observation", protocol: "source.change.v1", schema_id: "apple_health.record", schema_version: 1, source_type: "apple_health")
            state.pending.append(Wire.BackgroundEvent(event_id: UUID().uuidString.lowercased(), occurred_at_ms: Int64(Date().timeIntervalSince1970 * 1000),
                payload: try JSONValue.encode(payload), sequence: state.sequence, stream: "apple_health"))
        }
        state.checkpoint = checkpoint
    }
    public static func accept(_ receipt: Wire.DeliveryReceipt, batch: Wire.DeliveryBatch, into state: inout CollectorState) throws -> Bool {
        guard receipt.server_id == batch.server_id, receipt.data_epoch == batch.data_epoch,
              state.dataEpoch == batch.data_epoch, receipt.receipts.count == batch.events.count,
              Set(receipt.receipts.map(\.event_id)) == Set(batch.events.map(\.event_id)) else { throw ClientError.invalidResponse }
        let accepted = Set(receipt.receipts.filter { $0.status == "accepted" }.map(\.event_id))
        state.pending.removeAll { accepted.contains($0.event_id) }
        return accepted.count == batch.events.count
    }
    public static func validate(scope: Wire.CollectorScope, state: CollectorState, dataEpoch: String, collectorID: String) throws {
        let capability = scope.capability
        guard scope.connection_id == state.connectionID, scope.source_type == "apple_health",
              capability.capability_id == "apple_health.observe", capability.protocol == "source.change.v1",
              capability.schema_id == "apple_health.record", capability.schema_version == 1,
              capability.supports_resources != true, capability.direction == nil || capability.direction == "observe"
        else { throw ClientError.unsupportedProtocol }
        guard scope.claimed_by == nil || scope.claimed_by == collectorID else { throw ClientError.conflict }
        if let previous = state.dataEpoch, previous != dataEpoch { throw ClientError.expiredGeneration }
        if let previous = state.connectionEpoch, previous != scope.connection_epoch { throw ClientError.expiredGeneration }
    }
}

extension MagiClient {
    public func createPluginConnection(pluginID: String, body: JSONValue, requestID: String, dataEpoch: String) async throws -> Wire.PluginConnectionResponse {
        let headers = ["X-Magi-Request-Id": requestID, "X-Magi-Data-Epoch": dataEpoch]
        do {
            let receipt = try await request(Wire.PluginRpcReceipt.self, path: "/plugins/requests/\(ServerAddress.segment(requestID))", template: "/plugins/requests/{operation_id}", headers: headers)
            guard receipt.operation_id == requestID, receipt.state == "completed", receipt.http_status == 201 else { throw ClientError.conflict }
            try Contract.current.validate(receipt.result, named: "PluginConnectionResponse")
            return try receipt.result.decode(Wire.PluginConnectionResponse.self)
        } catch ClientError.http(404) {
            let result = try await request(JSONValue.self, method: "POST", path: "/plugins/\(ServerAddress.segment(pluginID))/connections",
                template: "/plugins/{plugin_id}/connections", body: body, headers: headers)
            guard result["connection_id"].string != nil else { throw ClientError.conflict }
            try Contract.current.validate(result, named: "PluginConnectionResponse")
            return try result.decode(Wire.PluginConnectionResponse.self)
        }
    }
    public func collectorScope(connectionID: String) async throws -> Wire.CollectorScope {
        try await request(Wire.CollectorScope.self, path: "/delivery/collector/\(ServerAddress.segment(connectionID))", template: "/delivery/collector/{connection_id}")
    }
    public func claimCollector(_ scope: Wire.CollectorScope) async throws -> Wire.CollectorScope {
        let claim = Wire.CollectorClaim(capability_id: scope.capability.capability_id, connection_epoch: scope.connection_epoch,
            protocol: scope.capability.protocol, schema_id: scope.capability.schema_id, schema_version: scope.capability.schema_version)
        return try await request(Wire.CollectorScope.self, method: "POST", path: "/delivery/collector/\(ServerAddress.segment(scope.connection_id))",
            template: "/delivery/collector/{connection_id}", body: JSONValue.encode(claim))
    }
}

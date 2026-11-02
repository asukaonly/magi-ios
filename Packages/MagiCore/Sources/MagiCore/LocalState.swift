import Foundation
import CryptoKit

public struct OutgoingTurn: Codable, Sendable, Equatable, Identifiable {
    public var id: String { request.client_turn_id ?? "" }
    public var request: Wire.UserMessageRequest
    public var dataEpoch: String
    public var attempted: Bool
    public var confirmed: Bool
    public var createdAt: Date
    public init(request: Wire.UserMessageRequest, dataEpoch: String, attempted: Bool = false, confirmed: Bool = false, createdAt: Date = Date()) {
        self.request = request; self.dataEpoch = dataEpoch; self.attempted = attempted; self.confirmed = confirmed; self.createdAt = createdAt
    }
}

public struct CachedState: Codable, Sendable {
    public var dataEpoch: String?
    public var sessions: [Wire.ChatSessionSummary] = []
    public var transcripts: [String: [Wire.ChatDisplayMessage]] = [:]
    public var outgoing: [OutgoingTurn] = []
    public init() {}
}

public actor LocalState {
    private let url: URL
    private var value = CachedState()
    private var loaded = false
    public init(root: URL, credential: ConnectionCredential) {
        let identity = "\(credential.address.baseURL.absoluteString)|\(credential.serverID)|\(credential.clientID)"
        let key = SHA256.hash(data: Data(identity.utf8)).map { String(format: "%02x", $0) }.joined()
        url = root.appendingPathComponent(key).appendingPathExtension("json")
    }
    public func read() throws -> CachedState {
        if !loaded {
            if FileManager.default.fileExists(atPath: url.path) {
                value = try JSONDecoder().decode(CachedState.self, from: Data(contentsOf: url))
            }
            loaded = true
        }
        return value
    }
    private func commit(_ next: CachedState) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true,
                                               attributes: [.posixPermissions: 0o700])
        var directory = url.deletingLastPathComponent()
        var properties = URLResourceValues(); properties.isExcludedFromBackup = true
        try directory.setResourceValues(properties)
        let data = try JSONEncoder().encode(next)
        #if os(iOS)
        try data.write(to: url, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
        #else
        try data.write(to: url, options: .atomic)
        #endif
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: url.path)
        value = next; loaded = true
    }
    public func observeGeneration(_ epoch: String) throws -> Bool {
        var next = try read()
        let changed = next.dataEpoch != nil && next.dataEpoch != epoch
        if changed { next.sessions = []; next.transcripts = [:] }
        next.dataEpoch = epoch
        try commit(next)
        return changed
    }
    public func updateSessions(_ sessions: [Wire.ChatSessionSummary]) throws {
        var next = try read(); next.sessions = Array(sessions.prefix(500)); try commit(next)
    }
    public func updateHistory(_ messages: [Wire.ChatDisplayMessage], sessionID: String) throws {
        var next = try read(); next.transcripts[sessionID] = Array(messages.suffix(200))
        if next.transcripts.count > 20 {
            let retained = Set(next.sessions.prefix(19).map(\.session_id) + [sessionID])
            next.transcripts = next.transcripts.filter { retained.contains($0.key) }
        }
        try commit(next)
    }
    public func put(_ outgoing: OutgoingTurn) throws {
        var next = try read()
        if let position = next.outgoing.firstIndex(where: { $0.id == outgoing.id }) { next.outgoing[position] = outgoing }
        else {
            guard next.outgoing.count < 100 else { throw ClientError.storage }
            next.outgoing.append(outgoing)
        }
        try commit(next)
    }
    public func remove(_ id: String) throws {
        var next = try read(); next.outgoing.removeAll { $0.id == id }; try commit(next)
    }
    public func erase() throws {
        if FileManager.default.fileExists(atPath: url.path) { try FileManager.default.removeItem(at: url) }
        value = CachedState(); loaded = true
    }
}

public enum DeliveryResult: Sendable, Equatable { case confirmed, concluded, uncertain }

public enum TurnDelivery {
    public static func deliver(_ input: OutgoingTurn, client: MagiClient, journal: LocalState) async throws -> DeliveryResult {
        var turn = input
        guard let sessionID = turn.request.session_id, let turnID = turn.request.client_turn_id,
              !sessionID.isEmpty, !turnID.isEmpty else { throw ClientError.invalidContract }
        let info = try await client.info()
        guard info.service_ready, ["idle", "completed"].contains(info.maintenance?.phase ?? "") else { throw ClientError.serviceUnavailable }
        guard info.maintenance?.data_epoch == turn.dataEpoch else { throw ClientError.expiredGeneration }
        if turn.attempted {
            let confirmation = try await client.confirmation(sessionID: sessionID, turnID: turnID)
            if confirmation.status == "confirmed" {
                turn.confirmed = true; try await journal.put(turn); return .confirmed
            }
            if confirmation.status == "concluded" { return .concluded }
            guard confirmation.safe_to_retry else { return .uncertain }
        }
        turn.attempted = true
        try await journal.put(turn)
        var modelSetupRequired = false
        do {
            let receipt = try await client.send(turn.request)
            if receipt.success, receipt.data?["session_id"]?.string == sessionID,
               receipt.data?["turn_id"]?.string == turnID {
                turn.confirmed = true; try await journal.put(turn); return .confirmed
            }
            modelSetupRequired = !receipt.success && receipt.data?["error_code"]?.string == "RUNTIME_NOT_READY"
        } catch {
            if error is CancellationError { throw error }
        }
        let confirmation = try await client.confirmation(sessionID: sessionID, turnID: turnID)
        if confirmation.status == "confirmed" {
            turn.confirmed = true; try await journal.put(turn); return .confirmed
        }
        if modelSetupRequired && confirmation.safe_to_retry { throw ClientError.runtimeNotReady }
        return confirmation.status == "concluded" ? .concluded : .uncertain
    }
}

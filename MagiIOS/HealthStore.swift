import Foundation
import Observation
import MagiCore

@MainActor @Observable final class HealthStore {
    private let owner: MagiClient
    private let credential: ConnectionCredential
    private let journal: CollectorJournal
    private let keychain: CredentialStore
    private let reader = HealthReader()
    private var collector: MagiClient?
    private var active = true
    private var foreground = true
    private var loaded = false
    private(set) var state = CollectorState()
    private(set) var preview: HealthPreview?
    private(set) var busy = false
    private(set) var sending = false
    private(set) var error: String?

    init(owner: MagiClient, credential: ConnectionCredential, root: URL) {
        self.owner = owner; self.credential = credential
        journal = CollectorJournal(root: root, credential: credential)
        keychain = CredentialStore(account: "health:\(credential.serverID):\(credential.clientID)")
    }
    func setForeground(_ value: Bool) { foreground = value }
    func load() async {
        guard !loaded else { return }
        do {
            state = try await journal.read()
            if let stored = try keychain.load() {
                guard stored.serverID == credential.serverID, stored.address == credential.address else { throw ClientError.identityChanged }
                collector = MagiClient(credential: stored)
            }
            loaded = true
        } catch { self.error = "error.storage" }
    }
    private func save() async throws {
        guard active else { throw CancellationError() }
        try await journal.save(state)
    }
    private var connectionPath: String {
        "/plugins/apple-health/connections/\(ServerAddress.segment(state.connectionID ?? ""))"
    }
    private func updateEnabled(_ enabled: Bool) async throws {
        let current = try await owner.request(Wire.PluginConnectionResponse.self, path: connectionPath, template: "/plugins/{plugin_id}/connections/{connection_id}")
        guard let revision = current.revision else { throw ClientError.invalidResponse }
        _ = try await owner.request(Wire.PluginConnectionResponse.self, method: "PATCH", path: connectionPath,
            template: "/plugins/{plugin_id}/connections/{connection_id}", body: .object([
                "expected_revision": .integer(revision), "enabled": .bool(enabled),
                "settings": .object(["sources": .object(["apple_health": .object(["enabled": .bool(enabled), "processing_consent": .bool(true)])])]),
            ]))
    }
    private func ensureConnection(types: [String], days: Int) async throws {
        let info = try await owner.info()
        guard let epoch = info.maintenance?.data_epoch else { throw ClientError.invalidResponse }
        if let saved = state.dataEpoch, saved != epoch { throw ClientError.expiredGeneration }
        if state.connectionID == nil {
            if state.createRequestID == nil {
                state.dataEpoch = epoch
                state.createRequestID = "\(Int64(Date().timeIntervalSince1970 * 1000))-\(UUID().uuidString.lowercased())"
                state.createBody = .object(["display_name": .string("iPhone · \(credential.clientID.prefix(6))"), "enabled": .bool(true),
                    "settings": .object(["sources": .object(["apple_health": .object(["enabled": .bool(true), "processing_consent": .bool(true)])])])])
                state.types = types.sorted()
                state.start = Calendar.current.startOfDay(for: Date().addingTimeInterval(-Double(days - 1) * 86400))
                state.timezone = TimeZone.current.identifier
                try await save()
            }
            guard let requestID = state.createRequestID, let body = state.createBody else { throw ClientError.storage }
            let connection = try await owner.createPluginConnection(pluginID: "apple-health", body: body, requestID: requestID, dataEpoch: epoch)
            state.connectionID = connection.connection_id; state.createRequestID = nil; state.createBody = nil
            try await save()
        } else if state.paused { try await updateEnabled(true) }
        guard active, let connectionID = state.connectionID else { throw CancellationError() }
        if collector == nil {
            let response = try await owner.request(JSONValue.self, method: "POST", path: "/server/collector-grants",
                body: .object(["connection_id": .string(connectionID), "source_type": .string("apple_health")]))
            guard response["success"].bool == true, let token = response["data"]["pairing_token"].string,
                  response["data"]["server_id"].string == credential.serverID else { throw ClientError.invalidResponse }
            let scoped = try await MagiClient.pair(address: credential.address, code: token, deviceName: "Magi iOS Health")
            guard active, scoped.serverID == credential.serverID else { throw ClientError.identityChanged }
            try keychain.save(scoped); collector = MagiClient(credential: scoped)
        }
        try await negotiate(epoch: epoch)
        state.paused = false; try await save()
    }
    private func negotiate(epoch: String) async throws {
        guard active, let collector, let id = state.connectionID else { throw ClientError.offline }
        var scope = try await collector.collectorScope(connectionID: id)
        let collectorID = await collector.credential.clientID
        try CollectorJournal.validate(scope: scope, state: state, dataEpoch: epoch, collectorID: collectorID)
        if scope.claimed_by == nil { scope = try await collector.claimCollector(scope) }
        guard scope.claimed_by == collectorID else { throw ClientError.conflict }
        state.connectionEpoch = scope.connection_epoch; state.dataEpoch = epoch
        try await save()
    }
    func prepare(types: [String], days: Int) async {
        guard active, foreground, loaded, !busy, !types.isEmpty else { return }
        busy = true; error = nil; preview = nil
        defer { busy = false }
        do {
            let selected = state.types.isEmpty ? types : state.types
            try await reader.authorize(types: selected)
            try await ensureConnection(types: selected, days: days)
            guard active else { throw CancellationError() }
            let result = try await reader.preview(state: state)
            guard active, foreground else { throw CancellationError() }
            preview = result
            if result.changes.isEmpty { state.checkpoint = result.checkpoint; try await save() }
        } catch { report(error) }
    }
    func send() async {
        guard active, foreground, !busy, !state.paused else { return }
        busy = true; sending = true; error = nil; defer { busy = false; sending = false }
        do {
            let info = try await owner.info()
            guard let epoch = info.maintenance?.data_epoch else { throw ClientError.invalidResponse }
            try await negotiate(epoch: epoch)
            guard active, foreground, !state.paused else { throw CancellationError() }
            if let preview {
                var next = state
                try CollectorJournal.enqueue(changes: preview.changes, checkpoint: preview.checkpoint, into: &next)
                try await journal.save(next)
                guard active else { throw CancellationError() }
                next.paused = state.paused
                state = next; self.preview = nil
            }
            guard let collector, let deliveryEpoch = state.dataEpoch else { throw ClientError.offline }
            while let event = state.pending.first {
                guard active, foreground, !state.paused else { throw CancellationError() }
                let batch = Wire.DeliveryBatch(data_epoch: deliveryEpoch, events: [event], producer_id: state.producerID, server_id: credential.serverID)
                let receipt = try await collector.request(Wire.DeliveryReceipt.self, method: "POST", path: "/delivery/events", body: JSONValue.encode(batch))
                guard active else { throw CancellationError() }
                let accepted = try CollectorJournal.accept(receipt, batch: batch, into: &state)
                try await save()
                guard accepted else { throw ClientError.conflict }
            }
            state.lastSent = .now; try await save()
        } catch { report(error) }
    }
    func pause() async {
        guard active, !busy || sending else { return }
        let wasBusy = busy
        state.paused = true; preview = nil
        busy = true; error = nil; defer { if !wasBusy { busy = false } }
        do {
            state.paused = true; preview = nil; try await save()
            if state.connectionID != nil { try await updateEnabled(false) }
        } catch { report(error) }
    }
    func clear() async {
        guard active, !busy else { return }
        busy = true; error = nil; defer { busy = false }
        do {
            state.paused = true; preview = nil; try await save()
            if state.connectionID != nil {
                try await updateEnabled(false)
                let current = try await owner.request(Wire.PluginConnectionResponse.self, path: connectionPath, template: "/plugins/{plugin_id}/connections/{connection_id}")
                guard let revision = current.revision else { throw ClientError.invalidResponse }
                _ = try await owner.request(Wire.PluginConnectionResponse.self, method: "POST", path: connectionPath + "/clear", template: "/plugins/{plugin_id}/connections/{connection_id}/clear",
                    body: .object(["expected_revision": .integer(revision)]))
            }
            state.pending = []; state.checkpoint = HealthCheckpoint(); state.connectionEpoch = nil; state.lastSent = nil
            state.dataEpoch = try await owner.info().maintenance?.data_epoch
            state.producerID = UUID().uuidString.lowercased(); state.sequence = 0
            try await save()
        } catch { report(error) }
    }
    func eraseLocal() async throws {
        active = false; state.paused = true; preview = nil
        try keychain.remove(); try await journal.erase()
    }
    private func report(_ failure: any Error) {
        if failure is CancellationError { return }
        switch failure as? ClientError {
        case .expiredGeneration: error = "health.generation"
        case .unauthorized: error = "health.reconnect"
        case .conflict: error = "health.pending"
        case .storage: error = "error.storage"
        default: error = "health.failed"
        }
    }
}

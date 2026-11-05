import Foundation
import Testing
@testable import MagiCore

func verifyHealthService(owner: MagiClient, credential: ConnectionCredential) async throws {
    let plan = try await owner.request(Wire.PluginInstallPlanResponse.self, method: "POST", path: "/plugins/install/registry/plan", body: .object(["plugin_id": .string("apple-health"), "update": .bool(false)]))
    var job = try await owner.request(Wire.PluginInstallJobSnapshot.self, method: "POST", path: "/plugins/install/registry/jobs", body: .object(["plugin_id": .string("apple-health"), "plan_fingerprint": .string(plan.fingerprint)]))
    for _ in 0..<90 {
        if ["completed", "failed"].contains(job.status) { break }
        try await Task.sleep(for: .seconds(1))
        job = try await owner.request(Wire.PluginInstallJobSnapshot.self, path: "/plugins/install/jobs/\(job.job_id)", template: "/plugins/install/jobs/{job_id}")
    }
    #expect(job.status == "completed", "Installation result: \(job)")
    let package = try #require(job.result)
    _ = try await owner.request(Wire.PluginPackageResponse.self, method: "POST", path: "/plugins/apple-health/trust", template: "/plugins/{plugin_id}/trust", body: .object([
        "expected_package_sha256": .string(try #require(package.package_sha256)), "expected_capabilities": try JSONValue.encode(package.manifest.capabilities ?? []), "expected_execution_mode": .string(package.manifest.execution_mode)]))
    let epoch = try #require(try await owner.info().maintenance?.data_epoch)
    let connection = try await owner.createPluginConnection(pluginID: "apple-health", body: .object(["display_name": .string("Synthetic health verification"), "enabled": .bool(true), "settings": .object(["sources": .object(["apple_health": .object(["enabled": .bool(true), "processing_consent": .bool(true)])])])]), requestID: "\(Int64(Date().timeIntervalSince1970 * 1000))-\(UUID().uuidString.lowercased())", dataEpoch: epoch)
    let grant = try await owner.request(JSONValue.self, method: "POST", path: "/server/collector-grants", body: .object(["connection_id": .string(connection.connection_id), "source_type": .string("apple_health")]))
    let scoped = try await MagiClient.pair(address: credential.address, code: #require(grant["data"]["pairing_token"].string), deviceName: "Synthetic Health Collector")
    let collector = MagiClient(credential: scoped)
    let scope = try await collector.claimCollector(collector.collectorScope(connectionID: connection.connection_id))
    var state = CollectorState(); state.connectionID = connection.connection_id; state.connectionEpoch = scope.connection_epoch; state.dataEpoch = epoch
    let now = Date().timeIntervalSince1970
    let payload: [String: JSONValue] = ["record_id": .string("steps:verification"), "record_type": .string("steps"), "start": .number(now - 3600), "end": .number(now), "timezone": .string("Asia/Shanghai"), "value": .number(1234), "unit": .string("count"), "category": .string(""), "source": .string("Synthetic verification")]
    let change = Wire.ObservationChange(object_id: "steps:verification", occurred_at: now - 3600, operation: "upsert", payload: payload, version: "one")
    try CollectorJournal.enqueue(changes: [change], checkpoint: HealthCheckpoint(), into: &state)
    let batch = Wire.DeliveryBatch(data_epoch: epoch, events: state.pending, producer_id: state.producerID, server_id: credential.serverID)
    for _ in 0..<2 {
        let receipt = try await collector.request(Wire.DeliveryReceipt.self, method: "POST", path: "/delivery/events", body: JSONValue.encode(batch))
        #expect(try CollectorJournal.accept(receipt, batch: batch, into: &state), "Delivery receipt: \(receipt)")
    }
    var records: [Wire.MemoryLibraryItem] = []
    for _ in 0..<30 {
        records = try await owner.memory(view: "events").items.filter { $0.text.contains("1234") }
        if !records.isEmpty { break }
        try await Task.sleep(for: .seconds(1))
    }
    #expect(records.count == 1, "The replayed observation must produce one visible memory event")
    try CollectorJournal.enqueue(changes: [Wire.ObservationChange(object_id: "steps:verification", operation: "delete", version: "two")], checkpoint: HealthCheckpoint(), into: &state)
    let deletion = Wire.DeliveryBatch(data_epoch: epoch, events: state.pending, producer_id: state.producerID, server_id: credential.serverID)
    let receipt = try await collector.request(Wire.DeliveryReceipt.self, method: "POST", path: "/delivery/events", body: JSONValue.encode(deletion))
    #expect(try CollectorJournal.accept(receipt, batch: deletion, into: &state))
    // Source deletion and cache clear preserve imported memory; the memory page owns forgetting.
    let path = "/plugins/apple-health/connections/\(connection.connection_id)"
    let current = try await owner.request(Wire.PluginConnectionResponse.self, path: path, template: "/plugins/{plugin_id}/connections/{connection_id}")
    _ = try await owner.request(Wire.PluginConnectionResponse.self, method: "PATCH", path: path, template: "/plugins/{plugin_id}/connections/{connection_id}", body: .object(["expected_revision": .integer(try #require(current.revision)), "enabled": .bool(false)]))
    let paused = try await owner.request(Wire.PluginConnectionResponse.self, path: path, template: "/plugins/{plugin_id}/connections/{connection_id}")
    _ = try await owner.request(Wire.PluginConnectionResponse.self, method: "POST", path: path + "/clear", template: "/plugins/{plugin_id}/connections/{connection_id}/clear", body: .object(["expected_revision": .integer(try #require(paused.revision))]))
    for record in records { try await owner.forgetMemory(record) }
    for _ in 0..<30 {
        records = try await owner.memory(view: "events").items.filter { $0.text.contains("1234") }
        if records.isEmpty { break }
        try await Task.sleep(for: .seconds(1))
    }
    #expect(records.isEmpty, "Explicitly forgotten health data must disappear from governed memory reads")
}

import Foundation
import Testing
@testable import MagiCore

private let connectionID = "conn_" + String(repeating: "a", count: 32)
private let connectionEpoch = "44444444-4444-4444-8444-444444444444"
private func state() -> CollectorState {
    var state = CollectorState()
    state.connectionID = connectionID; state.connectionEpoch = connectionEpoch; state.dataEpoch = dataEpoch
    return state
}
private func scope(version: Int64 = 1, epoch: String = connectionEpoch) -> Wire.CollectorScope {
    Wire.CollectorScope(capability: Wire.CollectionCapability(capability_id: "apple_health.observe", direction: "observe",
        payload_schema: ["type": .string("object")], protocol: "source.change.v1", schema_id: "apple_health.record", schema_version: version, supports_resources: false),
        claimed_by: clientID, connection_epoch: epoch, connection_id: connectionID, source_type: "apple_health")
}

@Test func collectorCheckpointAndPendingEventsPersistTogether() async throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let journal = CollectorJournal(root: root, credential: try credential())
    var next = state(), checkpoint = HealthCheckpoint()
    checkpoint.anchors["sleep"] = Data("opaque-anchor".utf8)
    let change = Wire.ObservationChange(object_id: "sleep:sample-id", operation: "delete", version: "revision-1")
    try CollectorJournal.enqueue(changes: [change], checkpoint: checkpoint, into: &next)
    try await journal.save(next)
    let reopened = try await CollectorJournal(root: root, credential: credential()).read()
    #expect(reopened.pending == next.pending)
    #expect(reopened.checkpoint == checkpoint)
    #expect(reopened.sequence == 1)
    let payload = try #require(reopened.pending.first?.payload)
    #expect(payload["change"]["operation"].string == "delete")
    #expect(payload["connection_epoch"].string == connectionEpoch)
    try Contract.current.validate(payload, named: "SourceObservation")
}

@Test func collectorOnlyRemovesExactlyAcknowledgedEvents() throws {
    var next = state()
    let change = Wire.ObservationChange(object_id: "sample", operation: "delete", version: "revision")
    try CollectorJournal.enqueue(changes: [change], checkpoint: HealthCheckpoint(), into: &next)
    let original = next.pending
    let batch = Wire.DeliveryBatch(data_epoch: dataEpoch, events: next.pending, producer_id: next.producerID, server_id: serverID)
    let id = try #require(next.pending.first?.event_id)
    for status in ["retry", "rejected"] {
        let receipt = Wire.DeliveryReceipt(data_epoch: dataEpoch, receipts: [Wire.EventReceipt(code: "connection_unavailable", event_id: id, status: status)], server_id: serverID)
        #expect(try CollectorJournal.accept(receipt, batch: batch, into: &next) == false)
        #expect(next.pending == original)
    }
    let wrong = Wire.DeliveryReceipt(data_epoch: dataEpoch, receipts: [Wire.EventReceipt(code: "accepted", event_id: UUID().uuidString, status: "accepted")], server_id: serverID)
    #expect(throws: ClientError.invalidResponse) { try CollectorJournal.accept(wrong, batch: batch, into: &next) }
    #expect(next.pending == original)
    let accepted = Wire.DeliveryReceipt(data_epoch: dataEpoch, receipts: [Wire.EventReceipt(code: "accepted", event_id: id, status: "accepted")], server_id: serverID)
    #expect(try CollectorJournal.accept(accepted, batch: batch, into: &next))
    #expect(next.pending.isEmpty)
}

@Test func collectorCannotRelabelOldEpochOrCapability() throws {
    let current = state()
    try CollectorJournal.validate(scope: scope(), state: current, dataEpoch: dataEpoch, collectorID: clientID)
    #expect(throws: ClientError.expiredGeneration) { try CollectorJournal.validate(scope: scope(epoch: UUID().uuidString), state: current, dataEpoch: dataEpoch, collectorID: clientID) }
    #expect(throws: ClientError.expiredGeneration) { try CollectorJournal.validate(scope: scope(), state: current, dataEpoch: UUID().uuidString, collectorID: clientID) }
    #expect(throws: ClientError.unsupportedProtocol) { try CollectorJournal.validate(scope: scope(version: 2), state: current, dataEpoch: dataEpoch, collectorID: clientID) }
    #expect(throws: ClientError.conflict) { try CollectorJournal.validate(scope: scope(), state: current, dataEpoch: dataEpoch, collectorID: UUID().uuidString) }
}

@Test func lostConnectionCreationUsesTheOriginalReceipt() async throws {
    let requestID = "1793894400000-55555555-5555-4555-8555-555555555555"
    let result: [String: Any] = ["connection_id": connectionID, "display_name": "Phone", "plugin_id": "apple-health", "readiness": [], "revision": 1]
    let receipt = HTTPResponse(status: 200, data: try jsonData(["operation_id": requestID, "state": "completed", "http_status": 201, "result": result]))
    let transport = MockTransport([.response(HTTPResponse(status: 404, data: Data())), .disconnected, .response(receipt)])
    let client = MagiClient(credential: try credential(), transport: transport)
    let body: JSONValue = .object(["display_name": .string("Phone")])
    await #expect(throws: URLError.self) { try await client.createPluginConnection(pluginID: "apple-health", body: body, requestID: requestID, dataEpoch: dataEpoch) }
    let connection = try await client.createPluginConnection(pluginID: "apple-health", body: body, requestID: requestID, dataEpoch: dataEpoch)
    #expect(connection.connection_id == connectionID)
    let posts = await transport.calls.filter { $0.url?.path == "/api/plugins/apple-health/connections" }
    #expect(posts.count == 1)
    #expect(posts.first?.value(forHTTPHeaderField: "X-Magi-Request-Id") == requestID)
    #expect(posts.first?.value(forHTTPHeaderField: "X-Magi-Data-Epoch") == dataEpoch)
}

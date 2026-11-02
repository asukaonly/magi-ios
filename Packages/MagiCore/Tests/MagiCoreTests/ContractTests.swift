import Foundation
import Testing
@testable import MagiCore

let serverID = "11111111-1111-4111-8111-111111111111"
let clientID = "22222222-2222-4222-8222-222222222222"
let dataEpoch = "33333333-3333-4333-8333-333333333333"

func jsonData(_ object: Any) throws -> Data { try JSONSerialization.data(withJSONObject: object) }
func credential() throws -> ConnectionCredential {
    ConnectionCredential(address: try ServerAddress("https://example.invalid"), serverID: serverID, clientID: clientID, credential: "secret")
}
func accessResponse() throws -> HTTPResponse {
    HTTPResponse(status: 200, data: try jsonData(["success": true, "data": [
        "server_id": serverID, "client_id": clientID, "access_token": "access", "expires_at_ms": 9_000_000_000_000,
    ]]))
}
func infoResponse(epoch: String = dataEpoch, version: Int = 3) throws -> HTTPResponse {
    HTTPResponse(status: 200, data: try jsonData(["success": true, "data": [
        "server_id": serverID, "protocol_version": version, "service_ready": true, "plugin_execution": "server",
        "events": ["epoch": dataEpoch, "sequence": 1], "supervisor": [:],
        "client_contract": ["version": 1, "product_events": "/api/events?scope=product", "diagnostic_events": "/api/events?scope=diagnostics", "schema": "/api/openapi.json"],
        "maintenance": ["version": 2, "data_epoch": epoch, "content_epoch": epoch, "phase": "idle", "kind": NSNull(), "operation_id": NSNull(), "result": NSNull(), "error": NSNull()],
    ]]))
}

actor MockTransport: HTTPTransport {
    enum Reply: Sendable { case response(HTTPResponse), disconnected }
    var replies: [Reply]
    var calls: [URLRequest] = []
    init(_ replies: [Reply]) { self.replies = replies }
    func send(_ request: URLRequest) async throws -> HTTPResponse {
        calls.append(request)
        if request.url?.path == "/api/auth/session" { return try accessResponse() }
        guard !replies.isEmpty else { throw ClientError.invalidResponse }
        switch replies.removeFirst() { case .response(let value): return value; case .disconnected: throw URLError(.networkConnectionLost) }
    }
    func events(_ request: URLRequest) async throws -> EventConnection { throw ClientError.offline }
}

@Test func addressConfinesCredentialsToOneOrigin() throws {
    for raw in ["http://example.com", "https://a.example/path", "https://name:secret@a.example", "https://a.example?token=x", "file:///tmp/a"] {
        #expect(throws: ClientError.self) { try ServerAddress(raw) }
    }
    let address = try ServerAddress("https://example.com/api/")
    #expect(address.baseURL.absoluteString == "https://example.com/api")
    #expect(throws: ClientError.self) { try address.url(path: "//evil.example/a") }
    #expect(try ServerAddress("http://localhost:8080").baseURL.host == "127.0.0.1")
    #expect(ServerAddress.segment("a/b?x") == "a%2Fb%3Fx")
}

@Test func schemaRejectsOldAndMalformedProductEvents() throws {
    var decoder = EventStream()
    let payload: [String: Any] = ["contract_version": 1, "server_id": serverID, "epoch": dataEpoch, "sequence": 1,
        "event_id": "\(dataEpoch):1", "event_type": "state.changed", "data": ["resource": "messages"]]
    _ = try decoder.consume(line: "data: " + String(decoding: jsonData(payload), as: UTF8.self), serverID: serverID)
    #expect(try decoder.consume(line: "", serverID: serverID)?.kind == "state.changed")
    _ = try decoder.consume(line: "data: " + String(decoding: jsonData(payload), as: UTF8.self), serverID: serverID)
    #expect(try decoder.consume(line: "", serverID: serverID) == nil)
    var old = payload; old["event_type"] = "runtime.notification"
    _ = try decoder.consume(line: "data: " + String(decoding: jsonData(old), as: UTF8.self), serverID: serverID)
    #expect(throws: ClientError.self) { try decoder.consume(line: "", serverID: serverID) }
    var malformed = payload; malformed["contract_version"] = 2
    #expect(throws: ClientError.self) { try Contract.current.validate(JSONDecoder().decode(JSONValue.self, from: jsonData(malformed)), named: "ProductEvent") }
    var invalidType = try JSONDecoder().decode(JSONValue.self, from: infoResponse().data)["data"]["maintenance"].object!
    invalidType["kind"] = .integer(5)
    #expect(throws: ClientError.self) { try Contract.current.validate(.object(invalidType), named: "GatewayMaintenanceStatus") }
}

@Test func explicitModelSetupFailureKeepsTheJournal() async throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let journal = LocalState(root: root, credential: try credential())
    let pending = OutgoingTurn(request: Wire.UserMessageRequest(client_turn_id: "t", message: "Hello", session_id: "s"), dataEpoch: dataEpoch)
    let rejected = HTTPResponse(status: 200, data: try jsonData(["success": false, "message": "Not ready", "data": ["error_code": "RUNTIME_NOT_READY"]]))
    let absent = HTTPResponse(status: 200, data: try jsonData(["session_id": "s", "identity": "t", "status": "absent", "safe_to_retry": true]))
    let transport = MockTransport([.response(try infoResponse()), .response(rejected), .response(absent)])
    let client = MagiClient(credential: try credential(), transport: transport)
    await #expect(throws: ClientError.runtimeNotReady) { try await TurnDelivery.deliver(pending, client: client, journal: journal) }
    #expect(try await journal.read().outgoing.first?.attempted == true)
    #expect(try await journal.read().outgoing.first?.confirmed == false)
}

@Test func serviceVersionMustMatchExactly() async throws {
    let transport = MockTransport([.response(try infoResponse(version: 2))])
    let client = MagiClient(credential: try credential(), transport: transport)
    await #expect(throws: ClientError.unsupportedProtocol) { try await client.info() }
}

@Test func unauthorizedMutationIsNeverAutomaticallyReplayed() async throws {
    let transport = MockTransport([.response(HTTPResponse(status: 401, data: Data()))])
    let client = MagiClient(credential: try credential(), transport: transport)
    await #expect(throws: ClientError.unauthorized) { try await client.send(Wire.UserMessageRequest(message: "Hi", session_id: "s")) }
    let calls = await transport.calls
    #expect(calls.filter { $0.url?.path == "/api/messages/send" }.count == 1)
    #expect(calls.allSatisfy { $0.url?.query?.contains("secret") != true })
}

@Test func lostAcknowledgementIsConfirmedWithoutSendingTwice() async throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let journal = LocalState(root: root, credential: try credential())
    let turn = OutgoingTurn(request: Wire.UserMessageRequest(client_turn_id: "t", message: "Hello", session_id: "s"), dataEpoch: dataEpoch)
    try await journal.put(turn)
    let receipt = HTTPResponse(status: 200, data: try jsonData(["identity": "t", "session_id": "s", "status": "confirmed", "safe_to_retry": false]))
    let transport = MockTransport([.response(try infoResponse()), .disconnected, .response(receipt)])
    let client = MagiClient(credential: try credential(), transport: transport)
    #expect(try await TurnDelivery.deliver(turn, client: client, journal: journal) == .confirmed)
    let state = try await LocalState(root: root, credential: credential()).read()
    #expect(state.outgoing.first?.confirmed == true)
    let calls = await transport.calls
    #expect(calls.filter { $0.url?.path == "/api/messages/send" }.count == 1)
    #expect(calls.last?.url?.path == "/api/messages/confirmation")
}

@Test func changedGenerationPreservesPendingWorkWithoutSending() async throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let journal = LocalState(root: root, credential: try credential())
    let turn = OutgoingTurn(request: Wire.UserMessageRequest(client_turn_id: "t", message: "Hello", session_id: "s"), dataEpoch: "old")
    try await journal.put(turn)
    let transport = MockTransport([.response(try infoResponse())])
    let client = MagiClient(credential: try credential(), transport: transport)
    await #expect(throws: ClientError.expiredGeneration) { try await TurnDelivery.deliver(turn, client: client, journal: journal) }
    #expect(try await journal.read().outgoing == [turn])
    #expect(await transport.calls.allSatisfy { $0.url?.path != "/api/messages/send" })
}

@Test func corruptJournalFailsClosed() async throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let journal = LocalState(root: root, credential: try credential())
    _ = try await journal.observeGeneration(dataEpoch)
    let file = try #require(FileManager.default.contentsOfDirectory(at: root, includingPropertiesForKeys: nil).first)
    try Data("corrupt".utf8).write(to: file)
    let reopened = LocalState(root: root, credential: try credential())
    await #expect(throws: (any Error).self) { try await reopened.read() }
    #expect(try String(contentsOf: file, encoding: .utf8) == "corrupt")
}

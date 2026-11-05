import Foundation
import Testing
@testable import MagiCore

@Test(.enabled(if: ProcessInfo.processInfo.environment["MAGI_TEST_SERVICE"] != nil))
func realServiceClient() async throws {
    let env = ProcessInfo.processInfo.environment
    let address = try ServerAddress(#require(env["MAGI_TEST_SERVICE"]))
    let grant = try await MagiClient.pair(address: address, code: #require(env["MAGI_TEST_PAIRING"]), deviceName: "iOS boundary verification")
    let client = MagiClient(credential: grant)
    let info = try await client.info()
    #expect(info.service_ready)
    let key = UUID().uuidString.lowercased()
    let session = try await client.createSession(key: key)
    #expect(try await client.createSession(key: key) == session)
    #expect(try await client.sessions().sessions.contains { $0.session_id == session })
    #expect(try await client.history(sessionID: session).messages.isEmpty)
    let turnID = UUID().uuidString.lowercased()
    #expect(try await client.confirmation(sessionID: session, turnID: turnID).safe_to_retry)
    #expect(try await client.turn(sessionID: session, turnID: turnID).can_resubmit)
    _ = try await client.request(Wire.ItemPage.self, path: "/personal-tasks")
    _ = try await client.request(Wire.ListResponse.self, path: "/notifications")
    _ = try await client.memory(view: "about")
    _ = try await client.memory(view: "events")
    _ = try await client.request(Wire.PluginsListResponse.self, path: "/plugins")
    let imageBytes = try Data(contentsOf: URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("MagiIOS/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png"))
    let image = try await client.upload(sessionID: session, turnID: turnID, filename: "Magi.png", mimeType: "image/png", data: imageBytes)
    let imageID = try #require(image["attachment_id"].string)
    #expect(image["kind"].string == "image")
    // Uploaded bytes remain private until a visible message owns the attachment.
    await #expect(throws: ClientError.http(404)) {
        try await client.image(sessionID: session, attachmentID: imageID)
    }
    let imageOnly = try await client.send(Wire.UserMessageRequest(attachments: [try #require(image.object)], client_turn_id: turnID, message: "", session_id: session))
    #expect(!imageOnly.success)
    #expect(imageOnly.data?["error_code"]?.string == "RUNTIME_NOT_READY")
    #expect(try await client.confirmation(sessionID: session, turnID: turnID).safe_to_retry)
    let stream = try await client.openEvents(after: nil)
    var decoder = EventStream()
    var received = false
    for try await line in stream.lines {
        if let update = try decoder.consume(line: line, serverID: grant.serverID) {
            #expect(update.needsSnapshot); received = true; break
        }
    }
    #expect(received)
    let file = try await client.upload(sessionID: session, turnID: turnID, filename: "boundary.txt", mimeType: "text/plain", data: Data("A native client attachment.".utf8))
    #expect(file["attachment_id"].string != nil)
    let message = Wire.UserMessageRequest(attachments: [try #require(file.object), try #require(image.object)], client_turn_id: turnID, message: "Native client boundary verification.", session_id: session)
    let sent = try await client.send(message)
    // The isolated service intentionally has no provider configuration.
    #expect(!sent.success)
    #expect(sent.data?["error_code"]?.string == "RUNTIME_NOT_READY")
    #expect(try await client.confirmation(sessionID: session, turnID: turnID).safe_to_retry)
    #expect(try await client.history(sessionID: session).messages.isEmpty)
    _ = try await client.request(JSONValue.self, method: "DELETE", path: "/messages/session/\(ServerAddress.segment(session))", template: "/messages/session/{session_id}")
    #expect(try await client.confirmation(sessionID: session, turnID: turnID).status == "concluded")
    if env["MAGI_TEST_HEALTH"] == "1" { try await verifyHealthService(owner: client, credential: grant) }
}

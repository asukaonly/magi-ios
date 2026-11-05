import Foundation

public actor MagiClient {
    public let credential: ConnectionCredential
    private let transport: any HTTPTransport
    private var access: Wire.GatewayAccessSession?
    private var renewing: Task<Wire.GatewayAccessSession, any Error>?

    public init(credential: ConnectionCredential, transport: any HTTPTransport = URLSessionTransport()) {
        self.credential = credential; self.transport = transport
    }

    public static func pair(address: ServerAddress, code: String, deviceName: String,
                            transport: any HTTPTransport = URLSessionTransport()) async throws -> ConnectionCredential {
        let code = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard code.count == 64, code.allSatisfy({ $0.isHexDigit && $0.isASCII }) else { throw ClientError.invalidPairingCode }
        var request = URLRequest(url: try address.url(path: "/auth/pair"))
        request.httpMethod = "POST"
        request.setValue(code, forHTTPHeaderField: "x-magi-session-token")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(Wire.PairRequest(name: deviceName))
        let response = try await transport.send(request)
        try checkStatus(response.status)
        let envelope = try Contract.current.response(Wire.PairResponse.self, data: response.data, path: "/api/auth/pair", method: "POST", status: response.status)
        guard envelope.success, UUID(uuidString: envelope.data.server_id) != nil, UUID(uuidString: envelope.data.client_id) != nil,
              !envelope.data.client_credential.isEmpty else { throw ClientError.invalidResponse }
        return ConnectionCredential(address: address, serverID: envelope.data.server_id,
                                    clientID: envelope.data.client_id, credential: envelope.data.client_credential)
    }

    private func token() async throws -> String {
        if let access, access.expires_at_ms > Int64(Date().timeIntervalSince1970 * 1000) + 30_000 { return access.access_token }
        if let renewing { return try await renewing.value.access_token }
        let credential = self.credential, transport = self.transport
        let task = Task<Wire.GatewayAccessSession, any Error> {
            var request = URLRequest(url: try credential.address.url(path: "/auth/session"))
            request.httpMethod = "POST"
            request.setValue(credential.credential, forHTTPHeaderField: "x-magi-session-token")
            let response = try await transport.send(request)
            try Self.checkStatus(response.status)
            let session = try Contract.current.response(Wire.AccessResponse.self, data: response.data,
                path: "/api/auth/session", method: "POST", status: response.status).data
            guard session.server_id == credential.serverID, session.client_id == credential.clientID,
                  !session.access_token.isEmpty, session.expires_at_ms > Int64(Date().timeIntervalSince1970 * 1000)
            else { throw ClientError.identityChanged }
            return session
        }
        renewing = task
        do {
            let session = try await task.value
            access = session; renewing = nil
            return session.access_token
        } catch { renewing = nil; throw error }
    }

    public func request<T: Decodable & Sendable>(_ type: T.Type, method: String = "GET", path: String,
        template: String? = nil, query: [String: String] = [:], body: JSONValue? = nil, headers: [String: String] = [:]) async throws -> T {
        for attempt in 0...1 {
            var request = URLRequest(url: try credential.address.url(path: path, query: query))
            request.httpMethod = method
            for (name, value) in headers { request.setValue(value, forHTTPHeaderField: name) }
            request.setValue(try await token(), forHTTPHeaderField: "x-magi-session-token")
            request.setValue(Locale.preferredLanguages.first ?? "en", forHTTPHeaderField: "Accept-Language")
            if let body { request.httpBody = try JSONEncoder().encode(body); request.setValue("application/json", forHTTPHeaderField: "Content-Type") }
            let response = try await transport.send(request)
            if response.status == 401 {
                access = nil
                if method == "GET", attempt == 0 { continue }
            }
            try Self.checkStatus(response.status)
            return try Contract.current.response(type, data: response.data, path: "/api" + (template ?? path), method: method, status: response.status)
        }
        throw ClientError.unauthorized
    }

    public func info() async throws -> Wire.ServerInfoResponse_data {
        let info = try await request(Wire.ServerInfoResponse.self, path: "/server/info").data
        guard info.server_id == credential.serverID else { throw ClientError.identityChanged }
        guard info.protocol_version == 3, info.client_contract.version == 1, info.plugin_execution == "server" else { throw ClientError.unsupportedProtocol }
        return info
    }

    public func sessions(before: String? = nil) async throws -> Wire.SessionPageResponse {
        var query = ["limit": "50"]
        if let before { query["before"] = before }
        return try await request(Wire.SessionPageResponse.self, path: "/messages/sessions", query: query)
    }
    public func createSession(key: String) async throws -> String {
        let value = try await request(JSONValue.self, method: "POST", path: "/messages/session/new", query: ["idempotency_key": key])
        guard value["success"].bool == true, let id = value["session_id"].string, !id.isEmpty else { throw ClientError.invalidResponse }
        return id
    }
    public func history(sessionID: String, before: String? = nil) async throws -> Wire.HistoryPageResponse {
        var query = ["session_id": sessionID, "limit": "100"]
        if let before { query["before"] = before }
        let history = try await request(Wire.HistoryPageResponse.self, path: "/messages/history", query: query)
        guard history.session_id == sessionID else { throw ClientError.identityChanged }
        return history
    }
    public func send(_ message: Wire.UserMessageRequest) async throws -> Wire.MessageResponse {
        try await request(Wire.MessageResponse.self, method: "POST", path: "/messages/send", body: JSONValue.encode(message))
    }
    public func confirmation(sessionID: String, turnID: String) async throws -> Wire.SendConfirmation {
        let query = Wire.TurnConfirmationRequest(kind: "turn", session_id: sessionID, turn_id: turnID)
        let receipt = try await request(Wire.SendConfirmation.self, method: "POST", path: "/messages/confirmation", body: JSONValue.encode(query))
        guard receipt.session_id == sessionID, receipt.identity == turnID,
              !(receipt.safe_to_retry && receipt.status != "absent") else { throw ClientError.invalidResponse }
        return receipt
    }
    public func turn(sessionID: String, turnID: String) async throws -> Wire.TurnSnapshot {
        let value = try await request(Wire.TurnSnapshot.self,
            path: "/messages/session/\(ServerAddress.segment(sessionID))/turn/\(ServerAddress.segment(turnID))",
            template: "/messages/session/{session_id}/turn/{turn_id}")
        guard value.session_id == sessionID, value.turn_id == turnID,
              value.can_resubmit == (value.acceptance == "absent"), !(value.response_complete && !value.terminal)
        else { throw ClientError.invalidResponse }
        return value
    }
    public func cancel(sessionID: String, turnID: String?) async throws {
        var body = Wire.CancelSessionRunRequest()
        body.turn_id = turnID
        _ = try await request(JSONValue.self, method: "POST", path: "/messages/session/\(ServerAddress.segment(sessionID))/cancel-run",
            template: "/messages/session/{session_id}/cancel-run", body: JSONValue.encode(body))
    }
    public func openEvents(after: String?) async throws -> EventConnection {
        for attempt in 0...1 {
            var request = URLRequest(url: try credential.address.url(path: "/events", query: ["scope": "product"]))
            request.setValue(try await token(), forHTTPHeaderField: "x-magi-session-token")
            request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
            if let after { request.setValue(after, forHTTPHeaderField: "Last-Event-ID") }
            let response = try await transport.events(request)
            if response.status == 401, attempt == 0 { access = nil; continue }
            try Self.checkStatus(response.status)
            guard response.contentType.hasPrefix("text/event-stream") else { throw ClientError.invalidResponse }
            return response
        }
        throw ClientError.unauthorized
    }
    public func upload(sessionID: String, turnID: String, filename: String, mimeType: String, data: Data) async throws -> JSONValue {
        guard !data.isEmpty, data.count <= 20 * 1024 * 1024 else { throw ClientError.responseTooLarge }
        guard !mimeType.contains("\r"), !mimeType.contains("\n"),
              turnID.allSatisfy({ $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "-" || $0 == "_") })
        else { throw ClientError.invalidContract }
        let boundary = "Magi-\(UUID().uuidString)"
        let safeName = filename.replacingOccurrences(of: "\"", with: "_").replacingOccurrences(of: "\r", with: "_").replacingOccurrences(of: "\n", with: "_")
        var body = Data("--\(boundary)\r\nContent-Disposition: form-data; name=\"turn_id\"\r\n\r\n\(turnID)\r\n--\(boundary)\r\nContent-Disposition: form-data; name=\"file\"; filename=\"\(safeName)\"\r\nContent-Type: \(mimeType)\r\n\r\n".utf8)
        body.append(data); body.append(Data("\r\n--\(boundary)--\r\n".utf8))
        var request = URLRequest(url: try credential.address.url(path: "/messages/session/\(ServerAddress.segment(sessionID))/attachments"))
        request.httpMethod = "POST"; request.httpBody = body
        request.setValue(try await token(), forHTTPHeaderField: "x-magi-session-token")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let response = try await transport.send(request)
        if response.status == 401 { access = nil }
        try Self.checkStatus(response.status)
        let value = try Contract.current.response(JSONValue.self, data: response.data,
            path: "/api/messages/session/{session_id}/attachments", method: "POST", status: response.status)
        guard value["success"].bool == true, value["data"]["session_id"].string == sessionID,
              value["data"]["turn_id"].string == turnID, value["data"]["attachment"]["attachment_id"].string != nil
        else { throw ClientError.invalidResponse }
        return value["data"]["attachment"]
    }
    public func image(sessionID: String, attachmentID: String) async throws -> Data {
        guard !sessionID.isEmpty, !attachmentID.isEmpty else { throw ClientError.invalidContract }
        for attempt in 0...1 {
            var request = URLRequest(url: try credential.address.url(path:
                "/messages/session/\(ServerAddress.segment(sessionID))/attachments/\(ServerAddress.segment(attachmentID))/content"))
            request.setValue(try await token(), forHTTPHeaderField: "x-magi-session-token")
            request.setValue("image/*", forHTTPHeaderField: "Accept")
            let response = try await transport.send(request)
            if response.status == 401 { access = nil; if attempt == 0 { continue } }
            try Self.checkStatus(response.status)
            guard response.status == 200, response.contentType.lowercased().hasPrefix("image/"), !response.data.isEmpty else {
                throw ClientError.invalidResponse
            }
            guard response.data.count <= 20 * 1024 * 1024 else { throw ClientError.responseTooLarge }
            return response.data
        }
        throw ClientError.unauthorized
    }

    private static func checkStatus(_ status: Int) throws {
        if status == 401 || status == 403 { throw ClientError.unauthorized }
        if status == 409 { throw ClientError.conflict }
        if status == 503 { throw ClientError.serviceUnavailable }
        guard (200..<300).contains(status) else { throw ClientError.http(status) }
    }
}

extension MagiClient {
    public func memory(view: String, query: String = "", offset: Int = 0) async throws -> Wire.MemoryLibraryPage {
        try await request(Wire.MemoryLibraryPage.self, path: "/memory/library",
                          query: ["view": view, "query": query, "offset": String(offset), "limit": "40"])
    }
    public func memoryEvidence(id: String) async throws -> Wire.MemoryLibraryItem {
        try await request(Wire.MemoryLibraryItem.self, path: "/memory/library/evidence/\(ServerAddress.segment(id))",
                          template: "/memory/library/evidence/{event_id}")
    }
    public func correctMemory(_ item: Wire.MemoryLibraryItem, value: String?, requestID: String) async throws {
        guard let assertion = item.assertion_id else { throw ClientError.invalidContract }
        var body: [String: JSONValue] = ["request_id": .string(requestID), "target": .object(["kind": .string("assertion"), "id": .string(assertion)]),
                                         "correction_kind": .string("record_error")]
        if let value { body["replacement"] = .object(["value": .string(value)]) }
        if let updated = item.updated_at { body["expected_updated_at"] = .number(updated) }
        _ = try await request(JSONValue.self, method: "POST", path: "/memory/l2/corrections", body: .object(body))
    }
    public func forgetMemory(_ item: Wire.MemoryLibraryItem) async throws {
        guard item.kind == "event", item.can_delete == true else { throw ClientError.invalidContract }
        _ = try await request(JSONValue.self, method: "DELETE", path: "/memory/l1/events/\(ServerAddress.segment(item.id))",
                              template: "/memory/l1/events/{event_id}")
    }
}

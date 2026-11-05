import Foundation

public struct HTTPResponse: Sendable {
    public var status: Int
    public var data: Data
    public var contentType: String
    public init(status: Int, data: Data, contentType: String = "application/json") {
        self.status = status; self.data = data; self.contentType = contentType
    }
}

public struct EventConnection: Sendable {
    public var status: Int
    public var contentType: String
    public var lines: AsyncThrowingStream<String, any Error>
    public init(status: Int, contentType: String, lines: AsyncThrowingStream<String, any Error>) {
        self.status = status; self.contentType = contentType; self.lines = lines
    }
}

public protocol HTTPTransport: Sendable {
    func send(_ request: URLRequest) async throws -> HTTPResponse
    func events(_ request: URLRequest) async throws -> EventConnection
}

private final class RedirectPolicy: NSObject, URLSessionTaskDelegate, Sendable {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest, completionHandler: @escaping @Sendable (URLRequest?) -> Void) {
        completionHandler(nil)
    }
}

public final class URLSessionTransport: HTTPTransport, Sendable {
    private let session: URLSession
    public init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.urlCache = nil
        configuration.httpCookieStorage = nil
        configuration.httpShouldSetCookies = false
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.timeoutIntervalForRequest = 40
        configuration.timeoutIntervalForResource = 60 * 60
        session = URLSession(configuration: configuration, delegate: RedirectPolicy(), delegateQueue: nil)
    }

    public func send(_ request: URLRequest) async throws -> HTTPResponse {
        let (bytes, response) = try await session.bytes(for: request)
        guard let http = response as? HTTPURLResponse else { throw ClientError.invalidResponse }
        var data = Data()
        do {
            for try await byte in bytes {
                guard data.count < 20 * 1024 * 1024 else { throw ClientError.responseTooLarge }
                data.append(byte)
            }
        } catch { bytes.task.cancel(); throw error }
        return HTTPResponse(status: http.statusCode, data: data, contentType: http.value(forHTTPHeaderField: "Content-Type") ?? "")
    }

    public func events(_ request: URLRequest) async throws -> EventConnection {
        let (bytes, response) = try await session.bytes(for: request)
        guard let http = response as? HTTPURLResponse else { bytes.task.cancel(); throw ClientError.invalidResponse }
        let lines = AsyncThrowingStream<String, any Error> { continuation in
            let task = Task {
                do {
                    var buffer = Data()
                    for try await byte in bytes {
                        try Task.checkCancellation()
                        if byte == 10 {
                            if buffer.last == 13 { buffer.removeLast() }
                            guard let line = String(data: buffer, encoding: .utf8) else { throw ClientError.invalidResponse }
                            continuation.yield(line)
                            buffer.removeAll(keepingCapacity: true)
                        } else {
                            guard buffer.count < 128 * 1024 else { throw ClientError.responseTooLarge }
                            buffer.append(byte)
                        }
                    }
                    continuation.finish()
                } catch { continuation.finish(throwing: error) }
                bytes.task.cancel()
            }
            continuation.onTermination = { _ in task.cancel(); bytes.task.cancel() }
        }
        return EventConnection(status: http.statusCode, contentType: http.value(forHTTPHeaderField: "Content-Type") ?? "", lines: lines)
    }
}

public struct ServerAddress: Codable, Sendable, Equatable {
    public let baseURL: URL
    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(values.decode(URL.self, forKey: .baseURL).absoluteString)
    }
    private enum CodingKeys: String, CodingKey { case baseURL }
    public init(_ raw: String) throws {
        guard var parts = URLComponents(string: raw.trimmingCharacters(in: .whitespacesAndNewlines)),
              let host = parts.host, !host.isEmpty, parts.user == nil, parts.password == nil,
              parts.query == nil, parts.fragment == nil, ["", "/", "/api", "/api/"].contains(parts.path),
              parts.scheme == "https" || (parts.scheme == "http" && ["localhost", "127.0.0.1", "::1"].contains(host))
        else { throw ClientError.invalidAddress }
        if parts.scheme == "http", host == "localhost" { parts.host = "127.0.0.1" }
        parts.path = "/api"
        guard let url = parts.url else { throw ClientError.invalidAddress }
        baseURL = url
    }

    public func url(path: String, query: [String: String] = [:]) throws -> URL {
        guard path.hasPrefix("/"), !path.hasPrefix("//"), !path.contains("?"), !path.contains("#"),
              !path.split(separator: "/").contains(".."), var parts = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        else { throw ClientError.invalidAddress }
        parts.percentEncodedPath = "/api" + path
        parts.queryItems = query.isEmpty ? nil : query.sorted(by: { $0.key < $1.key }).map { URLQueryItem(name: $0.key, value: $0.value) }
        guard let url = parts.url else { throw ClientError.invalidAddress }
        return url
    }
    public static func segment(_ value: String) -> String {
        value.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_-"))) ?? ""
    }
}

public struct ConnectionCredential: Codable, Sendable, Equatable {
    public var address: ServerAddress
    public var serverID: String
    public var clientID: String
    public var credential: String
    public init(address: ServerAddress, serverID: String, clientID: String, credential: String) {
        self.address = address; self.serverID = serverID; self.clientID = clientID; self.credential = credential
    }
}

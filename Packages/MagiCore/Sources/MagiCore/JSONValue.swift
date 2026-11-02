import Foundation

public indirect enum JSONValue: Codable, Sendable, Equatable {
    case object([String: JSONValue]), array([JSONValue]), string(String), integer(Int64), number(Double), bool(Bool), null

    public init(from decoder: any Decoder) throws {
        let box = try decoder.singleValueContainer()
        if box.decodeNil() { self = .null }
        else if let value = try? box.decode(Bool.self) { self = .bool(value) }
        else if let value = try? box.decode(Int64.self) { self = .integer(value) }
        else if let value = try? box.decode(Double.self) { self = .number(value) }
        else if let value = try? box.decode(String.self) { self = .string(value) }
        else if let value = try? box.decode([String: JSONValue].self) { self = .object(value) }
        else { self = .array(try box.decode([JSONValue].self)) }
    }

    public func encode(to encoder: any Encoder) throws {
        var box = encoder.singleValueContainer()
        switch self {
        case .object(let value): try box.encode(value)
        case .array(let value): try box.encode(value)
        case .string(let value): try box.encode(value)
        case .integer(let value): try box.encode(value)
        case .number(let value): try box.encode(value)
        case .bool(let value): try box.encode(value)
        case .null: try box.encodeNil()
        }
    }

    public subscript(_ key: String) -> JSONValue { object?[key] ?? .null }
    public var object: [String: JSONValue]? { if case .object(let value) = self { value } else { nil } }
    public var array: [JSONValue]? { if case .array(let value) = self { value } else { nil } }
    public var string: String? { if case .string(let value) = self { value } else { nil } }
    public var bool: Bool? { if case .bool(let value) = self { value } else { nil } }
    public var integer: Int64? { if case .integer(let value) = self { value } else { nil } }
    public var number: Double? {
        switch self { case .integer(let value): Double(value); case .number(let value): value; default: nil }
    }
    public static func encode<T: Encodable>(_ value: T) throws -> JSONValue {
        try JSONDecoder().decode(JSONValue.self, from: JSONEncoder().encode(value))
    }
    public func decode<T: Decodable>(_ type: T.Type) throws -> T {
        try JSONDecoder().decode(type, from: JSONEncoder().encode(self))
    }
}

public enum ClientError: Error, LocalizedError, Sendable, Equatable {
    case invalidAddress, invalidPairingCode, invalidContract, unsupportedProtocol, identityChanged
    case unauthorized, serviceUnavailable, invalidResponse, responseTooLarge, expiredGeneration
    case http(Int), offline, storage, conflict, runtimeNotReady

    public var errorDescription: String? {
        switch self {
        case .invalidAddress: "Use an HTTPS server address without a path or credentials."
        case .invalidPairingCode: "Enter a valid pairing code."
        case .invalidContract: "The server response does not match the current contract."
        case .unsupportedProtocol: "The server protocol is unsupported."
        case .identityChanged: "The server identity changed."
        case .unauthorized: "Pair this device again."
        case .serviceUnavailable: "The service is not ready."
        case .runtimeNotReady: "Configure the service's model before sending messages."
        case .invalidResponse: "The server returned an invalid response."
        case .responseTooLarge: "The response exceeds the size limit."
        case .expiredGeneration: "The service data changed. This pending message cannot be resent."
        case .http(let status): "The server rejected the request (\(status))."
        case .offline: "The server is unreachable."
        case .storage: "Local data could not be saved."
        case .conflict: "The item changed. Refresh before trying again."
        }
    }
}

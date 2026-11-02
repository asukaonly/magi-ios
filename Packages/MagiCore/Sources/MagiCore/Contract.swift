import Foundation

/// Validates the authoritative schema before decoding a generated projection.
public struct Contract: Sendable {
    public static let current = Contract()
    private let document: JSONValue

    private init() {
        guard let url = Bundle.module.url(forResource: "product-api", withExtension: "json"),
              let data = try? Data(contentsOf: url), let value = try? JSONDecoder().decode(JSONValue.self, from: data)
        else { preconditionFailure("Missing bundled product contract") }
        document = value
    }

    public func decode<T: Decodable>(_ type: T.Type, data: Data, schema: String) throws -> T {
        let value = try JSONDecoder().decode(JSONValue.self, from: data)
        try validate(value, named: schema)
        return try JSONDecoder().decode(type, from: data)
    }

    public func validate(_ value: JSONValue, named: String) throws {
        guard let schema = document["components"]["schemas"].object?[named] else { throw ClientError.invalidContract }
        try validate(value, against: schema)
    }

    public func response<T: Decodable>(_ type: T.Type, data: Data, path: String, method: String, status: Int) throws -> T {
        let operation = document["paths"][path][method.lowercased()]
        let schema = operation["responses"][String(status)]["content"]["application/json"]["schema"]
        guard schema != .null else { throw ClientError.invalidContract }
        let value = try JSONDecoder().decode(JSONValue.self, from: data)
        try validate(value, against: schema)
        return try JSONDecoder().decode(type, from: data)
    }

    private func validate(_ value: JSONValue, against schema: JSONValue, depth: Int = 0) throws {
        guard depth < 100 else { throw ClientError.invalidContract }
        func failUnless(_ condition: Bool) throws { if !condition { throw ClientError.invalidContract } }
        if schema == .bool(false) { throw ClientError.invalidContract }
        if let ref = schema["$ref"].string {
            let prefix = "#/components/schemas/"
            guard ref.hasPrefix(prefix), let target = document["components"]["schemas"].object?[String(ref.dropFirst(prefix.count))]
            else { throw ClientError.invalidContract }
            try validate(value, against: target, depth: depth + 1)
        }
        for keyword in ["anyOf", "oneOf"] {
            if let variants = schema[keyword].array {
                let matches = variants.filter { (try? validate(value, against: $0, depth: depth + 1)) != nil }.count
                try failUnless(keyword == "oneOf" ? matches == 1 : matches > 0)
            }
        }
        for part in schema["allOf"].array ?? [] { try validate(value, against: part, depth: depth + 1) }
        if let constant = schema.object?["const"] { try failUnless(value == constant) }
        if let options = schema["enum"].array { try failUnless(options.contains(value)) }
        func matchesType(_ kind: String) throws -> Bool {
            switch kind {
            case "null": return value == .null
            case "string": return value.string != nil
            case "integer": return value.integer != nil
            case "number": return value.number != nil
            case "boolean": return value.bool != nil
            case "object": return value.object != nil
            case "array": return value.array != nil
            default: throw ClientError.invalidContract
            }
        }
        if let kind = schema["type"].string { try failUnless(matchesType(kind)) }
        if let kinds = schema["type"].array {
            let matching = try kinds.map { try matchesType($0.string ?? "") }
            try failUnless(matching.contains(true))
        }
        if let object = value.object {
            for field in schema["required"].array ?? [] { try failUnless(object[field.string ?? ""] != nil) }
            let properties = schema["properties"].object ?? [:]
            for (key, item) in object {
                if let rule = properties[key] { try validate(item, against: rule, depth: depth + 1) }
                else if schema["additionalProperties"] == .bool(false) { throw ClientError.invalidContract }
                else if let rule = schema["additionalProperties"].object { try validate(item, against: .object(rule), depth: depth + 1) }
            }
        }
        if let array = value.array {
            if let minimum = schema["minItems"].integer { try failUnless(array.count >= minimum) }
            if let maximum = schema["maxItems"].integer { try failUnless(array.count <= maximum) }
            if let rule = schema.object?["items"] { for item in array { try validate(item, against: rule, depth: depth + 1) } }
        }
        if let string = value.string {
            if let minimum = schema["minLength"].integer { try failUnless(string.unicodeScalars.count >= minimum) }
            if let maximum = schema["maxLength"].integer { try failUnless(string.unicodeScalars.count <= maximum) }
            if let pattern = schema["pattern"].string {
                let expression = try NSRegularExpression(pattern: pattern)
                try failUnless(expression.firstMatch(in: string, range: NSRange(string.startIndex..., in: string)) != nil)
            }
            if schema["format"].string == "uuid" { try failUnless(UUID(uuidString: string) != nil) }
        }
        if let number = value.number {
            try failUnless(number.isFinite)
            if let min = schema["minimum"].number { try failUnless(number >= min) }
            if let max = schema["maximum"].number { try failUnless(number <= max) }
            if let min = schema["exclusiveMinimum"].number { try failUnless(number > min) }
            if let max = schema["exclusiveMaximum"].number { try failUnless(number < max) }
        }
    }
}

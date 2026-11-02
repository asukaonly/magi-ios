import Foundation

public struct ProductUpdate: Sendable, Equatable {
    public var kind: String
    public var data: JSONValue
    public var needsSnapshot: Bool
}

public struct EventStream: Sendable {
    public private(set) var lastID: String?
    private var epoch: String?
    private var sequence: Int64?
    private var lines: [String] = []
    private var frameBytes = 0
    public init() {}

    public mutating func consume(line: String, serverID: String) throws -> ProductUpdate? {
        if !line.isEmpty {
            frameBytes += line.utf8.count + 1
            guard frameBytes <= 128 * 1024 else { throw ClientError.responseTooLarge }
            if line.hasPrefix("data:") { lines.append(String(line.dropFirst(5)).trimmingCharacters(in: .whitespaces)) }
            return nil
        }
        defer { lines.removeAll(keepingCapacity: true); frameBytes = 0 }
        guard !lines.isEmpty else { return nil }
        let value = try JSONDecoder().decode(JSONValue.self, from: Data(lines.joined(separator: "\n").utf8))
        try Contract.current.validate(value, named: "ProductEvent")
        guard value["server_id"].string == serverID, let nextEpoch = value["epoch"].string,
              let nextSequence = value["sequence"].integer, let id = value["event_id"].string,
              let kind = value["event_type"].string, id == "\(nextEpoch):\(nextSequence)"
        else { throw ClientError.identityChanged }
        let changed = epoch != nil && epoch != nextEpoch
        if !changed, let sequence, nextSequence <= sequence, kind != "resync_required" { return nil }
        let gap = !changed && sequence.map { nextSequence > $0 + 1 } == true
        epoch = nextEpoch; sequence = nextSequence; lastID = id
        return ProductUpdate(kind: kind, data: value["data"], needsSnapshot: changed || gap || kind == "resync_required")
    }
}

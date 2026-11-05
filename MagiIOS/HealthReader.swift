import Foundation
import HealthKit
import CryptoKit
import MagiCore

struct HealthPreview: Sendable {
    var changes: [Wire.ObservationChange]
    var checkpoint: HealthCheckpoint
    var counts: [String: Int]
}

private struct HealthPage: Sendable {
    let samples: [HKSample]
    let deleted: [String]
    let anchor: Data
}

actor HealthReader {
    private let store = HKHealthStore()
    static var available: Bool { HKHealthStore.isHealthDataAvailable() }
    private func type(_ name: String) throws -> HKSampleType {
        switch name {
        case "steps": HKQuantityType(.stepCount)
        case "sleep": HKCategoryType(.sleepAnalysis)
        case "workout": HKObjectType.workoutType()
        default: throw ClientError.invalidContract
        }
    }
    func authorize(types: [String]) async throws {
        guard Self.available else { throw ClientError.serviceUnavailable }
        try await store.requestAuthorization(toShare: [], read: Set(try types.map { try type($0) }))
    }
    private func page(type: HKSampleType, start: Date, anchor: Data?) async throws -> HealthPage {
        let previous = try anchor.map { try NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: $0) } ?? nil
        let predicate = HKQuery.predicateForSamples(withStart: start, end: nil, options: .strictStartDate)
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKAnchoredObjectQuery(type: type, predicate: predicate, anchor: previous, limit: 500) { _, samples, deleted, next, error in
                if let error { continuation.resume(throwing: error); return }
                do {
                    guard let next else { throw ClientError.invalidResponse }
                    continuation.resume(returning: HealthPage(samples: samples ?? [], deleted: (deleted ?? []).map { $0.uuid.uuidString.lowercased() },
                        anchor: try NSKeyedArchiver.archivedData(withRootObject: next, requiringSecureCoding: true)))
                } catch { continuation.resume(throwing: error) }
            }
            store.execute(query)
        }
    }
    private func steps(start: Date, timezone: String) async throws -> [[String: JSONValue]] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: timezone) ?? .current
        let anchor = calendar.startOfDay(for: start), now = Date()
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsCollectionQuery(quantityType: HKQuantityType(.stepCount), quantitySamplePredicate:
                HKQuery.predicateForSamples(withStart: anchor, end: now), options: .cumulativeSum, anchorDate: anchor, intervalComponents: DateComponents(day: 1))
            query.initialResultsHandler = { _, result, error in
                if let error { continuation.resume(throwing: error); return }
                guard let result else { continuation.resume(throwing: ClientError.invalidResponse); return }
                var records: [[String: JSONValue]] = []
                result.enumerateStatistics(from: anchor, to: now) { statistic, _ in
                    guard let quantity = statistic.sumQuantity() else { return }
                    let identifier = "steps:\(Int64(statistic.startDate.timeIntervalSince1970)):\(timezone)"
                    records.append([
                        "record_id": .string(identifier), "record_type": .string("steps"),
                        "start": .number(statistic.startDate.timeIntervalSince1970), "end": .number(statistic.endDate.timeIntervalSince1970),
                        "timezone": .string(timezone), "value": .number(quantity.doubleValue(for: .count()).rounded()),
                        "unit": .string("count"), "source": .string("Apple Health"), "category": .string(""),
                    ])
                }
                continuation.resume(returning: records)
            }
            store.execute(query)
        }
    }
    func preview(state: CollectorState) async throws -> HealthPreview {
        guard let start = state.start, !state.types.isEmpty else { throw ClientError.invalidContract }
        var checkpoint = state.checkpoint, changes: [Wire.ObservationChange] = [], counts: [String: Int] = [:]
        var deletedStepDays = Set<Double>()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: state.timezone) ?? .current
        func append(_ payload: [String: JSONValue], kind: String) throws {
            guard let id = payload["record_id"]?.string else { throw ClientError.invalidResponse }
            let encoder = JSONEncoder(); encoder.outputFormatting = [.sortedKeys]
            let digest = SHA256.hash(data: try encoder.encode(payload)).map { String(format: "%02x", $0) }.joined()
            guard checkpoint.fingerprints[id] != digest else { return }
            checkpoint.fingerprints[id] = digest
            changes.append(Wire.ObservationChange(object_id: id, occurred_at: payload["start"]?.number, operation: "upsert", payload: payload, version: digest))
            counts[kind, default: 0] += 1
        }
        for kind in state.types {
            var pages = 0
            while true {
                try Task.checkCancellation()
                let result = try await page(type: type(kind), start: start, anchor: checkpoint.anchors[kind])
                if !result.samples.isEmpty || !result.deleted.isEmpty { checkpoint.anchors[kind] = result.anchor }
                for sample in result.samples {
                    let id = sample.uuid.uuidString.lowercased()
                    if kind == "steps" { checkpoint.stepDates[id] = calendar.startOfDay(for: sample.startDate).timeIntervalSince1970; continue }
                    var payload: [String: JSONValue] = [
                        "record_id": .string("\(kind):\(id)"), "record_type": .string(kind),
                        "start": .number(sample.startDate.timeIntervalSince1970), "end": .number(sample.endDate.timeIntervalSince1970),
                        "timezone": .string(state.timezone), "unit": .string("seconds"),
                        "source": .string(sample.sourceRevision.source.name),
                    ]
                    guard sample.endDate > sample.startDate else { continue }
                    if let sleep = sample as? HKCategorySample {
                        let labels = [0: "in_bed", 1: "asleep", 2: "awake", 3: "core", 4: "deep", 5: "rem"]
                        payload["value"] = .number(sample.endDate.timeIntervalSince(sample.startDate))
                        payload["category"] = .string(labels[sleep.value] ?? "unknown")
                    } else if let workout = sample as? HKWorkout {
                        payload["value"] = .number(workout.duration)
                        payload["category"] = .string(Self.workoutName(workout.workoutActivityType))
                    }
                    try append(payload, kind: kind)
                }
                for id in result.deleted {
                    if kind == "steps" {
                        if let day = checkpoint.stepDates.removeValue(forKey: id) { deletedStepDays.insert(day) }
                    } else {
                        let object = "\(kind):\(id)"
                        guard checkpoint.fingerprints.removeValue(forKey: object) != nil else { continue }
                        changes.append(Wire.ObservationChange(object_id: object, operation: "delete", version: UUID().uuidString.lowercased()))
                        counts["deleted", default: 0] += 1
                    }
                }
                pages += 1
                if result.samples.count + result.deleted.count < 500 { break }
                if kind == "steps", pages >= 400 { throw ClientError.responseTooLarge }
                if kind != "steps", pages >= 20 { break }
            }
        }
        if state.types.contains("steps") {
            let records = try await steps(start: start, timezone: state.timezone)
            let presentDays = Set(records.compactMap { $0["start"]?.number })
            for record in records { try append(record, kind: "steps") }
            // Only explicit HealthKit deletion evidence can remove a daily aggregate.
            // Empty reads alone also mean denied access and must never imply deletion.
            for day in deletedStepDays.subtracting(presentDays) {
                let id = "steps:\(Int64(day)):\(state.timezone)"
                guard checkpoint.fingerprints.removeValue(forKey: id) != nil else { continue }
                changes.append(Wire.ObservationChange(object_id: id, operation: "delete", version: UUID().uuidString.lowercased()))
                counts["deleted", default: 0] += 1
            }
        }
        guard changes.count <= 10000 else { throw ClientError.responseTooLarge }
        return HealthPreview(changes: changes, checkpoint: checkpoint, counts: counts)
    }
    private static func workoutName(_ type: HKWorkoutActivityType) -> String {
        switch type {
        case .walking: "walking"
        case .running: "running"
        case .cycling: "cycling"
        case .swimming: "swimming"
        case .yoga: "yoga"
        case .hiking: "hiking"
        case .traditionalStrengthTraining: "strength_training"
        default: "activity_\(type.rawValue)"
        }
    }
}

import Foundation
import Observation
import UIKit
import UniformTypeIdentifiers
import MagiCore

struct DraftAttachment: Identifiable, Sendable {
    let id = UUID()
    let filename: String
    let mimeType: String
    let data: Data
}

struct Interaction: Identifiable {
    let id: String
    let kind: String
    let title: String
    let detail: String
    let options: [String]
    let allowsText: Bool
}

@MainActor @Observable final class AppStore {
    enum Phase { case disconnected, connecting, online, offline, unauthorized }
    var phase: Phase = .disconnected
    var address = ""
    var sessions: [Wire.ChatSessionSummary] = []
    var sessionBefore: String?
    var selectedSessionID: String?
    var messages: [Wire.ChatDisplayMessage] = []
    var historyBefore: String?
    var outgoing: [OutgoingTurn] = []
    var tasks: [Wire.PersonalItem] = []
    var taskCounts: [String: Int64] = [:]
    var notifications: [Wire.NotificationItemModel] = []
    var unreadCount = 0
    var interactions: [Interaction] = []
    var turn: Wire.TurnSnapshot?
    var previewText = ""
    var draft = ""
    var attachments: [DraftAttachment] = []
    var errorKey: String?
    var isSending = false
    var isCreating = false
    var isRefreshing = false
    var isLoadingHistory = false
    var showConnection = false
    var taskView = "next"
    var dataEpoch: String?
    var localEpochChanged = false
    var hasConnection: Bool { client != nil }
    var selectedTitle: String { sessions.first { $0.session_id == selectedSessionID }?.title ?? "" }
    var canSend: Bool { phase == .online && !isSending && selectedSessionID != nil && interactions.isEmpty && (!draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !attachments.isEmpty) }
    private var client: MagiClient?
    private var journal: LocalState?
    private var generation = UUID()
    private var eventsTask: Task<Void, Never>?
    private var pollingTask: Task<Void, Never>?
    private var refreshTask: Task<Void, Never>?
    private var eventStream = EventStream()
    private var foreground = true
    private var initialized = false
    private var createKey: String?
    private var drafts: [String: (String, [DraftAttachment])] = [:]
    private var activePreviewTurn: String?
    private let credentialStore = CredentialStore()

    func bootstrap() async {
        guard !initialized else { return }; initialized = true
        do {
            if let credential = try credentialStore.load() {
                try await install(credential)
                await activate()
            }
        } catch { report(error) }
    }
    private func install(_ credential: ConnectionCredential) async throws {
        generation = UUID(); stopStreams(); eventStream = EventStream()
        isRefreshing = false; isSending = false; isCreating = false
        selectedSessionID = nil; messages = []; turn = nil; interactions = []
        drafts = [:]; draft = ""; attachments = []
        client = MagiClient(credential: credential)
        address = credential.address.baseURL.absoluteString
        let root = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("Magi", isDirectory: true)
        let local = LocalState(root: root, credential: credential)
        journal = local
        let cache = try await local.read()
        sessions = cache.sessions; outgoing = cache.outgoing; dataEpoch = cache.dataEpoch
        if let first = sessions.first { selectedSessionID = first.session_id; messages = cache.transcripts[first.session_id] ?? [] }
        phase = .connecting
    }
    func connect(address raw: String, code: String) async {
        guard phase != .connecting else { return }
        phase = .connecting; errorKey = nil
        do {
            let address = try ServerAddress(raw)
            let credential = try await MagiClient.pair(address: address, code: code, deviceName: UIDevice.current.name)
            try credentialStore.save(credential)
            try await install(credential)
            showConnection = false
            await activate()
        } catch { phase = client == nil ? .disconnected : .offline; report(error) }
    }
    func disconnect() async {
        generation = UUID(); stopStreams()
        do { try credentialStore.remove(); try await journal?.erase() } catch { report(error); return }
        client = nil; journal = nil; sessions = []; messages = []; tasks = []; notifications = []; outgoing = []
        interactions = []; selectedSessionID = nil; dataEpoch = nil; draft = ""; attachments = []
        previewText = ""; turn = nil; phase = .disconnected; errorKey = nil
    }
    func setForeground(_ active: Bool) async {
        foreground = active
        if active { await activate() } else { stopStreams() }
    }
    private func activate() async {
        guard client != nil, foreground else { return }
        await refresh()
        if phase != .unauthorized { startStreams() }
    }
    func refresh() async {
        guard let client, let journal, !isRefreshing else { return }
        let owner = generation, previousPhase = phase
        isRefreshing = true
        defer { if owner == generation { isRefreshing = false } }
        do {
            let info = try await client.info()
            guard owner == generation else { return }
            guard info.service_ready, let epoch = info.maintenance?.data_epoch,
                  ["idle", "completed"].contains(info.maintenance?.phase ?? "") else { throw ClientError.serviceUnavailable }
            let changed = try await journal.observeGeneration(epoch)
            guard owner == generation else { return }
            if changed {
                localEpochChanged = true; drafts = [:]; createKey = nil; messages = []; sessions = []; selectedSessionID = nil
                turn = nil; interactions = []; previewText = ""; attachments = []; draft = ""
            }
            dataEpoch = epoch
            let page = try await client.sessions()
            guard owner == generation else { return }
            sessions = page.sessions; sessionBefore = page.next_before
            try await journal.updateSessions(sessions)
            phase = .online
            if selectedSessionID == nil { selectedSessionID = sessions.first?.session_id }
            if let selectedSessionID { try await loadConversation(selectedSessionID, client: client, owner: owner) }
            guard owner == generation else { return }
            outgoing = try await journal.read().outgoing
            try await loadTasks(client: client, owner: owner)
            try await loadNotifications(client: client, owner: owner)
        } catch {
            guard owner == generation, !(error is CancellationError) else { return }
            if error as? ClientError == .unauthorized { phase = .unauthorized }
            else { phase = .offline }
            if phase != previousPhase { report(error) }
        }
    }
    func select(_ id: String) async {
        if let previous = selectedSessionID { drafts[previous] = (draft, attachments) }
        selectedSessionID = id; messages = []; previewText = ""; interactions = []; turn = nil
        draft = drafts[id]?.0 ?? ""; attachments = drafts[id]?.1 ?? []
        if let journal { do { messages = try await journal.read().transcripts[id] ?? [] } catch { report(error) } }
        guard let client else { return }
        do { try await loadConversation(id, client: client, owner: generation) } catch { report(error) }
    }
    private func loadConversation(_ id: String, client: MagiClient, owner: UUID) async throws {
        let page = try await client.history(sessionID: id)
        guard owner == generation, id == selectedSessionID else { return }
        messages = page.messages; historyBefore = page.next_before
        try await journal?.updateHistory(messages, sessionID: id)
        for pending in outgoing where pending.request.session_id == id && messages.contains(where: { $0.role == "user" && $0.turn_id == pending.id }) {
            try await journal?.remove(pending.id)
        }
        if let lastTurn = messages.last(where: { $0.role == "user" })?.turn_id {
            let status = try await client.turn(sessionID: id, turnID: lastTurn)
            guard owner == generation, id == selectedSessionID else { return }
            turn = status
            if status.response_complete || messages.contains(where: { $0.role == "assistant" && $0.kind != "status" && $0.turn_id == activePreviewTurn }) {
                previewText = ""; activePreviewTurn = nil
            }
        } else { turn = nil }
        let base = "/control/sessions/\(ServerAddress.segment(id))"
        async let askRequest = client.request(JSONValue.self, path: base + "/ask", template: "/control/sessions/{session_id}/ask")
        async let permissionRequest = client.request(JSONValue.self, path: base + "/permissions", template: "/control/sessions/{session_id}/permissions")
        let (ask, permissions) = try await (askRequest, permissionRequest)
        guard owner == generation, id == selectedSessionID else { return }
        interactions = []
        let question = ask["ask"]
        if question["status"].string == "pending", let requestID = question["request_id"].string,
           let title = question["question"].string {
            interactions.append(Interaction(id: requestID, kind: "ask", title: title, detail: "",
                options: question["options"].array?.compactMap(\.string) ?? [], allowsText: question["allow_free_text"].bool ?? true))
        }
        for value in permissions["items"].array ?? [] {
            guard let requestID = value["request_id"].string else { continue }
            interactions.append(Interaction(id: requestID, kind: "permission", title: value["tool_name"].string ?? L("permission.title"),
                detail: permissionDetail(value), options: [], allowsText: false))
        }
    }
    func loadOlder() async {
        guard let id = selectedSessionID, let before = historyBefore, let client, !isLoadingHistory else { return }
        isLoadingHistory = true; let owner = generation
        defer { isLoadingHistory = false }
        do {
            let page = try await client.history(sessionID: id, before: before)
            guard owner == generation, id == selectedSessionID else { return }
            let current = Set(messages.compactMap(\.message_id))
            messages = page.messages.filter { $0.message_id.map { !current.contains($0) } ?? true } + messages
            historyBefore = page.next_before
        } catch { report(error) }
    }
    func loadMoreSessions() async {
        guard let client, let before = sessionBefore else { return }
        let owner = generation
        do {
            let page = try await client.sessions(before: before)
            guard owner == generation else { return }
            let ids = Set(sessions.map(\.session_id))
            sessions += page.sessions.filter { !ids.contains($0.session_id) }; sessionBefore = page.next_before
        } catch { report(error) }
    }
    func newSession() async {
        guard let client, phase == .online, !isCreating else { return }
        isCreating = true; let owner = generation
        defer { isCreating = false }
        let key = createKey ?? UUID().uuidString.lowercased(); createKey = key
        do {
            let id = try await client.createSession(key: key)
            guard owner == generation else { return }
            createKey = nil
            await select(id); await refresh()
        } catch { report(error) }
    }
    func send() async {
        guard canSend, let client, let journal, let id = selectedSessionID, let dataEpoch else { return }
        isSending = true; errorKey = nil
        let owner = generation, text = draft, files = attachments
        let turnID = UUID().uuidString.lowercased()
        defer { if owner == generation { isSending = false } }
        do {
            var uploaded: [[String: JSONValue]] = []
            for file in files {
                let metadata = try await client.upload(sessionID: id, turnID: turnID, filename: file.filename, mimeType: file.mimeType, data: file.data)
                guard owner == generation else { return }
                guard let object = metadata.object else { throw ClientError.invalidResponse }
                uploaded.append(object)
            }
            var request = Wire.UserMessageRequest()
            request.message = text; request.session_id = id; request.client_turn_id = turnID
            request.client_environment = Wire.ClientEnvironment(os: "ios", timezone: TimeZone.current.identifier)
            request.attachments = uploaded
            let pending = OutgoingTurn(request: request, dataEpoch: dataEpoch)
            try await journal.put(pending)
            guard owner == generation else { return }
            outgoing = try await journal.read().outgoing
            drafts[id] = nil
            if selectedSessionID == id { draft = ""; attachments = [] }
            let result = try await TurnDelivery.deliver(pending, client: client, journal: journal)
            guard owner == generation else { return }
            if result != .confirmed { errorKey = result == .concluded ? "error.concluded" : "error.uncertain" }
            outgoing = try await journal.read().outgoing
            await refresh()
        } catch { if owner == generation { outgoing = (try? await journal.read().outgoing) ?? outgoing; report(error) } }
    }
    func retry(_ pending: OutgoingTurn) async {
        guard let client, let journal, !isSending else { return }
        isSending = true; let owner = generation
        defer { if owner == generation { isSending = false } }
        do {
            let result = try await TurnDelivery.deliver(pending, client: client, journal: journal)
            guard owner == generation else { return }
            if result == .concluded { errorKey = "error.concluded" }
            else if result == .uncertain { errorKey = "error.uncertain" }
            outgoing = try await journal.read().outgoing
            await refresh()
        } catch { report(error) }
    }
    func discard(_ pending: OutgoingTurn) async {
        do { try await journal?.remove(pending.id); outgoing.removeAll { $0.id == pending.id } } catch { report(error) }
    }
    func stopTurn() async {
        guard let client, let id = selectedSessionID else { return }
        do { try await client.cancel(sessionID: id, turnID: turn?.turn_id); await refresh() } catch { report(error) }
    }
    func respond(_ interaction: Interaction, answer: String) async {
        guard let client, let sessionID = selectedSessionID, !isSending else { return }
        let owner = generation; isSending = true
        defer { if owner == generation { isSending = false } }
        let requestID = ServerAddress.segment(interaction.id)
        do {
            if interaction.kind == "ask" {
                do {
                    _ = try await client.request(JSONValue.self, method: "POST", path: "/control/ask/\(requestID)/respond",
                        template: "/control/ask/{request_id}/respond", body: .object(["answer": .string(answer)]))
                } catch {
                    let query = Wire.AnswerConfirmationRequest(answer: answer, kind: "ask_response", request_id: interaction.id, session_id: sessionID)
                    let receipt = try await client.request(Wire.SendConfirmation.self, method: "POST", path: "/messages/confirmation", body: JSONValue.encode(query))
                    guard receipt.identity == interaction.id, receipt.session_id == sessionID, receipt.status == "confirmed" else { throw error }
                }
            } else {
                _ = try await client.request(JSONValue.self, method: "POST", path: "/control/permission/\(requestID)/respond",
                    template: "/control/permission/{request_id}/respond", body: .object(["outcome": .string(answer), "scope": .string("one_shot")]))
            }
            guard owner == generation else { return }
            await refresh()
        } catch { if owner == generation { report(error); await refresh() } }
    }
    private func loadTasks(client: MagiClient, owner: UUID) async throws {
        let view = taskView
        let page = try await client.request(Wire.ItemPage.self, path: "/personal-tasks", query: ["view": view, "limit": "100"])
        guard owner == generation, view == taskView else { return }
        tasks = page.items; taskCounts = page.counts
    }
    func chooseTaskView(_ view: String) async { taskView = view; await refresh() }
    func completeTask(_ item: Wire.PersonalItem) async {
        guard let client else { return }
        do {
            var fields = Wire.ItemPatch(); fields.status = "completed"
            let command = Wire.TaskMutation(action: "update", expected_version: item.version, fields: fields,
                item_id: item.id, request_id: UUID().uuidString.lowercased())
            _ = try await client.request(Wire.MutationResult.self, method: "POST", path: "/personal-tasks/mutations", body: JSONValue.encode(command))
            await refresh()
        } catch { report(error) }
    }
    private func loadNotifications(client: MagiClient, owner: UUID) async throws {
        let response = try await client.request(Wire.ListResponse.self, path: "/notifications", query: ["limit": "100"])
        guard owner == generation else { return }
        notifications = response.items; unreadCount = Int(response.unread_count)
    }
    func markRead(_ id: Int64) async {
        guard let client else { return }
        do {
            _ = try await client.request(JSONValue.self, method: "POST", path: "/notifications/mark-read", body: .object(["ids": .array([.integer(id)])]))
            await refresh()
        } catch { report(error) }
    }
    private func stopStreams() {
        eventsTask?.cancel(); eventsTask = nil; pollingTask?.cancel(); pollingTask = nil
        refreshTask?.cancel(); refreshTask = nil; previewText = ""; activePreviewTurn = nil
    }
    private func startStreams() {
        guard eventsTask == nil, let client else { return }
        let owner = generation
        eventsTask = Task { [weak self] in
            let serverID = await client.credential.serverID
            var failures = 0
            while !Task.isCancelled {
                guard let self, self.generation == owner, self.foreground else { return }
                do {
                    let connection = try await client.openEvents(after: self.eventStream.lastID)
                    failures = 0
                    for try await line in connection.lines {
                        try Task.checkCancellation()
                        guard self.generation == owner else { return }
                        if let update = try self.eventStream.consume(line: line, serverID: serverID) { self.receive(update) }
                    }
                } catch {
                    if Task.isCancelled { return }
                    if error as? ClientError == .unauthorized { self.phase = .unauthorized; self.report(error); return }
                    self.eventStream = EventStream(); self.queueRefresh()
                }
                failures += 1
                do { try await Task.sleep(for: .seconds(min(30, 1 << min(failures, 4)))) } catch { return }
            }
        }
        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                do { try await Task.sleep(for: .seconds(15)) } catch { return }
                guard let self, self.generation == owner, self.foreground else { return }
                await self.refresh()
            }
        }
    }
    private func receive(_ update: ProductUpdate) {
        if update.needsSnapshot { previewText = ""; queueRefresh(); return }
        let data = update.data
        if update.kind == "agent_response_chunk", data["session_id"].string == selectedSessionID {
            let id = data["turn_id"].string
            if activePreviewTurn != id { previewText = ""; activePreviewTurn = id }
            let event = data["event"]
            switch event["kind"].string {
            case "text_delta": previewText += event["text"].string ?? ""
            case "text_reset", "text_flush": previewText = event["text"].string ?? ""
            case "done", "error": queueRefresh()
            default: break
            }
            if previewText.utf8.count > 256 * 1024 { previewText = String(previewText.suffix(64 * 1024)) }
        } else { queueRefresh() }
    }
    private func queueRefresh() {
        guard refreshTask == nil else { return }
        refreshTask = Task { [weak self] in
            do { try await Task.sleep(for: .milliseconds(250)) } catch { return }
            guard let self else { return }
            self.refreshTask = nil; await self.refresh()
        }
    }
    private func permissionDetail(_ value: JSONValue) -> String {
        let encoder = JSONEncoder(); encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let arguments = (try? encoder.encode(value["arguments"])).flatMap { String(data: $0, encoding: .utf8) } ?? ""
        return [value["preview"].string, arguments].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: "\n\n")
    }
    func addFiles(_ urls: [URL]) async {
        guard !isSending else { return }
        let id = selectedSessionID
        do {
            let files = try await Task.detached(priority: .userInitiated) {
                try urls.map { url in
                    let permitted = url.startAccessingSecurityScopedResource()
                    defer { if permitted { url.stopAccessingSecurityScopedResource() } }
                    let values = try url.resourceValues(forKeys: [.fileSizeKey, .contentTypeKey])
                    guard let size = values.fileSize, size > 0, size <= 20 * 1024 * 1024 else { throw ClientError.responseTooLarge }
                    return DraftAttachment(filename: url.lastPathComponent, mimeType: values.contentType?.preferredMIMEType ?? "application/octet-stream", data: try Data(contentsOf: url))
                }
            }.value
            guard id == selectedSessionID else { return }
            guard attachments.count + files.count <= 8 else { throw ClientError.responseTooLarge }
            attachments += files
        } catch { report(error) }
    }
    func report(_ error: any Error) {
        if error is CancellationError { return }
        if error is DecodingError { errorKey = "error.contract"; return }
        switch error as? ClientError {
        case .invalidAddress: errorKey = "error.address"
        case .invalidPairingCode: errorKey = "error.pairing"
        case .unauthorized: errorKey = "error.unauthorized"
        case .unsupportedProtocol, .invalidContract, .invalidResponse: errorKey = "error.contract"
        case .identityChanged: errorKey = "error.identity"
        case .expiredGeneration: errorKey = "error.generation"
        case .storage: errorKey = "error.storage"
        case .responseTooLarge: errorKey = "error.size"
        case .serviceUnavailable: errorKey = "error.service"
        case .runtimeNotReady: errorKey = "error.model"
        case .conflict: errorKey = "error.conflict"
        default: errorKey = "error.network"
        }
    }
}

func L(_ key: String) -> String { NSLocalizedString(key, comment: "") }

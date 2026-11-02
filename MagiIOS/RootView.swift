import SwiftUI
import MagiCore

struct RootView: View {
    @Environment(AppStore.self) private var store
    var body: some View {
        @Bindable var store = store
        Group {
            if store.hasConnection {
                TabView {
                    ConversationsView().tabItem { Label("tab.conversations", systemImage: "bubble.left.and.bubble.right") }
                    TasksView().tabItem { Label("tab.tasks", systemImage: "checkmark.circle") }
                    NotificationsView().tabItem { Label("tab.notifications", systemImage: "bell") }.badge(store.unreadCount)
                }
            } else { NavigationStack { ConnectionView() } }
        }
        .sheet(isPresented: $store.showConnection) { NavigationStack { ConnectionView() } }
        .alert(L("error.title"), isPresented: Binding(get: { store.errorKey != nil }, set: { if !$0 { store.errorKey = nil } })) {
            Button("action.ok", role: .cancel) { store.errorKey = nil }
        } message: { Text(L(store.errorKey ?? "error.network")) }
    }
}

struct ConnectionView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var address = ""
    @State private var code = ""
    @State private var confirmDisconnect = false
    var body: some View {
        Form {
            if store.hasConnection {
                Section {
                    Label(store.address, systemImage: "server.rack").font(.subheadline).textSelection(.enabled)
                    ConnectionStatus()
                } header: { Text("connection.current") }
                Section {
                    Button("connection.disconnect", role: .destructive) { confirmDisconnect = true }
                } footer: { Text("connection.disconnect.help") }
            } else {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Image(systemName: "sparkle").font(.system(size: 38, weight: .medium)).foregroundStyle(Color.magi)
                        Text("welcome.title").font(.largeTitle.bold())
                        Text("welcome.body").foregroundStyle(.secondary)
                    }.padding(.vertical, 16)
                }.listRowBackground(Color.clear)
                Section {
                    TextField("connection.address", text: $address)
                        .keyboardType(.URL).textContentType(.URL).textInputAutocapitalization(.never).autocorrectionDisabled()
                        .accessibilityIdentifier("connection.address")
                    SecureField("connection.code", text: $code)
                        .textInputAutocapitalization(.never).autocorrectionDisabled()
                        .accessibilityIdentifier("connection.code")
                } header: { Text("connection.server") } footer: { Text("connection.help") }
                Section {
                    Button {
                        Task {
                            await store.connect(address: address, code: code)
                            if store.hasConnection { code = "" }
                        }
                    } label: {
                        HStack {
                            Text("connection.connect").fontWeight(.semibold)
                            Spacer()
                            if store.phase == .connecting { ProgressView() }
                            else { Image(systemName: "arrow.right") }
                        }
                    }
                    .disabled(address.isEmpty || code.isEmpty || store.phase == .connecting)
                    .accessibilityIdentifier("connection.connect")
                }
            }
            Section { Text("connection.privacy").font(.footnote).foregroundStyle(.secondary) }
        }
        .navigationTitle(store.hasConnection ? L("connection.title") : "Magi")
        .toolbar { if store.hasConnection { ToolbarItem(placement: .confirmationAction) { Button("action.done") { dismiss() } } } }
        .confirmationDialog("connection.disconnect.confirm", isPresented: $confirmDisconnect, titleVisibility: .visible) {
            Button("connection.disconnect", role: .destructive) { Task { await store.disconnect(); dismiss() } }
        } message: { Text("connection.disconnect.help") }
    }
}

struct ConnectionStatus: View {
    @Environment(AppStore.self) private var store
    private var key: String {
        switch store.phase {
        case .online: "connection.online"
        case .connecting: "connection.connecting"
        case .offline: "connection.offline"
        case .unauthorized: "connection.unauthorized"
        case .disconnected: "connection.disconnected"
        }
    }
    var body: some View {
        HStack(spacing: 8) {
            Circle().fill(store.phase == .online ? Color.magi : Color.orange).frame(width: 7, height: 7)
            Text(L(key)).font(.caption).foregroundStyle(.secondary)
            if store.phase == .offline { Button("action.retry") { Task { await store.refresh() } }.font(.caption) }
        }.accessibilityElement(children: .combine)
    }
}

struct ConnectionToolbar: ToolbarContent {
    @Environment(AppStore.self) private var store
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button { store.showConnection = true } label: { Image(systemName: "gearshape") }
                .accessibilityLabel(Text("connection.title")).accessibilityIdentifier("connection.settings")
        }
    }
}

struct ConversationsView: View {
    @Environment(AppStore.self) private var store
    @State private var path: [String] = []
    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section {
                    ConnectionStatus()
                    if store.localEpochChanged { Label("connection.reset", systemImage: "arrow.triangle.2.circlepath").font(.footnote) }
                }.listRowBackground(Color.clear)
                if store.sessions.isEmpty {
                    ContentUnavailableView("conversations.empty", systemImage: "bubble.left.and.bubble.right", description: Text("conversations.empty.help"))
                        .listRowBackground(Color.clear)
                }
                Section {
                    ForEach(store.sessions, id: \.session_id) { session in
                        NavigationLink(value: session.session_id) {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(alignment: .firstTextBaseline) {
                                    Text(session.title.isEmpty ? L("chat.untitled") : session.title).font(.headline).lineLimit(1)
                                    Spacer(minLength: 4)
                                    Text(Date(timeIntervalSince1970: Double(session.last_timestamp) / 1000), style: .date)
                                        .font(.caption2).foregroundStyle(.secondary)
                                }
                                Text(session.last_message_preview.isEmpty ? L("chat.start") : session.last_message_preview)
                                    .font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
                            }.padding(.vertical, 6)
                        }.accessibilityIdentifier("session.\(session.session_id)")
                    }
                    if store.sessionBefore != nil { Button("action.more") { Task { await store.loadMoreSessions() } } }
                }
                if !store.outgoing.isEmpty {
                    Section("outgoing.title") {
                        ForEach(store.outgoing) { pending in PendingTurnView(pending: pending) }
                    }
                }
            }
            .navigationTitle("tab.conversations")
            .refreshable { await store.refresh() }
            .toolbar {
                ConnectionToolbar()
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await store.newSession()
                            if let id = store.selectedSessionID { path = [id] }
                        }
                    } label: { if store.isCreating { ProgressView() } else { Image(systemName: "square.and.pencil") } }
                    .disabled(store.phase != .online || store.isCreating)
                    .accessibilityLabel(Text("conversations.new")).accessibilityIdentifier("conversations.new")
                }
            }
            .navigationDestination(for: String.self) { id in ChatView(sessionID: id) }
            .onChange(of: store.dataEpoch) { before, after in if before != nil && before != after { path = [] } }
        }
    }
}

struct TasksView: View {
    @Environment(AppStore.self) private var store
    @State private var completing = Set<String>()
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ConnectionStatus()
                    Picker("tasks.view", selection: Binding(get: { store.taskView }, set: { view in Task { await store.chooseTaskView(view) } })) {
                        Text("tasks.next").tag("next")
                        Text("tasks.inbox").tag("inbox")
                        Text("tasks.completed").tag("completed")
                    }.pickerStyle(.segmented)
                }.listRowBackground(Color.clear)
                if store.tasks.isEmpty {
                    ContentUnavailableView("tasks.empty", systemImage: "checkmark.circle", description: Text("tasks.empty.help"))
                        .listRowBackground(Color.clear)
                }
                ForEach(store.tasks, id: \.id) { item in
                    HStack(alignment: .top, spacing: 12) {
                        Button {
                            completing.insert(item.id)
                            Task { await store.completeTask(item); completing.remove(item.id) }
                        } label: {
                            Image(systemName: item.status == "completed" ? "checkmark.circle.fill" : "circle").font(.title2)
                        }.buttonStyle(.borderless)
                            .disabled(item.status == "completed" || completing.contains(item.id) || store.phase != .online)
                            .accessibilityLabel(Text("tasks.complete")).accessibilityIdentifier("task.complete.\(item.id)")
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.title).font(.headline)
                            if let body = item.body_md, !body.isEmpty { Text(body).font(.subheadline).foregroundStyle(.secondary) }
                            if let due = item.due { Label(due, systemImage: "calendar").font(.caption).foregroundStyle(.secondary) }
                        }.textSelection(.enabled)
                    }.padding(.vertical, 6)
                }
            }
            .navigationTitle("tab.tasks").refreshable { await store.refresh() }
            .toolbar { ConnectionToolbar() }
        }
    }
}

struct NotificationsView: View {
    @Environment(AppStore.self) private var store
    @State private var marking = Set<Int64>()
    var body: some View {
        NavigationStack {
            List {
                Section { ConnectionStatus() }.listRowBackground(Color.clear)
                if store.notifications.isEmpty {
                    ContentUnavailableView("notifications.empty", systemImage: "bell", description: Text("notifications.empty.help"))
                        .listRowBackground(Color.clear)
                }
                ForEach(store.notifications, id: \.id) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            if item.status == "unread" { Circle().fill(Color.magi).frame(width: 7, height: 7) }
                            Text(item.title).font(.headline)
                        }
                        Text(item.body).font(.subheadline).foregroundStyle(.secondary).textSelection(.enabled)
                        HStack {
                            Text(Date(timeIntervalSince1970: Double(item.created_at_ms) / 1000), style: .relative).font(.caption).foregroundStyle(.secondary)
                            Spacer()
                            if item.status == "unread" {
                                Button("notifications.read") {
                                    marking.insert(item.id)
                                    Task { await store.markRead(item.id); marking.remove(item.id) }
                                }.font(.caption).disabled(marking.contains(item.id) || store.phase != .online)
                            }
                        }
                    }.padding(.vertical, 6)
                }
            }
            .navigationTitle("tab.notifications").refreshable { await store.refresh() }
            .toolbar { ConnectionToolbar() }
        }
    }
}

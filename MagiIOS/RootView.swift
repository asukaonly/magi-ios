import SwiftUI
import MagiCore

extension Color {
    static let canvas = Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
        ? UIColor(red: 0.09, green: 0.09, blue: 0.085, alpha: 1)
        : UIColor(red: 0.975, green: 0.969, blue: 0.951, alpha: 1) })
    static let paper = Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
        ? UIColor(white: 0.16, alpha: 1) : UIColor(white: 1, alpha: 1) })
}

struct RootView: View {
    @Environment(AppStore.self) private var store
    var body: some View {
        @Bindable var store = store
        Group {
            if store.hasConnection {
                TabView {
                    ChatHome().tabItem { Label("tab.conversations", systemImage: "bubble.left") }
                    MemoryView().tabItem { Label("tab.memory", systemImage: "sparkles") }
                    TasksView().tabItem { Label("tab.tasks", systemImage: "checkmark.circle") }
                    ExtensionsView().tabItem { Label("tab.extensions", systemImage: "square.grid.2x2") }
                }.id(store.connectionGeneration).background(Color.canvas)
            } else { NavigationStack { WelcomeView() } }
        }
        .sheet(isPresented: $store.showConnection) { NavigationStack { ConnectionView() } }
        .sheet(isPresented: $store.showNotifications) { NotificationsView() }
        .alert(L("error.title"), isPresented: Binding(get: { store.errorKey != nil }, set: { if !$0 { store.errorKey = nil } })) {
            Button("action.ok", role: .cancel) { store.errorKey = nil }
        } message: { Text(L(store.errorKey ?? "error.network")) }
    }
}

struct MagiMark: View {
    var size: CGFloat = 44
    var body: some View { Image("MagiMark").resizable().scaledToFit().frame(width: size, height: size).accessibilityHidden(true) }
}

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 22) {
                MagiMark(size: 96)
                Text("Magi").font(.system(size: 38, weight: .semibold, design: .rounded))
                Text("welcome.title").font(.title3).foregroundStyle(.secondary).multilineTextAlignment(.center)
            }
            Spacer()
            NavigationLink {
                ConnectionView()
            } label: {
                Text("welcome.start").fontWeight(.semibold).frame(maxWidth: .infinity).padding(.vertical, 17)
            }
            .buttonStyle(.plain).background(Color.magi, in: RoundedRectangle(cornerRadius: 18)).foregroundStyle(Color.canvas)
            .accessibilityIdentifier("welcome.start")
        }
        .padding(28).padding(.bottom, 16).frame(maxWidth: 520)
        .frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.canvas)
    }
}

struct ConnectionView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var address = ""
    @State private var code = ""
    @State private var help = false
    @State private var confirmDisconnect = false
    private enum Field { case address, code }
    @FocusState private var focused: Field?
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                if store.hasConnection {
                    Text(store.address).font(.body).textSelection(.enabled)
                    ConnectionStatus(showOnline: true)
                    Button("connection.disconnect", role: .destructive) { confirmDisconnect = true }
                } else {
                    VStack(spacing: 0) {
                        TextField("connection.address", text: $address)
                            .keyboardType(.URL).textContentType(.URL).textInputAutocapitalization(.never).autocorrectionDisabled()
                            .focused($focused, equals: .address).submitLabel(.next).onSubmit { focused = .code }
                            .accessibilityIdentifier("connection.address").padding(18)
                        Divider().padding(.horizontal, 18)
                        SecureField("connection.code", text: $code)
                            .textContentType(.oneTimeCode).textInputAutocapitalization(.never).autocorrectionDisabled()
                            .focused($focused, equals: .code).submitLabel(.go).onSubmit { connect() }
                            .accessibilityIdentifier("connection.code").padding(18)
                    }.background(Color.paper, in: RoundedRectangle(cornerRadius: 18))
                    Button {
                        connect()
                    } label: {
                        HStack { Spacer(); if store.phase == .connecting { ProgressView() } else { Text("connection.connect").fontWeight(.semibold) }; Spacer() }
                            .padding(.vertical, 17)
                    }
                    .buttonStyle(.plain).background(Color.magi, in: RoundedRectangle(cornerRadius: 18)).foregroundStyle(Color.canvas)
                    .disabled(address.isEmpty || code.isEmpty || store.phase == .connecting)
                    .opacity(address.isEmpty || code.isEmpty ? 0.5 : 1).accessibilityIdentifier("connection.connect")
                    Button("connection.help.title") { help = true }.font(.footnote).foregroundStyle(.secondary).frame(maxWidth: .infinity)
                }
            }.padding(28).frame(maxWidth: 520).frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity).background(Color.canvas)
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(store.hasConnection ? L("connection.title") : L("connection.connect")).navigationBarTitleDisplayMode(.inline)
        .toolbar { if store.hasConnection { ToolbarItem(placement: .confirmationAction) { Button("action.done") { dismiss() } } } }
        .sheet(isPresented: $help) {
            NavigationStack {
                VStack(alignment: .leading, spacing: 24) { Text("connection.help"); Text("connection.privacy").foregroundStyle(.secondary); Spacer() }.padding(28)
                    .navigationTitle("connection.help.title").navigationBarTitleDisplayMode(.inline)
                    .toolbar { ToolbarItem(placement: .confirmationAction) { Button("action.done") { help = false } } }
            }.presentationDetents([.medium])
        }
        .confirmationDialog("connection.disconnect.confirm", isPresented: $confirmDisconnect, titleVisibility: .visible) {
            Button("connection.disconnect", role: .destructive) { Task { await store.disconnect(); dismiss() } }
        } message: { Text("connection.disconnect.help") }
    }
    private func connect() {
        focused = nil
        Task { await store.connect(address: address, code: code); if store.hasConnection { code = "" } }
    }
}

struct ConnectionStatus: View {
    var showOnline = false
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
        if showOnline || store.phase != .online {
            HStack(spacing: 8) {
                Circle().fill(Color.magi.opacity(0.5)).frame(width: 5, height: 5)
                Text(L(key)).font(.caption).foregroundStyle(.secondary)
                if store.phase == .offline { Button("action.retry") { Task { await store.refresh() } }.font(.caption) }
            }.accessibilityElement(children: .contain)
        }
    }
}

struct AppToolbar: ToolbarContent {
    @Environment(AppStore.self) private var store
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button { store.showNotifications = true } label: {
                Image(systemName: "bell").overlay(alignment: .topTrailing) {
                    if store.unreadCount > 0 { Circle().fill(Color.magi).frame(width: 5, height: 5).offset(x: 3, y: -2) }
                }
            }.accessibilityLabel(Text("tab.notifications")).accessibilityIdentifier("notifications.open")
        }
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button("action.refresh", systemImage: "arrow.clockwise") { Task { await store.refresh() } }
                Button("connection.title", systemImage: "gearshape") { store.showConnection = true }
            } label: { Image(systemName: "ellipsis") }.accessibilityLabel(Text("action.menu")).accessibilityIdentifier("app.menu")
        }
    }
}

struct ChatHome: View {
    @Environment(AppStore.self) private var store
    @State private var history = false
    var body: some View {
        NavigationStack {
            Group {
                if let id = store.selectedSessionID { ChatView(sessionID: id).id(id) }
                else {
                    VStack(spacing: 24) {
                        MagiMark(size: 56)
                        Text("chat.start").font(.title2.weight(.medium))
                        Button("conversations.new") { Task { await store.newSession() } }.buttonStyle(.bordered)
                            .disabled(store.phase != .online || store.isCreating)
                    }.frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.canvas)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button { history = true } label: { Image(systemName: "line.3.horizontal") }.accessibilityLabel(Text("conversations.history")).accessibilityIdentifier("chat.history") }
                ToolbarItem(placement: .principal) { HStack(spacing: 8) { MagiMark(size: 24); Text("Magi").font(.headline) } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { Task { await store.newSession() } } label: { Image(systemName: "square.and.pencil") }
                        .disabled(store.phase != .online || store.isCreating).accessibilityLabel(Text("conversations.new")).accessibilityIdentifier("conversations.new")
                }
                AppToolbar()
            }
        }
        .sheet(isPresented: $history) { ConversationHistory() }
    }
}

struct ConversationHistory: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                ForEach(store.sessions, id: \.session_id) { session in
                    Button {
                        Task { await store.select(session.session_id); dismiss() }
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(session.title.isEmpty || ["New conversation", "New Session"].contains(session.title)
                                 ? (session.last_user_message_preview.isEmpty ? L("chat.untitled") : session.last_user_message_preview) : session.title)
                                .font(.body.weight(.medium)).lineLimit(1)
                            Text(session.last_message_preview).font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
                        }.padding(.vertical, 8).frame(maxWidth: .infinity, alignment: .leading)
                    }.listRowBackground(Color.clear).accessibilityIdentifier("session.\(session.session_id)")
                }
                if store.sessionBefore != nil { Button("action.more") { Task { await store.loadMoreSessions() } } }
            }
            .listStyle(.plain).scrollContentBackground(.hidden).background(Color.canvas)
            .navigationTitle("conversations.history").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("action.done") { dismiss() } } }
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
            .listStyle(.plain).scrollContentBackground(.hidden).background(Color.canvas)
            .navigationTitle("tab.tasks").navigationBarTitleDisplayMode(.inline).refreshable { await store.refresh() }
            .toolbar { AppToolbar() }
        }
    }
}

struct NotificationsView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var marking = Set<Int64>()
    var body: some View {
        NavigationStack {
            List {
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
            .listStyle(.plain).scrollContentBackground(.hidden).background(Color.canvas)
            .navigationTitle("tab.notifications").navigationBarTitleDisplayMode(.inline).refreshable { await store.refresh() }
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("action.done") { dismiss() } } }
        }
    }
}

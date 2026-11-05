import SwiftUI
import MagiCore

struct MemoryView: View {
    @Environment(AppStore.self) private var store
    @State private var view = "about"
    @State private var query = ""
    @State private var items: [Wire.MemoryLibraryItem] = []
    @State private var total: Int64 = 0
    @State private var loading = false
    @State private var failed = false
    @State private var revision = 0
    @State private var stale = false
    @State private var loadToken = UUID()
    var body: some View {
        NavigationStack {
            List {
                Picker("tab.memory", selection: $view) {
                    Text("memory.about").tag("about")
                    Text("memory.events").tag("events")
                    Text("memory.stories").tag("stories")
                }.pickerStyle(.segmented).listRowBackground(Color.clear).listRowSeparator(.hidden)
                if stale { Label("memory.updating", systemImage: "arrow.trianglehead.2.clockwise").font(.footnote).foregroundStyle(.secondary).listRowBackground(Color.clear) }
                ForEach(items, id: \.id) { item in
                    NavigationLink {
                        MemoryDetail(item: item) { revision += 1 }
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            if let title = item.title, !title.isEmpty { Text(title).font(.headline).lineLimit(2) }
                            Text(item.text).lineLimit(4).font(.body)
                            HStack {
                                if item.needs_review == true { Label("memory.review", systemImage: "circle.dotted").font(.caption) }
                                if let timestamp = item.timestamp { Text(Date(timeIntervalSince1970: timestamp), style: .date).font(.caption).foregroundStyle(.secondary) }
                            }
                        }.padding(.vertical, 10)
                    }.listRowBackground(Color.clear).accessibilityIdentifier("memory.item.\(item.id)")
                }
                if loading { ProgressView().frame(maxWidth: .infinity).listRowBackground(Color.clear).listRowSeparator(.hidden) }
                else if failed { Button("action.retry") { revision += 1 }.frame(maxWidth: .infinity).listRowBackground(Color.clear) }
                else if items.isEmpty {
                    ContentUnavailableView(query.isEmpty ? "memory.empty" : "memory.noResults", systemImage: "sparkles")
                        .listRowBackground(Color.clear).listRowSeparator(.hidden)
                } else if items.count < total {
                    Button("action.more") { Task { await load(more: true) } }.listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain).scrollContentBackground(.hidden).background(Color.canvas)
            .navigationTitle("tab.memory").navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: Text("memory.search"))
            .task(id: "\(view)/\(query)/\(revision)") {
                do { if !query.isEmpty { try await Task.sleep(for: .milliseconds(250)) }; try Task.checkCancellation(); await load() }
                catch {}
            }
            .refreshable { await load() }
            .toolbar { AppToolbar() }
        }
    }
    private func load(more: Bool = false) async {
        guard !more || !loading, let client = store.productClient else { return }
        let requested = "\(view)/\(query)", owner = store.connectionGeneration
        let token = UUID(); loadToken = token
        loading = true; failed = false
        if !more { items = [] }
        do {
            let result = try await client.memory(view: view, query: query, offset: more ? items.count : 0)
            try Task.checkCancellation()
            guard token == loadToken, owner == store.connectionGeneration, requested == "\(view)/\(query)" else { return }
            items = more ? items + result.items : result.items; total = result.total; stale = result.stale == true; loading = false
        } catch {
            if !Task.isCancelled, token == loadToken, owner == store.connectionGeneration, requested == "\(view)/\(query)" { loading = false; failed = true }
        }
    }
}

struct MemoryDetail: View {
    let item: Wire.MemoryLibraryItem
    let changed: () -> Void
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var evidence: [Wire.MemoryLibraryItem] = []
    @State private var loading = false
    @State private var evidenceFailed = false
    @State private var editing = false
    @State private var value = ""
    @State private var busy = false
    @State private var confirmForget = false
    @State private var requestID = UUID().uuidString.lowercased()
    var body: some View {
        List {
            Section {
                if let title = item.title, !title.isEmpty { Text(title).font(.title3.weight(.medium)) }
                Text(item.text).textSelection(.enabled).lineSpacing(5)
                if let timestamp = item.timestamp { Text(Date(timeIntervalSince1970: timestamp), style: .date).foregroundStyle(.secondary).font(.footnote) }
            }.listRowBackground(Color.clear)
            if item.assertion_id != nil {
                Section {
                    Button("memory.correct", systemImage: "pencil") { value = item.correction_value ?? item.text; editing = true }
                    Button("memory.incorrect", systemImage: "xmark.circle") { Task { await correct(nil) } }
                }
            }
            if loading || !evidence.isEmpty || evidenceFailed {
                Section("memory.evidence") {
                    if loading { ProgressView() }
                    ForEach(evidence, id: \.id) { event in
                        NavigationLink { MemoryDetail(item: event, changed: changed) } label: {
                            Text(event.text).lineLimit(4).padding(.vertical, 6)
                        }
                    }
                    if evidenceFailed { Button("action.retry") { Task { await loadEvidence() } } }
                }
            }
            if item.can_delete == true {
                Section { Button("memory.forget", role: .destructive) { confirmForget = true } }
            }
        }
        .scrollContentBackground(.hidden).background(Color.canvas)
        .navigationTitle("tab.memory").navigationBarTitleDisplayMode(.inline)
        .disabled(busy)
        .task(id: item.id) { await loadEvidence() }
        .sheet(isPresented: $editing) {
            NavigationStack {
                Form {
                    if let options = item.correction_options, !options.isEmpty {
                        Picker("memory.value", selection: $value) { ForEach(options, id: \.self) { Text($0).tag($0) } }
                    } else { TextField("memory.value", text: $value, axis: .vertical).lineLimit(3...10) }
                }
                .navigationTitle("memory.correct").navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("action.cancel") { editing = false } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("action.save") { Task { await correct(value) } }.disabled(busy || value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }.presentationDetents([.medium, .large])
        }
        .confirmationDialog("memory.forget.confirm", isPresented: $confirmForget, titleVisibility: .visible) {
            Button("memory.forget", role: .destructive) {
                Task {
                    guard let client = store.productClient else { return }
                    busy = true; defer { busy = false }
                    do { try await client.forgetMemory(item); changed(); dismiss() } catch { store.report(error) }
                }
            }
        } message: { Text("memory.forget.help") }
    }
    private func correct(_ replacement: String?) async {
        guard let client = store.productClient else { return }
        busy = true; defer { busy = false }
        do {
            try await client.correctMemory(item, value: replacement, requestID: requestID)
            editing = false; changed(); dismiss()
        } catch { store.report(error) }
    }
    private func loadEvidence() async {
        guard let client = store.productClient else { return }
        loading = true; evidenceFailed = false; evidence = []
        defer { loading = false }
        do {
            var ids = (item.evidence_ids ?? []).filter { item.kind != "event" || $0 != item.id }
            if item.kind == "story" {
                let result = try await client.request(JSONValue.self, path: "/memory/stories/\(ServerAddress.segment(item.id))/evidence", template: "/memory/stories/{summary_id}/evidence")
                ids = result["items"].array?.compactMap { $0["event_id"].string } ?? []
            }
            for id in ids {
                try Task.checkCancellation()
                evidence.append(try await client.memoryEvidence(id: id))
            }
        } catch { if !Task.isCancelled { evidenceFailed = true } }
    }
}

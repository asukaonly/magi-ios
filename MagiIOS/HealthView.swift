import SwiftUI
import MagiCore

struct HealthView: View {
    let package: Wire.PluginPackageResponse
    @Environment(AppStore.self) private var store
    @State private var selected = Set(["steps", "sleep", "workout"])
    @State private var days = 7
    @State private var consent = false
    @State private var clearing = false
    private var supported: Bool {
        (package.manifest.device_collectors ?? []).contains { $0.capability_id == "apple_health.observe" && $0.schema_id == "apple_health.record" && $0.schema_version == 1 && $0.protocol == "source.change.v1" }
    }
    var body: some View {
        List {
            if let health = store.health {
                if !HealthReader.available { Text("health.unavailable") }
                else if !supported { Text("extensions.appUpdate") }
                else {
                    if health.state.connectionID == nil {
                        Section("health.scope") {
                            ForEach(["steps", "sleep", "workout"], id: \.self) { type in
                                Toggle(L("health.\(type)"), isOn: Binding(get: { selected.contains(type) }, set: { if $0 { selected.insert(type) } else { selected.remove(type) } }))
                            }
                            Picker("health.range", selection: $days) { Text("health.week").tag(7); Text("health.month").tag(30) }
                        }
                        Section {
                            Toggle("health.consent", isOn: $consent)
                        } footer: { Text("health.consent.help") }
                    } else {
                        Section {
                            HStack { Text("health.status"); Spacer(); Text(health.state.paused ? "extensions.paused" : "extensions.active").foregroundStyle(.secondary) }
                            Text(health.state.types.map { L("health.\($0)") }.joined(separator: " · ")).font(.footnote).foregroundStyle(.secondary)
                            if let sent = health.state.lastSent { LabeledContent("health.sent") { Text(sent, style: .relative) } }
                            if !health.state.pending.isEmpty { LabeledContent("health.queued", value: String(health.state.pending.count)) }
                        }
                    }
                    Section {
                        Button(health.state.paused && health.state.connectionID != nil ? "health.resume" : "health.preview", systemImage: "heart") {
                            Task { await health.prepare(types: Array(selected), days: days) }
                        }.disabled(health.busy || (health.state.connectionID == nil && (!consent || selected.isEmpty)))
                        if let preview = health.preview {
                            if preview.changes.isEmpty { Text("health.noData").font(.footnote).foregroundStyle(.secondary) }
                            ForEach(preview.counts.keys.sorted(), id: \.self) { type in
                                LabeledContent(L("health.\(type)"), value: String(preview.counts[type] ?? 0))
                            }
                            if !preview.changes.isEmpty {
                                NavigationLink("health.details") { HealthPreviewView(preview: preview) }
                            }
                            Button("health.send", systemImage: "arrow.up") { Task { await health.send() } }
                                .disabled(health.busy || (preview.changes.isEmpty && health.state.pending.isEmpty))
                        } else if !health.state.pending.isEmpty, !health.state.paused {
                            Button("health.retry") { Task { await health.send() } }.disabled(health.busy)
                        }
                        if health.busy { ProgressView() }
                    } footer: { Text("health.manual") }
                    if let error = health.error { Text(L(error)).font(.footnote).foregroundStyle(.secondary) }
                    if health.state.connectionID != nil {
                        Section {
                            if !health.state.paused { Button("health.pause") { Task { await health.pause() } }.disabled(health.busy && !health.sending) }
                            Button("health.clear", role: .destructive) { clearing = true }.disabled(health.busy)
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden).background(Color.canvas)
        .navigationTitle("health.open").navigationBarTitleDisplayMode(.inline)
        .task { await store.health?.load() }
        .confirmationDialog("health.clear", isPresented: $clearing, titleVisibility: .visible) {
            Button("health.clear", role: .destructive) { Task { await store.health?.clear() } }
        } message: { Text("health.clear.help") }
    }
}

private struct HealthPreviewView: View {
    let preview: HealthPreview
    var body: some View {
        List(preview.changes, id: \.object_id) { change in
            if change.operation == "delete" {
                Label("health.deleted", systemImage: "minus.circle").foregroundStyle(.secondary)
            } else if let payload = change.payload {
                let kind = payload["record_type"]?.string ?? ""
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(L("health.\(kind)")); Spacer()
                        if let value = payload["value"]?.number {
                            Text(kind == "steps" ? value.formatted(.number.precision(.fractionLength(0))) : Duration.seconds(value).formatted(.units(allowed: [.hours, .minutes], width: .abbreviated)))
                        }
                    }
                    if let start = payload["start"]?.number {
                        Text(Date(timeIntervalSince1970: start), format: .dateTime.month().day().hour().minute()).font(.subheadline).foregroundStyle(.secondary)
                    }
                    if let source = payload["source"]?.string { Text(source).font(.caption).foregroundStyle(.secondary) }
                }.padding(.vertical, 4)
            }
        }
        .scrollContentBackground(.hidden).background(Color.canvas)
        .navigationTitle("health.details").navigationBarTitleDisplayMode(.inline)
    }
}

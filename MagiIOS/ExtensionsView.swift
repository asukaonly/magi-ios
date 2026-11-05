import SwiftUI
import MagiCore

private func localizedName(_ name: String, _ translations: [String: String]?) -> String {
    Locale.preferredLanguages.first?.hasPrefix("zh") == true ? (translations?["zh-CN"] ?? name) : name
}

struct ExtensionsView: View {
    @Environment(AppStore.self) private var store
    @State private var entries: [Wire.PluginRegistryEntryResponse] = []
    @State private var installed: [Wire.PluginPackageResponse] = []
    @State private var query = ""
    @State private var loading = false
    @State private var failed = false
    @State private var showInstalled = false
    var body: some View {
        NavigationStack {
            List {
                Picker("tab.extensions", selection: $showInstalled) {
                    Text("extensions.market").tag(false); Text("extensions.installed").tag(true)
                }.pickerStyle(.segmented).listRowBackground(Color.clear).listRowSeparator(.hidden)
                if showInstalled {
                    ForEach(installed.filter { query.isEmpty || $0.manifest.name.localizedCaseInsensitiveContains(query) }, id: \.manifest.plugin_id) { package in
                        NavigationLink { ExtensionDetail(pluginID: package.manifest.plugin_id, initialPackage: package) } label: {
                            ExtensionRow(name: package.manifest.name, description: package.manifest.description, health: package.manifest.plugin_id == "apple-health", installed: true)
                        }.listRowBackground(Color.clear)
                    }
                } else {
                    ForEach(entries.filter { query.isEmpty || localizedName($0.name, $0.name_i18n).localizedCaseInsensitiveContains(query) }, id: \.plugin_id) { entry in
                        NavigationLink { ExtensionDetail(pluginID: entry.plugin_id, initialPackage: installed.first { $0.manifest.plugin_id == entry.plugin_id }) } label: {
                            ExtensionRow(name: localizedName(entry.name, entry.name_i18n), description: localizedName(entry.description ?? "", entry.description_i18n), health: entry.plugin_id == "apple-health", installed: entry.installed == true)
                        }.listRowBackground(Color.clear)
                    }
                }
                if loading { ProgressView().frame(maxWidth: .infinity).listRowBackground(Color.clear) }
                if failed { Button("action.retry") { Task { await load() } }.listRowBackground(Color.clear) }
                if !loading && !failed && (showInstalled ? installed.isEmpty : entries.isEmpty) {
                    ContentUnavailableView("extensions.empty", systemImage: "square.grid.2x2").listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain).scrollContentBackground(.hidden).background(Color.canvas)
            .navigationTitle("tab.extensions").navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: Text("extensions.search"))
            .task { await load() }.refreshable { await load() }
            .toolbar { AppToolbar() }
        }
    }
    private func load() async {
        guard let client = store.productClient else { return }
        loading = true; failed = false; defer { loading = false }
        do {
            async let registry = client.request(Wire.PluginRegistryResponse.self, path: "/plugins/registry")
            async let packages = client.request(Wire.PluginsListResponse.self, path: "/plugins")
            let result = try await (registry, packages); try Task.checkCancellation()
            entries = result.0.plugins ?? []; installed = result.1.plugins
        } catch { if !Task.isCancelled { failed = true } }
    }
}

private struct ExtensionRow: View {
    let name: String
    let description: String
    let health: Bool
    let installed: Bool
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: health ? "heart" : "square.grid.2x2").font(.title3.weight(.light)).frame(width: 46, height: 46)
                .background(Color.magi.opacity(0.05), in: RoundedRectangle(cornerRadius: 13))
            VStack(alignment: .leading, spacing: 5) {
                HStack { Text(name).font(.headline); if installed { Image(systemName: "checkmark").font(.caption).foregroundStyle(.secondary) } }
                Text(description).font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
            }.frame(maxWidth: .infinity, alignment: .leading)
        }.padding(.vertical, 14)
    }
}

struct ExtensionDetail: View {
    let pluginID: String
    let initialPackage: Wire.PluginPackageResponse?
    @Environment(AppStore.self) private var store
    @State private var package: Wire.PluginPackageResponse?
    @State private var plan: Wire.PluginInstallPlanResponse?
    @State private var showingPlan = false
    @State private var trusting = false
    @State private var busy = false
    @State private var installJob: Wire.PluginInstallJobSnapshot?
    @State private var failed = false
    @State private var connections: [Wire.PluginConnectionResponse] = []
    var body: some View {
        List {
            if let package {
                Section {
                    ExtensionRow(name: package.manifest.name, description: package.manifest.description, health: pluginID == "apple-health", installed: true)
                    if !package.trusted {
                        Button("extensions.authorize") { trusting = true }
                    } else if pluginID == "apple-health" {
                        NavigationLink("health.open") { HealthView(package: package) }.accessibilityIdentifier("health.open")
                    } else if !(package.manifest.device_collectors ?? []).isEmpty {
                        Text("extensions.appUpdate").font(.footnote).foregroundStyle(.secondary)
                    }
                }.listRowBackground(Color.clear)
                if !connections.isEmpty {
                    Section("extensions.connections") {
                        ForEach(connections, id: \.connection_id) { connection in
                            HStack { Text(connection.display_name); Spacer(); Text(connection.enabled == true ? "extensions.active" : "extensions.paused").foregroundStyle(.secondary) }
                        }
                    }
                }
                Section {
                    Button("extensions.checkUpdate") { Task { await reviewInstall(update: true) } }
                }.listRowBackground(Color.clear)
            } else if let plan {
                ForEach(plan.changes, id: \.entry.plugin_id) { change in
                    ExtensionRow(name: localizedName(change.entry.name, change.entry.name_i18n), description: localizedName(change.entry.description ?? "", change.entry.description_i18n), health: pluginID == "apple-health", installed: false)
                }.listRowBackground(Color.clear)
                Button("extensions.install") { showingPlan = true }.buttonStyle(.borderedProminent).listRowBackground(Color.clear)
            }
            if let job = installJob {
                if job.status == "failed" { Label("extensions.failed", systemImage: "exclamationmark.circle") }
                else if job.status != "completed" { ProgressView().accessibilityLabel(Text("extensions.installing")) }
            }
            if busy { ProgressView().frame(maxWidth: .infinity).listRowBackground(Color.clear) }
            if failed { Button("action.retry") { Task { await load() } } }
        }
        .scrollContentBackground(.hidden).background(Color.canvas)
        .navigationTitle(package?.manifest.name ?? "").navigationBarTitleDisplayMode(.inline)
        .task { package = initialPackage; await load() }
        .disabled(busy)
        .sheet(isPresented: $showingPlan) {
            NavigationStack {
                List {
                    if let plan {
                        ForEach(plan.changes, id: \.entry.plugin_id) { change in
                            Section(localizedName(change.entry.name, change.entry.name_i18n)) {
                                Text(change.entry.version).font(.footnote).foregroundStyle(.secondary)
                                if change.entry.execution_mode == "trusted_process" { Text("extensions.trustedCode").font(.footnote) }
                                ForEach(Array((change.entry.capabilities ?? []).enumerated()), id: \.offset) { _, access in
                                    Text(localizedName(access.reason ?? access.capability, access.reason_i18n))
                                }
                                ForEach(change.entry.device_collectors ?? [], id: \.capability_id) { collector in
                                    Label(collector.platforms.joined(separator: ", "), systemImage: "iphone")
                                }
                            }
                        }
                    }
                }
                .navigationTitle("extensions.review").navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("action.cancel") { showingPlan = false } }
                    ToolbarItem(placement: .confirmationAction) { Button("extensions.install") { showingPlan = false; Task { await install() } }.disabled(busy) }
                }
            }
        }
        .confirmationDialog("extensions.authorize", isPresented: $trusting, titleVisibility: .visible) {
            Button("extensions.authorize") { Task { await trust() } }
        } message: {
            Text("extensions.trustedCode")
        }
    }
    private func load() async {
        guard let client = store.productClient else { return }
        busy = true; failed = false; defer { busy = false }
        do {
            let packages = try await client.request(Wire.PluginsListResponse.self, path: "/plugins")
            package = packages.plugins.first { $0.manifest.plugin_id == pluginID }
            if package != nil {
                connections = try await client.request(Wire.PluginConnectionsResponse.self, path: "/plugins/\(ServerAddress.segment(pluginID))/connections", template: "/plugins/{plugin_id}/connections").connections
            } else { plan = try await makePlan(client, update: false) }
        } catch { failed = true; store.report(error) }
    }
    private func makePlan(_ client: MagiClient, update: Bool) async throws -> Wire.PluginInstallPlanResponse {
        try await client.request(Wire.PluginInstallPlanResponse.self, method: "POST", path: "/plugins/install/registry/plan", body: JSONValue.encode(Wire.PluginInstallPlanRequest(plugin_id: pluginID, update: update)))
    }
    private func reviewInstall(update: Bool) async {
        guard let client = store.productClient else { return }
        busy = true; defer { busy = false }
        do { plan = try await makePlan(client, update: update); showingPlan = true } catch { store.report(error) }
    }
    private func install() async {
        guard let client = store.productClient, let plan else { return }
        busy = true; defer { busy = false }
        do {
            let updating = plan.update
            let path = updating ? "/plugins/\(ServerAddress.segment(pluginID))/update/jobs" : "/plugins/install/registry/jobs"
            let body: JSONValue = updating ? .object(["plan_fingerprint": .string(plan.fingerprint)]) : try JSONValue.encode(Wire.PluginInstallRequest(plan_fingerprint: plan.fingerprint, plugin_id: pluginID))
            var job = try await client.request(Wire.PluginInstallJobSnapshot.self, method: "POST", path: path,
                template: updating ? "/plugins/{plugin_id}/update/jobs" : nil, body: body)
            installJob = job
            while !["completed", "failed"].contains(job.status) {
                try await Task.sleep(for: .seconds(1))
                job = try await client.request(Wire.PluginInstallJobSnapshot.self, path: "/plugins/install/jobs/\(ServerAddress.segment(job.job_id))", template: "/plugins/install/jobs/{job_id}")
                installJob = job
            }
            if job.status == "completed" { package = job.result; await load() }
        } catch { store.report(error); failed = true }
    }
    private func trust() async {
        guard let client = store.productClient, let current = package, let digest = current.package_sha256 else { return }
        busy = true; defer { busy = false }
        do {
            package = try await client.request(Wire.PluginPackageResponse.self, method: "POST", path: "/plugins/\(ServerAddress.segment(pluginID))/trust", template: "/plugins/{plugin_id}/trust", body: .object([
                "expected_package_sha256": .string(digest), "expected_capabilities": try JSONValue.encode(current.manifest.capabilities ?? []),
                "expected_execution_mode": .string(current.manifest.execution_mode),
            ]))
        } catch { store.report(error) }
    }
}

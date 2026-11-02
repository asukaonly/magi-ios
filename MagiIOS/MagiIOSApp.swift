import SwiftUI

@main
struct MagiIOSApp: App {
    @State private var store = AppStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .tint(.magi)
                .task {
                    #if DEBUG
                    if ProcessInfo.processInfo.arguments.contains("--uitesting-reset") { await store.disconnect() }
                    #endif
                    await store.bootstrap()
                }
                .onChange(of: scenePhase) { _, phase in
                    Task { await store.setForeground(phase == .active) }
                }
        }
    }
}

extension Color {
    static let magi = Color("AccentColor")
}

import SwiftUI

@main
struct MomentWatchApp: App {
    @StateObject private var store = LifeStore()
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            WatchCountdownView().environmentObject(store)
                .onChange(of: scenePhase) { _, phase in if phase == .active { store.synchronize() } }
        }
    }
}

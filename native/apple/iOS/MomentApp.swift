import SwiftUI

@main
struct MomentApp: App {
    @StateObject private var store = LifeStore()
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            CountdownView().environmentObject(store).preferredColorScheme(.light)
                .onChange(of: scenePhase) { _, phase in if phase == .active { store.synchronize() } }
        }
    }
}

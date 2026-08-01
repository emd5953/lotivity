import SwiftUI

@main
struct LotivityApp: App {
    @State private var state = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(state)
                .task { state.hydrate() }
        }
    }
}

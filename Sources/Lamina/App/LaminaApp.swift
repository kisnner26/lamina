import SwiftUI

@main
struct LaminaApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .frame(minWidth: 980, minHeight: 680)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1280, height: 820)
    }
}

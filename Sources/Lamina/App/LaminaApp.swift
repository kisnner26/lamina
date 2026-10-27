import SwiftUI

@main
struct LaminaApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Lamina")
                .frame(minWidth: 980, minHeight: 680)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1280, height: 820)
    }
}

import AppKit
import SwiftUI

/// Makes the app a regular, keyboard-focusable application even when launched
/// as a bare executable (`swift run`, Xcode without a bundle). Without this,
/// keystrokes keep going to the terminal and text fields cannot be typed into.
final class LaminaAppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate()
        NSApp.windows.first?.makeKeyAndOrderFront(nil)
    }
}

@main
struct LaminaApp: App {
    @NSApplicationDelegateAdaptor(LaminaAppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .frame(minWidth: 980, minHeight: 680)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1280, height: 820)
    }
}

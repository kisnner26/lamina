import Foundation
import Testing
import WebKit
@testable import Lamina

@MainActor
struct WebViewRenderTests {
    @Test func compiledDeckProducesVisibleWebContent() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let deck = DeckIR(
            version: 1,
            title: "render check",
            subtitle: nil,
            theme: "editorial-dark",
            slides: [DeckSlide(
                id: "slide-1",
                pattern: "hero",
                kicker: "proof",
                title: "visible title",
                body: "visible body",
                bullets: nil,
                factIDs: nil,
                media: nil,
                accent: "#FF4F2E",
                notes: nil
            )]
        )
        try DeckCompiler().compile(deck: deck, facts: [], in: directory)

        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 1280, height: 720))
        webView.loadFileURL(directory.appending(path: "index.html"), allowingReadAccessTo: directory)
        for _ in 0..<100 where webView.isLoading {
            try await Task.sleep(for: .milliseconds(25))
        }
        try await Task.sleep(for: .seconds(1))

        let text = try await webView.evaluateJavaScript("document.body.innerText") as? String
        let opacity = try await webView.evaluateJavaScript(
            "getComputedStyle(document.querySelector('.slide-copy')).opacity"
        ) as? String
        let width = try await webView.evaluateJavaScript(
            "document.querySelector('.slide-copy').getBoundingClientRect().width"
        ) as? Double

        #expect(text?.localizedCaseInsensitiveContains("visible title") == true)
        #expect(opacity == "1")
        #expect((width ?? 0) > 100)
    }
}

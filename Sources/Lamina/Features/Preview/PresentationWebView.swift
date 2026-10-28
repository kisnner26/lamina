import SwiftUI
import WebKit

struct PresentationWebView: NSViewRepresentable {
    let project: PresentationProject
    let isEditing: Bool
    let onAudit: ([Int]) -> Void
    let onEdit: (DeckEditMessage) -> Void

    func makeCoordinator() -> PresentationWebCoordinator {
        PresentationWebCoordinator(onAudit: onAudit, onEdit: onEdit)
    }

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.userContentController.add(context.coordinator.layoutHandler, name: "layoutAudit")
        configuration.userContentController.add(context.coordinator.editorHandler, name: "deckEditor")
        configuration.userContentController.addUserScript(WKUserScript(
            source: LayoutAuditScript.source,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        ))
        configuration.userContentController.addUserScript(WKUserScript(
            source: DeckEditorScript.source,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        ))
        let webView = WKWebView(frame: .zero, configuration: configuration)
        context.coordinator.isEditing = isEditing
        webView.navigationDelegate = context.coordinator
        webView.setValue(false, forKey: "drawsBackground")
        load(project, in: webView)
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        context.coordinator.isEditing = isEditing
        context.coordinator.applyEditing(to: webView)
        if webView.url != project.indexURL { load(project, in: webView) }
    }

    private func load(_ project: PresentationProject, in webView: WKWebView) {
        webView.loadFileURL(project.indexURL, allowingReadAccessTo: project.directory)
    }
}

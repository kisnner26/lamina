import Foundation
import WebKit

@MainActor
final class PresentationWebCoordinator: NSObject, WKNavigationDelegate {
    let layoutHandler: LayoutAuditMessageHandler
    let editorHandler: DeckEditorMessageHandler
    var isEditing = false
    var loadedRevision: UUID?

    init(onAudit: @escaping ([Int]) -> Void, onEdit: @escaping (DeckEditMessage) -> Void) {
        layoutHandler = LayoutAuditMessageHandler(onAudit: onAudit)
        editorHandler = DeckEditorMessageHandler(onEdit: onEdit)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation?) {
        applyEditing(to: webView)
    }

    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation?,
        withError error: any Error
    ) {
        loadedRevision = nil
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation?,
        withError error: any Error
    ) {
        loadedRevision = nil
    }

    func applyEditing(to webView: WKWebView) {
        webView.evaluateJavaScript("window.LaminaEditor?.setEnabled(\(isEditing ? "true" : "false"))")
    }
}

import Foundation
import WebKit

@MainActor
final class PresentationWebCoordinator: NSObject, WKNavigationDelegate {
    let layoutHandler: LayoutAuditMessageHandler
    let editorHandler: DeckEditorMessageHandler
    var isEditing = false

    init(onAudit: @escaping ([Int]) -> Void, onEdit: @escaping (DeckEditMessage) -> Void) {
        layoutHandler = LayoutAuditMessageHandler(onAudit: onAudit)
        editorHandler = DeckEditorMessageHandler(onEdit: onEdit)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation?) {
        applyEditing(to: webView)
    }

    func applyEditing(to webView: WKWebView) {
        webView.evaluateJavaScript("window.LaminaEditor?.setEnabled(\(isEditing ? "true" : "false"))")
    }
}

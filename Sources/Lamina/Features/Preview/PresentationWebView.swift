import SwiftUI
import WebKit

struct PresentationWebView: NSViewRepresentable {
    let project: PresentationProject
    let onAudit: ([Int]) -> Void

    func makeCoordinator() -> LayoutAuditMessageHandler {
        LayoutAuditMessageHandler(onAudit: onAudit)
    }

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.userContentController.add(context.coordinator, name: "layoutAudit")
        configuration.userContentController.addUserScript(WKUserScript(
            source: LayoutAuditScript.source,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        ))
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.setValue(false, forKey: "drawsBackground")
        load(project, in: webView)
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        guard webView.url != project.indexURL else { return }
        load(project, in: webView)
    }

    private func load(_ project: PresentationProject, in webView: WKWebView) {
        webView.loadFileURL(project.indexURL, allowingReadAccessTo: project.directory)
    }
}

import Foundation
import WebKit

@MainActor
final class LayoutAuditMessageHandler: NSObject, WKScriptMessageHandler {
    private let onAudit: ([Int]) -> Void

    init(onAudit: @escaping ([Int]) -> Void) {
        self.onAudit = onAudit
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard let slides = message.body as? [Int] else { return }
        onAudit(slides)
    }
}

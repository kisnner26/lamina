import Foundation
import WebKit

@MainActor
final class DeckEditorMessageHandler: NSObject, WKScriptMessageHandler {
    private let onEdit: (DeckEditMessage) -> Void

    init(onEdit: @escaping (DeckEditMessage) -> Void) {
        self.onEdit = onEdit
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard let body = message.body as? [String: Any],
              let slide = body["slide"] as? Int,
              let field = body["field"] as? String else { return }
        onEdit(DeckEditMessage(
            slide: slide,
            field: field,
            value: body["value"] as? String,
            x: body["x"] as? Double,
            y: body["y"] as? Double,
            scale: body["scale"] as? Double,
            rotation: body["rotation"] as? Double
        ))
    }
}

import Foundation

enum LayoutAuditScript {
    static let source = """
    (() => {
      const audit = () => {
        const broken = [...document.querySelectorAll('.slide')].flatMap((slide, index) => {
          const bounds = slide.getBoundingClientRect();
          const text = [...slide.querySelectorAll('h2,.body-copy,.bullet-list,.facts')];
          const overflow = text.some(node => node.scrollWidth > node.clientWidth + 2 || node.scrollHeight > node.clientHeight + 2);
          const outside = text.some(node => {
            const rect = node.getBoundingClientRect();
            return rect.left < bounds.left - 2 || rect.right > bounds.right + 2 || rect.top < bounds.top - 2 || rect.bottom > bounds.bottom + 2;
          });
          return overflow || outside ? [index] : [];
        });
        window.webkit?.messageHandlers?.layoutAudit?.postMessage(broken);
      };
      addEventListener('load', () => requestAnimationFrame(() => requestAnimationFrame(audit)));
      addEventListener('resize', audit);
    })();
    """
}

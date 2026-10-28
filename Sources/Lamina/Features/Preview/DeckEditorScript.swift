import Foundation

enum DeckEditorScript {
    static let source = """
    (() => {
      let enabled = false;
      let drag = null;
      const post = payload => window.webkit?.messageHandlers?.deckEditor?.postMessage(payload);
      const editable = () => [...document.querySelectorAll('[data-edit-field]')];
      const setEnabled = value => {
        enabled = value;
        document.body.classList.toggle('editor-on', enabled);
        editable().forEach(node => node.contentEditable = enabled ? 'true' : 'false');
      };
      document.addEventListener('blur', event => {
        if (!enabled || !event.target.dataset?.editField) return;
        const slide = Number(event.target.closest('.slide')?.dataset.slide || 0);
        post({slide, field:event.target.dataset.editField, value:event.target.innerText});
      }, true);
      document.addEventListener('pointerdown', event => {
        const visual = event.target.closest('.slide-visual');
        if (!enabled || !visual) return;
        event.preventDefault();
        const slide = visual.closest('.slide');
        drag = {visual, slide:Number(slide.dataset.slide || 0), startX:event.clientX, startY:event.clientY, x:Number(visual.dataset.x || 0), y:Number(visual.dataset.y || 0), scale:Number(visual.dataset.scale || 1)};
        visual.setPointerCapture(event.pointerId);
      }, true);
      document.addEventListener('pointermove', event => {
        if (!drag) return;
        drag.x += ((event.clientX - drag.startX) / innerWidth) * 100;
        drag.y += ((event.clientY - drag.startY) / innerHeight) * 100;
        drag.startX = event.clientX; drag.startY = event.clientY;
        drag.visual.dataset.x = drag.x; drag.visual.dataset.y = drag.y;
        drag.visual.style.transform = `translate(${drag.x}%,${drag.y}%) scale(${drag.scale})`;
      }, true);
      document.addEventListener('pointerup', () => {
        if (!drag) return;
        post({slide:drag.slide, field:'layout', x:drag.x, y:drag.y, scale:drag.scale, rotation:0});
        drag = null;
      }, true);
      document.addEventListener('wheel', event => {
        const visual = event.target.closest('.slide-visual');
        if (!enabled || !visual) return;
        event.preventDefault(); event.stopImmediatePropagation();
        const scale = Math.max(.35, Math.min(2.4, Number(visual.dataset.scale || 1) - event.deltaY * .001));
        visual.dataset.scale = scale;
        const x = Number(visual.dataset.x || 0), y = Number(visual.dataset.y || 0);
        visual.style.transform = `translate(${x}%,${y}%) scale(${scale})`;
        post({slide:Number(visual.closest('.slide').dataset.slide || 0), field:'layout', x, y, scale, rotation:0});
      }, {capture:true, passive:false});
      window.LaminaEditor = {setEnabled};
    })();
    """
}

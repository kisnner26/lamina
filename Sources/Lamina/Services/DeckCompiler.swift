import Foundation

struct DeckCompiler: Sendable {
    private let slideCompiler = IncrementalSlideCompiler()
    private let themeLibrary = ThemeLibrary()

    func compile(deck: DeckIR, facts: [FactRecord], in directory: URL) throws {
        let theme = try themeLibrary.theme(id: deck.theme)
        let slides = try slideCompiler.compile(slides: deck.slides, facts: facts, in: directory)
        try indexHTML(deck: deck, slides: slides).write(
            to: directory.appending(path: "index.html"),
            atomically: true,
            encoding: .utf8
        )
        try stylesCSS(theme: theme).write(
            to: directory.appending(path: "styles.css"),
            atomically: true,
            encoding: .utf8
        )
        try appJavaScript.write(
            to: directory.appending(path: "app.js"),
            atomically: true,
            encoding: .utf8
        )
    }

    private func indexHTML(deck: DeckIR, slides: [String]) -> String {
        """
        <!doctype html>
        <html lang="en">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width,initial-scale=1">
          <title>\(escape(deck.title))</title>
          <link rel="stylesheet" href="styles.css">
        </head>
        <body>
          <main class="deck-shell" aria-label="\(escape(deck.title))">
            <div class="deck-track">\(slides.joined(separator: "\n"))</div>
          </main>
          <nav class="deck-controls" aria-label="presentation controls">
            <button id="previous" type="button" aria-label="previous slide">←</button>
            <div class="progress"><i></i></div>
            <span id="counter">01 / \(padded(deck.slides.count))</span>
            <button id="next" type="button" aria-label="next slide">→</button>
            <button id="fullscreen" type="button" aria-label="toggle fullscreen">⛶</button>
          </nav>
          <script src="app.js"></script>
        </body>
        </html>
        """
    }

    private func stylesCSS(theme: ThemeDefinition) -> String {
        """
        :root{--bg:\(theme.background);--surface:\(theme.surface);--fg:\(theme.foreground);--muted:\(theme.muted);--accent:\(theme.accent);--display:\(theme.displayFont);--body:\(theme.bodyFont);color-scheme:dark}
        *{box-sizing:border-box}html,body{margin:0;width:100%;height:100%;overflow:hidden;background:var(--bg);color:var(--fg);font-family:var(--body)}button{font:inherit;color:inherit}
        .deck-shell{width:100vw;height:100vh;overflow:hidden}.deck-track{display:flex;width:max-content;height:100%;transition:transform .75s cubic-bezier(.77,0,.18,1);will-change:transform}
        .slide{--slide-accent:var(--accent);position:relative;display:grid;grid-template-columns:minmax(0,1.02fr) minmax(320px,.98fr);gap:clamp(28px,6vw,110px);align-items:center;width:100vw;height:100vh;padding:clamp(54px,7vw,128px);overflow:hidden;isolation:isolate}
        .slide::before{content:"";position:absolute;inset:0;background:linear-gradient(125deg,color-mix(in srgb,var(--slide-accent) 9%,transparent),transparent 42%);z-index:-2}.slide::after{content:"";position:absolute;width:42vw;aspect-ratio:1;border:1px solid color-mix(in srgb,var(--fg) 12%,transparent);border-radius:50%;right:-18vw;top:-22vw;z-index:-1}
        .slide-copy{max-width:880px;z-index:2}.kicker,.slide-index{font:700 clamp(11px,1vw,15px)/1 var(--body);letter-spacing:.16em;text-transform:uppercase;color:var(--slide-accent)}
        h2{margin:.15em 0 .32em;font-family:var(--display);font-size:clamp(54px,7.6vw,146px);font-weight:800;line-height:.84;letter-spacing:-.045em;text-wrap:balance;text-transform:uppercase}.body-copy{max-width:720px;margin:0;font-size:clamp(18px,1.65vw,31px);line-height:1.32;color:color-mix(in srgb,var(--fg) 84%,var(--muted));text-wrap:pretty}
        .slide-index{position:absolute;top:32px;right:40px;color:var(--muted)}.slide-visual{position:relative;display:grid;place-items:center;min-width:0;height:min(62vh,680px)}
        .bullet-list{display:grid;gap:10px;margin:28px 0 0;padding:0;list-style:none}.bullet-list li{display:grid;grid-template-columns:38px 1fr;gap:14px;align-items:start;padding:12px 0;border-top:1px solid color-mix(in srgb,var(--fg) 16%,transparent);font-size:clamp(16px,1.25vw,23px)}.bullet-list span{font:700 12px var(--body);color:var(--slide-accent)}
        .facts{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:12px;margin-top:24px}.facts blockquote{margin:0;padding:18px;border-left:3px solid var(--slide-accent);background:color-mix(in srgb,var(--surface) 76%,transparent);font-size:clamp(14px,1vw,19px);line-height:1.35}.facts small{display:block;margin-bottom:8px;color:var(--slide-accent);letter-spacing:.14em}.fact-refs{margin:24px 0 0;font:700 10px var(--body);letter-spacing:.15em;text-transform:uppercase;color:var(--muted)}
        .media-stack{position:absolute;inset:2%;z-index:1}.media-frame{position:absolute;inset:0;margin:0;border-radius:48% 52% 42% 58%;overflow:hidden;filter:saturate(1.15) contrast(1.05);box-shadow:0 36px 90px #0007}.media-frame img{width:100%;height:100%;object-fit:contain}.media-count-2 .media-frame{width:62%;height:78%;top:8%}.media-count-2 .media-frame:first-child{left:0;right:auto;transform:rotate(-5deg)}.media-count-2 .media-frame:last-child{left:auto;right:0;top:20%;transform:rotate(5deg)}.media-count-3 .media-frame{width:52%;height:62%}.media-count-3 .media-frame:nth-child(2){left:42%;top:8%}.media-count-3 .media-frame:nth-child(3){left:22%;top:42%}.speaker-notes{display:none}
        .hero-mark{position:relative;width:min(34vw,500px);aspect-ratio:1}.hero-mark i{position:absolute;inset:4%;border:2px solid var(--slide-accent);border-radius:42% 58% 68% 32%;animation:orbit 14s linear infinite}.hero-mark i:nth-child(2){inset:18%;border-color:color-mix(in srgb,var(--fg) 35%,transparent);animation-direction:reverse}.hero-mark b{position:absolute;inset:0;display:grid;place-items:center;font:800 clamp(130px,18vw,300px)/1 var(--display);color:var(--slide-accent)}
        .compare-shapes{display:grid;grid-template-columns:1fr auto 1fr;align-items:center;width:100%;gap:18px}.compare-shapes i{display:grid;place-items:center;aspect-ratio:1;border-radius:50% 8% 50% 8%;background:var(--slide-accent);font:800 clamp(70px,10vw,180px) var(--display);color:var(--bg);box-shadow:28px 28px 0 color-mix(in srgb,var(--fg) 10%,transparent)}.compare-shapes i:last-child{border-radius:8% 50% 8% 50%;background:var(--fg)}.compare-shapes b{font:800 22px var(--display);writing-mode:vertical-rl}
        .sequence-line{display:flex;align-items:center;width:100%;height:100%}.sequence-line::before{content:"";position:absolute;left:5%;right:5%;height:3px;background:linear-gradient(90deg,var(--slide-accent),var(--fg))}.sequence-line i{position:relative;flex:1;aspect-ratio:1;max-width:120px;margin:auto;border:3px solid var(--slide-accent);background:var(--surface);transform:rotate(45deg)}.sequence-line i:nth-child(even){border-radius:50%;transform:none}
        .inventory-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:clamp(12px,2vw,28px);width:100%}.inventory-grid i{aspect-ratio:1;background:color-mix(in srgb,var(--slide-accent) 18%,var(--surface));border:1px solid color-mix(in srgb,var(--slide-accent) 55%,transparent);clip-path:polygon(12% 0,100% 16%,84% 100%,0 82%)}.inventory-grid i:nth-child(2n){border-radius:50%;clip-path:none;transform:translateY(22px)}
        .timeline-track{display:grid;grid-template-columns:repeat(4,1fr);align-items:center;width:100%;position:relative}.timeline-track::before{content:"";position:absolute;left:0;right:0;height:2px;background:var(--muted)}.timeline-track i{position:relative;justify-self:center;width:clamp(48px,6vw,96px);aspect-ratio:1;border-radius:50%;background:var(--surface);border:8px solid var(--slide-accent);box-shadow:0 0 0 12px var(--bg)}.timeline-track i:nth-child(even){transform:translateY(-90px)}.timeline-track i:nth-child(odd){transform:translateY(90px)}
        .concept-svg{width:100%;height:100%;overflow:visible}.concept-svg path{fill:none;stroke:var(--muted);stroke-width:3;stroke-dasharray:8 10}.concept-svg circle{fill:var(--surface);stroke:var(--slide-accent);stroke-width:6}.concept-svg circle:first-child{fill:var(--slide-accent)}
        .evidence-orbit{width:min(34vw,500px);aspect-ratio:1;border:2px solid var(--muted);border-radius:50%;display:grid;place-items:center}.evidence-orbit::before,.evidence-orbit i{content:"";position:absolute;width:74%;aspect-ratio:1;border:1px solid var(--slide-accent);transform:rotate(35deg)}.evidence-orbit i{width:46%;border-radius:50%;transform:none}.evidence-orbit b{font:800 clamp(130px,17vw,290px) var(--display);color:var(--slide-accent)}
        .matrix-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:8px;width:min(34vw,520px);transform:rotate(-5deg)}.matrix-grid i{aspect-ratio:1;background:var(--surface);border:1px solid color-mix(in srgb,var(--fg) 12%,transparent)}.matrix-grid i:nth-child(3n+2),.matrix-grid i:nth-child(7){background:var(--slide-accent)}
        .closing-mark{display:grid;place-items:center;width:min(32vw,470px);aspect-ratio:1;border-radius:50%;background:var(--slide-accent);color:var(--bg);font:800 clamp(140px,18vw,300px)/1 var(--display);transform:rotate(-12deg)}
        .pattern-evidence-focus{grid-template-columns:.85fr 1.15fr}.pattern-evidence-focus h2{font-size:clamp(48px,6vw,112px)}.pattern-closing{grid-template-columns:1.2fr .8fr}.pattern-closing h2{font-size:clamp(64px,9vw,170px)}
        .deck-controls{position:fixed;z-index:20;left:50%;bottom:22px;transform:translateX(-50%);display:flex;align-items:center;gap:10px;padding:8px;border:1px solid color-mix(in srgb,var(--fg) 12%,transparent);border-radius:999px;background:color-mix(in srgb,var(--bg) 78%,transparent);backdrop-filter:blur(18px)}.deck-controls button{width:38px;height:38px;border:0;border-radius:50%;background:transparent;cursor:pointer}.deck-controls button:hover,.deck-controls button:focus-visible{background:var(--slide-accent);color:var(--bg);outline:none}.progress{width:110px;height:3px;background:color-mix(in srgb,var(--fg) 15%,transparent)}.progress i{display:block;width:0;height:100%;background:var(--slide-accent);transition:width .5s ease}#counter{min-width:68px;text-align:center;font:700 11px var(--body);letter-spacing:.1em;color:var(--muted)}
        .slide.is-active .slide-copy{animation:enter-copy .7s .18s both}.slide.is-active .slide-visual{animation:enter-visual .9s .1s both}
        @keyframes enter-copy{from{opacity:0;transform:translateY(34px)}to{opacity:1;transform:none}}@keyframes enter-visual{from{opacity:0;transform:scale(.88) rotate(3deg)}to{opacity:1;transform:none}}@keyframes orbit{to{transform:rotate(360deg)}}
        @media(max-width:850px){.slide{grid-template-columns:1fr;grid-template-rows:auto minmax(180px,36vh);gap:18px;padding:64px 26px 84px}.slide-copy{align-self:end}h2{font-size:clamp(46px,13vw,92px)}.body-copy{font-size:17px}.slide-visual{height:100%}.facts{grid-template-columns:1fr}.bullet-list{margin-top:16px}.slide-index{top:20px;right:24px}.deck-controls{bottom:12px}.progress{width:64px}}
        @media(prefers-reduced-motion:reduce){*,*::before,*::after{animation-duration:.01ms!important;animation-iteration-count:1!important;transition-duration:.01ms!important;scroll-behavior:auto!important}}
        """
    }

    private var appJavaScript: String {
        """
        (() => {
          const track = document.querySelector('.deck-track');
          const slides = [...document.querySelectorAll('.slide')];
          const progress = document.querySelector('.progress i');
          const counter = document.querySelector('#counter');
          let current = 0;
          let locked = false;
          const pad = value => String(value).padStart(2, '0');
          const show = index => {
            current = Math.max(0, Math.min(slides.length - 1, index));
            track.style.transform = `translate3d(${-current * 100}vw,0,0)`;
            slides.forEach((slide, i) => slide.classList.toggle('is-active', i === current));
            progress.style.width = `${((current + 1) / slides.length) * 100}%`;
            counter.textContent = `${pad(current + 1)} / ${pad(slides.length)}`;
          };
          const step = delta => show(current + delta);
          document.querySelector('#previous').addEventListener('click', () => step(-1));
          document.querySelector('#next').addEventListener('click', () => step(1));
          document.querySelector('#fullscreen').addEventListener('click', () => document.fullscreenElement ? document.exitFullscreen() : document.documentElement.requestFullscreen());
          addEventListener('keydown', event => {
            if (['ArrowRight','ArrowDown','PageDown',' '].includes(event.key)) step(1);
            if (['ArrowLeft','ArrowUp','PageUp'].includes(event.key)) step(-1);
            if (event.key === 'Home') show(0);
            if (event.key === 'End') show(slides.length - 1);
          });
          addEventListener('wheel', event => {
            if (locked || Math.abs(event.deltaX) + Math.abs(event.deltaY) < 18) return;
            locked = true;
            step((Math.abs(event.deltaX) > Math.abs(event.deltaY) ? event.deltaX : event.deltaY) > 0 ? 1 : -1);
            setTimeout(() => locked = false, 650);
          }, {passive:true});
          show(0);
        })();
        """
    }

    private func escape(_ value: String) -> String {
        value.replacing("&", with: "&amp;").replacing("<", with: "&lt;").replacing("\"", with: "&quot;")
    }

    private func padded(_ value: Int) -> String { value < 10 ? "0\(value)" : "\(value)" }
}

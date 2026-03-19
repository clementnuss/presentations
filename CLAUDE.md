# Presentations Repository

Slidev-based technical presentations by Clément Nussbaumer.

## Repository Structure

- `template/` — base template for new talks (copy to start)
- `2024/`, `2025/`, `2026/` — talks organized by year
- Each talk: `slides.md`, `package.json`, `outline.txt`, `images/`, `drawings/`, `components/`

## Slide Authoring Conventions

### Layout & Styling
- Use `layout: default` for most slides
- Grid layouts: `grid-cols-2`, `grid-cols-3`, `grid-cols-5` with `gap-6` or `gap-8`
- Cards: `bg-white bg-opacity-80 rounded-lg p-5 border border-gray-200 shadow-md`
- Info callouts: `p-3 bg-orange-100 bg-opacity-80 border-l-4 border-orange-500 rounded`
- Progressive reveals with `v-click`
- Speaker notes in `<!-- -->` HTML comments
- Footnotes with `[^ref]` for citations/links

### Important: `mdc: true` breaks footnotes
The MDC plugin conflicts with `markdown-it-footnote`. Do not enable `mdc: true` in frontmatter.

### Important: `backdrop-filter` breaks PDF export
Never use `backdrop-filter backdrop-blur-md` — Playwright/Chromium clips or misrenders these elements during PDF export. Use solid `bg-opacity-80` backgrounds instead.

### PDF Export
Use `--per-slide --wait 1000` flags for reliable export (async Excalidraw components need time to render):
```json
"export": "slidev export --per-slide --timeout 10000 --wait 1000"
```

### Markdown inside HTML blocks
Markdown (`**bold**`, `[links](url)`) works inside `<div>` blocks only if there's a blank line after the opening tag. For inline HTML elements (`<div class="...">text</div>` on one line), use `<strong>` instead of `**`.

## Diagrams

### Excalidraw (static diagrams)
- Store `.excalidraw` files in `drawings/`
- Render with `<Excalidraw drawFilePath="./drawings/name.excalidraw" />`
- Wrap in a scaled container: `<div style="transform: scale(0.7); transform-origin: top center;">`
- The `Excalidraw.vue` component in `components/` converts to SVG at runtime via `exportToSvg`

### Interactive Visualizations (Ciechanowski-style)
For concepts that benefit from interactivity, build self-contained Vue 3 + inline SVG components. Prefer these over static Excalidraw when the audience should explore the data.

**Approach:**
- Pure Vue 3 + inline SVG in `components/` — no D3, no Canvas, no extra deps
- `computed` for reactive positions/connections, `watch` for state resets
- Sliders, toggles, click/hover interactions, live counters
- Smooth CSS transitions (0.6s ease on SVG attributes via inline `style`)
- Color-code elements by identity (HSL hue from index) to show reordering
- Theme colors inline (keep component self-contained)

**Reference implementations:**
- `2026/03-kubecon-eu-banking-on-reliability/components/HashRing.vue` — consistent hash ring with node count/neighbor sliders, O(n²) toggle, hash/linear order animation
- `2026/03-kubecon-eu-banking-on-reliability/components/RaceCondition502.vue` — animated sequence diagram with play/pause, scrubber, speed control, packet animations

**Pattern for animated sequence diagrams:**
- Define event timestamps as constants
- `packetProgress()` helper for interpolating packet positions
- `timeToY()` to map simulation time to vertical position
- `requestAnimationFrame` loop with speed multiplier
- Scrub bar for manual timeline control

## Social Links Row (conclusion slides)
```html
<a href="https://clement.n8r.ch/en/articles/" style="font-size: 1.1rem; color: #1a1a2e;" target="_blank">clement.n8r.ch</a>
<img src="./images/Jura.png" width="20rem" alt="Jura flag">
<a href="https://www.linkedin.com/in/clement-j-m-nussbaumer/" target="_blank" style="color: #1a1a2e;" class="text-xl icon-btn opacity-100 !border-none"><carbon-logo-linkedin /></a>
<a href="https://github.com/clementnuss" target="_blank" style="color: #1a1a2e;" class="text-xl icon-btn opacity-100 !border-none"><carbon-logo-github /></a>
```

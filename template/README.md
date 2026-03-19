# Presentation Template

## Quick Start

1. Copy this template folder to `YYYY/MM-event-name/`
2. Update title, author, theme in `slides.md` frontmatter
3. Install dependencies: `pnpm install`
4. Start development: `pnpm dev`
5. Export to PDF: `pnpm export`

## Structure

- `slides.md` — main presentation content
- `images/` — image assets (memes, screenshots, logos)
- `drawings/` — Excalidraw `.excalidraw` diagram files
- `components/` — Vue components (Excalidraw renderer, interactive visualizations)
- `setup/` — Slidev configuration (shiki, etc.)

## Slide Patterns

The template includes example slides for common patterns:

- **Outline** — 2x2 grid of cards
- **Content + Excalidraw** — text left, diagram right
- **Cards** — 2-column cards with icons
- **Key Takeaways** — 2x2 grid summary
- **Conclusion** — resources + QR code + social links

## Interactive Visualizations

For concepts that benefit from interactivity (hash rings, race conditions, timelines), create self-contained Vue 3 + SVG components in `components/`. See `CLAUDE.md` at the repo root for the full pattern.

## PDF Export

Uses `--per-slide --wait 1000` to ensure async Excalidraw components render before capture. Avoid `backdrop-filter` CSS as it breaks Playwright export.

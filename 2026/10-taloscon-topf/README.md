# TOPF — Container Days 2026, Hamburg

**Event:** Container Days, Hamburg — September 2026
**Speakers:** Clément Nussbaumer & Sebastian Stephan (both PostFinance)
**Talk:** TOPF — Open-Sourcing PostFinance's Tool to Migrate and Manage Talos Linux Clusters

Adapted from `2026/06-cloudnative-zurich-topf`.

## Development

```bash
npm install
npm run dev      # http://localhost:3030
npm run export   # PDF -> topf-container-days-hamburg-2026.pdf
npm run build    # static site -> dist/
```

## Structure

- `slides.md` — main presentation content
- `outline.txt` — working outline
- `theme/` — vendored Slidev theme (primary `#795649`)
- `images/` — image assets (git LFS)
- `drawings/` — Excalidraw diagrams
- `demo/` — TOPF demo config (layered patches, `topf.yaml`)
- `components/` — Vue components (Excalidraw renderer)
- `setup/` — Slidev configuration (shiki)

## Conventions

See `CLAUDE.md` at the repo root: no `mdc: true` (breaks footnotes), no
`backdrop-filter` (breaks PDF export), export with `--per-slide --wait 1000`.

## Adaptation TODO

- [ ] Confirm title, abstract and slot length with the Container Days CfP entry
- [ ] Split sections between the two speakers, mark hand-overs in speaker notes
- [ ] Add Sebastian's role to the intro speaker notes
- [ ] Add a ContainerDays logo if one is wanted on the title/closing slides
- [ ] Rework speaker notes written in first-person singular for a two-person delivery
- [ ] Refresh anything that changed since June 2026 (TOPF features, migration status)

---
title: 'SignalsAPI Docs — DESIGN.md'
status: final
created: '2026-08-01'
updated: '2026-08-01'
project: docs
scope: 'Visual identity contract for a Jekyll + just-the-docs static documentation site. Freeze, do not extend.'
sources:
  - '_bmad-output/planning-artifacts/prds/prd-docs-2026-08-01/prd.md'
  - '_bmad-output/planning-artifacts/briefs/brief-docs-2026-08-01/brief.md'
  - '_bmad-output/project-context.md'
  - '_sass/color_schemes/signalsapi.scss'
  - '_sass/custom/custom.scss'
  - '_includes/head_custom.html'

colors:
  bg: '#06070a'
  bg-el: '#0c0d11'
  bg-card: '#101218'
  bg-card-h: '#151720'
  bg-sf: '#0a0b0e'
  border: '#1c1e28'
  border-light: '#272a36'
  text: '#e8e8f0'
  text-muted: '#9192a6'
  text-faint: '#7c7d92'
  accent: '#00e87b'
  violet: '#7c6cf0'
  amber: '#f0a030'
  rose: '#e84090'

typography:
  body: "'DM Sans', system-ui, -apple-system, sans-serif"
  mono: "'JetBrains Mono', monospace"
  body-line-height: 1.6
  content-line-height: 1.6
  weights: [400, 500, 600, 700, 800]

rounded:
  sm: '3px'
  md: '5px'
  lg: '8px'
  xl: '10px'

spacing:
  unit: '{theme.spacing}'
  note: 'just-the-docs spacers only. No custom spacing scale is defined and none may be added.'

components:
  - callout
  - code-block
  - table
  - nav-list
  - search-input
  - button-primary
  - breadcrumb
  - footer
---

# DESIGN.md — SignalsAPI Documentation Site

This document is a **freeze contract**, not a design exploration. The site already
has a visual identity. It is dark, high-contrast, monospace-inflected, and it
matches the app. The overhaul described in the PRD changes *what the pages say
and how they are structured* — it does not change how they look.

Every token above is transcribed from files already in this repository. Nothing
here is invented. The rule for the whole overhaul is: **no new token, no new
component, no new CSS framework.** If a page needs a visual affordance that is
not listed under Components, the page is wrong, not the design system.

The customization surface is exactly three files:

| File | Owns |
|---|---|
| `_sass/color_schemes/signalsapi.scss` | The color scheme and font-family variables. Source of truth for the `colors` and `typography` tokens above. |
| `_sass/custom/custom.scss` | Component overrides layered on just-the-docs. 611 lines. |
| `_includes/head_custom.html` | Favicon (inline SVG data URI, accent-filled) and the Google Fonts link for DM Sans + JetBrains Mono. |

There is no fourth file. Adding one is out of scope.

## Brand & Style

Terminal-adjacent. The product is an API that watches the labour market; the
docs should read like something a developer would trust with a cron job, not
like a marketing microsite. Concretely:

- **Dark by default and only.** There is no light scheme and none is planned.
  `_config.yml` pins `color_scheme: signalsapi`.
- **Accent is signal, not decoration.** `{colors.accent}` (`#00e87b`) marks links,
  the active nav item, the primary button, and search hit highlighting. It never
  fills a large surface and never appears as body text.
- **Monospace carries evidence.** Anything a reader could paste into a terminal
  or an editor — endpoints, field names, front-matter keys, file paths, JSON —
  renders in `{typography.mono}`. Prose never does.
- **The tone the visuals must support** is stated in EXPERIENCE.md § Voice and
  Tone: factual, dated, sourced. A page that shows a number must show where the
  number came from. The visual system supports this with the callout component
  and the field table — not with badges, ribbons, or hero art.

**Anti-pattern, called out because the current site does it:** `index.md` is 325
words of pitch closing on *"Which side do you want to be on in 12 months?"* and a
booking CTA. That is brochure styling on a docs domain. The visual identity does
not change; the *page* becomes a router (EXPERIENCE.md § Information
Architecture). No new visual component is needed to fix it.

## Colors

Transcribed from `_sass/color_schemes/signalsapi.scss`. The just-the-docs greys
are remapped onto these, which is why the theme's own components inherit the
scheme without per-component overrides.

| Token | Hex | Used for |
|---|---|---|
| `{colors.bg}` | `#06070a` | Page background |
| `{colors.bg-el}` | `#0c0d11` | Sidebar, table background |
| `{colors.bg-card}` | `#101218` | Code blocks, search field |
| `{colors.bg-card-h}` | `#151720` | Card hover |
| `{colors.bg-sf}` | `#0a0b0e` | Recessed surface |
| `{colors.border}` | `#1c1e28` | Default rule and border |
| `{colors.border-light}` | `#272a36` | Emphasized border |
| `{colors.text}` | `#e8e8f0` | Body and heading text |
| `{colors.text-muted}` | `#9192a6` | Nav children, search previews |
| `{colors.text-faint}` | `#7c7d92` | De-emphasized metadata |
| `{colors.accent}` | `#00e87b` | Links, primary button, active nav, search highlight |
| `{colors.violet}` | `#7c6cf0` | Reserved secondary |
| `{colors.amber}` | `#f0a030` | Warning callout |
| `{colors.rose}` | `#e84090` | Error / danger callout |

**Semantic assignment for the new callout component** (the only new use of an
existing token this overhaul introduces):

| Callout kind | Border / label color |
|---|---|
| `note` | `{colors.text-muted}` |
| `tip` | `{colors.accent}` |
| `warning` | `{colors.amber}` |
| `danger` | `{colors.rose}` |

### Assertion

`script/check.rb` asserts the palette has not drifted:

- `_sass/color_schemes/signalsapi.scss` still defines all fourteen variables above
  with exactly these hex values. A changed hex fails the build until this document
  is changed in the same commit.
- The `{colors.text}` on `{colors.bg}` pair computes to a WCAG contrast ratio at or
  above 4.5:1, calculated in plain Ruby from the two hex constants read out of the
  scss file. This is the site's entire automated contrast story and it is
  deliberate: pa11y-ci and axe are rejected (they need a headless browser, a node
  toolchain, and they fail nondeterministically in CI). Alt-text coverage is
  asserted separately by html-proofer.

## Typography

| Role | Family | Notes |
|---|---|---|
| Body, headings, nav | `{typography.body}` | DM Sans, variable optical size 9–40, weights 400–800, plus italic 400/500 |
| Code, endpoints, field names, front-matter keys | `{typography.mono}` | JetBrains Mono, weights 400/500/600 |

Line height is `1.6` for both body and content. Both families load from Google
Fonts via `_includes/head_custom.html` with `preconnect` and `display=swap`.

### Assertion

- `script/check.rb` asserts `_includes/head_custom.html` still contains both
  `family=DM+Sans` and `family=JetBrains+Mono` and both `preconnect` hints. A
  font that silently stops loading degrades every page at once and nothing else
  in the stack would notice.
- Vale asserts prose does not wrap ordinary words in backticks. Monospace means
  *machine-readable token*; if it means "emphasis," the signal is gone. Rule:
  `SignalsAPI.BacktickProse` — flag inline code spans that contain a space and
  no character from `/:._{}[]-` and are not preceded by a defined term marker.

## Layout & Spacing

just-the-docs supplies the layout. This overhaul adds no grid, no container, no
breakpoint.

- **Single content column**, theme default width, left sidebar nav, right-hand
  table of contents where the theme renders one.
- **Spacing** uses the theme's spacer scale only. `{spacing.unit}` is a pointer
  to that scale, not a new number.
- **Responsive** behaviour is entirely the theme's. It is not re-specified here
  and must not be overridden. The one responsive requirement this overhaul adds
  is that wide content must scroll inside itself, not push the page: field
  tables and long `curl` lines get `overflow-x: auto` on their container.

### Assertion

`script/check.rb` asserts no `@media` query is added to `_sass/custom/custom.scss`
beyond the ones present at the start of this overhaul. Count them once, pin the
count, fail on increase. Rationale: every responsive bug this site could acquire
would come from a hand-rolled breakpoint fighting the theme's.

## Elevation & Depth

Four shadows exist. No fifth may be added.

| Purpose | Value |
|---|---|
| Focus ring | `0 0 0 2px rgba(0, 232, 123, 0.15)` |
| Raised panel / dropdown | `0 8px 32px rgba(0, 0, 0, 0.5)` |
| Card hover | `0 8px 24px rgba(0, 0, 0, 0.3)` |
| Button rest / hover / pressed | `0 1px 3px rgba(0, 0, 0, 0.3)` · `0 6px 20px rgba(0, 232, 123, 0.3)` · `inset 0 1px 3px rgba(0, 0, 0, 0.2)` |

Depth is carried mostly by background layering (`{colors.bg}` → `{colors.bg-sf}` →
`{colors.bg-el}` → `{colors.bg-card}` → `{colors.bg-card-h}`) rather than by
shadow. Prefer a background step to a new shadow.

## Shapes

| Token | Value | Applies to |
|---|---|---|
| `{rounded.sm}` | `3px` | Inline code, small chips |
| `{rounded.md}` | `5px` | Nav items, table cells that round |
| `{rounded.lg}` | `8px` | Code blocks, buttons, search field, favicon |
| `{rounded.xl}` | `10px` | Cards, dropdown panels |

No other radius. No circles. No pills.

## Components

Eight. This is the complete set available to any page produced by this overhaul.
Anything a page needs beyond these is a content problem.

### `callout`

Markdown blockquote with a just-the-docs callout class. Four kinds — `note`,
`tip`, `warning`, `danger` — colored per § Colors. Carries the single most
important convention in the whole overhaul: **a callout is where a claim states
its source.** A dated fact, a "verified on" line, or a `TODO(owner):` marker
lives in a callout, not in body prose.

### `code-block`

Fenced, `{typography.mono}`, `{colors.bg-card}`, `{rounded.lg}`, rouge-highlighted.
Every fence declares a language. Bare ``` fences are a defect: they lose
highlighting and they defeat the machine-readability work in EXPERIENCE.md.

**Assertion:** `script/check.rb` fails on any fenced block in a published `.md`
whose opening fence has no language token.

### `table`

`{colors.bg-el}` background, `{colors.border}` rules. The **field table** is a
constrained variant and it is load-bearing: it is what replaces the eight
stale 2024-era screenshots whose entire instructional payload sits in an image
with empty alt text. Columns: Field · What it does · Example. Text, not pixels;
diffable, greppable, translatable by an agent.

**Assertion:** `script/check.rb` fails if any published page contains an `<img>`
or `![]()` with empty alt text — but html-proofer already does this and is the
primary gate. `check.rb` additionally fails if a page under `features/` contains
an image and no table, which is the shape of the defect on
`remove-duplicate-signals.md` and `find-decision-makers.md`.

### `nav-list`

The theme's sidebar. Driven by front matter only — see EXPERIENCE.md
§ Information Architecture. Active item takes `{colors.accent}`; children take
`{colors.text-muted}`.

### `search-input`

The theme's lunr-backed search. `{colors.bg-card}`, `{rounded.lg}`, hits
highlighted in `{colors.accent}`. It is already live at
`assets/js/search-data.json`. The overhaul feeds it better input via
`search_aliases` front matter rather than replacing it.

### `button-primary`

`{colors.accent}` fill, `{colors.bg}` label, `{rounded.lg}`, the three-state
shadow set above. Used sparingly — a docs page usually wants a link, not a
button. **A button never triggers a network request.** No Run buttons, no live
counters, no forms that POST. This is a hard constraint from the PRD scope
boundary, and it is visual as much as behavioural: if it looks clickable it must
be a link to another page or an anchor.

### `breadcrumb`

The theme's parent-child trail. It only works if `parent:` front matter is
correct, which is exactly what the IA restructure fixes.

### `footer`

A new shared include (`_includes/footer_custom.html`) carrying the links pulled
out of the primary nav — Terms, Privacy, Is it working, Request a feature. These
four pages take `nav_exclude: true` and are reachable from every page via the
footer instead of competing with content for nav slots.

**Assertion:** `script/check.rb` fails if any of those four pages lacks
`nav_exclude: true`, or if `_includes/footer_custom.html` does not link all four.

## Do's and Don'ts

**Do**

- Reuse the fourteen colors, four radii, four shadows, two families. All of it exists.
- Put evidence in a `callout` and structure in a `table`.
- Declare a language on every code fence.
- Let just-the-docs own layout, spacing, and responsive behaviour.
- Fix visual problems by fixing content shape first — most "this page looks bad"
  findings in the audit are really "this page has no structure."

**Don't**

- Don't add a color, a radius, a shadow, a font, or a breakpoint.
- Don't add a CSS framework, a fourth customization file, or a `_layouts/` override
  that restyles rather than restructures.
- Don't build an interactive widget. Nothing POSTs; nothing calls the network at
  build time or page-view time.
- Don't use backticks for emphasis.
- Don't re-capture screenshots. Replacing a stale screenshot with a text click-path
  and a field table is the sanctioned fix; a Playwright screenshot rig is explicitly
  out of scope.
- Don't propose pa11y-ci or axe. The contrast constant plus html-proofer's alt-text
  assertion is the accessibility gate, by decision, not by omission.

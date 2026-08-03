---
stepsCompleted: [1, 2, 3, 4, 5, 6]
status: final
verdict: READY
assessedOn: 2026-08-01
documentsUnderAssessment:
  - _bmad-output/planning-artifacts/prd.md
  - _bmad-output/planning-artifacts/architecture.md
  - _bmad-output/planning-artifacts/epics.md
  - _bmad-output/planning-artifacts/ux-designs/ux-docs-2026-08-01/EXPERIENCE.md
  - _bmad-output/planning-artifacts/ux-designs/ux-docs-2026-08-01/DESIGN.md
  - _bmad-output/project-context.md
---

# Implementation Readiness Assessment Report

**Date:** 2026-08-01
**Project:** SignalsAPI documentation site overhaul

## Step 1 — Document Inventory

### PRD

**Whole documents**

- `_bmad-output/planning-artifacts/prd.md` (28K, modified 2026-08-01) — **canonical**
- `_bmad-output/planning-artifacts/prds/prd-docs-2026-08-01/prd.md` (28K, modified 2026-08-01) — provenance copy

### Architecture

**Whole documents**

- `_bmad-output/planning-artifacts/architecture.md` (20K, modified 2026-08-01) — **canonical**
- `_bmad-output/planning-artifacts/architecture/architecture-docs-2026-08-01/ARCHITECTURE-SPINE.md` (20K, modified 2026-08-01) — provenance copy

### Epics and stories

**Whole documents**

- `_bmad-output/planning-artifacts/epics.md` (89K, modified 2026-08-01) — **canonical**, no competing version

### UX

**Whole documents**

- `_bmad-output/planning-artifacts/ux-designs/ux-docs-2026-08-01/EXPERIENCE.md` (27K) — information architecture, page-shape contracts, reader journeys
- `_bmad-output/planning-artifacts/ux-designs/ux-docs-2026-08-01/DESIGN.md` (13K) — visual token freeze contract

### Supporting inputs (not assessed, used as evidence)

- `_bmad-output/planning-artifacts/briefs/brief-docs-2026-08-01/brief.md` and `addendum.md`
- `_bmad-output/brainstorming/brainstorm-better-docs-2026-07-31/.memlog.md` — 358 lines, 311 ideas, nine synthesis insights, phased sequencing direction
- `_bmad-output/project-context.md` — binding technical constraints

### Duplicate resolution

Two document types exist in both a flat and a dated-folder form. This is expected: the planning run wrote each artifact into a dated run folder for provenance, then published a flat alias at the location downstream tooling reads.

| Document | Resolution |
| --- | --- |
| PRD | The flat `prd.md` is canonical. The dated copy is byte-equivalent provenance and is not assessed separately. |
| Architecture | The flat `architecture.md` is canonical. `ARCHITECTURE-SPINE.md` under the dated folder is byte-equivalent provenance and is not assessed separately. |

No sharded (`index.md` plus fragments) form exists for any document type, so there is no whole-versus-sharded conflict to resolve.

### Missing documents

None. All four required document types are present.

## PRD Analysis

Source: `_bmad-output/planning-artifacts/prd.md`, read in full (275 lines). Requirements are reproduced verbatim, not summarized.

### Functional Requirements

The PRD groups its functional requirements A through K, each group bound to one epic.

**Group A — Verification harness (Epic 1)**

- **FR1.** A `Rakefile` defines `rake check` = `jekyll build` -> `html-proofer` -> `vale` -> `ruby script/check.rb`, exiting nonzero on the first failure.
- **FR2.** `html-proofer ~> 5` is added to the `Gemfile` and runs `--disable-external` in the PR path, asserting internal link integrity, image presence, unique ids, valid anchors and non-empty `alt` attributes.
- **FR3.** Vale runs from an in-repo `.vale.ini` plus `styles/SignalsAPI/`, exiting 1 on error-level rules.
- **FR4.** `script/check.rb` exists as plain stdlib Ruby (no new gem) and holds every repository invariant that html-proofer and Vale cannot express.
- **FR5.** `_config.yml` sets `strict_front_matter: true`; `.ruby-version` pins `3.3`; `.github/workflows/ci.yml` runs exactly `bundle exec rake check`.

**Group B — Credibility patch (Epic 2)**

- **FR6.** No rendered page contains a malformed canonical, `og:url` or JSON-LD URL. *(Closes F1 — remove the trailing slash from `url:` at `_config.yml:7`; asserted by "no file under `_site/` contains `docs.signalsapi.com//`".)*
- **FR7.** `_config.yml` declares `exclude:` covering `README.md`, `LICENSE`, `push.sh`, `run.sh`, `Gemfile`, `Gemfile.lock`. *(Closes F2; asserted by "`_site/` root contains no file lacking front matter".)*
- **FR8.** Every internal link resolves. *(Closes F3 — `features/filter-leads-with-ai.md:32`.)*
- **FR9.** No currency symbol or commercial figure appears outside `_data/pricing.yml`. *(Closes F4 — the contradicted `faq.md:26` and `faq.md:51` figures are deleted, not reconciled; the "propsects" typo goes with them.)*
- **FR10.** `nav_order` is unique within each parent, and leaf content pages use `layout: default` rather than `layout: home`. *(Closes F5 and F6.)*
- **FR11.** The site declares `permalink: pretty`, ships `jekyll-sitemap`, `robots.txt`, and a `404.md` with `permalink: /404.html` wired to the lunr index, and populates `aux_links`.

**Group C — Baseline (Epic 3)**

- **FR12.** `_data/baseline.yml` records the 2026-07-31 as-is state (page count, word count, image count, finding set) and renders at `/docs-baseline`, so every later claim of improvement is measurable against a committed starting point. *(Source: `.memlog.md:302`.)*

**Group D — Core concepts and the object model (Epic 4)**

- **FR13.** `_data/glossary.yml` is the single definition of the object model — Signal, Search, Filter, Persona, Lead list (= `project` in the REST API), Credit, and the pipeline order — rendering `/concepts` and feeding Vale rules that fail on banned aliases (`personation`, "project" used for a lead list in prose, "person settings", "campaign"). *(Source: `.memlog.md:99`.)*

**Group E — Getting started (Epic 5)**

- **FR14.** `index.md` is a task router linking into the documentation, not a pitch. *(Closes F10; source `.memlog.md:96`, `.memlog.md:120`.)*
- **FR15.** A written quick start exists (restored from `835852a^`, no video embed), plus three role-shaped quickstarts — recruitment-agency owner, B2B service provider, agent builder — and explicit documentation of creating a search, the primary product action and currently undocumented. *(Source: `.memlog.md:93`, `.memlog.md:226`.)*

**Group F — Symptom-named troubleshooting (Epic 6)**

- **FR16.** A `/troubleshooting` section exists with pages named after the symptom the user types: "Why is my lead list empty?" (all nine causes as a decision tree), "Why is the phone column blank?", "What does Enriching mean?" *(Source: `.memlog.md:23`, `.memlog.md:114`, `.memlog.md:282`.)*
- **FR17.** A statuses-and-error-codes reference and a single support page carrying a copy-paste diagnostic block exist, retiring the `mykola@` / `support@` split. *(Source: `.memlog.md:283`, `.memlog.md:286`, `.memlog.md:105`.)*

**Group G — `_data/` single source of truth (Epic 7)**

- **FR18.** Six datasets live in `_data/`: `providers.yml`, `variables.yml`, `integrations.yml`, `filters.yml`, `pricing.yml`, `glossary.yml`. *(SYNTHESIS 2, `.memlog.md:348`.)*
- **FR19.** Every surviving page that restates one of those datasets renders it through Liquid instead. A `_data` key may not be renamed without updating every `site.data` reference in the same commit.
- **FR20.** Affiliate URLs are emitted only through a shared include that is structurally incapable of producing a link without `rel="sponsored nofollow"` and its cost label; unsourceable cost values ship as `TODO(owner):` markers. *(Source: `.memlog.md:327`; SYNTHESIS 7.)*

**Group H — SEO and machine-readability (Epic 8)**

- **FR21.** Every page carries a unique, non-default `description:`. *(Closes F7.)*
- **FR22.** `/llms.txt` and `/llms-full.txt` are generated from `site.pages` via `layout: null` pages. *(SYNTHESIS 3; source `.memlog.md:76`, `.memlog.md:257`.)*
- **FR23.** `head_custom.html` emits schema.org JSON-LD (including FAQPage where applicable) and a programmatically generated 1200x630 OG card built from the page title and the existing palette.
- **FR24.** `jekyll-redirect-from` maps GitBook-era paths, `.md`-suffixed paths, and any `features/*` slug that moves.

**Group I — Trust and governance (Epic 9)**

- **FR25.** Every page carries `verified_on:` and `verified_against:` front matter, rendered as a freshness chip, with a `script/check.rb` staleness assertion. *(SYNTHESIS 8.)*
- **FR26.** `/docs-health` renders the audit finding set from `_data/` with status and fix date, alongside the live CI assertions — the burn-down is published, not claimed. *(Source: `.memlog.md:58`, `.memlog.md:112`.)*
- **FR27.** "When SignalsAPI is the wrong tool" and the limits page are drafted to `_drafts/` for review. *(SYNTHESIS 4; source `.memlog.md:116`.)*

**Group J — Agent data plane, static subset (Epic 10)**

- **FR28.** `openapi/plane-v1.yaml` exists per the Scope Rationale specification and passes `npx @stoplight/spectral-cli lint`.
- **FR29.** `/fixtures/v1/**.json` static recorded bodies exist, each carrying `"recorded_on"` in the payload.
- **FR30.** A curl gallery targets those fixture URLs, paired with a "same call against the production base URL (pending)" block, plus `prism mock` instructions.
- **FR31.** `mcp/` holds stdio MCP server source and the literal `claude_desktop_config.json` connect snippet. Source only — no hosting.
- **FR32.** `/plane-status.json` and a generated status column replace the "can never drift" parity language with a computed sentence.
- **FR33.** The four `email mykola@signalsapi.com` dead-ends are replaced with spec -> fixtures -> mock -> waitlist.

**Group K — Content ops cleanup (Epic 11)**

- **FR34.** Stale screenshots are deleted and their instructional payload written out as text click-paths and field tables; no image ships with empty `alt`. *(Closes F8; source `.memlog.md:86`, `.memlog.md:117`, `.memlog.md:119`.)*
- **FR35.** `features/index.md` declares `has_children: true` so `features/*` nests correctly, and an `/apis/` router page exists. *(Closes F9; source `.memlog.md:284`, `.memlog.md:118`.)*
- **FR36.** A Pricing page exists with real structure — plans, credit model, BYO-provider phone model — and a `TODO(owner):` marker for every figure not sourceable from this repository. *(Source: `.memlog.md:290`.)*
- **FR37.** The changelog moves to `_data/changelog.yml` and renders from there; the 2026-06-30 API-access and 2026-07-09 agent-data-plane entries are backfilled. *(Closes F11; source `.memlog.md:75`, `.memlog.md:100`.)*

**Total FRs: 37** (FR1 through FR37, contiguous, uniquely numbered, each bound to exactly one epic group).

### Non-Functional Requirements

- **NFR1 — Verification is the acceptance mechanism.** See `## Verification`. `bundle exec rake check` is the sole quality gate and the sole CI command.
- **NFR2 — No live network call** at build time or page-view time. Static fixtures served from the docs origin are the sanctioned substitute.
- **NFR3 — No invented figure.** No price, plan allowance, credit cost, commission rate, match rate, uptime or latency is written unless sourceable from this repository.
- **NFR4 — No string may imply** a live sandbox key, a public API base URL, or an issued credential exists. Enforced as a Vale deny rule.
- **NFR5 — URL surface preservation.** Bulk page deletion is permitted only when paired with `jekyll-redirect-from` entries in the same commit.
- **NFR6 — Build determinism.** `strict_front_matter: true` plus `.ruby-version` = `3.3` so local green matches CI green (local is currently 3.1.3, CI pins 3.3 inline with no `.ruby-version`).
- **NFR7 — Plugin policy.** Deployment is a custom Actions build, not the GitHub Pages gem whitelist, so arbitrary plugins and `_plugins/` generators are legal. Adding one requires two edits: the gem in `Gemfile` and a `plugins:` array in `_config.yml` (which does not exist yet).
- **NFR8 — Accessibility.** Verified by html-proofer's alt-text assertion plus a contrast constant asserted in `script/check.rb` against `_sass/color_schemes/signalsapi.scss`. Headless-browser runners are excluded from the loop.
- **NFR9 — No new runtime dependency for assertions.** `script/check.rb` runs under `ruby script/check.rb` with stdlib only.
- **NFR10 — Legal copy is drafted, never published,** from this workstream. `_drafts/` only.
- **NFR11 — Repository boundary.** This repository may publish a contract; it may not claim the application consumes one. No change to `app.signalsapi.com` or the app repo.
- **NFR12 — Branch discipline.** Work lands on `plan/better-docs`. `pages.yml` deploys on `push: main` only, so a branch commit never deploys.

**Total NFRs: 12** (NFR1 through NFR12).

### Additional Requirements

Beyond the numbered FR and NFR sets, the PRD carries five further binding sections. Each imposes obligations on the epics and is therefore assessed as a requirement source in its own right.

**1. The scope boundary (`## Scope`).** In Scope is stated once: "Anything that is a pure change to this repository, verifiable by `rake check` on the developer's machine with no network call at build time or page-view time." Out of Scope is a sixteen-item numbered list, each item a prohibition the backlog must respect:

1. Any live network call at build time or page-view time. No Run buttons, live counters, `/panel`, Hiring Pulse Index, live ICP checker, free domain lookup, measured `/data-freshness`.
2. Standing up, minting, or describing-as-existing any sandbox key or public base URL. Spec + static fixtures + `prism` mock only; no page may contain a string implying a live sandbox, a public base URL, or an issued key exists. Enforce as a Vale deny rule.
3. Hosting an MCP server. Source + connect snippet in scope; deployment, npm publish, public URL out.
4. Ledger-generated programmatic pages — `/market/*`, `/hiring/*`, Signal Index, the 290-source directory, nightly provider benchmark.
5. Any change to `app.signalsapi.com` or the app repo. Docs may publish a contract; docs may not claim the app consumes it.
6. Screenshot re-capture, Playwright rigs, nightly app-label assertions. Deleting stale screenshots and replacing them with text click-paths and field tables IS in scope.
7. Publishing any number not sourceable from this repo — prices, plan allowances, credit costs, commission rates, match rates, uptime, latency, the 290-source list. Ship the render mechanism plus a `TODO(owner):` marker in `_data/` that `script/check.rb` flags. Never invent a figure.
8. Legal/compliance artifacts — privacy-policy rewrite, DPA, sub-processor commitments, accessibility conformance claims, GDPR guidance, data-subject removal forms. Draft to `_drafts/` only.
9. Analytics, telemetry, feedback collectors, zero-result search logging — anything that POSTs. GitHub-issue-prefill is the permitted substitute.
10. Domain and hosting changes — rehosting, sandbox subdomains, DNS, status-page components.
11. Localization / translation.
12. Human research outputs — user testing, inbox mining, `/asked`, `/incidents`, credits-for-docs-PRs.
13. Design assets requiring a designer. Programmatically generated OG cards from page title + the existing palette are in scope.
14. Memlog #197 "Collapse 28 pages into one scrolling URL with anchors." Destroys the URL surface. Reject outright.
15. Any bulk page deletion not paired with `jekyll-redirect-from` entries in the same commit.
16. Memlog #328's service worker. Take the fixtures, drop the SW.

**2. The Definition of Done (`## Verification`).** Quoted verbatim from the PRD: "**Definition of Done for every story:** (a) `rake check` is green, AND (b) the story adds at least one new assertion to `script/check.rb` or a new rule to `.vale.ini` that **fails on the branch point before the change and passes after**." The PRD then states: "Clause (b) is non-negotiable... Stories that cannot express (b) (pure prose additions) must instead be paired with a coverage assertion." Clause (b) binds from Story 1.2 onward; Story 1.1 creates the harness itself. This is the single most consequential constraint on the epic backlog, because it converts every story into a red-to-green transition rather than an edit.

**3. The verification stack.** Six named tools with fixed roles: `jekyll build` with `strict_front_matter: true`; `html-proofer ~> 5` as the primary gate, `--disable-external` on the PR path; Vale as a Go binary with in-repo `.vale.ini` and `styles/SignalsAPI/`; `script/check.rb` in plain Ruby with no new dependency; Spectral for OpenAPI once Epic 10 lands; lychee nightly only. pa11y-ci and axe are explicitly rejected from the main loop.

**4. The delivery sequence (`## Delivery Sequence`).** The brainstorm's five-phase direction with one stated deviation: the verification harness is pulled ahead of everything, because DoD clause (b) is unsatisfiable until `script/check.rb`, `.vale.ini` and the `Rakefile` exist. Phase 5 is out of scope entirely. An epic-to-finding table binds each of the eleven epics to the audit findings it closes.

**5. Constraints, assumptions and open questions.** Seven `[ASSUMPTION]`-tagged statements (audit accuracy as of 2026-07-31, plugin legality via the custom Actions build, absence of a unit-test framework, inferred user profiles, faithfulness of the derived OpenAPI contract, `zollsoft.de` as an acceptable public example, stakes = launch) and seven open questions (pricing figures, measured verification rate and latency, per-operation live status, DPA and sub-processors, docs owner and review cadence, changelog migration depth, affiliate cost values). Every open question that touches a figure is already routed to a `TODO(owner):` marker rather than a guess.

### PRD Completeness Assessment

| Dimension | Finding |
| --- | --- |
| Requirement identity | 37 FRs and 12 NFRs, contiguously numbered, each uniquely identified. Zero gaps, zero duplicate identifiers. |
| Requirement text | Every FR is a single testable statement. Each cites either the audit finding it closes (F1-F12) or the brainstorm memlog line it derives from. |
| Traceability | The PRD ships its own `## Requirements Inventory` table mapping all twelve audit findings to the FRs and epics that close them. This is unusual and materially raises readiness. |
| Epic binding | Every FR group names its epic (A through K to Epics 1 through 11). The mapping is total and injective. |
| Testability | The `## Verification` section names the exact tool that catches each defect class, so an FR can be traced to the mechanism that enforces it. |
| Scope discipline | The Out of Scope list is explicit, numbered, and rationalized for its three highest-risk items. The PRD names the strongest brainstorm convergence (a public sandbox key) and states plainly that it is not buildable here, then scopes the buildable 80% as the Epic 10 static subset. |
| Measurability | Success metrics are mechanism-shaped by design, with four counter-metrics naming what failure looks like. The PRD asserts zero metrics it cannot source. |
| Gaps | Seven open questions remain, all of them figure-shaped or ownership-shaped. None blocks implementation: each is routed to a `TODO(owner):` marker that `script/check.rb` flags, so the render mechanism ships and the number arrives later. |

**Assessment: the PRD is complete and implementation-ready.** It carries requirements, non-functional constraints, a scope boundary, a verification contract, a delivery sequence, and its own traceability table. The one structural risk — unsourceable figures — is anticipated by NFR3, Out of Scope item 7, and the `TODO(owner):` mechanism, rather than left to the implementer's discretion.

## Epic Coverage Validation

`epics.md` was loaded completely: 11 epics, 112 stories.

**Method note.** The epics document ships a `## Requirements Inventory` keyed to the twelve audit findings (F1-F12), not to the PRD's FR identifiers, and individual stories cite a `Source:` memlog line or an audit finding rather than an FR number. The matrix below was therefore derived by reading every story and matching its acceptance criteria against the FR text extracted in the previous step. Full verbatim FR text is in `## PRD Analysis` above; the column here carries the requirement's operative clause.

### Coverage Matrix

| FR | PRD requirement (operative clause) | Epic coverage | Status |
| --- | --- | --- | --- |
| FR1 | `Rakefile` defines `rake check` = build, html-proofer, vale, `script/check.rb`, exiting nonzero on first failure | Epic 1, Story 1.1 | Covered |
| FR2 | `html-proofer ~> 5` in the Gemfile, `--disable-external` on the PR path | Epic 1, Story 1.3 | Covered |
| FR3 | Vale runs from in-repo `.vale.ini` plus `styles/SignalsAPI/`, exit 1 on error-level rules | Epic 1, Stories 1.4, 1.5 | Covered |
| FR4 | `script/check.rb` in plain stdlib Ruby holding every invariant the other tools cannot express | Epic 1, Stories 1.1, 1.6, 1.7 | Covered |
| FR5 | `strict_front_matter: true`; `.ruby-version` = 3.3; `ci.yml` runs exactly `bundle exec rake check` | Epic 1, Stories 1.2, 1.9, 1.10 | Covered |
| FR6 | No rendered page contains a malformed canonical, `og:url` or JSON-LD URL | Epic 2, Story 2.1; Epic 8, Story 8.2 | Covered |
| FR7 | `_config.yml` declares `exclude:` covering README, LICENSE, `push.sh`, `run.sh`, Gemfile, Gemfile.lock | Epic 2, Story 2.2 | Covered |
| FR8 | Every internal link resolves | Epic 2, Story 2.7; enforced by Epic 1, Story 1.3 | Covered |
| FR9 | No currency symbol or commercial figure outside `_data/pricing.yml` | Epic 2, Stories 2.8, 2.9; Epic 7, Story 7.7 | Covered |
| FR10 | `nav_order` unique within each parent; leaf pages use `layout: default` | Epic 2, Stories 2.10, 2.11 | Covered |
| FR11 | `permalink: pretty`, `jekyll-sitemap`, `robots.txt`, `404.md` wired to the lunr index, populated `aux_links` | Epic 2, Stories 2.3, 2.4, 2.5, 2.6, 2.12 | Covered |
| FR12 | `_data/baseline.yml` records the 2026-07-31 as-is state and renders at `/docs-baseline` | Epic 3, Stories 3.1, 3.2, 3.3 | Covered |
| FR13 | `_data/glossary.yml` as the single object-model definition, rendering `/concepts` and feeding Vale alias rules | Epic 4, Stories 4.1, 4.2, 4.4, 4.5, 4.6 | Covered |
| FR14 | `index.md` is a task router linking into the documentation, not a pitch | Epic 5, Story 5.1 | Covered |
| FR15 | Written quick start restored from `835852a^`, three role-shaped quickstarts, and creating a search documented | Epic 5, Stories 5.2, 5.4, 5.5, 5.6, 5.7 | Covered |
| FR16 | `/troubleshooting` section with symptom-named pages including the nine-cause decision tree | Epic 6, Stories 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8 | Covered |
| FR17 | Statuses-and-error-codes reference plus one support page with a copy-paste diagnostic block | Epic 6, Stories 6.9, 6.10 | Covered |
| FR18 | Six datasets in `_data/`: providers, variables, integrations, filters, pricing, glossary | Epic 7, Stories 7.2, 7.4, 7.5, 7.6, 7.7; Epic 4, Story 4.1 | Covered |
| FR19 | Every surviving page that restates a dataset renders it through Liquid; keys may not be renamed without updating references | Epic 7, Stories 7.1, 7.9, 7.10 | Covered |
| FR20 | Affiliate URLs emitted only through an include structurally incapable of omitting `rel="sponsored nofollow"` and its cost label | Epic 7, Story 7.3 | Covered |

| FR21 | Every page carries a unique, non-default `description:` | Epic 8, Story 8.1; Epic 5, Story 5.3 | Covered |
| FR22 | `/llms.txt` and `/llms-full.txt` generated from `site.pages` via `layout: null` | Epic 8, Stories 8.3, 8.4 | Covered |
| FR23 | `head_custom.html` emits schema.org JSON-LD including FAQPage, plus a generated 1200x630 OG card | Epic 8, Stories 8.5, 8.6, 8.7 | Covered |
| FR24 | `jekyll-redirect-from` maps GitBook-era paths, `.md`-suffixed paths, and moved `features/*` slugs | Epic 8, Story 8.8 | Covered |
| FR25 | Every page carries `verified_on:` and `verified_against:`, rendered as a freshness chip, with a staleness assertion | Epic 9, Stories 9.1, 9.2, 9.4 | Covered |
| FR26 | `/docs-health` renders the audit finding set from `_data/` with status and fix date, alongside live CI assertions | Epic 9, Story 9.3 | Covered |
| FR27 | "When SignalsAPI is the wrong tool" and the limits page drafted to `_drafts/` for review | Epic 9, Stories 9.6, 9.7 | Covered |
| FR28 | `openapi/plane-v1.yaml` exists per the Scope Rationale specification and passes Spectral lint | Epic 10, Stories 10.1, 10.2 | Covered |
| FR29 | `/fixtures/v1/**.json` static recorded bodies, each carrying `"recorded_on"` in the payload | Epic 10, Story 10.3 | Covered |
| FR30 | A curl gallery against the fixture URLs paired with a pending-production block, plus `prism mock` instructions | Epic 10, Stories 10.4, 10.5 | Covered |
| FR31 | `mcp/` holds stdio server source and the literal `claude_desktop_config.json` snippet, source only | Epic 10, Story 10.6 | Covered |
| FR32 | `/plane-status.json` and a generated status column replace the parity claim with a computed sentence | Epic 10, Stories 10.7, 10.9 | Covered |
| FR33 | The four `email mykola@signalsapi.com` dead ends replaced with spec, fixtures, mock, waitlist | Epic 10, Story 10.8 | Covered |
| FR34 | Stale screenshots deleted, payload rewritten as click paths and field tables; zero empty `alt` | Epic 11, Stories 11.1, 11.2, 11.3, 11.4 | Covered |
| FR35 | `features/index.md` declares `has_children: true`; an `/apis/` router page exists | Epic 5, Story 5.8; Epic 11, Story 11.5; Epic 10, Story 10.10 | Covered |
| FR36 | Pricing page with real structure and a `TODO(owner):` marker for every unsourceable figure | Epic 11, Story 11.6; Epic 7, Story 7.7 | Covered |
| FR37 | Changelog moves to `_data/changelog.yml` and renders from there; the two 2026 launches backfilled | Epic 11, Stories 11.7, 11.8, 11.9 | Covered |

### Missing Requirements

Zero PRD functional requirements lack an implementation path. Every FR from FR1 through FR37 resolves to at least one story, and 24 of the 37 resolve to two or more stories that decompose the requirement into separately shippable units.

### Stories beyond the FR set

Thirty-one stories implement content that originates in the architecture spine, the UX experience spine, or the brainstorm memlog rather than in a numbered FR. These are additions, not orphans, and each carries a `Source:` citation:

- **Harness ergonomics (Epic 1):** 1.6 assertion registry, 1.7 site model, 1.8 covers manifest, 1.11 scaffolding and single-assertion addressing, 1.12 `TODO(owner:)` grammar, 1.13 nightly external-link workflow. These exist because Definition of Done clause (b) requires adding an assertion to be cheap; the architecture spine identifies expensive assertion authoring as the mechanism most likely to make stories skip clause (b).
- **Accessibility and budget (Epic 2):** 2.13 focus ring, 2.14 plugin budget.
- **Object model depth (Epic 4):** 4.3 term include, 4.7 anatomy of a lead, 4.8 pipeline as data, 4.9 nesting how-it-works.
- **Navigation contracts (Epic 5):** 5.9 top-level navigation shape, 5.10 footer placement.
- **Troubleshooting wiring (Epic 6):** 6.11 links from task pages into the symptom pages.
- **Data-layer hygiene (Epic 7):** 7.8 prerequisite include, 7.11 data-file freshness.
- **Machine-surface integrity (Epic 8):** 8.9 keeps `llms.txt`, `sitemap.xml` and the page set in sync.
- **Governance (Epic 9):** 9.5 orphan pages, 9.8 commercial-relationship page, 9.9 trust router.
- **Content ops (Epic 11):** 11.10 image payload, 11.11 redundant page retirement with redirect, 11.12 page budget, 11.13 retirement ledger.

### Coverage Statistics

- Total PRD FRs: **37**
- FRs covered in epics: **37**
- Coverage percentage: **100%**
- FRs present in epics but absent from the PRD: **0**
- Stories in the backlog: **112** across **11** epics
- Stories implementing a numbered FR: **81**
- Stories implementing architecture, UX or memlog-sourced work outside the FR set: **31**

### Traceability observation

Severity: low. Stories cite memlog lines and audit findings rather than FR identifiers, and the epics document's own inventory is keyed to F1-F12. The mapping is complete and unambiguous once derived, but it is derived rather than declared. This costs nothing at implementation time — each story's acceptance criteria are self-contained — and it is recorded here so the matrix above becomes the durable traceability record.

## UX Alignment Assessment

### UX Document Status

**Found.** Two peer spines, both `status: final`, both dated 2026-08-01:

- `ux-designs/ux-docs-2026-08-01/EXPERIENCE.md` — information architecture, voice, component behaviour, state and interaction patterns, accessibility floor, three named-protagonist flows (Priya the operator, Dan the developer, Atlas the agent), and five page-shape contracts.
- `ux-designs/ux-docs-2026-08-01/DESIGN.md` — the visual freeze contract: fourteen palette constants, two type families, spacing, elevation, shapes, eight permitted components.

Both spines declare the same `sources:` set as the PRD and state that they win on conflict with any mock or import.

### UX to PRD alignment

| Check | Result |
| --- | --- |
| UX requirements reflected in the PRD | Yes. The eleven-entry navigation tree implements FR14 (home as router), FR16 (a `/troubleshooting` section), FR35 (`features/index.md` with `has_children`, plus an `/apis/` section), and FR11's `404.html`. |
| UX journeys match PRD use cases | Yes, one-to-one. Priya maps to the PRD's operator, Dan to the developer, Atlas to the AI agent. The PRD's fourth user, the maintainer, is served by the governance surfaces rather than by a flow, which is consistent — the maintainer's experience is `rake check`. |
| UX requirements absent from the PRD | One, and it is additive rather than contradictory: the `page_type` taxonomy (`router`, `concept`, `task`, `symptom`, `reference`) with a required H2 skeleton per type. The PRD does not name it; the UX spine introduces it as the mechanism that makes page structure assertable. Epic stories 4.6, 4.7, 5.4, 6.2 and 6.9 adopt it and register the matching assertions (`router-page-shape`, `concept-page-shape`, `task-page-shape`, `symptom-page-shape`, `reference-page-metadata`), so the addition is fully absorbed by the backlog. |
| PRD requirements the UX contradicts | Zero. The IA restructure is explicitly designed to ship zero redirects, because just-the-docs resolves `parent:` by page title rather than by directory, so nesting is a front-matter edit. This strengthens NFR5 (URL surface preservation) rather than straining it. |

### UX to Architecture alignment

| Check | Result |
| --- | --- |
| Architecture supports the UX assertions | Yes. Every one of the nine IA assertions in EXPERIENCE.md and every page-shape assertion lands in `script/check.rb`, which the architecture spine designs as a registry of one-assertion-one-file units parsed against a site model built once per run. The UX spine's rule that "a convention with no assertion is a suggestion, and suggestions rot" is the same rule the architecture encodes as Definition of Done clause (b). |
| Non-page outputs supported | Yes. `/404.html`, `/llms.txt`, `/llms-full.txt`, `/fixtures/v1/**.json`, `/plane-status.json` and `/robots.txt` all use the `layout: null` plus `permalink:` mechanism the architecture specifies for non-HTML output. `sitemap.xml` comes from `jekyll-sitemap` under the three-plugin budget. |
| Performance and responsiveness | Not applicable in the usual sense and correctly so. There is no runtime, no session, no state surviving a page load, and nothing that POSTs. Responsive behaviour is owned by just-the-docs 0.10.0, exact-pinned, and the spines specify only the behavioural delta. |
| UI components unsupported by the architecture | Zero. DESIGN.md permits eight components, all of them already renderable by the theme plus the three-file customization surface (`_includes/head_custom.html`, `_sass/color_schemes/signalsapi.scss`, `_sass/custom/custom.scss`). |

### Alignment Issues

**Issue 1 — the DESIGN.md palette and contrast assertion has no owning story. Severity: medium.**

DESIGN.md § Colors requires `script/check.rb` to assert that `_sass/color_schemes/signalsapi.scss` still defines all fourteen palette variables at exactly the stated hex values, and that the text-on-background pair computes to a WCAG contrast ratio at or above 4.5:1 in plain Ruby. PRD NFR8 states the same thing: accessibility is verified by html-proofer's alt-text check plus "a contrast constant asserted in `script/check.rb`". The architecture spine names the file as "read by the contrast assertion". Zero of the 112 stories create that assertion — a full-text scan of `epics.md` returns no occurrence of the word "contrast". Story 2.13 covers the focus ring, which is a different accessibility mechanism.

- Impact: NFR8 is half-implemented. Alt-text coverage ships (Stories 11.2, 1.3); the contrast and palette-drift half does not. A theme or palette edit could silently drop the site below 4.5:1 with the build still green — precisely the failure class this overhaul exists to eliminate.
- Recommendation: add one story to Epic 2, adjacent to Story 2.13, registering an assertion (suggested id `palette-contrast-floor`) that parses the fourteen hex constants out of the scss file, fails on any drift from DESIGN.md, and computes the text-on-background ratio.

**Issue 2 — the DESIGN.md typography assertion has no owning story. Severity: low.**

DESIGN.md § Typography requires `script/check.rb` to assert that `_includes/head_custom.html` still contains both font family declarations and both `preconnect` hints, on the reasoning that "a font that silently stops loading degrades every page at once and nothing else in the stack would notice." It also specifies a Vale rule `SignalsAPI.BacktickProse`. Neither appears in a story.

- Impact: a silent visual regression across all pages, invisible to every other gate. Low severity because it degrades appearance rather than correctness.
- Recommendation: fold both into the Epic 2 story proposed for Issue 1, or attach the Vale rule to Epic 4 Story 4.5, which already authors the `styles/SignalsAPI/` rule set.

**Issue 3 — a tension between DESIGN.md typography and PRD NFR2. Severity: low, but it needs an explicit decision.**

DESIGN.md loads DM Sans and JetBrains Mono from Google Fonts at page-view time. PRD NFR2 reads "No live network call at build time or page-view time," and Out of Scope item 1 repeats it. The PRD's evident intent is to forbid dynamic data calls — Run buttons, live counters, measured freshness widgets — rather than static font assets, and the current site already loads webfonts, so this is inherited behaviour rather than something the overhaul introduces. Still, the two documents read as contradictory to an implementer, and no story self-hosts the fonts.

- Impact: an implementer working Epic 8 or Epic 2 could reasonably read NFR2 as requiring font self-hosting, which is unbudgeted work with a licensing question attached.
- Recommendation: record the reading in `project-context.md` or as a one-line clarification on NFR2 — third-party static asset fetches are exempt; dynamic data calls are what NFR2 forbids. Do not add a self-hosting story to this workstream.

### Warnings

1. **Carried-forward UX open question, unresolved by design.** EXPERIENCE.md open question 1 states that the fifteen `features/*` children need a reading order, that alphabetical is the default and is wrong, and that the correct order is pipeline order, which needs `_data/pipeline.yml` to exist first. Story 4.8 creates `_data/pipeline.yml`; Story 5.8 nests the features pages; Story 2.10 makes every `nav_order` a contiguous integer. Zero stories assign the fifteen children their pipeline-order sequence. This is an ordering decision the backlog leaves open, exactly as the UX spine predicted. It does not block implementation — every page still renders and every assertion still passes — but the reading order will be arbitrary until someone sets it.
2. **EXPERIENCE.md open question 3 remains a policy gap.** The staleness threshold for `verified_on` has no defensible default and ships as a `TODO(owner):`. Story 9.4 implements the staleness assertion; the threshold value it enforces is unset. The story must not invent one. This aligns with PRD open question 5 (docs owner and review cadence).
3. **EXPERIENCE.md open question 2 is resolved by the backlog.** The `faq.md` overlap with `pricing.md`, `limits.md` and `support.md` resolves through Stories 2.8, 2.9, 9.6 and 11.6. The UX spine's warning that "deferring the split is safe; deferring the contradiction is not" is honoured — the contradiction is closed in Epic 2, the split lands later.
4. **EXPERIENCE.md open question 4 is resolved by the backlog.** The `whats-new/` migration question is answered by Stories 11.7 through 11.10, which move the changelog to `_data/`, backfill the two undocumented 2026 releases, and shrink the image payload.

## Epic Quality Review

Reviewed against the create-epics-and-stories standards: user value, epic independence, story sizing, forward dependencies, acceptance-criteria quality, and entity-creation timing. All 11 epics and all 112 stories were read.

### Epic Structure Validation

#### User value focus

| Epic | Title | User value verdict |
| --- | --- | --- |
| 1 | Verification harness | **Technical epic — flagged, then accepted.** See the deviation note below. |
| 2 | Credibility patch | Passes. A reader stops encountering a self-contradicting site; Story 2.1 alone repairs 28 canonical URLs. |
| 3 | Baseline | Borderline, accepted. `/docs-baseline` is a reader-visible page; the epic's real beneficiary is the maintainer, who is a named PRD user. |
| 4 | Core concepts and the object model | Passes. A reader learns what a Signal, a Search and a lead list are, from one authoritative page. |
| 5 | Getting started | Passes. An operator reaches a populated lead list without opening email. |
| 6 | Symptom-named troubleshooting | Passes. This is the strongest user-value epic in the backlog: a reader types their symptom and lands on a page named after it. |
| 7 | `_data/` DRY refactor | Borderline, accepted. Framed as a refactor but the user-facing outcome is stated in the story text: two pages can no longer disagree about what something costs. |
| 8 | SEO and machine-readability | Passes. The AI agent is a named primary PRD user, currently unserved. |
| 9 | Trust and governance | Passes. A reader can see when a page was last verified and what is known to be stale. |
| 10 | Agent data plane, static subset only | Passes. A developer gets a spec, working fixture URLs and a local mock instead of four email dead ends. |
| 11 | Content ops cleanup | Passes. Instructional content moves out of images a screen reader cannot read. |

**Deviation note on Epic 1.** By the standard's own red-flag list, "Verification harness" is an infrastructure epic and would normally be a critical violation. It is accepted here for three reasons, all documented upstream rather than invented during this review. First, the PRD names the maintainer as a user and defines their success as "a regression fails CI instead of surviving 21 months" — Epic 1 is that user's entire epic. Second, the PRD's Definition of Done clause (b) requires every story to add an assertion that fails before the change and passes after; clause (b) is literally unsatisfiable until the `Rakefile`, `script/check.rb` and `.vale.ini` exist, so no other epic can start. Third, the PRD's `## Delivery Sequence` states the deviation explicitly: "the verification harness is pulled ahead of everything." A documented, rationalized deviation is not the same defect as an undocumented technical milestone.

#### Epic independence

Tested Epic N against Epic N+1 for every N.

| Test | Result |
| --- | --- |
| Epic 1 stands alone | Passes. Story 1.1 creates the harness against the repository as it is today. Story 1.1 is also the one story exempt from clause (b), correctly, since it creates the mechanism clause (b) uses. |
| Epic 2 needs only Epic 1 | Passes. Every Epic 2 story is a `_config.yml` or single-file edit plus an assertion. |
| Epic 3 needs only Epics 1 and 2 | Passes. |
| Epic 4 needs only Epics 1 to 3 | Passes. |
| Epic 5 needs only Epics 1 to 4 | **Fails.** Stories 5.4, 5.5 and 5.6 require pages that Epic 6 creates. Detail under Critical Violations. |
| Epic 6 needs only Epics 1 to 5 | Passes. |
| Epic 7 needs only Epics 1 to 6 | Passes. |
| Epic 8 needs only Epics 1 to 7 | Passes. |
| Epic 9 needs only Epics 1 to 8 | Passes. |
| Epic 10 needs only Epics 1 to 9 | **Fails.** Story 10.10 requires the APIs router that Story 11.5 creates. Detail under Critical Violations. |
| Epic 11 needs only Epics 1 to 10 | Passes. |
| Circular dependencies | None found. |

### Story Quality Assessment

#### Sizing

Every story is one loop iteration: a single file or single-concern change plus one registered assertion. Zero epic-sized stories were found. The largest is Story 1.1 (Rakefile plus `script/check.rb` skeleton), which is correctly the harness-creation story and correctly the sole exemption from Definition of Done clause (b). The smallest, Story 2.1, is a one-character `_config.yml` edit plus an assertion, and the PRD identifies it as the highest-return change in the backlog.

#### Acceptance criteria

| Dimension | Result |
| --- | --- |
| Given/When/Then structure | 112 of 112 stories carry a complete Given, When, Then and at least one And. Verified mechanically. |
| Testable | Every `Then` and `And` names a concrete assertion identifier — the `id:` passed to `Check.register` in `script/checks/<id>.rb`, or a named Vale rule. This is materially stronger than typical acceptance criteria: the AC and the test are the same artifact. |
| Specific | No vague criteria of the "user can log in" class were found. Criteria name files, front-matter keys, headings and assertion identifiers. |
| Failure conditions | Present by construction. Each assertion is phrased as what makes it fail, not what makes it pass, so the negative case is the stated case. |
| Traceability | Every story carries a `Source:` line citing a memlog line, an audit finding, or a named spine section. |

#### Entity-creation timing

The database analogue here is `_data/`. The check is satisfied: no story creates all data files upfront. Story 4.1 creates `glossary.yml` when the glossary needs it; Stories 7.2, 7.4, 7.5, 7.6 and 7.7 each create one file at the point its first consumer exists; Story 3.1 creates `baseline.yml` for the baseline page; Story 11.1 creates `screenshots.yml` for the screenshot inventory; Story 11.7 creates `changelog.yml` for the changelog. Story 7.1 correctly establishes the envelope convention before the files that use it.

#### Brownfield indicators

Present and appropriate. The backlog carries no greenfield scaffolding story, which is correct for a live 28-page site. Compatibility work is explicit: Story 2.1 repairs existing canonicals, Story 8.8 maps GitBook-era paths through `jekyll-redirect-from`, Story 10.10 asserts the five API page URLs are unchanged against the recorded baseline, and Story 11.11 pairs a retirement with a redirect. The architecture specifies no starter template, so the absence of a "set up from starter template" story is correct rather than a gap.

### Findings by severity

Findings C1 through C4, M1 and M2 were remediated in `epics.md` during this assessment. Each finding below is stated as it was found; the remediation actually applied is recorded in `## Summary and Recommendations`.

#### Critical

**C1 — Story 2.9 links to a page that does not exist until Story 11.6.**
Story 2.9's `When` clause reads: "the figure is replaced by a `TODO(owner: <handle>):` marker and a link to the pricing page structure created in Epic 11." `pricing.md` is created by Story 11.6, 84 stories later. html-proofer runs from Story 1.3 onward and fails on dead internal links, so `rake check` goes red the moment Story 2.9 lands and stays red until Epic 11. Definition of Done clause (a) becomes unsatisfiable and the implementation loop cannot advance.

- Remediation: drop the forward link from Story 2.9. The `TODO(owner:)` marker plus the `currency-outside-data` assertion already carry the story's value. If a destination is wanted, point at `support.md`, which Story 6.10 creates, or leave the marker unlinked.

**C2 — Stories 5.4, 5.5 and 5.6 require troubleshooting pages that Epic 6 creates.**
The `task-page-shape` assertion registered by Story 5.4 fails "when its final section contains no link to a page under `/troubleshooting/`". The first troubleshooting page is Story 6.2. Stories 5.4, 5.5 and 5.6 each author a `page_type: task` page, so each must carry a link into a section that does not yet exist. html-proofer fails on the dead link; if the link is omitted, `task-page-shape` fails instead. Either way `rake check` is red.

- Remediation: two options, both clean. Either move the `task-page-shape` link clause out of Story 5.4 and into Story 6.11, which already registers `task-links-troubleshooting` for exactly this rule and correctly sits after the symptom pages exist; or move Epic 6 ahead of Epic 5. The first option is smaller and preserves the epic order the PRD fixed. Story 5.4 keeps the four-heading skeleton assertion; the link requirement activates at 6.11.

**C3 — Story 5.3 asserts a condition that Story 8.1 creates.**
Story 5.3 registers `description-unique` and `description-not-site-default` and opens with "Given every page now declares its own `description`". No story before 5.3 authors those descriptions — Story 8.1 does, 43 stories later, and its own acceptance criteria acknowledge this by referring back to "the assertions `description-unique` and `description-not-site-default` from Story 5.3". Registered at 5.3, satisfied at 8.1. Every page inherits the single `_config.yml` description today, so both assertions fail on all 28 pages the moment Story 5.3 lands.

- Remediation: merge the two stories. Either move the assertion registration from 5.3 into 8.1 so registration and satisfaction land together, or move the description-authoring work from 8.1 into 5.3. The second is preferable, because unique descriptions are a navigation contract the Epic 5 router pages depend on.

**C4 — Story 10.10 declares a parent that Story 11.5 creates.**
Story 10.10 has the five interface pages "declare the new APIs router as its `parent:`". `apis/index.md` is authored by Story 11.5. The UX spine's IA assertion 5 fails when a page declares `parent: X` and no page with `title: X` declares `has_children: true`, so the build breaks on the parent-resolution check.

- Remediation: have Story 10.10 create `apis/index.md` as a minimal router as part of its own change — it is otherwise a front-matter-only story, so the addition is small — and reduce Story 11.5 to enriching that router with the intent table and the cross-page banners. Alternatively swap the two stories' positions.

#### Major

**M1 — no story implements the contrast and palette-drift assertion.**
Carried forward from the UX alignment step. PRD NFR8 and DESIGN.md both require it; the architecture spine names the file it reads; zero stories create it. Recommendation is in the UX Alignment Assessment above.

**M2 — the pinned root-section count has no update path.**
Story 5.9 registers `root-section-count`, which "fails when the number of pages with an integer `nav_order` and no `parent:` differs from the pinned count." Six later stories add a root section: 6.1 Troubleshooting, 6.10 Support, 9.9 Trust, 10.10 or 11.5 APIs, 11.6 Pricing, and the Concepts router at 4.6 if Epic 4 runs after 5.9 in a reordered run. None of those stories states that it must bump the pinned count in the same commit. Each will fail the assertion on landing until an implementer works out why.

- Remediation: add one sentence to Story 5.9's acceptance criteria requiring the pinned value to live in a single named constant, and one `And` clause to each root-section-adding story requiring that constant to be updated in the same commit. This is the mechanism the UX spine intends — "Growth is allowed; silent growth is not."

#### Minor

**m1 — duplicate assertion ownership.** `description-unique` and `description-not-site-default` are referenced by both Story 5.3 and Story 8.1; the troubleshooting-link rule appears in both `task-page-shape` (5.4) and `task-links-troubleshooting` (6.11). Resolving C2 and C3 removes both overlaps. Until then, an implementer may register the same assertion identifier twice, which the registry treats as a collision.

**m2 — FR identifiers absent from story text.** Recorded in the coverage step. Stories cite memlog lines and audit findings rather than FR numbers, so FR traceability is derived rather than declared.

**m3 — the `_data/pipeline.yml` reading order is unassigned.** Story 4.8 creates the file; no story applies pipeline order to the fifteen `features/*` children. Carried forward from EXPERIENCE.md open question 1.

### Best-practices compliance checklist

Stated as found, with the post-remediation result in the right-hand column.

| Check | Result as found | After remediation |
| --- | --- | --- |
| Epic delivers user value | 9 of 11 pass outright; Epics 1 and 7 pass with the documented deviation note above. | Unchanged. |
| Epic can function independently | 9 of 11 pass; Epics 5 and 10 carry the forward dependencies C2 and C4. | 11 of 11. C2 and C4 are closed. |
| Stories appropriately sized | Passes. 112 of 112. | Passes. 113 of 113. |
| Zero forward dependencies | **Fails.** Four found: C1, C2, C3, C4. | **Passes.** All four closed in `epics.md`. |
| Entities created when needed | Passes. `_data/` files are created at first use, not upfront. | Unchanged. |
| Clear acceptance criteria | Passes. 112 of 112 carry a complete Given/When/Then plus a named assertion identifier. | Passes. 113 of 113. |
| Traceability to requirements maintained | Passes with the minor caveat m2. | Unchanged. |

## Summary and Recommendations

Assessed by the Product Owner proxy on 2026-08-01 against `prd.md`, `architecture.md`, `epics.md`, `ux-designs/ux-docs-2026-08-01/EXPERIENCE.md`, `ux-designs/ux-docs-2026-08-01/DESIGN.md` and `project-context.md`.

### Overall Readiness Status

**READY.**

The planning set is internally consistent and complete: 37 of 37 functional requirements are implemented by at least one story, zero requirements are unimplemented, zero stories are orphaned, and every one of the twelve audit findings has a named closing epic and at least one named assertion. The architecture spine fixes the single quality gate (`rake check`) that every story's Definition of Done clause (a) depends on, and Epic 1 builds that gate before any content story runs.

The four Critical findings were not requirement gaps — they were sequencing defects, each one a forward dependency in a backlog whose execution order is strictly ascending story ID. Every one would have left `rake check` red at the story that landed it, which under a one-story-at-a-time implementation loop means a stall rather than a slow build. All four were remediated in `epics.md` during this assessment rather than deferred, because handing an autonomous loop a backlog with a known unsatisfiable Definition of Done is worse than the edit cost of fixing it. Both Major findings were remediated on the same reasoning.

### Critical Issues Requiring Immediate Action

Zero open Critical issues. All four were closed by edits to `epics.md` made during this assessment.

| ID | Defect | Edit applied to `epics.md` |
| --- | --- | --- |
| C1 | Story 2.9 linked to a pricing page created 84 stories later | Story 2.9's `When` clause now replaces the figure with an unlinked `TODO(owner: <handle>):` marker and states why the link is withheld. The `currency-outside-data` assertion is unchanged. |
| C2 | Story 5.4's `task-page-shape` demanded a `/troubleshooting/` link before Epic 6 created any such page | Story 5.4 now asserts only the four-heading skeleton and explicitly hands the troubleshooting-link clause to Story 6.11, which already registers `task-links-troubleshooting` and correctly sits after the symptom pages exist. Epic order is unchanged. |
| C3 | Story 5.3 registered `description-unique` and `description-not-site-default` while Story 8.1 authored the descriptions 43 stories later | Story 5.3 now authors every page's `description` in the same commit that registers both assertions. Story 8.1 was rewritten to depend on that state and to add a new `description-length` assertion (50 to 160 characters) rather than re-register the two it inherits. |
| C4 | Story 10.10 declared `parent:` against an APIs router created by Story 11.5 | Story 10.10 now creates `apis/index.md` itself as a minimal router with `has_children: true`, `page_type: router` and an integer `nav_order`, and asserts `api-pages-urls-unchanged` against `_data/baseline.yml`. Story 11.5 was reduced to enriching the router that already exists. |

### Major Issues

Zero open Major issues.

| ID | Defect | Edit applied to `epics.md` |
| --- | --- | --- |
| M1 | Zero stories implemented the contrast and palette-drift assertion that PRD NFR8, DESIGN.md section Colors and architecture spine AD-6 all require | **Story 2.15 "Freeze the palette and its contrast floor" was added to Epic 2.** It registers `palette-constants` (the fourteen hex values parsed from `_sass/color_schemes/signalsapi.scss` must match DESIGN.md) and `palette-contrast-floor` (WCAG relative-luminance ratio computed in plain Ruby, failing below 4.5:1). Neither needs a browser, so the rejection of pa11y-ci and axe stands. |
| M2 | The `root-section-count` pin had no update path, so six later stories would each fail it on landing | Story 5.9 now requires the count to live in a single named constant at the top of `script/checks/root-section-count.rb`, adds a `title-unique` assertion because `parent:` resolves by title, and binds every later story that adds or retires a top-level section to update the constant in the same commit. |

**Backlog size changed.** Epic 2 grew from 14 stories to 15 and the total is now **113 stories across 11 epics**, not 112. Every downstream count — sprint planning, the Ralph fix plan, the handover report — must read 113.

### Minor Issues Left Open

Three, all deliberately.

- **m1 — duplicate assertion ownership.** Closed as a side effect of the C2 and C3 remediations. Each of `description-unique`, `description-not-site-default` and the troubleshooting-link rule now has exactly one registering story.
- **m2 — FR identifiers absent from story text.** Stories cite memlog lines and audit finding numbers rather than FR numbers, so FR traceability is derived rather than declared. Left as is: the audit findings are the problem statement this backlog exists to close, and re-citing FR IDs across 113 stories buys documentation symmetry, not build safety. The coverage matrix in this report is the traceability record.
- **m3 — the `_data/pipeline.yml` reading order is unassigned.** Story 4.8 creates the file; zero stories apply pipeline order to the fifteen `features/*` children. Carried forward from EXPERIENCE.md open question 1. Left open: the file exists and is asserted for shape, so nothing breaks. Applying the order is a content judgement the first implementer of Epic 7 can make with the data file in front of them, and forcing it now would be inventing an ordering the sources do not state.

### Recommended Next Steps

1. **Start implementation at Story 1.1 and run in strict ascending story ID order.** The backlog is now free of forward dependencies, and that property only holds if the order is respected. A reordered run reintroduces exactly the class of defect this assessment removed.
2. **Treat Story 1.1 as the sole Definition of Done exemption.** It creates the `Rakefile` and the `script/check.rb` runner that clause (b) names. From Story 1.2 onward, clause (b) binds without exception: every story adds at least one assertion to `script/check.rb` or one rule to `.vale.ini` that fails at the branch point before the change and passes after.
3. **Land Epic 1 whole before any content story.** Epics 2 through 11 have zero satisfiable Definition of Done until `rake check` exists and CI runs it.
4. **Keep the root-section constant honest.** Six stories add a top-level section after Story 5.9 pins the count. Each is now bound to bump the constant in the same commit. An implementer who splits that edit into a follow-up commit will land a red build.
5. **Do not resolve a `TODO(owner: <handle>):` marker by inventing a figure.** Prices, plan allowances, credit costs, commission rates, match rates, uptime and latency are unsourceable from this repository. The marker plus the render mechanism is the shipped deliverable; `script/check.rb` inventories the markers so none is lost.
6. **Revisit the three open EXPERIENCE.md questions before Epic 7.** The pipeline reading order (m3) is the only one that touches a story's content, and it wants the data file in front of it.
7. **Re-run this readiness check if the epic order is ever changed.** The forward-dependency analysis is order-sensitive and none of its conclusions survive a reordering.

### Final Note

This backlog was assessed at the story level rather than the epic level, and that is where the findings were. Mechanical validation — unique IDs, strict `N.M` format, an epic heading above every story, a complete Given/When/Then in every story — passed cleanly on the first pass and would have signed the backlog off. Reading the 113 stories in execution order is what surfaced four cases where a story asserted or linked against a page, a router or a front-matter field that a later story creates. Under an implementation loop that takes one unchecked story at a time in ascending order, each of those is a stall, not a slow build: `rake check` goes red, Definition of Done clause (a) cannot be met, and the loop has nowhere to go.

The remediation was to edit `epics.md`, not to annotate the risk. Seven story edits and one new story closed C1 through C4, M1 and M2. The backlog is now 113 stories across 11 epics with zero known forward dependencies, 100 percent functional-requirement coverage, and a first epic that builds the gate everything else is measured by.

One property is worth stating plainly, because it is what makes this backlog implementable by a machine rather than merely readable by a person: every story's acceptance criteria names the assertion identifier that proves it. That is not documentation discipline — it is the mechanism by which a reverted change fails the build. It was designed in at the architecture layer (AD-2 and AD-3) so that adding the hundredth assertion costs the same as adding the second. If that property is ever relaxed for convenience, the verification-first thesis this whole overhaul rests on goes with it.

**Assessed:** 2026-08-01. **Assessor:** Product Owner proxy, `bmad-check-implementation-readiness`. **Verdict:** READY.



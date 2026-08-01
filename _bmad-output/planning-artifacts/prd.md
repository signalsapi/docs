---
title: 'PRD: SignalsAPI Documentation Overhaul'
status: final
created: '2026-08-01'
updated: '2026-08-01'
---

# PRD: SignalsAPI Documentation Overhaul

## Vision

`docs.signalsapi.com` becomes a documentation *system* rather than a documentation *artifact*: every fact has one home, every claim is either sourceable from this repository or absent, and every defect closed by this workstream is closed by a machine assertion that fails the build if it returns.

The site today is a 28-page, 17,349-word GitBook inheritance that contradicts the product in production — `faq.md:51` sells phone numbers at a monthly price while `features/find-phone-numbers.md:12` states phones come from the customer's own LeadMagic key — and nothing in the repository can detect it. CI runs `bundle exec jekyll build`, which exits 0 in 0.52 seconds with a 21-month-dead link, a duplicated `nav_order`, 28 malformed canonical URLs, and the unedited just-the-docs template README published live at `docs.signalsapi.com/README.md`.

A 2026-07-31 audit produced 81 verified findings; the brainstorm over them produced 311 ideas across 14 techniques and 9 synthesis insights. The load-bearing insight (SYNTHESIS 8, `.memlog.md:354`) names the root cause: nobody owns the docs, so every fact rots — and the only fix in the entire set that is structural rather than editorial is making regression visible by default.

Therefore this PRD does not begin with content. It begins with a machine that can fail the build.

## Context and Problem

Three readers arrive and all three leave wrong.

**The operator** — a recruitment-agency user setting up a first search — lands on `index.md`: 325 words of pitch, zero links into the documentation, closing on "Which side do you want to be on in 12 months?" and a booking link. There is no quick start (`quick-start.md` was deleted; recoverable at `835852a^`). When their lead list comes back empty, the nine known causes exist only as one-line asides on unrelated pages.

**The developer** integrating the REST API or the agent data plane finds no OpenAPI spec, no `robots.txt`, no `sitemap.xml`, and an MCP parity claim asserted in prose rather than computed. The changelog has been dead since 2025-04-09, so API access (2026-06-30) and the agent data plane (2026-07-09) both shipped with documentation and no announcement.

**The AI agent** reading the corpus as a tool finds 28 identical meta descriptions, 28 malformed canonicals, no `llms.txt`, and instructional payload sealed inside 62 empty-alt PNGs — eight of which depict a UI the application no longer has. A company selling an agent data plane and an MCP server publishes among the least agent-readable docs on the internet (SYNTHESIS 3, `.memlog.md:349`).

The cost compounds silently. Every unowned page rots one more month; every ticket answered by email leaves no trace; every published contradiction spends credibility the product must re-earn.

## Users

| User | Need | Success looks like |
|---|---|---|
| **Operator** (primary) | Set up a first search, get leads, self-diagnose when the list is empty | Reaches a populated lead list without opening email; when empty, lands on a page named after their symptom |
| **Developer** (primary) | Integrate the REST API, agent data plane, or Clay | Reads one spec and knows which operations exist, which are live, which are code-complete but unhosted — without inferring it from prose |
| **AI agent** (primary, currently unserved) | Read the corpus as a tool | Retrieves the whole corpus from `llms-full.txt` or the docs MCP server; every page carries a correct canonical and a real description |
| **Maintainer** (secondary) | Keep it true after this lands | A regression fails CI instead of surviving 21 months |

## Scope

### In Scope

Anything that is a pure change to this repository, verifiable by `rake check` on the developer's machine with no network call at build time or page-view time. That includes sequencing phases 1-3, the entire `_data/` refactor, every troubleshooting and concepts page (the facts already exist as asides in-repo), all SEO and machine-readability work, CI hardening, and the static subset of the agent-data-plane work.

### Out of Scope

1. **Any live network call at build time or page-view time.** No Run buttons, live counters, `/panel`, Hiring Pulse Index, live ICP checker, free domain lookup, measured `/data-freshness`.
2. **Standing up, minting, or describing-as-existing any sandbox key or public base URL.** Spec + static fixtures + `prism` mock only; no page may contain a string implying a live sandbox, a public base URL, or an issued key exists. Enforce as a Vale deny rule.
3. **Hosting an MCP server.** Source + connect snippet in scope; deployment, npm publish, public URL out.
4. **Ledger-generated programmatic pages** — `/market/*`, `/hiring/*`, Signal Index, the 290-source directory, nightly provider benchmark.
5. **Any change to `app.signalsapi.com` or the app repo.** Docs may publish a contract; docs may not claim the app consumes it.
6. **Screenshot re-capture, Playwright rigs, nightly app-label assertions.** Deleting stale screenshots and replacing them with text click-paths and field tables IS in scope.
7. **Publishing any number not sourceable from this repo** — prices, plan allowances, credit costs, commission rates, match rates, uptime, latency, the 290-source list. Ship the render mechanism plus a `TODO(owner):` marker in `_data/` that `script/check.rb` flags. Never invent a figure.
8. **Legal/compliance artifacts** — privacy-policy rewrite, DPA, sub-processor commitments, accessibility conformance claims, GDPR guidance, data-subject removal forms. Draft to `_drafts/` only.
9. **Analytics, telemetry, feedback collectors, zero-result search logging** — anything that POSTs. GitHub-issue-prefill is the permitted substitute.
10. **Domain and hosting changes** — rehosting, sandbox subdomains, DNS, status-page components.
11. **Localization / translation.**
12. **Human research outputs** — user testing, inbox mining, `/asked`, `/incidents`, credits-for-docs-PRs.
13. **Design assets requiring a designer.** Programmatically generated OG cards from page title + the existing palette are in scope.
14. **Memlog #197 "Collapse 28 pages into one scrolling URL with anchors."** Destroys the URL surface. Reject outright.
15. **Any bulk page deletion not paired with `jekyll-redirect-from` entries in the same commit.**
16. **Memlog #328's service worker.** Take the fixtures, drop the SW.

## Scope Rationale

**Item 7 — never invent a figure.** This is the single highest-risk failure mode in the workstream; roughly 15 of the 311 brainstormed ideas invite it. The current docs are untrustworthy *precisely because* someone once wrote a plausible number. Where a figure is unsourceable, the story ships the render mechanism plus a `TODO(owner):` marker in `_data/` that `script/check.rb` flags — never a placeholder that reads as fact.

**Item 9 — no collectors.** Anything that POSTs needs a backend, a retention policy and a privacy disclosure this workstream cannot deliver. The permitted substitute is memlog #301: "No backend — the issue body is the log." A prefilled GitHub issue link captures the same signal with zero infrastructure.

**Item 16 — no service worker.** A service worker makes the browser demo pass while the printed `curl` fails in a terminal — a demo that lies about the artifact printed next to it. Fixture URLs served from the docs origin achieve the same goal honestly and are `curl`-verifiable in CI.

**The flagship, honestly scoped.** SYNTHESIS 1 (`.memlog.md:347`) — a public read-only sandbox key for the agent data plane — was the strongest convergence in the entire brainstorm, independently invented by 8 of 12 techniques. **It is not buildable in this repository.** It needs a hostname, DNS, TLS, key minting and scoping, per-IP rate limits, abuse controls, revocation, a frozen anonymized demo tenant in the production database, and legal review of serving named-company hiring data keyless. No story pretends otherwise.

Roughly 80% of its value *is* buildable, as the Epic 10 static subset:

1. `openapi/plane-v1.yaml` — OpenAPI 3.1 covering every endpoint already documented in `features/agent-data-plane-api.md`, with components for the provenance envelope, the `X-Data-Freshness` and `X-Meter-Class` headers, the `202 {"job_id":…,"status":"crawling"}` response, and the four meter units (`call`, `change`, `watch`, `forced_fresh`). Two vendor extensions per operation: `x-mcp-tool` and `x-status: live|code-complete|planned`. Verified by `npx @stoplight/spectral-cli lint`.
2. `/fixtures/v1/**.json` — static recorded response bodies for ~20-50 fixed domains (`zollsoft.de` is already the worked example in `agent-data-plane-clay.md` and `api-access.md`), emitted by Jekyll pages with `layout: null`, each carrying `"recorded_on": "2026-07-31"` inside the payload. **These are real URLs** — `curl https://docs.signalsapi.com/fixtures/v1/hiring-pulse/zollsoft.de.json` genuinely works from any terminal, today, with no key.
3. A runnable curl gallery where every fenced block targets those fixture URLs, printed above a paired "same call against the production base URL (pending)" block.
4. `prism mock openapi/plane-v1.yaml` as the one-command local sandbox — reader-side execution, zero ops.
5. `mcp/` — a stdio MCP server reading the fixtures plus `_site/assets/js/search-data.json`, with the literal `claude_desktop_config.json` block. Works via `node mcp/server.js` from a clone.
6. `/plane-status.json` plus a generated status column, replacing the false "can never drift" parity language with a computed sentence of the shape "MCP exposes N of M operations; K are REST-only."
7. Replace the four `email mykola@signalsapi.com` dead-ends with: spec download → fixtures → mock command → waitlist link. **Not** with a fake key.

## Functional Requirements

### Group A — Verification harness (Epic 1)

- **FR1.** A `Rakefile` defines `rake check` = `jekyll build` → `html-proofer` → `vale` → `ruby script/check.rb`, exiting nonzero on the first failure.
- **FR2.** `html-proofer ~> 5` is added to the `Gemfile` and runs `--disable-external` in the PR path, asserting internal link integrity, image presence, unique ids, valid anchors and non-empty `alt` attributes.
- **FR3.** Vale runs from an in-repo `.vale.ini` plus `styles/SignalsAPI/`, exiting 1 on error-level rules.
- **FR4.** `script/check.rb` exists as plain stdlib Ruby (no new gem) and holds every repository invariant that html-proofer and Vale cannot express.
- **FR5.** `_config.yml` sets `strict_front_matter: true`; `.ruby-version` pins `3.3`; `.github/workflows/ci.yml` runs exactly `bundle exec rake check`.

### Group B — Credibility patch (Epic 2)

- **FR6.** No rendered page contains a malformed canonical, `og:url` or JSON-LD URL. *(Closes F1 — remove the trailing slash from `url:` at `_config.yml:7`; asserted by "no file under `_site/` contains `docs.signalsapi.com//`".)*
- **FR7.** `_config.yml` declares `exclude:` covering `README.md`, `LICENSE`, `push.sh`, `run.sh`, `Gemfile`, `Gemfile.lock`. *(Closes F2; asserted by "`_site/` root contains no file lacking front matter".)*
- **FR8.** Every internal link resolves. *(Closes F3 — `features/filter-leads-with-ai.md:32`.)*
- **FR9.** No currency symbol or commercial figure appears outside `_data/pricing.yml`. *(Closes F4 — the contradicted `faq.md:26` and `faq.md:51` figures are deleted, not reconciled; the "propsects" typo goes with them.)*
- **FR10.** `nav_order` is unique within each parent, and leaf content pages use `layout: default` rather than `layout: home`. *(Closes F5 and F6.)*
- **FR11.** The site declares `permalink: pretty`, ships `jekyll-sitemap`, `robots.txt`, and a `404.md` with `permalink: /404.html` wired to the lunr index, and populates `aux_links`.

### Group C — Baseline (Epic 3)

- **FR12.** `_data/baseline.yml` records the 2026-07-31 as-is state (page count, word count, image count, finding set) and renders at `/docs-baseline`, so every later claim of improvement is measurable against a committed starting point. *(Source: `.memlog.md:302`.)*

### Group D — Core concepts and the object model (Epic 4)

- **FR13.** `_data/glossary.yml` is the single definition of the object model — Signal, Search, Filter, Persona, Lead list (= `project` in the REST API), Credit, and the pipeline order — rendering `/concepts` and feeding Vale rules that fail on banned aliases (`personation`, "project" used for a lead list in prose, "person settings", "campaign"). *(Source: `.memlog.md:99`.)*

### Group E — Getting started (Epic 5)

- **FR14.** `index.md` is a task router linking into the documentation, not a pitch. *(Closes F10; source `.memlog.md:96`, `.memlog.md:120`.)*
- **FR15.** A written quick start exists (restored from `835852a^`, no video embed), plus three role-shaped quickstarts — recruitment-agency owner, B2B service provider, agent builder — and explicit documentation of creating a search, the primary product action and currently undocumented. *(Source: `.memlog.md:93`, `.memlog.md:226`.)*

### Group F — Symptom-named troubleshooting (Epic 6)

- **FR16.** A `/troubleshooting` section exists with pages named after the symptom the user types: "Why is my lead list empty?" (all nine causes as a decision tree), "Why is the phone column blank?", "What does Enriching mean?" *(Source: `.memlog.md:23`, `.memlog.md:114`, `.memlog.md:282`.)*
- **FR17.** A statuses-and-error-codes reference and a single support page carrying a copy-paste diagnostic block exist, retiring the `mykola@` / `support@` split. *(Source: `.memlog.md:283`, `.memlog.md:286`, `.memlog.md:105`.)*

### Group G — `_data/` single source of truth (Epic 7)

- **FR18.** Six datasets live in `_data/`: `providers.yml`, `variables.yml`, `integrations.yml`, `filters.yml`, `pricing.yml`, `glossary.yml`. *(SYNTHESIS 2, `.memlog.md:348`.)*
- **FR19.** Every surviving page that restates one of those datasets renders it through Liquid instead. A `_data` key may not be renamed without updating every `site.data` reference in the same commit.
- **FR20.** Affiliate URLs are emitted only through a shared include that is structurally incapable of producing a link without `rel="sponsored nofollow"` and its cost label; unsourceable cost values ship as `TODO(owner):` markers. *(Source: `.memlog.md:327`; SYNTHESIS 7.)*

### Group H — SEO and machine-readability (Epic 8)

- **FR21.** Every page carries a unique, non-default `description:`. *(Closes F7.)*
- **FR22.** `/llms.txt` and `/llms-full.txt` are generated from `site.pages` via `layout: null` pages. *(SYNTHESIS 3; source `.memlog.md:76`, `.memlog.md:257`.)*
- **FR23.** `head_custom.html` emits schema.org JSON-LD (including FAQPage where applicable) and a programmatically generated 1200×630 OG card built from the page title and the existing palette.
- **FR24.** `jekyll-redirect-from` maps GitBook-era paths, `.md`-suffixed paths, and any `features/*` slug that moves.

### Group I — Trust and governance (Epic 9)

- **FR25.** Every page carries `verified_on:` and `verified_against:` front matter, rendered as a freshness chip, with a `script/check.rb` staleness assertion. *(SYNTHESIS 8.)*
- **FR26.** `/docs-health` renders the audit finding set from `_data/` with status and fix date, alongside the live CI assertions — the burn-down is published, not claimed. *(Source: `.memlog.md:58`, `.memlog.md:112`.)*
- **FR27.** "When SignalsAPI is the wrong tool" and the limits page are drafted to `_drafts/` for review. *(SYNTHESIS 4; source `.memlog.md:116`.)*

### Group J — Agent data plane, static subset (Epic 10)

- **FR28.** `openapi/plane-v1.yaml` exists per the Scope Rationale specification and passes `npx @stoplight/spectral-cli lint`.
- **FR29.** `/fixtures/v1/**.json` static recorded bodies exist, each carrying `"recorded_on"` in the payload.
- **FR30.** A curl gallery targets those fixture URLs, paired with a "same call against the production base URL (pending)" block, plus `prism mock` instructions.
- **FR31.** `mcp/` holds stdio MCP server source and the literal `claude_desktop_config.json` connect snippet. Source only — no hosting.
- **FR32.** `/plane-status.json` and a generated status column replace the "can never drift" parity language with a computed sentence.
- **FR33.** The four `email mykola@signalsapi.com` dead-ends are replaced with spec → fixtures → mock → waitlist.

### Group K — Content ops cleanup (Epic 11)

- **FR34.** Stale screenshots are deleted and their instructional payload written out as text click-paths and field tables; no image ships with empty `alt`. *(Closes F8; source `.memlog.md:86`, `.memlog.md:117`, `.memlog.md:119`.)*
- **FR35.** `features/index.md` declares `has_children: true` so `features/*` nests correctly, and an `/apis/` router page exists. *(Closes F9; source `.memlog.md:284`, `.memlog.md:118`.)*
- **FR36.** A Pricing page exists with real structure — plans, credit model, BYO-provider phone model — and a `TODO(owner):` marker for every figure not sourceable from this repository. *(Source: `.memlog.md:290`.)*
- **FR37.** The changelog moves to `_data/changelog.yml` and renders from there; the 2026-06-30 API-access and 2026-07-09 agent-data-plane entries are backfilled. *(Closes F11; source `.memlog.md:75`, `.memlog.md:100`.)*

## Non-Functional Requirements

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

## Verification

Today's only signal is `bundle exec jekyll build` (0.52 s, exit 0). **Every audit finding builds green.** That signal is insufficient and must not be the loop's gate.

The mandated stack — all deterministic, all offline-capable except the nightly external check:

| Tool | Install | Catches |
|---|---|---|
| `jekyll build` + `strict_front_matter: true` | one `_config.yml` key | malformed front matter (currently only a warning) |
| **html-proofer ~> 5** | `gem "html-proofer"` in Gemfile | dead internal links (incl. `filter-leads-with-ai.md:32` → `ai-variables.md`), missing images, duplicate ids, bad anchors, **empty alt (62 of 70 today)**. **Primary gate.** `--disable-external` in PR CI; external nightly with `--only-4xx` |
| **Vale** | Go binary, `errata-ai/vale-action@v2` | the glossary lock: `personation`, `lead list` vs `project`, `100% reliable`, unqualified `real-time`, `mykola@`, live-sandbox claims. Exit 1 on error-level rules. `.vale.ini` + `styles/SignalsAPI/` in-repo |
| **`script/check.rb`** (plain Ruby, no new dep) | write it | unique non-default `description:`; unique `nav_order` per parent; no `£/€/$` outside `_data/pricing.yml`; every vendor name resolves in `_data/providers.yml`; **`_site/` root contains no file without front matter** (regression-guards README/push.sh/run.sh); `verified_on` ≤ N days; every `?via=`/`?fp_ref=` URL carries `rel="sponsored nofollow"` |
| **Spectral** | `npx @stoplight/spectral-cli` | OpenAPI validity — only once Epic 10 lands |
| **lychee** | Rust binary | external 404s — **nightly cron only, never in the loop** |

pa11y-ci and axe are **deliberately rejected** from the main loop — headless Chrome is slow and flaky for a 28-page static site. Accessibility is handled as one-shot stories verified by html-proofer's alt check plus the contrast constant in `script/check.rb`.

**The mandated mechanism:**

> Add a `Rakefile` with `rake check` = build → html-proofer → vale → `script/check.rb`, exiting nonzero on any failure. `ci.yml` runs exactly `bundle exec rake check`.
>
> **Definition of Done for every story:** (a) `rake check` is green, AND (b) the story adds at least one new assertion to `script/check.rb` or a new rule to `.vale.ini` that **fails on the branch point before the change and passes after**.
>
> Clause (b) is non-negotiable. Without it the loop inherits a build that was already green before the audit and will stay green through every regression. With it, every story is a genuine red→green and the gate strictly ratchets. Stories that cannot express (b) (pure prose additions) must instead be paired with a coverage assertion — e.g. "`_data/symptoms.yml` has ≥ 6 entries and each renders a page returning 200 in `_site`".

Clause (b) becomes binding from Story 1.2 onward; Story 1.1 creates the harness itself. Also pin Ruby: add `.ruby-version` = `3.3` so local green matches CI green (local is currently 3.1.3, CI is 3.3).

## Delivery Sequence

The brainstorm's five-phase direction (`.memlog.md:356`) is (1) credibility patch, (2) core concepts + getting started + symptom-named troubleshooting, (3) `_data/` single-source-of-truth refactor with CI gates, (4) machine-readability, (5) ledger-generated market pages.

One deviation applies: **the verification harness is pulled ahead of everything.** The implementation loop takes strictly the first unchecked item in epic/story-ID order, and Definition of Done clause (b) is unsatisfiable until `script/check.rb`, `.vale.ini` and the `Rakefile` exist. Phase 5 is out of scope entirely.

| Epic | Title | Closes |
|---|---|---|
| 1 | Verification harness | F12 |
| 2 | Credibility patch (Story 2.1 = the one-character trailing-slash fix) | F1, F2, F3, F4, F5, F6 |
| 3 | Baseline | — |
| 4 | Core concepts and the object model | — |
| 5 | Getting started | F10 |
| 6 | Symptom-named troubleshooting | — |
| 7 | `_data/` DRY refactor | F4 (structurally) |
| 8 | SEO and machine-readability | F7 |
| 9 | Trust and governance | — |
| 10 | Agent data plane, static subset | — |
| 11 | Content ops cleanup | F8, F9, F11 |

## Requirements Inventory

| Finding | Defect | Closed by | Epic |
|---|---|---|---|
| F1 | `_config.yml:7` trailing slash malforms all 28 canonicals | FR6 | 2 (Story 2.1) |
| F2 | No `exclude:` — README, `push.sh`, `run.sh`, LICENSE, Gemfile published | FR7 | 2 |
| F3 | `filter-leads-with-ai.md:32` dead `ai-variables.md` link, 21 months | FR2, FR8 | 2 |
| F4 | `faq.md:26` and `faq.md:51` figures contradict `find-phone-numbers.md:12`; "propsects" typo | FR9, FR18 | 2, 7 |
| F5 | `nav_order: 6` collision; `5` unused; float shims elsewhere | FR10 | 2 |
| F6 | `layout: home` on leaf content pages | FR10 | 2 |
| F7 | 28 pages inherit one `description:`; no og:image, no JSON-LD | FR21, FR23 | 8 |
| F8 | 62 of 70 PNGs empty alt; eight 2024-10 screenshots depict a dead UI | FR2, FR34 | 1, 11 |
| F9 | `features/index.md` lacks `has_children: true` | FR35 | 11 |
| F10 | `index.md` is 325 words of pitch, zero docs links; no quick start | FR14, FR15 | 5 |
| F11 | Changelog dead since 2025-04-09; two 2026 launches unannounced | FR37 | 11 |
| F12 | `ci.yml` is `jekyll build` only — exits 0 with all of the above | FR1-FR5 | 1 |

## Success Metrics

Deliberately mechanism-shaped. This PRD asserts no metric it cannot source.

1. `bundle exec rake check` is the sole CI command and exits nonzero on any of F1-F12 reintroduced.
2. Every one of F1-F12 is either closed with a paired assertion or explicitly deferred with a written reason.
3. `html-proofer` passes with zero internal broken links and zero missing `alt` attributes.
4. Vale rejects the banned vocabulary set at error level, including any string implying a live sandbox key or public base URL.
5. No currency symbol exists outside `_data/pricing.yml`.
6. `llms.txt`, `llms-full.txt`, `sitemap.xml`, `robots.txt` and `openapi/plane-v1.yaml` exist and are asserted present.
7. Every page carries a unique `description:` and a `verified_on:` date, both enforced.
8. `/docs-health` renders the finding set from `_data/`.

**Counter-metrics** — what would indicate this went wrong:

- A story lands with `rake check` green but no new assertion. That is the failure mode clause (b) exists to prevent; it means the ratchet stopped.
- A `TODO(owner):` marker is silently replaced with a plausible number rather than a sourced one.
- Page count grows while `/docs-health` staleness grows with it — volume added without ownership.
- A page is deleted without a paired redirect, trading an audit finding for lost URL surface.

## Assumptions

- `[ASSUMPTION]` F1-F12 and the 81-finding audit behind them are accurate as of 2026-07-31 and still present in `main`. F1, F3, F4, F5, F6 and F12 were spot-verified by direct file read.
- `[ASSUMPTION]` Arbitrary Jekyll plugins are legal because `pages.yml` is a custom Actions build. Verified in `.github/workflows/pages.yml`.
- `[ASSUMPTION]` No unit-test framework is wanted; `rake check` is the only gate. Inherited from `project-context.md` as a binding constraint.
- `[ASSUMPTION]` The four user profiles are inferred from repository content and the brainstorm, not from interviews or analytics. No usage data was available.
- `[ASSUMPTION]` The endpoints documented in `features/agent-data-plane-api.md` are an accurate description of the intended contract, so an OpenAPI spec derived from them is faithful. `x-status` values are an open question.
- `[ASSUMPTION]` `zollsoft.de` remains an acceptable public worked example; it already appears in `agent-data-plane-clay.md` and `api-access.md`.
- `[ASSUMPTION]` Stakes = launch. The site is in production and every defect is publicly visible.

## Open Questions

1. **Prices, plan allowances, credit costs, free-tier grant.** Nothing sourceable exists in-repo; `faq.md`'s figures are contradicted by `find-phone-numbers.md`. Blocks a truthful Pricing page — FR36 ships `TODO(owner):` until answered.
2. **Measured email-verification rate and median signal latency.** Needed to replace `faq.md:65`'s "100% reliable" and the unqualified "real-time" claim.
3. **Which agent-data-plane operations are live vs code-complete vs planned, and is there a public base URL yet?** Drives `x-status` in FR28 and the computed parity sentence in FR32.
4. **Is there a DPA, and who are the named sub-processors?** Determines whether the trust page can list them or must defer. FR27 drafts to `_drafts/` regardless.
5. **Docs owner and review cadence.** SYNTHESIS 8 identifies unowned docs as the root cause. FR25 ships the mechanism; assigning the owner is outside this workstream.
6. **Changelog migration depth** — backfill all 105 entries into `_data/changelog.yml`, or start fresh from 2026-06? The 53 PNGs (~1.9 MB) are the cost driver. FR37 assumes full migration.
7. **Affiliate cost-per-usable-lead values** for the FR20 include. Unmeasured today; ships as `TODO(owner):`.

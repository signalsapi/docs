---
title: 'Addendum: SignalsAPI Documentation Overhaul'
status: draft
created: '2026-08-01'
updated: '2026-08-01'
---

# Addendum

Depth that belongs downstream (PRD, architecture, epics) rather than in the brief.

## The Nine Synthesis Insights

Verbatim substance from `_bmad-output/brainstorming/brainstorm-better-docs-2026-07-31/.memlog.md:347-355`.

| # | Line | Insight | Disposition in this workstream |
|---|------|---------|-------------------------------|
| 1 | L347 | A public read-only sandbox/demo key for the agent data plane was independently invented by 8 of 12 techniques — the strongest convergence in the run. Converts the one audience that buys without a human; costs one cached Tier 0 read. | **Out of scope.** Requires a hosted endpoint this repository does not control. Substitute: OpenAPI spec + static fixtures + `prism mock`. |
| 2 | L348 | The master key is DRY applied to docs: move six datasets (providers, ai-variables, integrations, glossary, plans/pricing, changelog) into `_data/` and render pages as templates. Dissolves the four-name object model, the FAQ-vs-phone-pricing contradiction, the integrations self-contradiction, the provider-matrix duplication and changelog rot at once. ~49 content-ops ideas are facets of it. | **In scope.** Its own epic. |
| 3 | L349 | `llms.txt`, an OpenAPI spec and a docs MCP server are one idea wearing three hats: make the corpus machine-readable. A company selling an agent data plane publishes the least agent-readable docs on the internet. A docs MCP server has no hosting dependency and ships in a day. | **In scope.** MCP server publication is the one part with an external dependency — treat as its own story with a hosting decision. |
| 4 | L350 | Admitting weakness is the conversion lever — reached independently by Trickster, Worst Possible Idea and Relativity Frame Shift. When-not-to-use, published affiliate commissions, `/docs-health`, measured freshness instead of "real-time". | **In scope**, minus any figure that cannot be sourced. |
| 5 | L351 | Support deflection has one mechanic: name pages after the symptom the user types when broken, then wire the app's empty states to those anchors. Nine known causes of an empty lead list exist only as one-line asides on unrelated pages. | **Docs half in scope.** The app-side wiring is out — this repository may publish a contract, not claim the application consumes one. |
| 6 | L352 | The hiring-events ledger is the only asset that *creates* traffic. Programmatic role × geo × month pages are unique and un-copyable, and each can end with the search config that reproduces it. | **Out of scope.** Phase 5, after this workstream. |
| 7 | L353 | Resolved contradiction: no affiliate link renders without its measured cost-per-usable-lead beside it, plus a ninth row for a SignalsAPI managed-enrichment SKU. | **Mechanism in scope** (the include that structurally cannot emit a link without `rel="sponsored nofollow"` and a cost label). The measured costs are an open question. |
| 8 | L354 | `/docs-health` is not a page, it is the governance mechanism answering the Five Whys root cause: nobody owns the docs, so every fact rots. Independently invented 5 times. With `last_verified` front matter and CI gates it makes regression visible by default — the only structural rather than editorial fix in the set. | **In scope, load-bearing.** This is the thesis of the whole workstream. |
| 9 | L355 | Highest impact-to-effort in the session: delete one character. `_config.yml:7` `url:` trailing slash malforms all 28 canonicals, og:urls and JSON-LD urls into `docs.signalsapi.com//features/...`. | **In scope, first content story.** |

## Recommended Sequencing (memlog L356, verbatim substance)

1. Monday credibility patch — trailing slash, exclude README/push.sh/run.sh, fix the broken `ai-variables` link, strip the dead phone pricing from `faq.md`, add sitemap/robots/404.
2. Core concepts + Getting started + a symptom-named troubleshooting section.
3. `_data/` single-source-of-truth refactor with CI gates.
4. Public sandbox key + `llms.txt` + OpenAPI + docs MCP server.
5. Ledger-generated market pages.

Deviation applied by this brief: the verification harness is inserted **before** (1), so every credibility fix lands with the assertion that keeps it fixed. Item (4)'s sandbox key and item (5) entirely are excluded — see Rejected Alternatives.

## Technical Constraints Carried Forward

Binding, from `project-context.md`. Repeated here because the PRD and architecture consume this file.

- Jekyll `~> 4.3.4`; just-the-docs **exact-pinned** at `0.10.0`; kramdown 2.4 + GFM; rouge 4.3; Bundler 2.5.9. CI pins Ruby `3.3` inline in both workflows; there is **no `.ruby-version`** and local dev is 3.1.3 — local green does not prove CI green.
- Deployment is a **custom** Actions build (`pages.yml`: checkout → setup-ruby → configure-pages → `bundle exec jekyll build` → upload-pages-artifact → deploy-pages with a 3-attempt retry), not the GitHub Pages gem whitelist. Arbitrary plugins and `_plugins/` generators are legal.
- Adding a plugin is two edits: the gem in `Gemfile` **and** a `plugins:` array in `_config.yml`, which does not exist yet.
- `strict_front_matter: true` converts malformed front matter from a warning into a build failure. Intended — but one bad `.md` then breaks the whole build.
- Non-HTML output (JSON, txt, XML) is emitted from a Jekyll page with `layout: null` + `permalink:`. This is the mechanism for `llms.txt`, fixtures and `plane-status.json`.
- `script/check.rb` is plain stdlib Ruby — no new gem may be added to satisfy it.
- html-proofer runs `--disable-external` in the PR path; external link checking belongs in a nightly lychee job, never in the build loop.
- Headless-browser a11y runners (pa11y-ci, axe) are deliberately excluded from the loop; alt-text comes from html-proofer and the contrast constant is asserted in `script/check.rb` against `_sass/color_schemes/signalsapi.scss`.
- No live network call at build time or page-view time. Static fixtures served from the docs origin are the sanctioned substitute.
- Bulk page deletion is permitted only when paired with `jekyll-redirect-from` entries **in the same commit**. The URL surface is the site's only SEO asset.
- Work lands on branch `plan/better-docs` in the worktree. `pages.yml` deploys on `push: main` only, so branch commits never deploy.

## Rejected Alternatives, With Rationale

- **Public sandbox key / live demo endpoint** (SYNTHESIS 1, ~8 techniques; memlog L80, L109). Rejected for this workstream despite being the strongest convergence: it needs a hosted, rate-limited, publicly reachable endpoint owned by the application, not the docs repo. Publishing a key that does not exist is exactly the failure mode this workstream is fixing. Substitute: OpenAPI 3.1 + static fixtures + `prism mock` instructions.
- **Playwright screenshot pipeline** (memlog L85). Rejected: requires a demo account credential, a headless browser in CI, and login automation against the application. Substitute: retire the eight 2024-10 GitBook screenshots and write out the field tables in prose (memlog L86, L117, L119) — which also fixes 62 empty alts by construction.
- **Service worker for offline docs** (memlog L328). Rejected outright; the paired fixtures idea from the same line is taken.
- **pa11y-ci / axe in the build loop.** Rejected: headless-browser runners in the PR path make the loop slow and flaky for a static site. html-proofer's alt assertion plus a contrast constant covers the realistic defect surface.
- **Ledger-generated programmatic market pages** (SYNTHESIS 6, memlog L81, L110). Not rejected — deferred. It depends on ledger access this repository does not have, and it is the correct phase 5.
- **Deleting the changelog.** Rejected: `whats-new/index.md` is the only record of several shipped features. It is a data source to migrate, not dead weight.
- **Reconciling the contradicted phone prices into a single figure.** Rejected: inventing a reconciled price is the same failure as the original. Delete the contradicted figures; render from `_data/pricing.yml` behind a `TODO(owner):`.

## Confirmed Defect Anchors (for story-level acceptance criteria)

| Anchor | Defect |
|--------|--------|
| `_config.yml:7` | `url: https://docs.signalsapi.com/` — trailing slash malforms 28 canonicals |
| `_config.yml` (absent key) | no `exclude:` → `README.md`, `push.sh`, `run.sh`, `LICENSE`, `Gemfile`, `Gemfile.lock` published |
| `features/filter-leads-with-ai.md:32` | `[ai-variables.md](ai-variables.md "mention")` — dead GitBook link, 21 months |
| `faq.md:26` | `**£400/€490/$550**` |
| `faq.md:51` | `£49/month for 100 telephone numbers, £149 for 300 & £199 for 500`; contradicts `features/find-phone-numbers.md:12`; also the typo "propsects" |
| `faq.md:65` | "100% reliable" — unsourced claim |
| `is-it-working.md` / `privacy-policy.md` | both `nav_order: 6`; `nav_order: 5` unused |
| all root pages | `layout: home` on leaf content pages |
| all 28 pages | inherit the single `_config.yml` `description:` |
| `features/index.md` | 10 words, `nav_order: 3`, no `has_children: true` |
| `index.md` | 325 words of pitch, zero links into the docs |
| `whats-new/index.md` | 3,478 words, 105 entries, dead since 2025-04-09 |
| `.github/workflows/ci.yml` | `bundle exec jekyll build` only — exits 0 in 0.52 s with all of the above present |
| 70 PNGs | 62 empty alt; eight from 2024-10 depict a UI that no longer exists |
| `quick-start.md` | deleted; recoverable at `835852a^` |

## Definition of Done (carried verbatim into the PRD)

Every change: (a) `bundle exec rake check` green, **and** (b) the change adds at least one new assertion to `script/check.rb` or a new rule to `.vale.ini` that fails at the branch point before the change and passes after. Prose-only changes carry a paired coverage assertion instead — e.g. "`_data/symptoms.yml` has ≥ 6 entries and each renders a page present in `_site`". Clause (b) is non-negotiable.

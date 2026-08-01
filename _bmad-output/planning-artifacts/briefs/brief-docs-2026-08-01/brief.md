---
title: 'Product Brief: SignalsAPI Documentation Overhaul'
status: final
created: '2026-08-01'
updated: '2026-08-01'
---

# Product Brief: SignalsAPI Documentation Overhaul

## Executive Summary

`docs.signalsapi.com` is a 28-page Jekyll site carrying 17,349 words of GitBook-era inheritance. It contradicts the product it documents — `faq.md:51` sells phone numbers at a monthly price while `features/find-phone-numbers.md:12` states phones come from the customer's own LeadMagic key — and nothing in the repository can detect that. CI runs `bundle exec jekyll build`, which exits 0 in 0.52 seconds with a link that has been dead for 21 months, a duplicated `nav_order`, 28 malformed canonical URLs and the unedited just-the-docs template README published live at `docs.signalsapi.com/README.md`.

The failure is not editorial, it is structural. A 2026-07-31 audit produced 81 verified findings; a brainstorm run over them produced 311 ideas across 14 techniques. Nine synthesis insights fell out. The load-bearing one (SYNTHESIS 8) names the root cause directly: nobody owns the docs, so every fact rots — and the only fix in the whole set that is structural rather than editorial is making regression visible by default.

This workstream therefore does not begin with content. It begins with a machine that can fail the build. `bundle exec rake check` — `jekyll build` → `html-proofer` → `vale` → `ruby script/check.rb` — becomes the single quality gate, and every subsequent change ships with the assertion that would have caught its absence. Content, IA, machine-readability and governance follow, in that order, on top of a harness that holds them.

## The Problem

Three readers arrive at these docs and all three leave wrong.

**The recruitment-agency operator** lands on `index.md` — 325 words of pitch with zero links into the documentation, closing on "Which side do you want to be on in 12 months?" and a booking link. There is no quick start; `quick-start.md` was deleted (recoverable at `835852a^`). If their lead list comes back empty, the nine known causes exist only as one-line asides on unrelated pages. They email support, or they leave.

**The developer** evaluating the API or the agent data plane finds no OpenAPI spec, no `robots.txt`, no `sitemap.xml`, and an MCP parity claim asserted in prose rather than computed. The changelog has been dead since 2025-04-09, so API access (2026-06-30) and the agent data plane (2026-07-09) both shipped with documentation and no announcement.

**The AI agent** reading the corpus as a tool finds 28 identical meta descriptions, 28 malformed canonicals, no `llms.txt`, and instructional payload sealed inside 62 empty-alt PNGs — eight of which show a UI the application no longer has. This is the finding that stings: a company selling an agent data plane and an MCP server publishes among the least agent-readable docs on the internet (SYNTHESIS 3).

The cost of the status quo compounds. Every unowned page rots one more month, every support ticket answered in email leaves no trace, and every published contradiction spends credibility the product has to re-earn.

## The Solution

A documentation system, not a documentation edit.

1. **A verification harness first.** `rake check` wires `html-proofer` (link integrity, alt text), Vale (locked vocabulary, banned claims), and a plain-stdlib `script/check.rb` (repository invariants — no currency symbol outside `_data/pricing.yml`, no unexcluded shell script, no page missing `description:`) into one nonzero-exiting command that `ci.yml` runs in place of the bare build.
2. **A credibility patch** that clears what is provably wrong and cheap: the trailing slash on `_config.yml:7` that malforms all 28 canonicals (SYNTHESIS 9 — one character, sitewide SEO repair), the missing `exclude:`, the dead `ai-variables.md` link, the contradicted phone pricing, plus `sitemap.xml`, `robots.txt` and a `404.md`.
3. **A single source of truth.** Six datasets — providers, AI variables, integrations, glossary, pricing, changelog — move into `_data/` and pages become templates (SYNTHESIS 2). This one structural move dissolves the four-name object model, the FAQ-versus-phone-pricing contradiction, the provider-matrix duplication and changelog rot simultaneously.
4. **Symptom-named troubleshooting.** Pages titled the way a broken user types — "my lead list is empty", "my phone column is blank" — so docs become part of the product's error surface rather than a place you visit (SYNTHESIS 5).
5. **Machine-readability.** `llms.txt`, `llms-full.txt`, an OpenAPI 3.1 spec with `x-mcp-tool` and `x-status` vendor extensions, and the docs corpus itself exposed as an MCP server (SYNTHESIS 3).
6. **Governance made visible.** `verified_on` front matter rendered as a freshness chip, and a public `/docs-health` page that shows the site's own rot with fix dates (SYNTHESIS 8, independently invented five times in the brainstorm).

## Approach: Verification First

The differentiator here is not a content strategy — it is a refusal to call anything fixed until a machine can fail the build on its regression.

Concretely, the Definition of Done for every change has two clauses: (a) `bundle exec rake check` is green, and (b) the change adds at least one new assertion to `script/check.rb` or a new rule to `.vale.ini` that **fails at the branch point before the change and passes after**. Prose-only changes carry a paired coverage assertion instead. Clause (b) is the whole thesis. Without it this becomes the fourth documentation cleanup that decays in six months.

Two corollaries follow, and both are honest rather than flattering:

- **Admitting weakness is the conversion lever** (SYNTHESIS 4). A page naming when *not* to use SignalsAPI, affiliate links that render their measured cost beside them, and `/docs-health` publishing our own defect burn-down all trade on the same mechanic: the buyer already suspects the weaknesses, and naming them first is the cheapest way to be believed about the strengths.
- **This workstream never invents a figure.** No price, plan allowance, credit cost, commission rate, match rate, uptime or latency is written unless it is sourceable from this repository. Where it is not, the story ships the render mechanism plus a `TODO(owner):` marker in `_data/` that `script/check.rb` flags. The current docs are untrustworthy precisely because someone once wrote a plausible number.

## Who This Serves

- **The operator** (primary) — a recruitment-agency user setting up a first search. Success: they reach a populated lead list without opening email, and when it is empty they self-diagnose from a page named after their symptom.
- **The developer** (primary) — integrating the REST API, the agent data plane or Clay. Success: they can read one spec and know exactly which operations exist, which are live, and which are code-complete but unhosted, without inferring it from prose.
- **The AI agent** (primary, and currently unserved) — an LLM reading the corpus as a tool. Success: it can retrieve the whole corpus from `llms-full.txt` or query the docs MCP server, and every page it returns carries a correct canonical URL and a real description.
- **The maintainer** (secondary) — whoever owns docs after this lands. Success: a regression fails CI instead of surviving 21 months.

## Success Criteria

Deliberately mechanism-shaped, not numeric — this brief does not assert a metric it cannot source.

1. `bundle exec rake check` is the sole CI gate and exits nonzero on any of the 12 audit findings reintroduced.
2. Every one of the 12 audit findings is either fixed with a paired assertion, or explicitly deferred with a written reason.
3. No currency symbol exists outside `_data/pricing.yml`; the FAQ-versus-phone-pricing contradiction cannot be reintroduced without failing the build.
4. `html-proofer` passes with zero internal broken links and zero missing alt attributes.
5. Vale rejects the banned vocabulary set (including "personation" and any string implying a live sandbox key or public API base URL) at error level.
6. `llms.txt`, `llms-full.txt`, `sitemap.xml`, `robots.txt` and `openapi.yaml` exist and are asserted present by `script/check.rb`.
7. Every page carries a unique `description:` and a `verified_on:` date, both enforced.
8. `/docs-health` renders the finding set from `_data/`, so the burn-down is published rather than claimed.

## Scope

**In.** The `docs` repository only: the verification harness, the credibility patch, IA and navigation, core-concepts and getting-started content, symptom-named troubleshooting, the `_data/` refactor, SEO and machine-readability artifacts, trust and governance pages, and the static (fixture-and-spec) subset of the agent data plane documentation.

**Out.** Anything requiring the application, a live endpoint, a credential, or a number this repository cannot source. Specifically out: a public sandbox key or any live API surface; keyless live-demo widgets; ledger-generated programmatic market pages; app-side deep links from empty states; Playwright screenshot pipelines; published legal or DPA copy; any invented price or metric.

The sandbox-key exclusion deserves a note, because SYNTHESIS 1 named it the single strongest convergence in the brainstorm — independently invented by 8 of 12 techniques. It is correct and it is still out: it requires a hosted endpoint this repository does not control. The sanctioned substitute is an OpenAPI spec plus static fixtures served from the docs origin and `prism mock` instructions, which delivers the same reader experience with zero hosting dependency and zero false claim.

## Sequencing

Five phases, from the brainstorm's closing direction:

1. **Credibility patch** — trailing slash, `exclude:`, the dead link, the dead pricing, sitemap/robots/404. Preceded by the harness, so each fix lands with its assertion.
2. **Core concepts, getting started, symptom-named troubleshooting.**
3. **`_data/` single-source-of-truth refactor with CI gates.**
4. **Machine-readability** — `llms.txt`, OpenAPI, docs MCP server (sandbox key excluded per above).
5. **Ledger-generated market pages** — out of scope for this workstream; recorded as the direction that follows it.

## Vision

Docs that are part of the product rather than marketing about it: the surface the application deep-links into when something breaks, the corpus an agent queries before it calls an endpoint, and a `/docs-health` page whose burn-down is public because the rot is caught by machine before anyone has to notice it. The site stops being a brochure that decays and becomes the contract the product is held to.

## Assumptions

- `[ASSUMPTION]` The 12 audit findings and the 81-finding audit behind them are accurate as of 2026-07-31 and still present in `main`. Spot-verified: F1, F3, F4, F5, F6, F12 confirmed by direct file read during this run.
- `[ASSUMPTION]` Arbitrary Jekyll plugins are legal here because `pages.yml` is a custom Actions build, not the GitHub Pages gem whitelist. Verified in `.github/workflows/pages.yml`.
- `[ASSUMPTION]` No unit-test framework is wanted; `rake check` is the only gate. Inherited from `project-context.md` as a binding constraint.
- `[ASSUMPTION]` The three reader profiles above are inferred from repository content and the brainstorm, not from interviews or analytics. No usage data was available to this run.
- `[ASSUMPTION]` "Launch" stakes — the site is in production at `docs.signalsapi.com` and every defect is publicly visible.

## Open Questions

1. What are the real plan prices, plan allowances, credit costs and the free-tier credit grant? Nothing sourceable exists in the repository; `faq.md`'s figures are contradicted by `find-phone-numbers.md`. Blocks a truthful `/pricing` page — ships as `TODO(owner):` until answered.
2. What is the measured email-verification rate and the median signal latency? Needed to replace `faq.md:65`'s "100% reliable" and the "real-time" claim with something defensible.
3. Which agent-data-plane operations are live versus code-complete versus planned, and is there a public base URL yet? Drives `x-status` in the OpenAPI spec.
4. Is there a DPA, and who are the named sub-processors? Determines whether `/trust` can list them or must defer.
5. Who owns docs after this lands, and what is the review cadence that `verified_on` is measured against? SYNTHESIS 8 identifies unowned docs as the root cause; the mechanism is in scope, the owner is not something this workstream can assign.
6. Should `whats-new/` migrate to `_data/changelog.yml` with all 105 entries backfilled, or start fresh from 2026-06? The 53 PNGs (~1.9 MB) are the cost driver.

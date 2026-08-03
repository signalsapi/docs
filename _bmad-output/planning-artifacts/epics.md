# SignalsAPI Documentation Overhaul — Epics and Stories

Source inputs: `prd.md`, `architecture.md`, `ux-designs/ux-docs-2026-08-01/EXPERIENCE.md`, `brainstorming/brainstorm-better-docs-2026-07-31/.memlog.md`.

Every story carries the two-clause Definition of Done fixed by AD-2:

- (a) the change is made, and
- (b) `bundle exec rake check` passes AND at least one assertion exists that would fail if the change were reverted.

Clause (b) is not waivable. Story 1.1 is the single exception — it creates the harness that clause (b) depends on.

Assertion IDs below are the `id:` passed to `Check.register` in `script/checks/<id>.rb` (AD-3). Figures that cannot be sourced from this repository ship as `TODO(owner: <handle>): <what is needed>` markers (AD-8); no story invents a price, allowance, credit cost, commission rate, match rate, uptime or latency.

## Epic 1: Verification harness

Stand up `bundle exec rake check` as the single quality gate for this repository — `jekyll build` then html-proofer then Vale then `ruby script/check.rb`, exiting nonzero on any stage failure. Nothing in Epics 2 through 11 can satisfy its Definition of Done until this exists, so this epic ships first and ships whole. Closes F12.

### Story 1.1: Create the Rakefile and the script/check.rb runner skeleton

As a documentation maintainer,
I want a single `rake check` entry point that composes every quality stage,
So that one command on my machine tells me whether the site is publishable.

Source: .memlog.md:221 and .memlog.md:299; closes the first half of audit finding F12. This is the sole story exempt from Definition of Done clause (b), because it is the story that creates the mechanism clause (b) names.

**Acceptance Criteria:**

**Given** the repository has no `Rakefile` and no `script/` directory
**When** a developer runs `bundle exec rake check` from the repository root
**Then** the task runs `jekyll build` into `_site/` and exits nonzero when the build fails
**And** `script/check.rb` exists, loads every file matching `script/checks/*.rb` via `Dir.glob`, runs each registered assertion against a site model parsed once, and exits nonzero when any assertion calls `fail!`
**And** `rake check` with an empty `script/checks/` directory exits zero and prints the count of registered assertions

### Story 1.2: Add strict_front_matter and make a malformed page fail the build

As a documentation maintainer,
I want Jekyll to abort on unparseable front matter instead of silently emitting a page,
So that a broken YAML block is caught at build time rather than in production.

Source: architecture.md AD-5; supports audit finding F12.

**Acceptance Criteria:**

**Given** `_config.yml` carries `strict_front_matter: true`
**When** any page in the repository contains front matter that YAML cannot parse
**Then** `bundle exec rake check` exits nonzero at the build stage and names the offending file
**And** the assertion `config-strict-front-matter` fails if the `strict_front_matter` key is absent from `_config.yml` or set to anything other than `true`

### Story 1.3: Add html-proofer and wire the rake check:links stage

As a documentation maintainer,
I want every internal link, anchor and image reference in the built site verified,
So that a dead relative link cannot survive a green build.

Source: .memlog.md:221; closes audit finding F3's detection gap.

**Acceptance Criteria:**

**Given** `html-proofer` is declared in the `Gemfile` as `~> 5` and the lockfile is committed
**When** a developer runs `bundle exec rake check:links`
**Then** html-proofer runs against `_site/` with external checking disabled and exits nonzero on any broken internal link, broken anchor, or missing image
**And** the assertion `gemfile-html-proofer-pinned` fails if the `Gemfile` does not declare `html-proofer` with a `~> 5` constraint
**And** `rake check` invokes `check:links` after the build stage and aggregates its findings rather than aborting the run

### Story 1.4: Install Vale with a SignalsAPI style directory

As a documentation maintainer,
I want a prose linter with a project vocabulary,
So that banned terms and unqualifiable absolutes fail the build instead of shipping.

Source: .memlog.md:256; supports the vocabulary lock in Epic 4.

**Acceptance Criteria:**

**Given** `.vale.ini` exists at the repository root and points `StylesPath` at `styles/`
**When** a developer runs `bundle exec rake check:prose`
**Then** the Vale binary lints every `.md` file outside `_site/` and `_drafts/` and exits nonzero on any error-severity finding
**And** `styles/SignalsAPI/` contains at least one rule file and the assertion `vale-config-present` fails if `.vale.ini` is absent or its `StylesPath` does not resolve to an existing directory
**And** the assertion `vale-styles-nonempty` fails if `styles/SignalsAPI/` contains zero rule files

### Story 1.5: Document and enforce Vale binary provisioning in CI

As a contributor,
I want the Vale binary provisioned the same way locally and in CI,
So that a prose failure reproduces on my machine.

Source: architecture.md AD-12; Vale is a Go binary, not a gem.

**Acceptance Criteria:**

**Given** CI installs Vale by download at a version recorded in a single place in the repository
**When** `rake check:prose` runs on a machine where the Vale binary is absent
**Then** the task exits nonzero with a message naming the install command rather than silently skipping the stage
**And** the assertion `vale-version-pinned` fails if the recorded Vale version string is missing or is the literal word `latest`

### Story 1.6: Implement the self-registering assertion registry

As a story author,
I want to add an assertion by creating one new file,
So that the twentieth assertion does not collide with the nineteenth in a merge.

Source: architecture.md AD-3; this is what makes Definition of Done clause (b) cheap enough that stories will actually satisfy it.

**Acceptance Criteria:**

**Given** `script/check.rb` auto-loads `script/checks/*.rb`
**When** a file in that directory calls `Check.register(id:, desc:, covers:) { |site| ... }`
**Then** the assertion runs on the next `rake check` with no edit to `script/check.rb` or to any other assertion file
**And** the runner exits nonzero with a clear message if two files register the same `id`
**And** the assertion `checks-one-per-file` fails if any file under `script/checks/` calls `Check.register` more than once

### Story 1.7: Parse the site model once and expose it to assertions

As an assertion author,
I want a parsed site model handed to my block,
So that twenty assertions do not each re-walk `_site/` and the front matter.

Source: architecture.md AD-4.

**Acceptance Criteria:**

**Given** `script/check.rb` builds the site model before running any assertion
**When** an assertion block receives the `site` argument
**Then** `site.pages`, `site.html_files`, `site.data` and `site.raw(path)` are available and reflect the current working tree and the freshly built `_site/`
**And** the assertion `site-model-contract` fails if any of those four accessors is missing or returns nil for a repository that contains at least one page

### Story 1.8: Add the covers manifest and the coverage report

As a release reviewer,
I want each assertion to declare which story or requirement it covers,
So that I can see which parts of the backlog are actually defended by a check.

Source: architecture.md AD-6.

**Acceptance Criteria:**

**Given** every `Check.register` call carries a non-empty `covers:` array
**When** a developer runs `bundle exec rake check:manifest`
**Then** `_data/checks.yml` is regenerated from the registry with each assertion's `id`, `desc` and `covers`
**And** `bundle exec rake check` runs a staleness assertion `checks-manifest-current` that fails when `_data/checks.yml` does not match the live registry, without itself writing the file
**And** `bundle exec rake check:coverage` prints every story ID and requirement ID that no assertion covers

### Story 1.9: Pin Ruby with .ruby-version and remove the inline CI pins

As a contributor,
I want local Ruby and CI Ruby to be the same version from one source,
So that a green local run is evidence that CI will be green.

Source: closes the second half of audit finding F12; architecture.md AD-13.

**Acceptance Criteria:**

**Given** `.ruby-version` exists at the repository root containing `3.3`
**When** `.github/workflows/ci.yml` and `.github/workflows/pages.yml` run `ruby/setup-ruby`
**Then** neither workflow declares an inline `ruby-version:` key and both resolve the version from `.ruby-version`
**And** the `Gemfile` declares no `ruby` directive
**And** the assertion `ruby-version-single-source` fails if `.ruby-version` is absent, if either workflow declares an inline `ruby-version:`, or if the `Gemfile` declares a `ruby` directive
**And** `bundle exec rake check:env` prints a warning, not a failure, when the running interpreter differs from `.ruby-version`

### Story 1.10: Reduce ci.yml to bundle exec rake check

As a reviewer of a pull request,
I want CI to run the same command I run locally,
So that CI failures are reproducible without reading the workflow file.

Source: closes audit finding F12; .memlog.md:221.

**Acceptance Criteria:**

**Given** `.github/workflows/ci.yml` currently runs `bundle exec jekyll build` as its only step
**When** the workflow is rewritten
**Then** its build job runs `bundle exec rake check` and nothing else beyond checkout, Ruby setup, bundler cache and the Vale binary install
**And** the assertion `ci-runs-rake-check` fails if `ci.yml` does not contain a step whose run command is exactly `bundle exec rake check`
**And** `.github/workflows/pages.yml` is unchanged apart from the Ruby pin removed in Story 1.9, retaining its three-attempt deploy retry and its `cancel-in-progress: false` concurrency group

### Story 1.11: Add rake check:new scaffolding and single-assertion addressing

As a story author,
I want to scaffold and run one assertion without running the whole suite,
So that satisfying Definition of Done clause (b) costs a minute rather than a build cycle.

Source: architecture.md AD-3 and AD-5.

**Acceptance Criteria:**

**Given** the assertion registry from Story 1.6 exists
**When** a developer runs `bundle exec rake check:new[my-assertion-id]`
**Then** `script/checks/my-assertion-id.rb` is created from a template with `id`, `desc` and `covers` stubbed and a failing body
**And** `bundle exec rake check:assert[my-assertion-id]` runs only that assertion against the already-built `_site/`
**And** the assertion `checks-id-matches-filename` fails if any file under `script/checks/` registers an `id` that does not equal its own basename without extension

### Story 1.12: Define and enforce the TODO(owner:) marker grammar

As a documentation maintainer,
I want unsourceable figures to ship as a well-formed marker rather than an invented number,
So that a gap is visible and attributable instead of being filled with fiction.

Source: architecture.md AD-8; enforces the project's standing rule that no figure is invented.

**Acceptance Criteria:**

**Given** the marker grammar is exactly `TODO(owner: <handle>): <what is needed>`
**When** a well-formed marker appears in any `.md` file or any `_data/*.yml` value
**Then** `bundle exec rake check` passes and the marker is listed in the run's summary output with its file and line
**And** the assertion `todo-owner-grammar` fails when a string beginning `TODO` does not match the grammar, so a malformed marker breaks the build while a correct one does not

### Story 1.13: Add the nightly external-link workflow

As a documentation maintainer,
I want external links swept on a schedule rather than on every pull request,
So that a third party's outage never blocks a contributor's merge.

Source: architecture.md AD-10; html-proofer runs with external checking disabled on the pull-request path.

**Acceptance Criteria:**

**Given** a scheduled GitHub Actions workflow exists that builds the site and runs lychee over `_site/`
**When** the nightly run finds a broken external link
**Then** the workflow opens or updates a single tracking issue rather than failing any pull-request check
**And** the assertion `external-links-off-pr-path` fails if the html-proofer invocation in the `Rakefile` omits the disable-external flag, or if the nightly workflow's trigger includes `pull_request`

## Epic 2: Credibility patch

Remove every defect a visitor or a crawler can see today, smallest-first. Story 2.1 is the highest return in the entire backlog: one character. Closes F1, F2, F3, F4, F5 and F6.

### Story 2.1: Drop the trailing slash from the site url

As a search engine indexing this site,
I want each page to declare one well-formed canonical URL,
So that the indexed form of every page is the form that actually resolves.

Source: .memlog.md:355 (SYNTHESIS 9) and .memlog.md:299; closes audit finding F1. `_config.yml:7` reads `url: https://docs.signalsapi.com/`, so all 28 pages emit `docs.signalsapi.com//...` in every canonical, `og:url` and JSON-LD URL.

**Acceptance Criteria:**

**Given** `_config.yml` line 7 declares `url: https://docs.signalsapi.com/`
**When** the trailing slash is removed
**Then** no file under `_site/` contains the string `docs.signalsapi.com//`
**And** the assertion `canonical-no-double-slash` walks every HTML file in the built site and fails if that string appears anywhere, so reverting the character breaks the build

### Story 2.2: Stop publishing repository scaffolding

As a visitor who mistypes a URL,
I want the site to serve only documentation,
So that I never land on an unedited template README telling me to click "use this template".

Source: .memlog.md:299; closes audit finding F2. `docs.signalsapi.com/README.md` is live today.

**Acceptance Criteria:**

**Given** `_config.yml` has no `exclude:` key
**When** `exclude: [README.md, LICENSE, push.sh, run.sh, Gemfile, Gemfile.lock]` is added
**Then** none of those six files appears anywhere under `_site/` after a build
**And** the assertion `site-excludes-scaffolding` fails if any of the six is present in the built site, or if the `exclude:` key is missing from `_config.yml`

### Story 2.3: Set permalink: pretty and align internal links with their targets

As a reader following a link between pages,
I want extensionless internal links to resolve,
So that navigation does not depend on which era of the site authored the link.

Source: .memlog.md:299; supports audit finding F3.

**Acceptance Criteria:**

**Given** `_config.yml` declares `permalink: pretty`
**When** `bundle exec rake check` runs
**Then** html-proofer reports zero broken internal links across the built site
**And** the assertion `permalink-pretty-set` fails if the `permalink` key is absent from `_config.yml` or set to anything other than `pretty`

### Story 2.4: Add jekyll-sitemap and declare the plugins key

As a crawler,
I want a machine-readable inventory of every published page,
So that I do not have to guess the site's shape from its navigation.

Source: .memlog.md:257 and .memlog.md:299; supports audit finding F7.

**Acceptance Criteria:**

**Given** `_config.yml` has no `plugins:` key today
**When** `jekyll-sitemap` is added to the `Gemfile` and listed under a new `plugins:` key
**Then** `_site/sitemap.xml` exists after a build and lists every published page
**And** the assertion `sitemap-covers-published-pages` fails when a page that is not `nav_exclude`d and not `sitemap: false` is absent from `sitemap.xml`

### Story 2.5: Publish robots.txt

As a crawler,
I want an explicit crawl policy and a pointer to the sitemap,
So that I index the intended surface.

Source: .memlog.md:257 and .memlog.md:299.

**Acceptance Criteria:**

**Given** the repository contains no `robots.txt`
**When** a `robots.txt` source file with `layout: null` and `permalink: /robots.txt` is added
**Then** `_site/robots.txt` is served as plain text and contains an absolute `Sitemap:` line pointing at the site's `sitemap.xml`
**And** the assertion `robots-sitemap-absolute` fails if `robots.txt` is missing, if its `Sitemap:` line is relative, or if that line contains a double slash after the host

### Story 2.6: Add a 404 page wired to the site search

As a visitor arriving on a stale or mistyped URL,
I want the site's own search and a short list of destinations,
So that a wrong URL becomes a route rather than a dead end.

Source: .memlog.md:246 and .memlog.md:66; closes the unbranded-404 gap. There is no `404.md` today.

**Acceptance Criteria:**

**Given** `404.md` exists with `permalink: /404.html`, `layout: default` and `nav_exclude: true`
**When** a visitor requests a path that does not resolve
**Then** the served page renders the theme layout, the lunr search input, and at least six internal links to top-level destinations
**And** the assertion `404-router-shape` fails if `_site/404.html` is absent, contains fewer than six internal links, or does not reference the search input

### Story 2.7: Repair the dead ai-variables link

As a reader of the AI filtering page,
I want its reference to the AI variables page to resolve,
So that I can reach the page the sentence promises.

Source: closes audit finding F3. `features/filter-leads-with-ai.md:32` contains `[ai-variables.md](ai-variables.md "mention")`, a GitBook export artifact dead for 21 months.

**Acceptance Criteria:**

**Given** the GitBook-era `"mention"` link artifact at `features/filter-leads-with-ai.md:32`
**When** the link is rewritten to the page's real URL
**Then** html-proofer resolves it and `bundle exec rake check` passes
**And** the assertion `no-gitbook-mention-artifacts` fails if any `.md` file contains a Markdown link whose title attribute is the literal string `mention`

### Story 2.8: Strip the contradicted phone pricing from the FAQ

As a prospective customer reading the FAQ,
I want the phone-number section to match how phone lookup actually works,
So that the docs do not sell me something the product does not do.

Source: .memlog.md:290; closes audit finding F4. `faq.md:51` sells phone numbers on a monthly tier while `features/find-phone-numbers.md:12` states phones come from the customer's own provider key. `faq.md:51` also contains the typo `propsects`.

**Acceptance Criteria:**

**Given** `faq.md:51` states monthly prices for blocks of phone numbers
**When** those figures are removed and the answer is rewritten to point at the bring-your-own-provider model
**Then** `faq.md` contains no currency figure for phone numbers and the typo `propsects` is corrected
**And** the assertion `phone-pricing-not-in-faq` fails if `faq.md` contains a currency symbol adjacent to the word `phone`, and fails if the string `propsects` appears anywhere in the repository

### Story 2.9: Quarantine the remaining pricing prose behind a single owner marker

As a prospective customer,
I want any price I read to come from one place,
So that two pages cannot disagree about what something costs.

Source: .memlog.md:335; closes the second half of audit finding F4. `faq.md:26` states a figure in three currencies that no other page corroborates.

**Acceptance Criteria:**

**Given** `faq.md:26` states a plan figure in three currencies
**When** the figure is replaced by a `TODO(owner: <handle>):` marker carrying no link, since the pricing page does not exist yet and a forward link would break the internal link check
**Then** `bundle exec rake check` passes with the marker listed in the run summary
**And** the assertion `currency-outside-data` fails when a bare currency symbol appears in any `.md` file outside `_data/pricing.yml` and the pricing page template

### Story 2.10: Resolve the nav_order collision and remove the float shims

As a reader using the sidebar,
I want a deterministic navigation order,
So that two pages never compete for the same position.

Source: closes audit finding F5. `is-it-working.md` and `privacy-policy.md` both declare `nav_order: 6`; `nav_order: 5` is unused; other values are float shims such as 1.5, 3.5, 3.6, 3.7, 2.5 and 11.1 through 11.3.

**Acceptance Criteria:**

**Given** duplicate and fractional `nav_order` values across the current page set
**When** every top-level page is renumbered to a contiguous integer sequence starting at 1
**Then** no two siblings share a `nav_order` and no `nav_order` value is fractional
**And** the assertion `nav-order-integrity` fails when any sibling group contains a duplicate `nav_order`, a non-integer `nav_order`, or a gap in its integer sequence

### Story 2.11: Give leaf pages layout: default

As a reader of a content page,
I want the page rendered in the content layout,
So that the sidebar, breadcrumbs and table of contents behave as the theme intends.

Source: closes audit finding F6. Every root page declares `layout: home`, including leaf content pages.

**Acceptance Criteria:**

**Given** every root page currently declares `layout: home`
**When** each leaf content page is changed to `layout: default`
**Then** `index.md` is the only page in the repository declaring `layout: home`
**And** the assertion `layout-home-is-index-only` fails if any page other than `index.md` declares `layout: home`, or if a page declares no `layout` at all

### Story 2.12: Uncomment and populate aux_links

As a reader who needs to get back into the product,
I want a persistent way in from the docs header,
So that the only route to the application is not a booking form buried in the home page pitch.

Source: .memlog.md:247 and .memlog.md:299. `_config.yml` lines 9 to 11 hold a commented-out `aux_links` block still pointing at the just-the-docs template repository.

**Acceptance Criteria:**

**Given** the commented-out template `aux_links` block in `_config.yml`
**When** it is replaced with live links to the application, the free tier, pricing and support
**Then** every built page renders those auxiliary links in the header
**And** the assertion `aux-links-not-template` fails if `_config.yml` contains a commented `aux_links` block, if `aux_links` is absent, or if any of its URLs points at a just-the-docs template repository

### Story 2.13: Fix the focus ring so keyboard navigation is visible

As a keyboard-only reader,
I want a visible focus indicator on every interactive element,
So that I can see where I am on the page.

Source: .memlog.md:307 and .memlog.md:321; supports the accessibility floor in EXPERIENCE.md.

**Acceptance Criteria:**

**Given** `_sass/custom/custom.scss` currently styles a bare `*:focus` rule
**When** it is replaced with a solid `:focus-visible` ring using the accent colour from `_sass/color_schemes/signalsapi.scss`
**Then** every link, button and form control shows a visible ring when reached by keyboard
**And** the assertion `focus-visible-ring-present` fails if `custom.scss` contains a `:focus` rule that sets `outline: none` without a paired `:focus-visible` rule

### Story 2.14: Pin the plugin budget

As an architect of this repository,
I want the set of Jekyll plugins bounded and justified,
So that the build stays fast and the theme stays predictable.

Source: architecture.md AD-11. The deployment is a custom GitHub Actions workflow rather than the GitHub Pages gem whitelist, so arbitrary plugins are legal and the budget must therefore be self-imposed.

**Acceptance Criteria:**

**Given** the overhaul adds exactly `jekyll-sitemap`, `jekyll-redirect-from` and `jekyll-seo-tag`
**When** `bundle exec rake check` runs
**Then** the assertion `plugin-budget` fails if `_config.yml` lists a plugin outside that set of three
**And** the assertion `one-canonical-per-page` fails if any built HTML file contains more or fewer than one `rel="canonical"` element

### Story 2.15: Freeze the palette and its contrast floor

As a reader who needs to be able to read the page,
I want the colour constants pinned and their contrast asserted,
So that a theme edit cannot silently drop body text below the legibility floor.

Source: PRD NFR8, DESIGN.md section Colors, architecture.md AD-6. `_sass/color_schemes/signalsapi.scss` is one of the three customization files; nothing today would catch a hex edit that breaks contrast. Story 2.13 covers only the focus ring, so the palette itself is unasserted.

**Acceptance Criteria:**

**Given** DESIGN.md declares fourteen named hex constants and `_sass/color_schemes/signalsapi.scss` is the only place they are defined in code
**When** `bundle exec rake check` runs
**Then** the assertion `palette-constants` fails when the set of hex values parsed out of `_sass/color_schemes/signalsapi.scss` differs from the fourteen declared in DESIGN.md
**And** the assertion `palette-contrast-floor` computes the WCAG relative-luminance ratio in plain Ruby for each declared text-on-background pairing and fails when any pairing falls below 4.5:1
**And** neither assertion requires a browser, a headless runner or a network call, since pa11y-ci and axe are out of scope

## Epic 3: Baseline

Record the as-is state before any content story ships, so that every later claim of improvement is measurable against a committed number rather than a memory. This epic must land before Epic 4.

### Story 3.1: Commit the as-is baseline data file

As a documentation owner,
I want the site's condition on 2026-07-31 captured in the repository,
So that improvement is a diff rather than an assertion.

Source: .memlog.md:302.

**Acceptance Criteria:**

**Given** the repository contains no `_data/baseline.yml`
**When** the file is created carrying the measured as-is counts — published pages, pages with a unique `description`, images with empty alt text, presence of a sitemap, presence of `robots.txt`, pages with zero inbound in-body links, and the date of the last changelog entry
**Then** every value in the file is either a number derived from this repository or a `TODO(owner: <handle>):` marker, and no value is estimated
**And** the assertion `baseline-values-sourced` fails if any value in `_data/baseline.yml` is neither an integer, a date, a boolean, nor a well-formed owner marker

### Story 3.2: Render the baseline page

As a reader assessing whether these docs are maintained,
I want the starting condition published,
So that the improvements claimed elsewhere are checkable.

Source: .memlog.md:302.

**Acceptance Criteria:**

**Given** `_data/baseline.yml` exists
**When** `docs-baseline.md` renders it as a table via Liquid
**Then** the built page contains one row per measured dimension with its 2026-07-31 value and a stated re-measure date
**And** the assertion `baseline-page-renders-all-keys` fails if any key present in `_data/baseline.yml` is absent from the built `/docs-baseline/` page

### Story 3.3: Freeze the baseline against silent edits

As a reviewer,
I want the baseline to be a historical record rather than a moving target,
So that nobody quietly improves the past.

Source: .memlog.md:302; architecture.md AD-7.

**Acceptance Criteria:**

**Given** `_data/baseline.yml` carries a `meta:` envelope with `owner`, `verified_on` and `source`
**When** any measured value in the file changes
**Then** the assertion `baseline-immutable` fails unless `meta.verified_on` changes in the same commit
**And** the assertion `data-envelope-shape` confirms the file carries exactly a `meta:` mapping and an `items:` mapping and nothing else at the top level

## Epic 4: Core concepts and the object model

Lock the vocabulary. The product's central object is called four or five different names across the docs, which makes every downstream page ambiguous and every search miss. One data file becomes the single definition, the concepts pages render from it, and Vale fails the build on a banned alias.

### Story 4.1: Author the glossary data file

As a reader,
I want each product term defined exactly once,
So that two pages cannot define the same word differently.

Source: .memlog.md:220 and .memlog.md:348 (SYNTHESIS 2).

**Acceptance Criteria:**

**Given** the repository has no `_data/` directory
**When** `_data/glossary.yml` is created with an entry per term for Signal, Search, Filter, Persona, Project, Credit, Provenance envelope, `as_of`, Tier 0 and Tier 1
**Then** each entry carries a `term`, a one-sentence `definition`, an `owning_page`, and an optional `aliases` list naming the deprecated names for that term
**And** the assertion `glossary-entry-shape` fails when an entry is missing `term`, `definition` or `owning_page`, or when the same term appears twice

### Story 4.2: Record the canonical name of the lead-list object

As a developer reading both the interface copy and the REST reference,
I want to know that the object the interface calls a lead list is the object the API calls a project,
So that I stop looking for an endpoint that does not exist.

Source: .memlog.md:348 (SYNTHESIS 2); the object model carries four to five names across the current page set.

**Acceptance Criteria:**

**Given** `_data/glossary.yml` contains the entry for the lead-list object
**When** the entry is authored
**Then** it names `project` as the REST identifier, lists the interface-facing name as an alias, and cites the page where each name appears
**And** the assertion `object-model-single-name` fails if any `.md` file outside the glossary page introduces a name for that object which is neither the canonical term nor a declared alias rendered through the glossary include

### Story 4.3: Build the inline term include

As a reader meeting a product term for the first time on a page,
I want its definition in place,
So that I do not have to leave the page to understand the sentence.

Source: .memlog.md:220.

**Acceptance Criteria:**

**Given** `_includes/term.html` reads `_data/glossary.yml`
**When** a page writes the include with a term key
**Then** the built page renders that term with its definition available inline and a link to its entry on the glossary page
**And** the assertion `term-include-keys-resolve` fails when a page invokes the include with a key that has no entry in `_data/glossary.yml`

### Story 4.4: Render the glossary page from the data file

As a reader,
I want one page listing every term,
So that the vocabulary is browsable rather than scattered.

Source: .memlog.md:220 and .memlog.md:291.

**Acceptance Criteria:**

**Given** `_data/glossary.yml` is populated
**When** `concepts/glossary.md` renders it
**Then** the built page contains one anchored section per glossary entry, in alphabetical order, each linking to its `owning_page`
**And** the assertion `glossary-page-complete` fails if the built page omits any entry present in the data file

### Story 4.5: Add Vale rules that fail on deprecated aliases

As a documentation maintainer,
I want the build to reject a deprecated term,
So that vocabulary drift cannot re-enter the corpus.

Source: .memlog.md:256.

**Acceptance Criteria:**

**Given** `_data/glossary.yml` declares an `aliases` list per term
**When** `bundle exec rake check:prose` runs
**Then** Vale reports an error for any deprecated alias used in prose outside the glossary page and its own definition
**And** the assertion `vale-aliases-match-glossary` fails if the alias set encoded in `styles/SignalsAPI/` diverges from the alias set in `_data/glossary.yml`

### Story 4.6: Author the concepts router page

As a reader who does not yet know what the product calls things,
I want one entry point into the conceptual pages,
So that I can orient before reading a task page.

Source: .memlog.md:281 and EXPERIENCE.md information architecture.

**Acceptance Criteria:**

**Given** `concepts/index.md` exists with `has_children: true`, `page_type: router` and an integer `nav_order`
**When** the page is built
**Then** it contains a `## Where to go` heading, at least three internal links, no image, and fewer than 250 words
**And** the assertion `router-page-shape` fails when a page declaring `page_type: router` breaks any of those four conditions

### Story 4.7: Author the anatomy of a lead concept page

As an operator looking at a row in a lead list,
I want to know what each field is and where it came from,
So that I can judge whether the row is usable.

Source: .memlog.md:115 and .memlog.md:283.

**Acceptance Criteria:**

**Given** the field set already documented across the export and integration reference pages
**When** `concepts/anatomy-of-a-lead.md` is authored with `page_type: concept`
**Then** the page contains a table with one row per field naming its source — the job posting, the people-data provider, or a derived value — and carries the four required concept headings
**And** the assertion `concept-page-shape` fails when a page declaring `page_type: concept` omits any of `## What it is`, `## Why it matters`, `## How it fits the pipeline` or `## Related`

### Story 4.8: Model the pipeline as data and render the concept page

As a reader anywhere in the docs,
I want to know which stage of the pipeline the page I am reading belongs to,
So that I can see what comes before and after it.

Source: .memlog.md:336 and .memlog.md:102.

**Acceptance Criteria:**

**Given** `_data/pipeline.yml` declares the ordered stages with each stage's owning page and prerequisite
**When** `concepts/pipeline.md` renders it as a mermaid diagram and any page declares a `stage:` front-matter key
**Then** the built page renders the diagram and pages carrying a `stage:` key render an orientation strip naming the previous and next stage
**And** the assertion `stage-key-valid` fails when a page declares a `stage:` value that is not a stage declared in `_data/pipeline.yml`

### Story 4.9: Nest how-it-works under Concepts without moving the file

As a reader,
I want the conceptual overview to sit inside the concepts section,
So that navigation matches meaning.

Source: EXPERIENCE.md information architecture; just-the-docs resolves `parent:` by page title rather than by directory, so this requires no file move and therefore no redirect.

**Acceptance Criteria:**

**Given** `how-it-works.md` sits at the repository root
**When** its front matter gains a `parent:` naming the concepts router's title
**Then** the page renders as a child of Concepts in the sidebar while its URL is unchanged
**And** the assertion `parent-resolves-to-has-children` fails when any page's `parent:` value does not match the title of a page declaring `has_children: true`

## Epic 5: Getting started

Give a first-time reader somewhere to land. The home page is 325 words of pitch with zero links into the docs, and the primary product action — creating a search — is documented nowhere. Closes F9 and F10.

### Story 5.1: Turn the home page into a router

As a first-time visitor,
I want the home page to send me somewhere useful,
So that I do not have to read a pitch to find the documentation.

Source: .memlog.md:96, .memlog.md:281 and .memlog.md:344; closes audit finding F10. `index.md` today is 325 words of pitch, closes on a rhetorical question, and links only to a booking form.

**Acceptance Criteria:**

**Given** `index.md` contains a pitch, a rhetorical closing question and an external booking link
**When** it is rewritten as a router with a short definition and six task-named tiles
**Then** the page contains at least six internal links, no booking-host link, and fewer than 250 words
**And** the assertion `home-is-router` fails if `index.md` links to the booking host, contains fewer than six internal links, or exceeds the router word budget

### Story 5.2: Restore the deleted quick-start page

As a first-time operator,
I want the quick-start content that used to exist,
So that prior work is recovered rather than rewritten from memory.

Source: .memlog.md:93; closes the second half of audit finding F10. The file is recoverable at commit `835852a^`.

**Acceptance Criteria:**

**Given** `quick-start.md` was deleted and is recoverable at `835852a^`
**When** the file is restored and its front matter is brought up to the current contract
**Then** the page builds with `page_type: task`, an integer `nav_order`, a unique `description`, and `has_children: true`
**And** the assertion `frontmatter-universal-contract` fails when any page lacks `title`, `layout`, `description` or `page_type`, or declares a `description` shorter than 50 or longer than 160 characters

### Story 5.3: Enforce unique page descriptions as a navigation contract

As a reader scanning search results,
I want each page to describe itself distinctly,
So that two results are distinguishable.

Source: closes part of audit finding F7; all 28 pages currently inherit one site-level description.

**Acceptance Criteria:**

**Given** all 28 pages inherit the single site-level description today
**When** every page is given its own `description` in the same commit that registers the assertions
**Then** the assertion `description-unique` fails if two pages declare the same `description` string
**And** the assertion `description-not-site-default` fails if any page's `description` equals the value declared in `_config.yml`

### Story 5.4: Write the operator quickstart

As a recruitment agency owner evaluating the product,
I want a first-session path that ends in a real lead list,
So that I can judge the product without a call.

Source: .memlog.md:226.

**Acceptance Criteria:**

**Given** the quick-start router exists
**When** the operator quickstart is authored as a child page with `page_type: task`
**Then** it names the literal interface controls at each step and carries the four required task headings
**And** the assertion `task-page-shape` fails when a page declaring `page_type: task` omits `## Before you start`, `## Steps`, `## Check it worked` or `## If it did not work`. The requirement that the final section link into `/troubleshooting/` is registered separately by Story 6.11, once the symptom pages exist

### Story 5.5: Write the developer quickstart

As a developer with an API key,
I want the shortest path from key to exported rows,
So that I can integrate without reading the whole reference.

Source: .memlog.md:226.

**Acceptance Criteria:**

**Given** the REST reference already documents the endpoints and the export column set
**When** the developer quickstart is authored with `page_type: task`
**Then** every fenced code block declares a language and every documented response field appears in the reference page it links to
**And** the assertion `code-fence-language` fails when any fenced block in any `.md` file declares no language

### Story 5.6: Write the agent-builder quickstart

As someone wiring an AI agent to this product,
I want a path that works against committed artifacts,
So that I can build before a hosted endpoint exists.

Source: .memlog.md:226 and .memlog.md:236; depends on the fixtures shipped in Epic 10.

**Acceptance Criteria:**

**Given** the static fixtures and the specification from Epic 10 exist
**When** the agent-builder quickstart is authored with `page_type: task`
**Then** every command it prints resolves against a URL on this documentation origin or against the local mock, and no step instructs the reader to email for access
**And** the assertion `no-live-sandbox-claim` fails when any page asserts that a public base URL, a hosted sandbox, or an issued key exists

### Story 5.7: Document creating a search

As an operator,
I want the primary product action documented,
So that the thing the product exists to do is not the thing the docs omit.

Source: .memlog.md:226 and .memlog.md:267; the audit found this action documented nowhere.

**Acceptance Criteria:**

**Given** no current page documents creating a search end to end
**When** the page is authored with `page_type: task` and a `stage:` key naming the first pipeline stage
**Then** it names every required field, states which fields combine within a field and across fields, and links to the advanced options page for each named control
**And** the assertion `search-creation-documented` fails if no page in the built site declares the first pipeline stage as its `stage:` value

### Story 5.8: Nest the features pages under a real section

As a reader using the sidebar,
I want feature pages to sit inside the Features section,
So that twenty child pages stop appearing as siblings of the home page.

Source: closes audit finding F9. `features/index.md` is a 10-word landing page with no `has_children: true`.

**Acceptance Criteria:**

**Given** `features/index.md` declares no `has_children`
**When** it gains `has_children: true`, `page_type: router` and router-shaped content, and each `features/*` page declares a matching `parent:`
**Then** every feature page renders as a child of Features in the sidebar with its URL unchanged
**And** the assertion `no-childless-has-children` fails when a page declares `has_children: true` and no page names it as a `parent:`

### Story 5.9: Assert the top-level navigation shape

As a maintainer,
I want the navigation tree pinned by an assertion,
So that a future page cannot quietly widen the top level.

Source: EXPERIENCE.md information architecture; closes the structural half of audit finding F5.

**Acceptance Criteria:**

**Given** the information architecture fixes the top-level section count
**When** `bundle exec rake check` runs
**Then** the assertion `root-section-count` fails when the number of pages with an integer `nav_order` and no `parent:` differs from a single named constant declared at the top of `script/checks/root-section-count.rb`
**And** the assertion `title-unique` fails when two pages declare the same `title`, since `parent:` resolves by title
**And** any later story that adds or retires a top-level section updates that constant in the same commit, so the tree can grow but cannot grow silently

### Story 5.10: Move secondary pages into the footer

As a reader,
I want policy and feedback pages out of the primary navigation,
So that the sidebar carries documentation rather than administrivia.

Source: .memlog.md:98 and .memlog.md:281. `request-new-feature.md` currently sits at `nav_order: 0`, the literal first item in the sidebar.

**Acceptance Criteria:**

**Given** `request-new-feature.md`, `is-it-working.md`, `privacy-policy.md` and `tos.md` appear in the sidebar
**When** each gains `nav_exclude: true` and a footer include renders links to them on every page
**Then** none appears in the sidebar and every built page contains a link to each
**And** the assertion `footer-link-coverage` fails when a page declaring `nav_exclude: true` is not linked from the footer include, or when a built page omits the footer

## Epic 6: Symptom-named troubleshooting

Name pages after what a stuck reader types, not after the feature that failed. Nine known causes of an empty lead list currently exist only as one-line asides on unrelated pages.

### Story 6.1: Author the troubleshooting router

As a reader whose run did not do what they expected,
I want one place that lists the symptoms,
So that I can recognise mine without knowing which feature is at fault.

Source: .memlog.md:239 and .memlog.md:351 (SYNTHESIS 5).

**Acceptance Criteria:**

**Given** `troubleshooting/index.md` exists with `has_children: true` and `page_type: router`
**When** the page is built
**Then** it lists every symptom page as a link phrased as the reader's own words
**And** the assertion `troubleshooting-router-complete` fails when a page under `troubleshooting/` is absent from the router's link list

### Story 6.2: Write the empty lead list symptom page

As an operator whose lead list came back empty,
I want every known cause in one branching page,
So that I can find mine without opening a support thread.

Source: .memlog.md:23, .memlog.md:258 and .memlog.md:282; the causes exist today only as asides on unrelated pages.

**Acceptance Criteria:**

**Given** the known causes are scattered across the provider, phone, credit and run-frequency pages
**When** `troubleshooting/empty-results.md` is authored with `page_type: symptom`
**Then** it lists every cause with the symptom the reader sees, the check that confirms it, and a link to the owning page
**And** the assertion `symptom-page-shape` fails when a page declaring `page_type: symptom` omits `## What you are seeing`, `## Most likely cause`, `## Check this first`, `## Other causes` or `## Still stuck`, or declares an empty `search_aliases`

### Story 6.3: Write the blank phone column symptom page

As an operator who enabled phone lookup and got nothing,
I want to know that mobile numbers depend on which provider key is connected,
So that I stop looking for a broken checkbox.

Source: .memlog.md:239 and .memlog.md:282; the fact is currently a single aside at `features/find-phone-numbers.md:12`.

**Acceptance Criteria:**

**Given** the mobile-provider constraint exists only as an aside
**When** `troubleshooting/no-phone-numbers.md` is authored with `page_type: symptom`
**Then** it names the constraint in the first sentence under `## Most likely cause` and links to the provider comparison page
**And** the assertion `symptom-aliases-indexed` fails when a symptom page's `search_aliases` values are absent from the built lunr index

### Story 6.4: Write the wrong companies symptom page

As an operator getting matches outside the intended profile,
I want the filters that narrow a search listed in one place,
So that I can tighten the search rather than abandon it.

Source: .memlog.md:239 and .memlog.md:267.

**Acceptance Criteria:**

**Given** the narrowing controls are documented across several feature pages
**When** `troubleshooting/wrong-companies.md` is authored with `page_type: symptom`
**Then** each cause names the literal control that resolves it and links to its owning page
**And** the assertion `symptom-page-shape` passes for the page and `check:links` resolves every named control link

### Story 6.5: Write the duplicate signals symptom page

As an operator seeing the same company twice,
I want the deduplication setting explained,
So that I can choose the behaviour I want.

Source: .memlog.md:231 and .memlog.md:282; the setting is currently explained only inside an empty-alt screenshot.

**Acceptance Criteria:**

**Given** the deduplication control is documented only inside an image today
**When** `troubleshooting/duplicates.md` is authored with `page_type: symptom`
**Then** the control, its options and its default are stated as text and as a table with no dependency on any image
**And** the assertion `no-instruction-only-in-image` fails when a page's only occurrence of a documented control name is inside an image alt attribute or filename

### Story 6.6: Write the over-strict AI filter symptom page

As an operator whose AI filter rejected everything,
I want to see what the prompt actually receives,
So that I can loosen it deliberately.

Source: .memlog.md:315 and .memlog.md:239.

**Acceptance Criteria:**

**Given** the AI filtering and variables pages document the available variables
**When** `troubleshooting/ai-filter-too-strict.md` is authored with `page_type: symptom`
**Then** it states which variables come back empty on which provider and links to the variables reference
**And** the assertion `symptom-page-shape` passes for the page

### Story 6.7: Write the API authentication symptom page

As a developer receiving an authorization error,
I want each status code mapped to its cause,
So that I can tell a wrong key from a wrong path.

Source: .memlog.md:239 and .memlog.md:283; the status semantics exist today only inside the REST reference.

**Acceptance Criteria:**

**Given** the REST reference documents the authentication scheme and its error responses
**When** `troubleshooting/api-auth.md` is authored with `page_type: symptom`
**Then** every documented status code appears with its cause and its fix, and each links to the statuses reference
**And** the assertion `status-codes-cross-referenced` fails when a status code documented in the REST reference is absent from the statuses reference page

### Story 6.8: Write the stopped integration symptom page

As an operator whose destination stopped receiving leads,
I want the approval and credential causes named,
So that I check the two things that actually stop delivery.

Source: .memlog.md:239 and .memlog.md:316.

**Acceptance Criteria:**

**Given** the manual-approval behaviour and credential handling are documented on the integrations page
**When** `troubleshooting/integration-stopped.md` is authored with `page_type: symptom`
**Then** it names both causes with the check that confirms each and links to the integrations page
**And** the assertion `symptom-page-shape` passes for the page

### Story 6.9: Build the statuses and error codes reference

As a reader who searched for a literal status string,
I want one page that owns every machine-facing signal the product emits,
So that the string I saw has a page.

Source: .memlog.md:283 and .memlog.md:338; the interface status badges exist today only inside the changelog.

**Acceptance Criteria:**

**Given** the status badges, the REST error codes and the response headers are scattered across three pages
**When** the statuses reference is authored with `page_type: reference`
**Then** it lists every status string, code and header with its meaning and its owning page
**And** the assertion `reference-page-metadata` fails when a page declaring `page_type: reference` lacks a `verified_on` date or an `owner`

### Story 6.10: Publish one support page with a copy-paste diagnostic block

As a reader who could not self-serve,
I want one address and one list of what to include,
So that my first message contains everything needed to answer it.

Source: .memlog.md:286 and .memlog.md:342; the current pages split between a personal address and a support address.

**Acceptance Criteria:**

**Given** two different contact addresses appear across the current page set
**When** `support.md` is authored naming a single address and a fenced diagnostic block
**Then** the block lists exactly the identifiers needed to reproduce an issue and every other page's contact reference points at this page
**And** the assertion `single-support-address` fails when any page outside the support page and the policy pages contains an email address

### Story 6.11: Wire troubleshooting links into the task pages

As an operator following a task page whose final step failed,
I want the failure path named on the page I am already reading,
So that I do not have to search for the symptom.

Source: .memlog.md:351 (SYNTHESIS 5); EXPERIENCE.md task page contract.

**Acceptance Criteria:**

**Given** every task page declares `page_type: task`
**When** `bundle exec rake check` runs
**Then** the assertion `task-links-troubleshooting` fails when a task page's `## If it did not work` section contains no link to a page under `/troubleshooting/`
**And** every symptom page is reachable from at least one task page

## Epic 7: `_data/` DRY refactor

Move the six duplicated datasets into `_data/` and render pages as templates. This single structural move dissolves the object-model ambiguity, the provider-matrix duplication, the pricing contradiction and the integrations self-contradiction at once.

### Story 7.1: Fix and assert the data-file envelope convention

As an assertion author,
I want every data file to have the same top-level shape,
So that validating a new data file costs no schema library.

Source: architecture.md AD-7; .memlog.md:348 (SYNTHESIS 2).

**Acceptance Criteria:**

**Given** every file under `_data/` carries exactly a `meta:` mapping with `owner`, `verified_on` and `source`, plus an `items:` collection
**When** `bundle exec rake check` runs
**Then** the assertion `data-envelope-shape` fails when any data file declares a top-level key outside that pair, or when `meta` omits any of its three required keys
**And** the assertion `data-verified-on-parses` fails when any `meta.verified_on` is not an ISO date

### Story 7.2: Move the provider matrix into data

As a reader comparing people-data providers,
I want one table of record,
So that the provider facts on four different pages cannot disagree.

Source: .memlog.md:255 and .memlog.md:74.

**Acceptance Criteria:**

**Given** provider facts are duplicated across the comparison, bring-your-own, phone and variables pages
**When** `_data/providers.yml` is created with one item per provider carrying mobile support, at-source versus after-fetch behaviour per filter, credential shape, signup URL and an affiliate flag
**Then** every per-provider cost value is either sourced from this repository or a `TODO(owner: <handle>):` marker, and no cost is estimated
**And** the assertion `providers-schema` fails when an item omits any required key or declares an unknown key

### Story 7.3: Build the affiliate include that cannot omit its disclosure

As a reader following a provider link,
I want the commercial relationship disclosed at the link,
So that I can weigh the recommendation.

Source: .memlog.md:327 and .memlog.md:229; 22 affiliate-parameterised links exist across two pages today with no disclosure.

**Acceptance Criteria:**

**Given** `_includes/provider-link.html` is the only mechanism that emits a provider URL
**When** the include renders a provider whose `affiliate` flag is true
**Then** the emitted anchor carries `rel="sponsored nofollow"` and a visible cost label, and the label renders the provider's `TODO(owner: <handle>):` marker when the cost is unsourced
**And** the assertion `affiliate-links-disclosed` fails when any built page contains an anchor with an affiliate tracking parameter that lacks `rel="sponsored nofollow"` or was not emitted by the include

### Story 7.4: Move the AI variables into data

As a reader writing an AI prompt,
I want to know which variables are populated on my provider,
So that I do not write a prompt against fields that come back empty.

Source: .memlog.md:255 and .memlog.md:315.

**Acceptance Criteria:**

**Given** the variables are listed in prose on one page today
**When** `_data/variables.yml` is created with one item per variable carrying its name, meaning and the providers that populate it
**Then** the variables page renders from the data file and gains a per-provider availability column
**And** the assertion `variables-reference-providers` fails when a variable names a provider absent from `_data/providers.yml`

### Story 7.5: Move the integrations into data

As a reader choosing a destination,
I want a complete list with the credentials each one needs,
So that the numbered list on one page stops omitting destinations documented elsewhere.

Source: .memlog.md:259; the current integrations page omits destinations the changelog announced.

**Acceptance Criteria:**

**Given** the integrations page's numbered list contradicts the changelog and the feature pages
**When** `_data/integrations.yml` is created with one item per destination carrying credentials, plan requirement, field mapping and setup steps
**Then** the integrations index renders from the data file and every destination named anywhere in the repository appears in it
**And** the assertion `integrations-complete` fails when a destination name appears in any `.md` file but has no item in `_data/integrations.yml`

### Story 7.6: Move the search filters into data

As an operator tuning a search,
I want every filter documented with the same fields,
So that comparing two filters does not mean comparing two prose styles.

Source: .memlog.md:255 and .memlog.md:334.

**Acceptance Criteria:**

**Given** filters are described in varying prose across the advanced search page
**When** `_data/filters.yml` is created with one item per filter carrying its interface label, its click path, its options and its default
**Then** the filter documentation renders as a table from the data file and each row carries its literal interface label
**And** the assertion `filters-have-click-path` fails when an item omits its click path or its default

### Story 7.7: Create the pricing data file as the single figure source

As a maintainer,
I want every price and allowance to exist in exactly one file,
So that two pages cannot contradict each other about money.

Source: .memlog.md:335; supports closing audit finding F4.

**Acceptance Criteria:**

**Given** currency figures appear in prose on at least two pages today
**When** `_data/pricing.yml` is created carrying every plan, allowance, expiry and free-tier value as either a repository-sourced value or a `TODO(owner: <handle>):` marker
**Then** no figure is invented and every unsourced figure is an owner marker
**And** the assertion `currency-outside-data` fails when a bare currency symbol appears in any `.md` file outside the pricing template

### Story 7.8: Build the prerequisite include

As a reader landing on a page that will not work for them,
I want the blunt negative above the fold,
So that I stop before following steps that cannot succeed.

Source: .memlog.md:343 and .memlog.md:50.

**Acceptance Criteria:**

**Given** `_data/prereqs.yml` declares the prerequisite for each capability page
**When** `_includes/prereq.html` renders on a page declaring a `prereq:` key
**Then** the built page shows the prerequisite before its first task heading
**And** the assertion `prereq-key-resolves` fails when a page declares a `prereq:` value with no entry in `_data/prereqs.yml`

### Story 7.9: Render the provider comparison page from data

As a reader,
I want the comparison tables generated,
So that editing a provider fact means editing one line.

Source: .memlog.md:255.

**Acceptance Criteria:**

**Given** `_data/providers.yml` is populated
**When** the comparison page is rewritten as a Liquid template
**Then** both of its tables and every provider link render from the data file with no provider fact remaining in prose
**And** the assertion `providers-not-duplicated-in-prose` fails when a provider name appears in a table row that was not emitted from `_data/providers.yml`

### Story 7.10: Render the bring-your-own-provider and phone pages from data

As a reader,
I want the provider table and the mobile-support claim generated from the same file as the comparison page,
So that the three pages cannot drift apart.

Source: .memlog.md:255; supports audit finding F4.

**Acceptance Criteria:**

**Given** the provider table and the mobile-support claim are hand-written prose on two pages
**When** both are rewritten to render from `_data/providers.yml`
**Then** the mobile-support statement is generated from the provider items rather than naming a provider in prose
**And** the assertion `mobile-claim-generated` fails when the phone page names a provider in prose outside a Liquid-rendered block

### Story 7.11: Add a data-file freshness assertion

As a maintainer,
I want stale data files to surface,
So that a table that has not been checked in six months says so.

Source: .memlog.md:265 and architecture.md AD-7.

**Acceptance Criteria:**

**Given** every data file carries `meta.verified_on`
**When** `bundle exec rake check` runs
**Then** the assertion `data-staleness` reports every data file whose `verified_on` is more than 90 days old, listing each in the run summary
**And** the assertion fails the build when a data file's `verified_on` is in the future

## Epic 8: SEO and machine-readability

A company selling an agent data plane publishes the least agent-readable documentation it could. Fix the metadata, then publish the corpus in the two formats a machine actually wants. Closes F7.

### Story 8.1: Give every page a unique description

As a reader seeing this site in search results,
I want each result to describe its own page,
So that 28 identical descriptions stop competing with each other.

Source: .memlog.md:252 and .memlog.md:65; closes audit finding F7.

**Acceptance Criteria:**

**Given** every page already declares a unique, non-default `description` from Story 5.3
**When** each description is rewritten to read as a search-result snippet between 50 and 160 characters
**Then** every description states what the page answers rather than what the product sells
**And** the assertion `description-length` fails when any page's `description` is shorter than 50 or longer than 160 characters

### Story 8.2: Add jekyll-seo-tag and assert one canonical per page

As a crawler,
I want well-formed per-page metadata,
So that the canonical, the title and the social card agree with each other.

Source: .memlog.md:252; architecture.md AD-11.

**Acceptance Criteria:**

**Given** `jekyll-seo-tag` is added within the three-plugin budget
**When** the site is built
**Then** every HTML file carries exactly one `rel="canonical"`, one `og:title` and one `og:url`, and none contains a double slash after the host
**And** the assertion `one-canonical-per-page` fails when any page carries a count other than one

### Story 8.3: Publish llms.txt

As an AI agent reading this corpus,
I want a titled, described index of every page,
So that I can select a page without crawling the navigation.

Source: .memlog.md:257 and .memlog.md:349 (SYNTHESIS 3).

**Acceptance Criteria:**

**Given** a source file named with the target extension declaring `layout: null` and `permalink: /llms.txt`
**When** the site is built
**Then** `_site/llms.txt` is plain text listing every published page grouped by section with its title, absolute URL and its own `description`
**And** the assertion `llms-txt-covers-pages` fails when a published page is absent from `llms.txt`, or when any URL in it contains a double slash after the host

### Story 8.4: Publish llms-full.txt

As an AI agent,
I want the entire corpus as one document,
So that I can load it in a single fetch.

Source: .memlog.md:257 and .memlog.md:235.

**Acceptance Criteria:**

**Given** a source file declaring `layout: null` and `permalink: /llms-full.txt`
**When** the site is built
**Then** `_site/llms-full.txt` concatenates every published page's Markdown body, each preceded by its title and absolute URL
**And** the assertion `llms-full-covers-pages` fails when a published page's title is absent from the concatenation

### Story 8.5: Emit FAQPage structured data

As a search engine,
I want the FAQ marked up as structured data,
So that its answers are extractable.

Source: .memlog.md:252 and .memlog.md:65.

**Acceptance Criteria:**

**Given** the FAQ page is a sequence of question headings with answers
**When** `_includes/head_custom.html` emits FAQPage JSON-LD generated from those headings
**Then** the built FAQ page carries one JSON-LD block whose question count equals its heading count
**And** the assertion `faq-jsonld-matches-headings` fails when the counts differ or when the block is not valid JSON

### Story 8.6: Emit HowTo structured data on task pages

As a search engine,
I want task pages marked up as procedures,
So that their steps are extractable.

Source: .memlog.md:65.

**Acceptance Criteria:**

**Given** every task page declares `page_type: task` and carries a `## Steps` section
**When** the head include emits HowTo JSON-LD from that section
**Then** each task page carries one JSON-LD block whose step count equals the number of steps in its `## Steps` section
**And** the assertion `howto-jsonld-matches-steps` fails when the counts differ on any task page

### Story 8.7: Generate social cards from the page title and the existing palette

As a reader seeing a link to this site shared,
I want a card that names the page,
So that every shared link stops rendering as an untitled box.

Source: .memlog.md:306; the palette is already fixed in `_sass/color_schemes/signalsapi.scss` and requires no designer.

**Acceptance Criteria:**

**Given** the site has no `og:image` today
**When** a build step renders one 1200 by 630 card per page from the page title, its section and the committed palette
**Then** every built page carries an `og:image` resolving to its own card and every card file exists under the assets directory
**And** the assertion `og-image-per-page` fails when a page's `og:image` is missing or points at a file absent from the built site

### Story 8.8: Add jekyll-redirect-from and map the GitBook-era paths

As a visitor arriving from an old link,
I want the old URL to resolve,
So that the site's accumulated link equity survives the restructure.

Source: .memlog.md:285; architecture.md AD-14.

**Acceptance Criteria:**

**Given** `jekyll-redirect-from` is added within the three-plugin budget
**When** each known GitBook-era path is declared as a `redirect_from` entry on its current page
**Then** every declared old path resolves to a live page in the built site
**And** the assertion `no-page-deleted-without-redirect` fails when a page present in the baseline page list has neither a live URL nor a `redirect_from` entry claiming it

### Story 8.9: Assert that the machine-readable surfaces stay in sync

As a maintainer,
I want the four machine-readable artifacts checked against the page set,
So that adding a page cannot silently omit it from three of them.

Source: .memlog.md:349 (SYNTHESIS 3).

**Acceptance Criteria:**

**Given** `sitemap.xml`, `robots.txt`, `llms.txt` and `llms-full.txt` all exist
**When** a new page is added to the repository
**Then** the assertion `machine-surfaces-in-sync` fails when the page appears in the sitemap but not in `llms.txt`, or in `llms.txt` but not in `llms-full.txt`
**And** the assertion reports the missing surface by name rather than failing generically

## Epic 9: Trust and governance

The root cause the audit found is that nobody owns a page, so every fact rots quietly. This epic makes rot visible by default and publishes the limitations a buyer already suspects.

### Story 9.1: Stamp every page with an owner and a verification date

As a reader,
I want to know when a page was last checked and by whom,
So that I can weigh what I am reading.

Source: .memlog.md:265, .memlog.md:293 and .memlog.md:354 (SYNTHESIS 8).

**Acceptance Criteria:**

**Given** no page declares a verification date today
**When** every page gains `verified_on` and `owner` front matter, seeded honestly from the date each page was last substantively edited
**Then** the eight pages whose screenshots date from the GitBook era carry their true historical dates rather than the current date
**And** the assertion `verified-on-present` fails when any published page lacks `verified_on` or `owner`, or declares a `verified_on` in the future

### Story 9.2: Render the verification stamp on the page

As a reader,
I want the verification date visible on the page itself,
So that I do not have to read front matter to judge freshness.

Source: .memlog.md:242 and .memlog.md:265.

**Acceptance Criteria:**

**Given** every page declares `verified_on`
**When** the theme renders a page
**Then** the built page shows the date in its header or footer, styled with the committed palette and no new colour token
**And** the assertion `verified-on-rendered` fails when a page's `verified_on` value is absent from its built HTML

### Story 9.3: Publish the documentation health page

As a reader deciding whether to trust this site,
I want its own quality metrics published,
So that the numbers go down in public rather than in private.

Source: .memlog.md:230, .memlog.md:112 and .memlog.md:354 (SYNTHESIS 8).

**Acceptance Criteria:**

**Given** the assertion registry already computes page-level findings
**When** `docs-health.md` renders a table generated at build time
**Then** it publishes pages missing a description, images with empty alt text, broken internal links, pages past their verification horizon, and orphan pages with zero inbound in-body links
**And** the assertion `docs-health-rows-match-registry` fails when a metric published on the page has no corresponding registered assertion

### Story 9.4: Add the staleness assertion

As a maintainer,
I want a page that has gone unverified for too long to be flagged by the build,
So that rot is caught by a machine rather than by a customer.

Source: .memlog.md:293 and .memlog.md:265.

**Acceptance Criteria:**

**Given** every page declares `verified_on`
**When** `bundle exec rake check` runs
**Then** the assertion `page-staleness` lists every page whose `verified_on` is more than 90 days old in the run summary and marks it red on the health page
**And** the assertion fails the build when a page carries no `verified_on` at all, so the stamp cannot be silently dropped to dodge the check

### Story 9.5: Add the orphan page assertion

As a reader,
I want every page reachable from another page's body,
So that content is discoverable by reading rather than only by searching.

Source: .memlog.md:221 and .memlog.md:230.

**Acceptance Criteria:**

**Given** the site model exposes every internal in-body link
**When** `bundle exec rake check` runs
**Then** the assertion `no-orphan-pages` fails when a published page that is not a router and not `nav_exclude`d has zero inbound in-body links
**And** the failure names each orphan page and the section it belongs to

### Story 9.6: Publish the limits page with owner markers for every unsourced figure

As a developer planning an integration,
I want the stated limits in one place,
So that I learn a constraint before I hit it rather than after.

Source: .memlog.md:116 and .memlog.md:332.

**Acceptance Criteria:**

**Given** limits are scattered as asides across the reference pages
**When** `limits.md` is authored with `page_type: reference`
**Then** each row states the limit, whether it is enforced today, and its owning page, and every unpublished figure is a `TODO(owner: <handle>):` marker rather than a number
**And** the assertion `limits-no-invented-figures` fails when the limits page contains a numeric quantity that is not traceable to a `_data/` value or an owner marker

### Story 9.7: Draft the wrong-tool pages to _drafts

As a prospective buyer,
I want the cases where this product loses named,
So that I can believe the cases where it wins.

Source: .memlog.md:275, .memlog.md:237 and .memlog.md:350 (SYNTHESIS 4). Held in `_drafts/` because the claims need an owner's sign-off before publication.

**Acceptance Criteria:**

**Given** the disqualifiers already exist as asides across the repository
**When** the wrong-tool pages are written into `_drafts/`
**Then** they build only with the drafts flag, are absent from `_site/`, `sitemap.xml`, `llms.txt` and the lunr index, and each carries an `owner` and a sign-off marker
**And** the assertion `drafts-not-published` fails when any file under `_drafts/` appears in the built site or in any machine-readable surface

### Story 9.8: Publish the commercial-relationship page

As a reader following a provider recommendation,
I want to know how this company makes money from it,
So that I can discount the recommendation appropriately.

Source: .memlog.md:229 and .memlog.md:353 (SYNTHESIS 7).

**Acceptance Criteria:**

**Given** `_data/providers.yml` carries an affiliate flag per provider
**When** the commercial-relationship page renders from it
**Then** every provider with the flag set is named on the page and the page is linked from every page that emits a provider link
**And** the assertion `affiliate-disclosure-linked` fails when a page emits an affiliate link and does not link to the disclosure page

### Story 9.9: Author the trust router

As a reader evaluating the product beyond its features,
I want the health, baseline, limits and commercial pages in one section,
So that the trust material is a place rather than a scattering.

Source: .memlog.md:295 and EXPERIENCE.md information architecture.

**Acceptance Criteria:**

**Given** the health, baseline, limits and commercial pages exist
**When** the trust router is authored with `has_children: true` and `page_type: router`
**Then** each of those pages declares the router as its `parent:` and appears in the router's link list
**And** the assertion `router-page-shape` passes for the trust router and `troubleshooting-router-complete`-style coverage holds for its children

## Epic 10: Agent data plane, static subset only

Replace four dead ends that say to email for access with artifacts a developer can use today: a specification, recorded fixtures on this origin, a local mock, and server source. Nothing in this epic stands up a hosted service, mints a key, or publishes a base URL.

### Story 10.1: Author the plane specification with status stamps

As a developer,
I want the interface described in a machine-readable specification,
So that I can generate a client before an endpoint exists.

Source: .memlog.md:345 and .memlog.md:236.

**Acceptance Criteria:**

**Given** the REST reference already documents the operations in prose and tables
**When** `openapi/plane-v1.yaml` is authored covering every documented operation
**Then** each operation carries an `x-status` value of `live`, `code-complete` or `planned`, and an `x-mcp-tool` key where a tool exists
**And** the assertion `spec-covers-documented-operations` fails when an operation documented in prose is absent from the specification, or when an operation lacks `x-status`

### Story 10.2: Lint the specification in its own task and CI step

As a maintainer,
I want the specification validated,
So that a malformed spec cannot ship as a machine-readable artifact.

Source: architecture.md AD-12; Spectral runs outside `rake check` to keep the default developer loop free of a Node toolchain.

**Acceptance Criteria:**

**Given** `bundle exec rake lint:openapi` invokes Spectral against `openapi/plane-v1.yaml`
**When** the specification contains a validation error
**Then** the task exits nonzero and the dedicated CI step fails
**And** the assertion `openapi-lint-step-present` fails when `openapi/plane-v1.yaml` exists and `ci.yml` declares no Spectral step

### Story 10.3: Publish recorded fixtures on the documentation origin

As a developer,
I want real-shaped responses at a URL I can fetch,
So that I can build against the contract with no key and no backend.

Source: .memlog.md:328, taking the fixtures and rejecting the service worker that would make a browser demo pass while the printed command fails in a terminal.

**Acceptance Criteria:**

**Given** source files named with the target extension declaring `layout: null` and an explicit `permalink:` under `/fixtures/v1/`
**When** the site is built
**Then** each fixture is served as JSON, carries a visible recorded-on date inside the payload, and matches the schema its operation declares in the specification
**And** the assertion `fixtures-match-spec` fails when a fixture's keys diverge from its operation's response schema, and the assertion `no-service-worker` fails when any JavaScript file registers a service worker

### Story 10.4: Publish a runnable command gallery against the fixtures

As a developer,
I want every printed command to work when pasted into a terminal,
So that the example and the artifact next to it cannot disagree.

Source: .memlog.md:328 and .memlog.md:225.

**Acceptance Criteria:**

**Given** the fixtures resolve at absolute URLs on this origin
**When** the gallery page prints one command per documented operation
**Then** every command targets a fixture URL that exists in the built site and every fenced block declares a language
**And** the assertion `gallery-urls-resolve` fails when a command in the gallery targets a URL absent from `_site/`

### Story 10.5: Document running the specification as a local mock

As a developer,
I want one command that serves the whole interface locally,
So that I can develop against the contract without waiting for hosting.

Source: .memlog.md:236.

**Acceptance Criteria:**

**Given** `openapi/plane-v1.yaml` carries example payloads matching the fixtures
**When** the mock instructions are published as a task page
**Then** the page states the exact command, names the tool version it was verified against, and links to the specification
**And** the assertion `mock-examples-match-fixtures` fails when an example payload in the specification diverges from the corresponding fixture

### Story 10.6: Commit the MCP server source and its connect snippet

As someone wiring an agent to this product,
I want the server source and the client configuration,
So that I can run it myself rather than wait for it to be hosted.

Source: .memlog.md:235 and .memlog.md:333; hosting, publication and a public URL are explicitly out of scope.

**Acceptance Criteria:**

**Given** the specification declares `x-mcp-tool` on the operations a tool exposes
**When** the server source is committed under `mcp/` and the connect snippet is published
**Then** the documented tool list is generated from the specification rather than hand-typed, and no page claims the server is hosted or published
**And** the assertion `mcp-tool-table-generated` fails when the rendered tool table diverges from the `x-mcp-tool` set in the specification

### Story 10.7: Publish the plane status document

As an agent or a developer,
I want the implementation status of each operation as data,
So that I can tell what works today from what is planned.

Source: .memlog.md:345 and .memlog.md:128.

**Acceptance Criteria:**

**Given** every operation carries `x-status`
**When** a source file with `layout: null` and `permalink: /plane-status.json` renders from the specification
**Then** the built JSON lists every operation with its status and its MCP tool where one exists
**And** the assertion `plane-status-matches-spec` fails when the built document and the specification disagree about any operation's status

### Story 10.8: Replace the four email dead ends

As a developer reading the plane pages,
I want a path forward on the page,
So that evaluation does not require a human on the other end.

Source: .memlog.md:232 and .memlog.md:344; four pages currently end at an instruction to email for a base URL.

**Acceptance Criteria:**

**Given** four pages instruct the reader to email for access
**When** each is rewritten to route to the specification, the fixtures, the mock and the waitlist
**Then** no plane page instructs the reader to email for a base URL or a key
**And** the assertion `no-email-for-access` fails when any page contains an instruction to email in order to obtain access, a base URL or a key

### Story 10.9: Correct the works-today claims

As a developer,
I want the pages to state what actually works,
So that I do not build against a surface that has no public endpoint.

Source: .memlog.md:232 and .memlog.md:298; two claims currently assert a surface works today against an interface with no public base URL.

**Acceptance Criteria:**

**Given** the plane pages assert that the interface works today
**When** each claim is rewritten to reflect the `x-status` value of the operations it describes
**Then** the parity sentence is generated from the specification rather than asserted in prose
**And** the assertion `no-live-sandbox-claim` fails when any page asserts that a public base URL, a hosted sandbox, or an issued key exists

### Story 10.10: Promote the API pages into a top-level section

As a developer,
I want the interface documentation at the top level,
So that I stop hunting for it inside a feature list.

Source: .memlog.md:118 and .memlog.md:284; just-the-docs resolves `parent:` by title, so this is a front-matter change with no file move and therefore no redirect.

**Acceptance Criteria:**

**Given** the five interface pages sit under the Features section today
**When** `apis/index.md` is created as a minimal router with `has_children: true`, `page_type: router` and an integer `nav_order`, and each of the five pages declares it as their `parent:`
**Then** all five render under APIs in the sidebar and every one of their URLs is unchanged
**And** the assertion `api-pages-urls-unchanged` fails when any of the five pages' built URL differs from its baseline URL recorded in `_data/baseline.yml`

## Epic 11: Content ops cleanup

Retire what is misleading, replace images that carry instructions with text, and move the changelog into data so it stops being the only record of shipped work. Closes F8 and F11.

### Story 11.1: Inventory the screenshots as data

As a maintainer,
I want every image declared with its subject, its capture date and its owning page,
So that I can tell a current screenshot from one that depicts a product that no longer exists.

Source: .memlog.md:104 and .memlog.md:317; closes the first half of audit finding F8.

**Acceptance Criteria:**

**Given** the repository holds 70 images, 62 of them with empty alt text and eight dating from the GitBook era
**When** `_data/screenshots.yml` is created with one item per image carrying its path, subject, capture date, owning page and alt text
**Then** every image in the repository has an item and every item's path resolves to a file
**And** the assertion `screenshot-inventory-complete` fails when an image file has no item, or when an item names a path that does not exist

### Story 11.2: Eliminate empty alt text

As a reader using a screen reader,
I want every image described,
So that the site's images stop being invisible to me.

Source: .memlog.md:221 and .memlog.md:321; closes the second half of audit finding F8.

**Acceptance Criteria:**

**Given** `_data/screenshots.yml` carries alt text per image
**When** every image reference is rewritten to render its alt text from the data file
**Then** no image in the built site carries an empty alt attribute
**And** html-proofer's alt-text check passes and the assertion `alt-text-from-inventory` fails when a built image's alt attribute differs from the value in `_data/screenshots.yml`

### Story 11.3: Replace the instructional screenshots with click paths and field tables

As a reader on a page whose instructions live inside an image,
I want the steps as text,
So that the instructions are searchable, translatable and readable without sight.

Source: .memlog.md:334, .memlog.md:86 and .memlog.md:119; on two pages the entire instructional payload currently lives inside empty-alt images.

**Acceptance Criteria:**

**Given** eight images from the GitBook era depict a product surface that no longer matches the application
**When** each is replaced by a click path and a field table rendered from `_data/filters.yml` or `_data/controls.yml`
**Then** those eight image files are deleted and no page's instructions depend on an image
**And** the assertion `no-instruction-only-in-image` fails when a documented control name appears in the repository only inside an image alt attribute or filename

### Story 11.4: Adopt the text-first rule for new pages

As a maintainer,
I want new instructional content to be text by default,
So that the screenshot debt cannot rebuild itself.

Source: .memlog.md:38 and .memlog.md:334.

**Acceptance Criteria:**

**Given** the screenshot inventory exists
**When** a new page adds an image
**Then** the assertion `image-requires-inventory-entry` fails when an image is referenced without an item in `_data/screenshots.yml` carrying alt text and a capture date
**And** the assertion `screenshot-age` lists every image whose capture date is more than 180 days old in the run summary

### Story 11.5: Author the APIs router

As a reader who cannot tell which of the several interfaces they need,
I want a page that routes by intent,
So that the two similarly named integration paths stop being confused for each other.

Source: .memlog.md:284 and .memlog.md:280.

**Acceptance Criteria:**

**Given** `apis/index.md` exists as the minimal router created by Story 10.10
**When** the page is built
**Then** it carries a table whose rows are reader intents and whose targets are the interface pages, and both similarly named integration pages carry a one-line banner pointing at each other
**And** the assertion `apis-router-covers-children` fails when a page declaring the APIs router as its `parent:` is absent from the router's table

### Story 11.6: Build the pricing page structure

As a prospective customer,
I want a pricing page that exists,
So that the terms page stops citing a page that returns an error.

Source: .memlog.md:290 and .memlog.md:335; the terms page already cites a pricing page that does not exist.

**Acceptance Criteria:**

**Given** `_data/pricing.yml` exists with owner markers for unsourced figures
**When** `pricing.md` renders from it
**Then** every figure on the page comes from the data file, every unsourced figure renders as its owner marker, and the terms page's citation resolves
**And** the assertion `pricing-page-renders-from-data` fails when the pricing page contains a currency symbol outside a Liquid-rendered block

### Story 11.7: Move the changelog into data

As a maintainer,
I want each release entry to be a data item with a target page,
So that a shipped feature cannot exist only in a changelog paragraph.

Source: .memlog.md:75, .memlog.md:264 and .memlog.md:294; closes the first half of audit finding F11. The changelog is 3478 words across 105 entries and is the only record of several shipped features.

**Acceptance Criteria:**

**Given** the changelog is one 3478-word page of 105 entries
**When** `_data/changelog.yml` is created with one item per entry carrying its date, summary and the page it affects
**Then** every entry has a `date` and a `feature` naming a page that exists
**And** the assertion `changelog-entry-has-target` fails when an entry names a page absent from the built site or omits its date

### Story 11.8: Render the changelog and the per-page change strips

As a reader on a feature page,
I want to see what changed on that feature,
So that the release history reaches the page it is about.

Source: .memlog.md:223 and .memlog.md:264.

**Acceptance Criteria:**

**Given** `_data/changelog.yml` is populated
**When** the changelog page and a per-page change block render from it
**Then** the changelog page lists every entry in date order and each feature page shows the entries naming it
**And** the assertion `changelog-page-complete` fails when an entry in the data file is absent from the built changelog page

### Story 11.9: Backfill the undocumented releases

As a reader,
I want the recent shipped work recorded,
So that the changelog stops being dead while the product ships.

Source: closes the second half of audit finding F11; the interface access and agent data plane launches shipped with documentation and no changelog entry, and the changelog has been dead since 2025-04-09.

**Acceptance Criteria:**

**Given** two 2026 launches have documentation pages and no changelog entry
**When** entries for both are added to `_data/changelog.yml` with their commit dates and target pages
**Then** the changelog's newest entry date is not earlier than the newest documentation page's creation date
**And** the assertion `changelog-not-behind-docs` fails when a page exists whose creation date is later than the newest changelog entry and which no entry names

### Story 11.10: Shrink the changelog image payload

As a reader on a phone,
I want the changelog to load,
So that a release history does not cost megabytes.

Source: .memlog.md:307 and .memlog.md:325; 53 of the repository's 70 images sit in the changelog.

**Acceptance Criteria:**

**Given** the changelog carries 53 images totalling the bulk of the repository's image payload
**When** entries move into data and images without an instructional purpose are retired
**Then** every surviving image declares intrinsic width and height and has an item in `_data/screenshots.yml`
**And** the assertion `image-dimensions-declared` fails when a built image element omits width or height

### Story 11.11: Retire the redundant status page with a redirect

As a reader,
I want one answer to whether the product is running,
So that a 23-word page duplicating an FAQ answer stops occupying a navigation slot.

Source: .memlog.md:231 and .memlog.md:281; architecture.md AD-14 requires the paired redirect.

**Acceptance Criteria:**

**Given** the page duplicates an existing FAQ answer in 23 words
**When** it is deleted and its URL is claimed by a `redirect_from` entry on the FAQ page in the same commit
**Then** the old URL resolves to the FAQ answer and the page is absent from the built site
**And** the assertion `no-page-deleted-without-redirect` fails when a baseline URL resolves to neither a page nor a redirect

### Story 11.12: Adopt a page budget

As a maintainer,
I want adding a page to be a deliberate act,
So that the corpus stops accreting pages nobody owns.

Source: .memlog.md:61 and .memlog.md:329.

**Acceptance Criteria:**

**Given** the hand-written page count is pinned in `_data/baseline.yml`
**When** a pull request adds a hand-written page
**Then** the assertion `page-budget` fails when the count exceeds the pinned ceiling without the ceiling changing in the same commit
**And** the failure message names the current count, the ceiling, and the retirement ledger entry required to raise it

### Story 11.13: Publish the retirement ledger

As a reader who lost a page,
I want to see where it went,
So that a deletion is a redirect with a reason rather than a disappearance.

Source: .memlog.md:329 and .memlog.md:231.

**Acceptance Criteria:**

**Given** pages have been retired across Epics 2 and 11
**When** the retirement ledger renders from the `redirect_from` entries in the built site
**Then** every retired URL appears with its replacement and the reason it was retired
**And** the assertion `retirement-ledger-complete` fails when a `redirect_from` entry exists in the repository and is absent from the ledger page

## Requirements Inventory

Each audit finding, the epic that closes it, and the assertion that keeps it closed.

| Finding | Summary | Closed by | Guarding assertion |
| --- | --- | --- | --- |
| F1 | Site url carries a trailing slash, malforming every canonical, `og:url` and JSON-LD URL on all 28 pages | Epic 2, Story 2.1 | `canonical-no-double-slash` |
| F2 | No `exclude:` key, so the template README, licence, shell scripts and Gemfiles are published | Epic 2, Story 2.2 | `site-excludes-scaffolding` |
| F3 | Dead GitBook-era relative link at `features/filter-leads-with-ai.md:32`, broken for 21 months, with a build that exits zero anyway | Epic 2, Stories 2.3 and 2.7; detection from Epic 1, Story 1.3 | `no-gitbook-mention-artifacts`, html-proofer via `check:links` |
| F4 | Phone pricing in the FAQ contradicts the bring-your-own-provider model; plan figure uncorroborated; typo `propsects` | Epic 2, Stories 2.8 and 2.9; single source from Epic 7, Story 7.7 | `phone-pricing-not-in-faq`, `currency-outside-data` |
| F5 | Duplicate `nav_order: 6`, unused `nav_order: 5`, fractional shims throughout | Epic 2, Story 2.10; structure pinned by Epic 5, Story 5.9 | `nav-order-integrity`, `root-section-count` |
| F6 | Every root page declares `layout: home`, including leaf content pages | Epic 2, Story 2.11 | `layout-home-is-index-only` |
| F7 | All 28 pages inherit one site description; no per-page metadata, no social image, no structured data | Epic 8, Stories 8.1, 8.2, 8.5, 8.6 and 8.7; contract from Epic 5, Story 5.3 | `description-unique`, `description-not-site-default`, `one-canonical-per-page`, `og-image-per-page` |
| F8 | 62 of 70 images have empty alt text; eight GitBook-era screenshots carry the entire instructional payload of two pages | Epic 11, Stories 11.1, 11.2, 11.3 and 11.4 | `alt-text-from-inventory`, `no-instruction-only-in-image`, `screenshot-inventory-complete` |
| F9 | `features/index.md` is a 10-word landing page with no `has_children: true`, so feature pages are siblings of root pages | Epic 5, Story 5.8 | `no-childless-has-children`, `parent-resolves-to-has-children` |
| F10 | Home page is 325 words of pitch with zero links into the docs; the quick-start page was deleted | Epic 5, Stories 5.1, 5.2 and 5.7 | `home-is-router`, `frontmatter-universal-contract`, `search-creation-documented` |
| F11 | Changelog is 3478 words, dead since 2025-04-09, and the only record of several shipped features | Epic 11, Stories 11.7, 11.8 and 11.9 | `changelog-entry-has-target`, `changelog-not-behind-docs` |
| F12 | CI runs a bare build that exits zero with every finding above present; local Ruby differs from CI Ruby with no pin in the repository | Epic 1, all stories, in particular 1.1, 1.9 and 1.10 | `ci-runs-rake-check`, `ruby-version-single-source`, `checks-manifest-current` |

## Backlog Summary

| Epic | Title | Stories |
| --- | --- | --- |
| 1 | Verification harness | 13 |
| 2 | Credibility patch | 15 |
| 3 | Baseline | 3 |
| 4 | Core concepts and the object model | 9 |
| 5 | Getting started | 10 |
| 6 | Symptom-named troubleshooting | 11 |
| 7 | `_data/` DRY refactor | 11 |
| 8 | SEO and machine-readability | 9 |
| 9 | Trust and governance | 9 |
| 10 | Agent data plane, static subset only | 10 |
| 11 | Content ops cleanup | 13 |
| | **Total** | **113** |


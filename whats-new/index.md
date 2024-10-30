---
title: What's new
layout: home
nav_order: 5
---

# What's new

## 30.10.2024

- Bugfix: Daily searches sometimes did not plan the next run.

## 29.10.2024

- Bugfix: The new search engine introduced September 29th was not properly fed the "remote" parameter so it was ignored in LinkedIn searches.

## 26.10.2024

- When search is scheduled for the first time, it will not require a manual "Run now" anymore but will start running after a defined interval

## 23.10.2024

- Automated daily testing of new user registration, verification, welcome email

## 22.10.2024

- New engine for docs.signalsapi.com

## 20.10.2024

- Added more country options into both LinkedIn and Indeed searches.
- Added more location clusters to LinkedIn searches, like North America, Latin America etc.

## 19.10.2024

- Users on expired and cancelled plans are still able to go to billing and download invoices

## 18.10.2024

- Fixed bug -- manually initiated search never stopped but created a new run right after previous one has ended

## 29.09.2024

- Search speed and stability improved

## 26.09.2024

- Searching and fetching engine were completely re-written. The new one works slower, but much more stable.

## 08.07.2024

- Scheduled searches that were paused because of low balance continue automatically after balance top-up

## 20.06.2024

- Export showing integration name and exports per day stats.

Bugfixes

- Fixed webhook exporting

## 19.06.2024

- Exporting to a specific list in Hubspot

![](/whats-new/2024-06-19-exporting-to-a-specific.png)

- Popular choices are shown separately
- Ability to choose all popular choices with one click

![](/whats-new/2024-06-19-ability-to-choose-all.png)

## 18.06.2024

- Search has a "Job posting age" setting, which controls how recent the job posting should be to get matched.

![](/whats-new/2024-06-18-job-posting-age.png)

## 17.06.2024

- Filtering jobs based on where the match was found. Solving two most popular problems -- "too few matches" and "too many junk matches".

![](/whats-new/2024-06-17-filtering-jobs.png)

## 16.06.2024

- Showing in the run which part of the signal matches search terms. Some matches do not contain search terms at all, but the search engine (Indeed or LinkedIn) still shows them.
- Highlighting relevant keywords in the job title and description when viewing the match

## 14.06.2024

- Sourcing from Indeed

![](/whats-new/2024-06-14-sourcing-from-indeed.png)

## 07.06.2024

- Sped up navigation by moving frontend to a separate server
- [whoishiring.uk](https://whoishiring.uk/) -- a simplified stand-alone tool for developer jobs

## 30.05.2024

- Worldwide search on LinkedIn (searches -> add -> hiring location)

![](/whats-new/2024-05-30-worldwide-search-on-linkedin.png)

- Auto-validating emails in Snov.io (exports -> add -> snovio -> validate emails)

![](/whats-new/2024-05-30-auto-validating-emails.png)

## 29.05.2024

- Weekly emails with statistics

## 20.05.2024

- Limit the number of decision-makers per company. If more decision-makers are identified, they are prioritized in the order specified in the 'titles' field, and those with valid email addresses come first.

![](/whats-new/2024-05-20-limit-the-number-of-dec.png)

- Do-Not-Contact list allows to make sure you do not contact companies or people you do not want to. Set it up in [Leads -> DNC](https://app.signalsapi.com/dnc/).

![](/whats-new/2024-05-20-do-not-contact-list.png)

## 18.05.2024

- List views of searches, filters, personas, lead lists and exports show where they are taking data from and where they are sending it to.

![](/whats-new/2024-05-18-list-views-of-searches.png)

Bugfixes:

- Fixed: Searches get stuck forever in "running" status if run has failed.
- Fixed: Resetting a failed search did not reset match counts in that search so search match count stopped matching sum of success counts of its runs.
- Fixed: Opening a filter and a persona took significant time.

## 14.05.2024

- Leadlist has an AI field which applied to each person, available templates are {first_name}, {last_name}, {title}, {email}, {linkedin_url}

## 13.05.2024

- Leads within a leadlist, matches within personas and filters can be filtered by date

![](/whats-new/2024-05-13-leads-within-a-leadlist.png)

- Leads are downloaded based on the applied filters

## 12.05.2024

- Anti-bot protection
- Accepting registrations with personal emails, but asking for company info and limiting free runs in this case

## 11.05.2024

- Requiring business email to register
- Multiple bugs fixed

## 10.05.2024

- Searches, filters, personas and leadlists can be cloned

![](/whats-new/2024-05-10-searches-filters-personas.png)

- AI powered rejection of leads

![](/whats-new/2024-05-10-ai-powered-rejection-1.png)

![](/whats-new/2024-05-10-ai-powered-rejection-2.png)

- Search shows status as "running" while its runs are fetching

## 09.05.2024

- By default, deduplication of matches occurs within each run, not across the entire search. This avoids confusion regarding the actual match count for a given run. Deduplication on the search level and globally is still available as a lead list setting.
- LinkedIn match limits per search run increased.
- New run status: Fetching
- Regions of England in search location

Bugfix:

- Fixed: runs in "Fetching" status were showing as "Completed"

## 08.05.2024

- Preventing double submissions in forms by disabling buttons on first click
- If leadlist is reset while running, the run is terminated

Bugfixes:

- Fixed: deleting filter fails with a missing variable
- Fixed: deleting filters

## 07.05.2024

- AI-powered enrichment

Bugfixes

- Fixed: personas pulling disqualified matches

## 06.05.2024

- Showing job description

![](/whats-new/2024-05-06-showing-job-description.png)

- Company description is shown with line breaks instead of smashing all lines together
- Lead view has clickable hyperlinks for job posting, company website and LinkedIn, person LinkedIn

## 05.05.2024

- Speed-up under the hood: searching and fetching+enriching happens in separate processes, allowing new matches to appear and get processed before the whole search run is completed

## 04.05.2024

UX improvements:

- Email unlocking speed increased
- Checkboxes are changing state when clicked on their labels

Bugfixes:

- Fixed: newly created filters processed runs before they were completed

## 03.05.2024

- Filtering by job stop words and required words

![](/whats-new/2024-05-03-filtering-by-job-stop.png)

Bugfixes:

- Fixed: duplicate leads
- Fixed: showing people counts in persona list
- Fixed: filter is counting qualified matches, not all matches

## 02.05.2024

- Warning message on trying to create a duplicate search with the same parameters
- Auto-unlocking all emails if auto-approve is enabled

Bugfix:

- Fixed: unlocking emails gets stuck if email is missing

## 01.05.2024

- People in lead list have addresses

![](/whats-new/2024-05-01-people-in-lead-list.png)

- People can be filtered by location

![](/whats-new/2024-05-01-people-can-be-filtered.png)

- Save / save and re-run buttons in filters and personas

![](/whats-new/2024-05-01-save-save-and-re-run.png)

- All yearly credits are debited on the payment date

Bugfixes:

- Fixed: email unlocking
- Fixed: lead status does not change to "exported" after exporting happens

## 30.04.2024

- Moved to a more powerful server, everything works much faster now
- Showing running status in search list
- When you click "approve" or "reject" it shows the next lead, saving a few clicks

Bugfixes:

- Fixed: it is now possible to reject a lead that does not have unlocked emails
- Fixed: it is now possible to approve a lead before emails finished unlocking, export will happen automatically when unlocking is finished
- Fixed: searches are getting stuck in an infinite loop

## 29.04.2024

- New leads are marked as "New", and then change to "Seen" when you open them for the first time.

![](/whats-new/2024-04-29-new-leads-are-marked.png)

- Leads will get exported after you approve them by clicking "Approve" or "Reject" buttons, or enabling auto-approval in lead list settings.

![](/whats-new/2024-04-29-leads-will-get-exported.png)

## 28.04.2024

- New tab "Leads" for working with leads in a mailbox-style with folders, downloading, unlocking emails, etc

![](/whats-new/2024-04-28-new-tab-leads-for-working.png)

- Automatic approval and rejection rules can be set in lead list settings.

![](/whats-new/2024-04-28-automatic-approval-and-rej.png)

- Lead settings can be applied to new leads only, or the whole lead list can be emptied and re-run with the new settings.

![](/whats-new/2024-04-28-lead-settings.png)

## 26.04.2024

- One job title per search. Splitting a search into multiple ones with one title each produces results much faster, and also shows which searches are yielding matches, and which are not.
- To use multiple keywords in one search, you can:
  * either add multiple searches
  * or use modifiers in one search, for example, **keyword1 OR keyword2** for LinkedIn ([details](https://www.linkedin.com/help/linkedin/answer/a507571/using-boolean-modifiers-when-searching-for-jobs-on-linkedin))
- "Data sources" renamed to "Searches", "Filters" and "Personas" to avoid confusion

![](/whats-new/2024-04-26-one-job-title-per-search.png)

- Uniqueness / deduplication policy is now a part of the Searches form
- Tables got condensed to fit more data on the screen

## 25.04.2024

- "Unlock email" link works much faster
- Showing people counts in filters, personas, exports
- Showing date in matches

## 23.04.2024

- Each page (searches, filters, personas, export) showing running status automatically updates when running is finished

![](/whats-new/2024-04-23-showing-running-status.png)

## 22.04.2024

- Searches, Filters, and Personas are separated into different tabs and steps, so instead of having to wait until the whole search & processing will end, you can see intermediate results much faster.

![](/whats-new/2024-04-22-search-filters-personas.png)

- Different countries were separated to different searches for the same purpose -- you can see first country results faster, before all countries searches have finished.
- Credits are charged per run, not per match, so, hopefully, you'll get much more matches per credit.
- Previous matches are temporarily unavailable

## 16.04.2024

- The pricing model has changed to monthly run limits. A "run" is one job title, in one country, from one source, per day. To calculate your needed runs: (Number of Job Titles) x (Number of Countries) x (Number of Sources) x (Runs per Day) x (30 days)
- "Max credits daily" setting is removed since match count do not influence cost.
- You can now control how often runs are scheduled (and if they are scheduled at all) in each individual search settings.

![](/whats-new/2024-04-16-control-runs-schedule.png)

- Any query can be run manually.

![](/whats-new/2024-04-16-any-query-can-be-run.png)

- You can now choose if you still want to filter out companies without identified decision-makers, using "Minimum number of identified decision-makers" and "Minimum number of valid emails per match" fields.

![](/whats-new/2024-04-16-filter-out-companies-without.png)

- If "Minimum number of valid emails per match" is left empty, emails will not be automatically unlocked, you can unlock them manually

![](/whats-new/2024-04-16-if-minimum-valid-emails.png)

## 11.04.2024

Improvements

- Matches list is opening much faster now

## 10.04.2024

- Search can be opened to see queries. Showing last run date/time, today/yesterday signal/match count, next run date/time.

![](/whats-new/2024-04-10-search-can-be-opened-to-see.png)

## 07.04.2024

- Started using Featurebase [https://signalsapi.featurebase.app/](https://signalsapi.featurebase.app/) to collect feedback / feature requests

## 05.04.2024

- Search performance improved significantly by using 2.5x more proxies, and caching all search results

## 04.04.2024

- Daily match limit

![](/whats-new/2024-04-04-daily-match-limit.png)

- Trial is either 150 leads or 7 days now, starting counting from user getting first match

Bugfixes:

- Fixed a bug that led to "Failed" match status

## 31.03.2024

- Filtering companies by keywords

![](/whats-new/2024-03-31-filtering-companies-by.png)

## 28.03.2024

- HubSpot integration

## 27.03.2024

- People without a verified email (only having a LinkedIn URL) can also be matched now. Use "require email" option in search to control this.

![](/whats-new/2024-03-27-people-without-a-verified.png)

- Showing uploaded matches with a white "uploaded" badge in the matches list, and an "uploaded" button in place of approval buttons in match view.

![](/whats-new/2024-03-27-showing-uploaded-matches.png)
![](/whats-new/2024-03-27-showing-uploaded-matches-2.png)

## 26.03.2024

- Settings have their own menuitem now

![](/whats-new/2024-03-26-settings-have-their-own.png)

## 24.03.2024

- Search has a new parameter to require manual pre-approval of each lead before uploading

![](/whats-new/2024-03-24-search-has-a-new-parameter.png)

- Matches can be manually approved

![](/whats-new/2024-03-24-matches-can-be-manually.png)
![](/whats-new/2024-03-24-matches-can-be-manually-2.png)

## 23.03.2024

- We started offering [business developer as a service](https://signalsapi.com/bizdev)
- Run view (Runs -> click any run) is showing disqualified signals
- Stop words for job title and company name / headline / description

![](/whats-new/2024-03-23-stop-words.png)

## 22.03.2024

- FAQ section in docs
- Run displays count of disqualified matches, duplicates, and matches without people
- Runs display their statuses

![](/whats-new/2024-03-22-run-displays-statuses.png)

Bugfixes

- Some runs got stuck, and needed to be deleted manually

## 20.03.2024

- Research and matching core is rewritten, the process sped up significantly
- All users must edit and save their searches for new core to kick in
- "Runs" tab showing which queries are running and their run status
- Editing a search no longer deletes previous matches, they still can be deleted manually by deleting items in "runs" tab
- Run frequency depends on plan now -- check the [pricing](https://signalsapi.com/pricing) page for details
- Credits spending can be limited to avoid spending everything in one go -- check profile -> settings
- Matches are shown per day
- De-duplication policy in search

![](/whats-new/2024-03-20-de-duplication.png)

- Matches are downloadable as CSV, go to Matches -> Download

![](/whats-new/2024-03-20-matches-downloadable-as-csv.png)

Bugfixes:

- Fixed: all matches are now visible, not only first 50
- Fixed: matches randomly appearing and disappearing

## 11.03.2024

- More integrations are listed in Profile -> Integrations -> Add Integration, some are not yet available. Selecting an unavailable integration will increase priority for that one integration in the roadmap.

## 09.03.2024

- Webhook integration. Sending Webhook on new matches.

## 08.03.2024

- Credits now are per-month, not per-day
- Free user gets a total of 150 credits
- Message "Search will be automatically repeated every hour" makes it clear that search is not one-time but continuous

## 04.03.2024

- Matches page shows stats instead of a progress bar

![](/whats-new/2024-03-04-matches-page-shows-stats.png)

## 02.03.2024

- Showing a message if no matches are found
- "Exact match in title" checkbox for stricter matching

![](/whats-new/2024-03-02-exact-match-in-title.png)

## 01.03.2024

- Job researcher can be set to match only remote or only on-site positions

![](/whats-new/2024-03-01-job-researcher-can-be-set.png)

## 25.02.2024

- Progress bar showing research progress in Matches

## 23.02.2024

- Large frontend update: user interface simplified, Researchers + Qualifiers + Personas + Processors were removed, it's all called "Searches" now. One large form instead of 4 small ones.

## 19.02.2024

- Mobile layout

## 18.02.2024

- [Apollo](https://apollo.grsm.io/u7of3p5poia1) integration

## 15.02.2024

- Multiple job titles in one researcher
- Showing signal details in match view

## 14.02.2024

- When subscription plan changes, research starts right away to use new credits
- Showing match details on click

## 12.02.2024

- Same company can be matched multiple times within one day by different processors

## 11.02.2024

- [Snov.io](https://snov.io/?_get=nick94) integration

## 09.02.2024

- The product is usable, more effort will be spent on promotion now
- Intro section of docs rewritten from scratch
- Screenshots were added to "How it works" section

## 08.02.2024

- Dashboard is showing signal count by researcher over time as a chart and in a table

## 04.02.2024

- "Personas" form is accepting comma-delimited values, not only newline-delimited (foolproofing)
- Company filter by country has 'exclude' mode&#x20;

![](/whats-new/2024-02-04-company-filter-by-country.png)

- Backend performance and stability improved

## 29.01.2024

- "What's new" page in docs
- Statistics per processor to "Processors" page

![](/whats-new/2024-01-29-statistics-per-processor.png)

- Status page [https://status.signalsapi.com/](https://status.signalsapi.com/)

## 22.01.2024

- First user has registered

## 30.03.2023

- First line of code was written

# PLAN — VA Budget, FY2008–FY2026

**Team:** Evandro M. S. Gomes · Solbee Kim · John Vasconcelos  ·  EPPS 6356 Data Visualization, Fall 2026

## 1. Question and audience
**What should the audience learn?** How the executive and legislative branches differ in how they fund the Department of Veterans Affairs (VA).
- **RQ1, requested vs. enacted.** How far do VA's budget requests fall from what Congress enacts? Does the gap change from year to year, and is it larger for some accounts (medical care, IT, construction)?
- **RQ2, discretionary vs. mandatory.** When did mandatory funding overtake discretionary funding, and which programs drove it? Is the discretionary share shrinking mostly because mandatory funding grows faster?

**Audience:** policy students, congressional and agency budget staff, journalists and veterans' organizations who follow VA appropriations but have no time to read the five-volume budget books.

## 2. Data
- **Source and citation:** U.S. Department of Veterans Affairs, *Congressional Budget Submission*, Volumes I–V, FY2008–FY2027 editions. Washington, DC: VA Office of Budget. Figures were transcribed and linked across editions by the team (`va_data.csv`).
- **Unit of observation:** a budget line (account or total) × fiscal year × budget edition. Each fiscal year appears up to three times: as a **request**, as **enacted/estimated**, and as **enacted/actual**.
- **Time span:** fiscal years 2008–2026 (19 years; the FY2027 request is excluded).
- **Key variables:** `fiscal_year` (time), `series_id` (14 discretionary accounts, mandatory programs and totals), `value` (budget authority, $ millions, nominal), `value_request`, `value_latest` (enacted), `gap_pct_of_request` = (enacted − requested) ÷ requested, plus the derived discretionary total (total VA − mandatory).

## 3. Charts
| # | Chart | Abela Thought-Starter | Why it fits |
|---|---|---|---|
| 1 | Dumbbell, requested vs. enacted by fiscal year | Comparison → among items, over time (Thought-Starter # __) | Places the two branches' numbers side by side for each year, so the gap is the distance between the dots. |
| 2 | Diverging columns, gap by year | Comparison → over time, few categories, column (# __) | Shows at a glance whether Congress gave more or less than requested each year. |
| 3 | Horizontal bars, gap by account | Comparison → among items, many items, bar (# __) | Ranks the 14 accounts so the most- and least-revised stand out. |
| 4 | Lines, mandatory vs. discretionary | Comparison → over time, many periods, line (# __) | Shows the year the mandatory line crosses the discretionary line. |
| 5 | Stacked area, mandatory funding by program | Composition → changing over time, many periods, stacked area (# __) | Shows which programs make up mandatory growth (Compensation & Pensions, Toxic Exposures Fund). |

Supporting views: heatmap (account × year), bubble chart (how often vs. which direction, Relationship), ranked curve (Distribution), contribution columns with a unit chart, and a growth index.

## 4. Interaction
- **Fiscal-year range slider** on every page. Charts, value boxes, chart titles and narrative text recompute for the selected window.
- **RQ1:** choose the funding type (discretionary, mandatory, total VA), filter account groups (medical care, IT, construction, other), and switch the account comparison (median absolute gap, mean signed gap, share of years changed).
- **RQ2:** show funding in $ billions or as a % of total VA funding, and select which mandatory programs to display.
- Tabs within each page let users compare views. The sidebar shows only the controls that affect the open tab.

## 5. Deployment
A **Quarto dashboard** (`format: dashboard`) with the two analysis pages built as **bslib Shiny apps running in Shinylive**. It is published as a static page on the course website (GitHub Pages).

**Why:** Shinylive runs R in the visitor's browser (webR), so we get full Shiny reactivity with no server to pay for or maintain. The same code can move to Posit Connect Cloud if the apps outgrow the browser. This route also sets up Assignment 9, which asks for a fully reactive dashboard.

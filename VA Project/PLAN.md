# PLAN: VA Budget, FY2008–FY2026

**Team:** Evandro M. S. Gomes · Solbee Kim · John Vasconcelos
**Course:** EPPS 6356 Data Visualization, Fall 2026 (Assignment 8, plan for the final team project)

## 1. Question

How do the executive and legislative branches differ in funding the U.S. Department of Veterans Affairs (VA)?

- **RQ1, requested vs. enacted.** How far do VA's budget requests fall from what Congress enacts? Does the gap change by year, and is it larger for some accounts (medical care, IT, construction)?
- **RQ2, discretionary vs. mandatory.** When did mandatory funding overtake discretionary funding, which programs drove it, and is the discretionary share shrinking mostly because mandatory funding grows faster?

**Audience:** [CONFIRM WITH TEAM: e.g., students and general readers interested in public budgeting, and policy analysts who want to see where Congress changes the President's requests.] They should leave knowing the size and direction of the request-to-enacted gap, and how much of VA's budget is now mandatory.

## 2. Data

- **Source:** U.S. Department of Veterans Affairs, *Congressional Budget Submission*, Volumes I–V, FY2008–FY2027 editions, compiled by the authors.
- **Unit of observation:** budget line (account, program or total) × fiscal year × budget edition. 965 rows, 20 budget series.
- **Time span:** FY2008–FY2026. Every series is measured over time.
- **Key variables:** `series_id`, `fiscal_year`, `edition`, `value` (budget authority, $ millions, nominal), `value_request`, `value_latest` (enacted), `gap_pct_of_request` = (enacted − requested) ÷ requested. Discretionary = total VA − mandatory.

## 3. Charts

Numbers refer to Abela's *Chart Suggestions: A Thought-Starter* as numbered in the course handout.

| Abela # | Chart in the dashboard | Why it fits |
|---------|------------------------|-------------|
| 4 | Columns: gap by year (RQ1) | Shows change over time and the direction of the gap, year by year. |
| 2 | Heatmap table: account × year gap (RQ1) | Compares many accounts across many years in one table. |
| 18 | Bubbles: how often and in which direction each account is changed (RQ1) | Relates three variables at once: frequency, direction and size of change. |
| 6 | Lines: mandatory vs. discretionary (RQ2) | Shows when the mandatory line crosses the discretionary line over many periods. |
| 14 (15 in % view) | Stacked area: mandatory programs (RQ2) | Shows which programs make up mandatory funding and how the mix changes. |

Supporting views: a dumbbell of requested vs. enacted by year, gap by account, ranked account-years, what drove the growth (columns and unit chart), and the discretionary share.

## 4. Interaction

- **Both pages:** a fiscal-year range slider.
- **RQ1:** funding type (discretionary, mandatory, total VA), account groups (medical care, IT, construction, other) and the comparison measure (median absolute gap, mean signed gap, or share of years changed by more than 1%).
- **RQ2:** units ($ billions or % of total VA funding) and which mandatory programs are shown.
- The sidebar shows only the controls that affect the open tab. Value boxes (three per page), chart titles and the text under each chart update with the selection.

## 5. Deployment

A Quarto dashboard with Shinylive (the RQ1 and RQ2 Shiny apps run in the visitor's browser), published on GitHub Pages as part of the course website, so no server is needed. This route can be extended into the fully reactive version for Assignment 9. Posit Connect Cloud is the fallback if Shinylive loads too slowly.

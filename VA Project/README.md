# VA Budget, FY2008–FY2026

An interactive dashboard on how the executive and legislative branches differ in funding the U.S. Department of Veterans Affairs (VA).

**Team:** Evandro M. S. Gomes · Solbee Kim · John Vasconcelos
**Course:** EPPS 6356 Data Visualization, Fall 2026 (Assignment 8 prototype, Assignment 9 map, final team project)

## Research questions
- **RQ1, requested vs. enacted.** How far do VA's budget requests fall from what Congress enacts? Does the gap change by year, and is it larger for some accounts (medical care, IT, construction)?
- **RQ2, discretionary vs. mandatory.** When did mandatory funding overtake discretionary funding, which programs drove it, and is the discretionary share shrinking mostly because mandatory funding grows faster?
- **Map, where VA spends (Assignment 9).** In which states do mandatory benefits (compensation and pension) make up most of VA spending, and how has that changed from FY2015 to FY2023?

## What is in the dashboard
| Page | Content |
|---|---|
| **Overview** | Title banner, the research questions and how to read the numbers. |
| **RQ1 · Requested vs. enacted** | 3 value boxes and 6 charts: dumbbell by year, gap by year, gap by account, account × year heatmap, how often and which way (bubbles), all account-years ranked. |
| **RQ2 · Discretionary vs. mandatory** | 3 value boxes and 4 views: mandatory vs. discretionary lines, mandatory programs (stacked area), what drove the growth (columns and unit chart), growth index and discretionary share. |
| **Map · Where VA spends** | Leaflet choropleth of the states with 3 value boxes (states shown, median state, national value) and a top-10 states chart, all fed by one shared `reactive()`. Inputs: measure (compensation & pension share, construction share, medical care per patient), fiscal year (FY2015–FY2023) and colour scale (quantile or continuous). |
| **Data** | Preview of the dataset. |

**Interaction:** a fiscal-year range slider on each analysis page, plus funding type, account groups, comparison measure, units ($ billions or % of total) and program filters. The sidebar shows only the controls that affect the open tab. Value boxes, chart titles and the text under each chart update with the selection.

## Files
| File | Purpose |
|---|---|
| `va_dashboard.qmd` | The Quarto dashboard. The two Shiny apps (RQ1 and RQ2) and the data are embedded in it for Shinylive. |
| `va_data.csv` | The dataset: 20 budget series × fiscal year × budget edition (965 rows). |
| `va_states.csv` | Map data: VA expenditures by state × fiscal year, FY2015–FY2023 (477 rows), built from GDX. |
| `us_states.geojson` | Map boundaries: 50 states, DC, Puerto Rico and Guam, simplified, EPSG:4326 (about 80 KB). |
| `va_map_data.R` | Builds `va_states.csv` and `us_states.geojson` from the files in `gdx/`. |
| `gdx/` | Source files for the map: VA GDX workbooks FY2015–FY2023 and the Census state boundaries (`states-10m.json`). |
| `IA prompts.md` | Statement on how generative AI was used in this project. |
| `VA_Project.Rproj` | RStudio project file. |
| `_extensions/` | The `quarto-ext/shinylive` extension. Created by `quarto add`. |

## Data
- **Source:** U.S. Department of Veterans Affairs, *Congressional Budget Submission*, Volumes I–V, FY2008–FY2027 editions.
- **Unit:** budget line (account, program or total) × fiscal year × edition. Values are budget authority in **$ millions, nominal**.
- **Key fields:** `series_id`, `fiscal_year`, `edition`, `vintage_lag` (0 = the request), `value`, `value_request`, `value_latest` (enacted), `gap_pct_of_request` = (enacted − requested) ÷ requested.
- **Derived:** discretionary = total VA − mandatory.

### Map data (Assignment 9)
- **Source:** U.S. Department of Veterans Affairs, National Center for Veterans Analysis and Statistics, *Geographic Distribution of VA Expenditures (GDX)*, FY2015–FY2023, state summary sheets (<https://www.va.gov/vetdata/Expenditures.asp>). Expenditures in $ thousands, nominal.
- **Boundaries:** U.S. Census Bureau cartographic boundary file of states, 1:10m, from the `us-atlas` package; joined by state name.
- **Measures:** compensation & pension share and construction share (% of the state's VA spending, Loan Guaranty excluded because GDX books all of it in Texas); medical care per unique patient ($). No "per veteran" figures, following GDX guidance. DC is shown as not comparable because its totals include VA Central Office. FY2024 and later are left out because GDX changed its method in FY2024.

## How to run
1. Install R packages (once):
   ```r
   install.packages(c("shinylive", "shiny", "bslib", "dplyr", "tidyr",
                      "ggplot2", "scales", "ggrepel", "patchwork",
                      "sf", "leaflet", "readxl", "tidyverse"))   # last line: Map page and va_map_data.R
   ```
2. Install the Shinylive extension (once, in the Terminal, in this folder):
   ```
   quarto add quarto-ext/shinylive
   ```
3. Preview the dashboard:
   ```
   quarto preview va_dashboard.qmd
   ```
   The first load of the RQ1 and RQ2 pages takes 10–30 seconds while R starts in the browser (webR); the Map page can take up to a minute the first time, because it also downloads `sf` and `leaflet`. Do not open the rendered `.html` file by double-clicking it, because Shinylive needs to be served over http.

## Deployment
Rendered as a static Quarto dashboard with Shinylive and published on GitHub Pages as part of the course website. Shinylive runs the Shiny apps in the visitor's browser, so no server is needed.

## Design
- **Theme:** U.S. veterans motif with flag navy `#0A3161`, flag red `#B31942`, gold `#D4A62A`, light blue `#6C9BD2`, olive `#6E7B3E` and steel grey `#B8C0CC`.
- **Fonts:** Oswald for headings and Source Sans 3 for text (Google Fonts).
- **Built with:** `bs_theme()` (bslib, Bootstrap 5) inside the apps and custom CSS in the dashboard header.

## Use of generative AI
This project was developed with the help of Anthropic's Claude. See [IA prompts.md](IA%20prompts.md) for what was done and how the team reviewed it.

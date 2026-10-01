# epps6356-hackathon
[EPPS 6356]  Assignment 4: 48‑Hour Chart Hackathon

**Team:** Solbee Kim, John Vasconcelos, Evandro M. S. Gomes

## About

Charts 1–4 from the Chart Thought-Starter, built with the Happy Planet Index (HPI) 2025 dataset for EPPS 6356 Data Visualization.


## Data

Data comes from the Happy Planet Index 2006-2025 public dataset, downloaded from:
https://happyplanetindex.org/wp-content/uploads/2026/07/Happy-Planet-Index-2006-2025-public-data-set.xlsx

The file `Happy-Planet-Index-2006-2025-public-data-set.xlsx` is included in this repo. Data is filtered to the year 2025 before use.


## Charts

- **Chart 1** (Solbee Kim): Variable-width column chart, continent population vs. mean HPI score
- **Chart 2** (Solbee Kim): Table with embedded bar charts, top 5 countries by HPI within each region
- **Chart 3** ([Teammate]): [chart type and description]
- **Chart 4** ([Teammate]): [chart type and description]


## How to Reproduce

1. Clone this repository
2. Open the `.qmd`/`.Rmd` file(s) in RStudio
3. Ensure these packages are installed: `tidyverse`, `gt`, `gtExtras`, `glue`, `readxl`
4. Render the document (all code runs from a clean R session using only repo contents)

Session info is included at the end of the rendered output for reproducibility.


## AI Disclosure

AI assistance was used in parts of this project. See `prompts.md` for full details (tool, model, prompts, and what was fixed).


## Repository Structure

- `[your .qmd/.Rmd filename]` — chart code and write-up
- `Happy-Planet-Index-2006-2025-public-data-set.xlsx` — source data
- `prompts.md` — AI usage disclosure
- `synergy_report.md` — team coordination report

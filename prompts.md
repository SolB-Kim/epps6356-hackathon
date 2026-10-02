------------------------------------------------------------------------

editor_options: markdown: wrap: 72 ---

# AI Usage Disclosure — prompts.md

------------------------------------------------------------------------

## Solbee: Tool Information

- **Tool:** Claude (Anthropic)
- **Model:** Claude Sonnet 5
- **Date:** October 1, 2026

### Chart 1: Variable-width Column

**Prompts used:** 1. "requesting Chart 1 code based on assignment PDF" 2. "I don't like the colors." 3. "I don't want to add a package" (requesting a pastel palette without the `colorspace` package) 4. "Still it's cut. I want to use legend() to make separate on the right" 5. "Title is bold?" 6. "Center and Right align mean including region table too, not only the graph"

**What had to be fixed:** Several rounds of formatting fixes were needed: rotated region-name labels were being clipped by the plot margins and had to be replaced with a legend instead; the title and caption needed `plot.title.position = "plot"` / `plot.caption.position = "plot"` added (not just `hjust`) to actually center/right-align across the full plot including the legend area, since `hjust` alone only aligned within the panel; one palette color (yellow) needed manual darkening for readability against a white background.

### Chart 2: Table with Embedded Charts

**Prompts used:** 1. Request for a `gt` + `gtExtras` table of top countries by HPI with inline bars (per assignment's suggested R approach) 2. "Can I use continents rather than countries?" 4. "Can we make a top 5 countries based on each continent?" (switching to grouped rows by region) 5. "HPI score graph can include numbers into the graph? Also I want to make a graph for Life expectancy with exact numbers into the graph." 6. Pasted error: `Error in dt_boxhead_set_var_order(): The length of vars must equal the row count of _boxh.` 7. "broken" (raw HTML showing as literal text instead of rendering) 8. "numbers need to be rounded to 2 decimal places" 9. "HPI score also need to round up" (follow-up fix after re-running code in correct order)

**What had to be fixed:** Chaining multiple `gt_plt_bar(..., keep_column = TRUE)` calls from the `gtExtras` package triggered a reproducible package bug (`dt_boxhead_set_var_order()` error), which required switching to a manual approach: building bar-and-number combinations as raw HTML via a custom `make_bar()` function and rendering them with `fmt_markdown()` instead of relying on `gtExtras`. An initial attempt using `text_transform()` with `gt::html()` displayed raw HTML as literal text rather than rendering it, and was replaced with `fmt_markdown()`, which rendered correctly. Decimal values also needed explicit rounding (`round(value, 2)`) inside the bar-building function, since the raw HPI, Life Expectancy, and Ecological Footprint values carried many unrounded decimal places.

------------------------------------------------------------------------

## John: Tool Information

- **Tool:** Claude (Anthropic)
- **Model:** Claude Opus 5.5
- **Date:** October 1, 2026

### Chart 3: Bar Chart

**Prompts used:** Please help me create a chart in R, using ggplot2. Give me the script for a chart as follows: 
1. The chart collects data from the data table named chart3_data - The y axis will display each category as a horizontal bar, with the categories pulled from the Countrycolumn 
2. The x axis will account for the size of the bars, using the Avg_HPIcolumn. The axis must show only zero and the highest value in the scale, which should be the next multiple of ten. No ticks, but keep the horizontal line. 
3. The horizontal bars' labels will display each category name followed by the respective Avg_HPI value. The labels will be placed close to the y-axis, in the vertical middle of each bar. 
4. Duplicate the same model an show on the first graph only the top 20 Avg_HPI and on the second graph only the bottom 20 Avg_HPI. 
5. Use theme_minimal() 
6. Use the following script to identify the visual identity and use the same standard of collors, font, size etc. Prefer a positive color for the top 20 (blueish) and a negative color (redish) for the bottom 20. 
7. Insert the title: "Top/bottom 20 countries per HPI" 
8. Insert a subtitle: "Based on average HPI from 2006 to 2025" 
9. Keep the same scale for the x axis on both graphs

# Use of Generative AI: Transparency Statement

**Project:** VA Budget, FY2008–FY2026 (EPPS 6356 Data Visualization, Fall 2026)
**Team:** Evandro M. S. Gomes · Solbee Kim · John Vasconcelos
**Prepared by:** John Vasconcelos, who held the AI session
**Date of the session:** October 31, 2026

## 1. Tool
| | |
|---|---|
| **Assistant** | Claude, developed by **Anthropic** |
| **Model** | Claude Opus 5.5 (`claude-opus-5-5`), the model configured for the session. The platform can fall back to another Claude model for individual turns, so a few turns may have been served by a different version. |
| **Interface** | The Claude app in agentic mode. The assistant could read the files we uploaded, write and run R, Quarto and Python code in a cloud workspace, and, with permission, save files to the project folder on John's computer. |
| **Language of the prompts** | Mostly Portuguese, summarized in English below. |

## 2. Summary of how AI was used
The **research questions, the choice of data source, the study window and all editorial decisions** (what to keep, cut, emphasize, and every visual preference) came from the team. Claude acted as a **programming and design assistant**. It:

1. **Data preparation.** Consolidated the team's spreadsheet and the VA Congressional Budget Submission volumes into one tidy CSV (`va_data.csv`). It linked each fiscal year's request, enacted/estimated and enacted/actual figures across budget editions, derived discretionary funding (total − mandatory) and computed the request-to-enacted gap. It also drafted a PDF data dictionary.
2. **Analysis report.** Read the team's updated proposal and wrote a static Quarto report answering only RQ1 and RQ2, with ggplot2 charts.
3. **Visual design.** Proposed and applied colour palettes and fonts. The team rejected two palettes, then chose one from a reference image. The final U.S. veterans theme (flag navy, red, gold, Oswald and Source Sans 3) was requested by the team using a reference poster.
4. **Dashboard.** Converted the report into a Quarto dashboard with two bslib Shiny apps running in Shinylive (webR). This included value boxes, sidebar inputs, tabbed charts, narrative text and message-style chart titles that recompute with the filters.
5. **Iterative refinement.** Implemented about 40 rounds of the team's feedback on layout, font sizes, legend placement, labels, chart proportions and which controls appear on each tab.
6. **Assignment check.** Compared the dashboard with the Assignment 8 instructions. It then added message titles, axis titles with units and a source note to every chart, and drafted `PLAN.md` and `README.md`.
7. **Setup help.** Explained how to install packages, add the Shinylive extension, preview the dashboard and publish it on GitHub Pages.

## 3. Prompt log (condensed, in order)
| # | Team prompt (summarized) | What the AI did |
|---|---|---|
| 1 | Make the project concrete from the VA volumes, our Excel file and the proposal: one CSV dataset, a PDF data dictionary and an HTML file answering each question with charts; give everything for download. | Built `va_data.csv`, the PDF dictionary and an HTML chart report, and packaged them as a zip. |
| 2 | Explain "which edition first shows the final figure". | Explained how budget editions revise a fiscal year's numbers. |
| 3 | Read the PDFs, the initial proposal and the slides; keep only the questions in the updated proposal; produce a report in `.qmd`. | Wrote the Quarto report for RQ1 and RQ2. |
| 4 | Put end-of-line labels on the index and line charts. | Replaced legends with direct labels. |
| 5 | Give the dumbbell chart a consulting-report look (reference image). | Restyled the dumbbell chart, with a change column and administration groups. |
| 6 | Label the area chart directly instead of using a legend; borrow ideas from reference images. | Added direct labels and new chart ideas. |
| 7 | Use the same visual style and fonts as our Assignment 7 file. | Matched fonts and styles. |
| 8 | Use a pastel palette and a lighter font; remove the arrows from the dumbbell. | Applied the changes (later rejected by the team). |
| 9 | "It didn't look good"; choose a font and a strong palette; make one horizontal stacked bar with labels on the right. | Proposed a new font and palette and rebuilt the bar chart. |
| 10 | Show standard R palettes to choose from. | Displayed palette options. |
| 11 | Use the palette from this infographic; remove the dots covering the lines. | Applied the palette and removed the dots. |
| 12 | Text is too small; find a font with more personality; the summary cards should follow the palette and be the same size. | Enlarged the text, switched to the Outfit font and fixed the cards. |
| 13 | Make the x-axis labels readable. Turn the report into a Quarto dashboard with Shinylive to publish on GitHub; propose interactive buttons; the text should update with the interactions. | Built the dashboard: two Shiny apps with embedded data, sidebar inputs, value boxes and dynamic text. |
| 14 | I unzipped the files into the project folder; what now? | Gave setup steps and created `VA_Project.Rproj` in the folder. |
| 15 | Align the author names with the title; fix the size and alignment of the Overview cards; make the value boxes shorter; make the axis text the size of the tab titles. | Adjusted CSS and ggplot theme sizes. |
| 16 | Remove the redundant app title bar; remove the Overview cards for now; make the axis and legend text 70% of the chart-title size. | Applied the changes. |
| 17 | (Correction) The changes did not appear. | Found a file-sync error, re-saved the files and verified them. |
| 18 | Make the sidebar text 90% of the tab size; make the charts less tall. | Applied the changes. |
| 19 | Leave a gap between the cards and the panel; switch the whole look to a U.S. veterans theme (reference poster). | Applied the veterans theme: palette, fonts, flag stripe, starred banner. |
| 20 | Still need a small gap under the value boxes. | Fixed the spacing. |
| 21 | Move legends inside the plots (top-left, bottom-right) with smaller keys; put the bubble labels on top; label the area chart directly; flatten the bars and space out the unit chart; animate the share charts. | Implemented all of these. |
| 22 | No outline on the bubble labels; more transparent blue bubbles; reposition the legends; put the area labels inside the plot; fix the bar proportions; animate in a loop without a slider. | Implemented all of these. |
| 23 | Remove the animation (too slow); make the bar chart fill the card width. | Removed the animation and split the bar chart and unit chart into separate plots. |
| 24 | Make the dots 50% larger; when will the charts be interactive? | Enlarged the dots and proposed further interactivity (tooltips, click-to-highlight, administration filter, inflation toggle, CSV download). |
| 25 | The comparison buttons do nothing on the "Request vs. enacted" tab. | Made the sidebar tab-aware so it shows only relevant controls. |
| 26 | Check whether the project meets Assignment 8. | Reviewed the requirements and listed the gaps. |
| 27 | Fix items 1–4 (message titles, axis units, source notes, PLAN.md). | Implemented them and drafted `PLAN.md`. |
| 28 | Update the README; create this AI-use statement. | Wrote `README.md` and this file. |

## 4. What the team is responsible for
- **Verification.** AI-generated code and transcribed figures can contain errors. The team is responsible for checking the dataset against the original VA budget volumes and for checking every number shown in the dashboard and in `PLAN.md`.
- **Interpretation.** Conclusions about the executive and legislative branches are the team's own. The automatic chart titles and text describe the data mechanically and should be read with that in mind.
- **Open items in PLAN.md.** The Abela Thought-Starter numbers were left for the team to fill in.

## 5. Other assistance in the same session (not part of this project)
During the same session the assistant also helped John with unrelated tasks. It edited his personal website (layouts of the statistical-table apps and a new "StatTables" menu), styled a class slide deck, gave English phrasing and course-logistics answers, set up a hypothesis test, and answered questions about home internet. These are listed only for completeness and did not involve this project.

---
*This statement follows the principle that the use of generative AI in academic work should be disclosed, described and verified by the authors.*


# Synergy Report

**Team members**
  - Solbee Kim (Coordinator)
  - Evandro M. S. Gomes
  - John Vasconcelos

**Repository:** https://github.com/SolB-Kim/epps6356-hackathon


## Task Delegation

As coordinator, I divided the four charts from the Chart Thought-Starter among the team:

- **Solbee Kim:** Chart 1 (Variable-width column) & Chart 2 (Table with embedded charts)
- **John Vasconcelos:** Chart 3 (Bar chart)
- **Evandro M. S. G.:** Chart 4 (Column chart)

All charts use the Happy Planet Index 2025 dataset, filtered and cleaned once so every chart draws from the same underlying data.


## How the Pieces Came Together

All four charts were merged into a single shared Quarto document, with one common setup section at the top 
(library imports, data loading, and continent-code cleaning) that every chart builds on, so no one repeated the same data-prep work. 
Below that, each team member's charts sit in their own clearly labeled section, 
keeping each person's data-setup and plotting code together and easy to attribute. 
To satisfy the assignment's design-consistency requirement, we aligned on a shared color palette 
(an eight-color region palette, reused by name rather than by position so it stays correct regardless of how each chart sorts its bars) 
and a common `theme_minimal()` base across all four charts. 
The document ends with a single `sessionInfo()` call confirming the whole file renders from one clean, shared environment.


## What We Would Do Differently

GitHub collaborator invitations took longer than expected to be accepted, which compressed the working window for the remaining team members. 
In future team projects, we would send and confirm collaborator access immediately at the start of the assignment, 
before beginning individual work, rather than treating it as a parallel task. 
We would also agree on the shared color palette and theme in the first hour, before any individual chart work began, 
rather than retrofitting consistent colors across charts after each person had already built their own version independently.


# Builds the two files used by the Map page of va_dashboard.qmd (run from the "VA Project" folder):
#   va_states.csv        GDX expenditures by state and fiscal year (FY2015-FY2023)
#   us_states.geojson    simplified state boundaries (EPSG:4326)
# The dashboard embeds copies of both files for Shinylive: after re-running this script, paste the new
# contents under "## file: va_states.csv" and "## file: us_states.geojson" in va_dashboard.qmd.
# Source data: gdx/GDX_FY15.xlsx ... gdx/GDX_FY23.xlsx (VA, National Center for Veterans
# Analysis and Statistics) and the U.S. Census Bureau cartographic boundary file of states,
# 1:10m, as distributed in the us-atlas package (states-10m.json).
library(tidyverse); library(readxl); library(sf)

read_gdx <- function(path) {
  fy <- 2000 + as.integer(str_extract(basename(path), "\\d{2}"))
  read_excel(path, sheet = "State Level Expenditures", skip = 2, .name_repair = "unique_quiet") |>
    select(1:11) |>
    set_names(c("state", "vet_pop", "total", "comp_pension", "construction", "edu_voc",
                "loan_guaranty", "gen_operating", "insurance", "medical_care", "unique_patients")) |>
    mutate(state = str_squish(state)) |>
    filter(!is.na(state), !is.na(total), state != "Totals") |>
    mutate(across(-state, as.numeric), fiscal_year = fy, .before = 1)
}

va_states <- list.files("gdx", pattern = "^GDX_FY\\d{2}\\.xlsx$", full.names = TRUE) |>
  map(read_gdx) |> list_rbind() |>
  mutate(
    # Loan Guaranty is booked entirely in Travis County, TX, so it is left out of state totals
    total_ex_loan = total - loan_guaranty,
    cp_share      = 100 * comp_pension / total_ex_loan,        # mandatory benefits, % of state VA spending
    med_per_pt    = 1000 * medical_care / unique_patients,       # $ per unique patient
    total_bn      = total_ex_loan / 1e6,                         # $ billions ($000s / 1e6)
    # DC totals include VA Central Office (headquarters) spending, so its shares and averages
    # are not comparable with the states: they are set to missing and shown as "not comparable"
    across(c(cp_share, med_per_pt, total_bn), \(x) if_else(state == "District of Columbia", NA, x))
  )
write_csv(mutate(va_states, across(where(is.double), \(x) round(x, 2))), "va_states.csv")

# Boundaries: TopoJSON -> sf, keep states, DC and the two territories in GDX, simplify for the web
states <- st_read("gdx/states-10m.json", layer = "states", quiet = TRUE) |>
  st_set_crs(4326) |>
  transmute(state = name, fips = id) |>
  filter(state %in% unique(va_states$state))
states <- st_make_valid(st_simplify(st_transform(states, 5070), dTolerance = 5000, preserveTopology = TRUE)) |>
  st_transform(4326)
unlink("us_states.geojson")
st_write(states, "us_states.geojson", quiet = TRUE,
         layer_options = "COORDINATE_PRECISION=3")

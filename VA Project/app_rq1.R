library(shiny)
library(bslib)
library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)

# ---------------------------------------------------------------- data
va <- read.csv("va_data.csv")
FY_MIN <- 2008; FY_MAX <- 2026

gaps_all <- va |>
  filter(vintage_lag == 0, latest_is_final == 1, !is.na(gap_pct_of_request))

accts <- c(
  acct_medical_services = "Medical Services", acct_medical_community_care = "Medical Community Care",
  acct_medical_support_compliance = "Medical Support & Compliance", acct_medical_facilities = "Medical Facilities",
  acct_medical_research = "Medical & Prosthetic Research", acct_it_systems = "IT Systems",
  acct_ehrm = "EHR Modernization", acct_construction_major = "Construction, Major",
  acct_construction_minor = "Construction, Minor", acct_grants_state_ext_care = "Grants, State Extended Care",
  acct_goe_vba = "General Operating Exp., VBA", acct_general_admin = "General Administration",
  acct_nca = "National Cemetery Admin.", acct_oig = "Inspector General")
grp_of <- c(
  acct_medical_services = "Medical care", acct_medical_community_care = "Medical care",
  acct_medical_support_compliance = "Medical care", acct_medical_facilities = "Medical care",
  acct_medical_research = "Other", acct_it_systems = "IT", acct_ehrm = "IT",
  acct_construction_major = "Construction", acct_construction_minor = "Construction",
  acct_grants_state_ext_care = "Construction", acct_goe_vba = "Other", acct_general_admin = "Other",
  acct_nca = "Other", acct_oig = "Other")
GROUPS <- c("Medical care", "IT", "Construction", "Other")

acct_gaps_all <- gaps_all |>
  filter(series_id %in% names(accts)) |>
  mutate(account = unname(accts[series_id]),
         group   = factor(unname(grp_of[series_id]), levels = GROUPS))

FTYPE <- c("Discretionary" = "tot_discretionary_derived", "Mandatory" = "tot_mandatory", "Total VA" = "tot_va")
admin_of <- function(fy) case_when(fy <= 2009 ~ "Bush", fy <= 2017 ~ "Obama", fy <= 2021 ~ "Trump I",
                                   fy <= 2025 ~ "Biden", TRUE ~ "Trump II")

# ---------------------------------------------------------------- look
pal <- c(blue = "#0A3161", purple = "#B31942", sky = "#6C9BD2", yellow = "#D4A62A",
         orange = "#6E7B3E", pink = "#B31942", mint = "#A9B3C1", grey = "#B8C0CC")
grp_cols <- c("Medical care" = pal[["blue"]], IT = pal[["pink"]], Construction = pal[["orange"]], Other = pal[["grey"]])
ink <- "#13233F"; muted <- "#5A6578"
theme_va <- function() {
  theme_minimal(base_size = 8.5) +
    theme(text = element_text(colour = ink),
          axis.text = element_text(size = 8.5, colour = muted),
          axis.title = element_text(size = 8.5, colour = muted),
          legend.text = element_text(size = 8.5), legend.title = element_blank(),
          legend.position = "top", legend.justification = "left",
          strip.text = element_text(size = 8.5, face = "bold", colour = ink),
          panel.grid.minor = element_blank(),
          plot.margin = margin(8, 14, 8, 8))
}
leg_in <- function(x, y, key = 0.72, just = c(x, y)) {
  th <- theme(legend.direction = "vertical", legend.justification = just,
              legend.key.size = unit(key, "lines"),
              legend.background = element_rect(fill = alpha("white", 0.88), colour = NA),
              legend.margin = margin(3, 6, 3, 6))
  if (utils::packageVersion("ggplot2") >= "3.5.0") th + theme(legend.position = "inside", legend.position.inside = c(x, y))
  else th + theme(legend.position = c(x, y))
}
pct  <- function(x, d = 1) paste0(formatC(100 * x, format = "f", digits = d), "%")
spct <- function(x, d = 1) paste0(ifelse(x > 0, "+", ""), formatC(100 * x, format = "f", digits = d), "%")
mn   <- function(x) paste0("$", formatC(x, format = "f", digits = 0, big.mark = ","), "M")

# ---------------------------------------------------------------- UI
plot_card <- function(plot_id, text_id, height = "360px") {
  card(full_screen = TRUE, card_header(textOutput(paste0(plot_id, "_ttl"), inline = TRUE)),
       plotOutput(plot_id, height = height),
       card_footer(uiOutput(text_id), div(class = "src", "Source: U.S. Department of Veterans Affairs, Congressional Budget Submissions (Vols. I–V), FY2008–FY2027 editions; compiled by the authors. Nominal budget authority.")))
}

ui <- page_sidebar(
  fillable = FALSE,
  theme = bs_theme(version = 5, primary = pal[["blue"]], base_font = font_google("Source Sans 3", local = FALSE), heading_font = font_google("Oswald", local = FALSE), fg = ink, bg = "#ffffff"),
  sidebar = sidebar(
    width = 290,
    sliderInput("years", "Fiscal years", min = FY_MIN, max = FY_MAX, value = c(FY_MIN, FY_MAX), step = 1, sep = ""),
    conditionalPanel("input.tab == 'Request vs. enacted' || input.tab == 'Gap by year'",
      radioButtons("ftype", "Funding type", choices = names(FTYPE), selected = "Discretionary")),
    conditionalPanel("input.tab != 'Request vs. enacted' && input.tab != 'Gap by year'",
      checkboxGroupInput("groups", "Account groups", choices = GROUPS, selected = GROUPS)),
    conditionalPanel("input.tab == 'By account'",
      radioButtons("measure", "Compare accounts by",
                   choices = c("Median absolute gap" = "median_abs", "Mean signed gap" = "mean_signed",
                               "Share of years changed (>1%)" = "changed"),
                   selected = "median_abs")),
    helpText("Gap = (enacted − requested) ÷ requested. Request = the edition for that fiscal year; enacted = the latest edition.")
  ),
  tags$head(tags$style(HTML("
    .bslib-value-box { min-height: 0 !important; }
    .bslib-value-box .card-body { padding: .3rem .4rem !important; }
    .bslib-value-box .value-box-area { padding: .35rem .8rem !important; gap: 0 !important; }
    .bslib-value-box .value-box-title { font-size: .85rem !important; margin-bottom: .1rem !important; }
    .bslib-value-box .value-box-value { font-size: 1.55rem !important; line-height: 1.15 !important; margin-bottom: .1rem !important; }
    .bslib-sidebar-layout > .sidebar { font-size: .9rem; }
    .bslib-sidebar-layout > .sidebar .control-label, .bslib-sidebar-layout > .sidebar .form-label { font-size: .9rem; }
    .vb-row { margin-bottom: 1.4rem !important; }
    .vb-row + * { margin-top: 0 !important; }
    .bslib-value-box { border: 0 !important; border-top: 4px solid #B31942 !important; border-radius: 6px !important; }
    .bslib-value-box .value-box-title { font-family: Oswald, sans-serif; text-transform: uppercase; letter-spacing: .06em; }
    .bslib-value-box .value-box-title::before { content: '\\2605  '; color: #B31942; }
    .bslib-value-box .value-box-value { font-family: Oswald, sans-serif; font-weight: 600 !important; letter-spacing: .02em; }
    .card-header { font-family: Oswald, sans-serif; letter-spacing: .02em; font-weight: 500; font-size: 1.05rem; color: #0A1F44; border-bottom: 2px solid #B31942; }
    .card-footer .src { font-size: .75rem; color: #5A6578; margin-top: .35rem; border-top: 1px solid #E3E7EC; padding-top: .3rem; }
    .nav-underline .nav-link, .nav-tabs .nav-link { font-family: Oswald, sans-serif; text-transform: uppercase; letter-spacing: .05em; }
    .nav-underline .nav-link.active { color: #B31942 !important; border-bottom-color: #B31942 !important; }
    .bslib-value-box p { font-size: .8rem !important; margin: 0 !important; opacity: .9; }
  "))),
  layout_columns(
    fill = FALSE, class = "vb-row",
    value_box(title = "Largest gap in the window", value = textOutput("vb_max"), showcase = NULL,
              theme = value_box_theme(bg = "#0A1F44", fg = "white"), p(textOutput("vb_max_note"))),
    value_box(title = "Median gap, selected accounts", value = textOutput("vb_med"),
              theme = value_box_theme(bg = "#0A1F44", fg = "white"), p(textOutput("vb_med_note"))),
    value_box(title = "Most revised account", value = textOutput("vb_top"),
              theme = value_box_theme(bg = "#0A1F44", fg = "white"), p(textOutput("vb_top_note")))
  ),
  navset_card_underline(
    id = "tab",
    nav_panel("Request vs. enacted", plot_card("p_dumbbell", "t_dumbbell", "600px")),
    nav_panel("Gap by year",         plot_card("p_diverging", "t_diverging")),
    nav_panel("By account",          plot_card("p_accounts", "t_accounts")),
    nav_panel("Account × year",      plot_card("p_heatmap", "t_heatmap", "440px")),
    nav_panel("How often & which way", plot_card("p_bubbles", "t_bubbles", "440px")),
    nav_panel("All account-years",   plot_card("p_curve", "t_curve"))
  )
)

# ---------------------------------------------------------------- server
server <- function(input, output, session) {

  yr  <- reactive(input$years)
  tot <- reactive({
    gaps_all |> filter(series_id == FTYPE[[input$ftype]], between(fiscal_year, yr()[1], yr()[2]))
  })
  ag <- reactive({
    validate(need(length(input$groups) > 0, "Select at least one account group."))
    acct_gaps_all |> filter(group %in% input$groups, between(fiscal_year, yr()[1], yr()[2]))
  })
  acct_sum <- reactive({
    ag() |>
      group_by(account, group) |>
      summarise(years = n(), median_abs = median(abs(gap_pct_of_request)),
                mean_signed = mean(gap_pct_of_request), changed = mean(abs(gap_pct_of_request) > 0.01),
                med_signed = median(gap_pct_of_request), size = mean(value_latest) / 1000, .groups = "drop")
  })


  # ---- message titles (update with the filters)
  output$p_dumbbell_ttl <- renderText({
    d <- tot(); k <- sum(abs(d$gap_pct_of_request) <= 0.025)
    paste0(input$ftype, " funding: Congress enacted within ±2.5% of the request in ", k, " of ", nrow(d), " years")
  })
  output$p_diverging_ttl <- renderText({
    d <- tot(); up <- sum(d$gap_pct_of_request > 0.0005); dn <- sum(d$gap_pct_of_request < -0.0005)
    paste0("Congress gave more than requested in ", up, " years and less in ", dn,
           " (average gap ", spct(mean(d$gap_pct_of_request)), ")")
  })
  output$p_accounts_ttl <- renderText({
    a <- acct_sum(); a$val <- a[[input$measure]]
    hi <- a$account[which.max(a$val)]; lo <- a$account[which.min(a$val)]
    switch(input$measure,
      median_abs  = paste0(hi, " departs most from the request; ", lo, " the least"),
      mean_signed = paste0(hi, " gets the most extra money on average; ", lo, " is cut the most"),
      changed     = paste0(hi, " is changed most often; ", lo, " the least"))
  })
  output$p_heatmap_ttl <- renderText({
    g <- ag() |> group_by(group) |> summarise(big = sum(abs(gap_pct_of_request) > 0.10), .groups = "drop") |> arrange(desc(big))
    if (sum(g$big) == 0) "No account-year departs from the request by more than 10%" else
      paste0(g$group[1], " accounts hold ", g$big[1], " of the ", sum(g$big), " account-years that miss the request by more than 10%")
  })
  output$p_bubbles_ttl <- renderText({
    b <- acct_sum(); rare <- sum(b$changed < 0.5); cut <- sum(b$changed >= 0.5 & b$med_signed < -0.005)
    paste0(rare, " of ", nrow(b), " accounts are rarely changed; ", cut, " are often changed and usually cut")
  })
  output$p_curve_ttl <- renderText({
    q <- quantile(abs(ag()$gap_pct_of_request), c(.5, .9))
    paste0("Half of all account-years miss the request by less than ", pct(q[1]), "; the top 10% miss by more than ", pct(q[2], 0))
  })

  # ---- value boxes
  output$vb_max <- renderText({ d <- tot(); i <- which.max(abs(d$gap_pct_of_request)); spct(d$gap_pct_of_request[i]) })
  output$vb_max_note <- renderText({ d <- tot(); i <- which.max(abs(d$gap_pct_of_request))
    paste0(input$ftype, ", FY", d$fiscal_year[i]) })
  output$vb_med <- renderText(pct(median(abs(ag()$gap_pct_of_request))))
  output$vb_med_note <- renderText(paste0(nrow(ag()), " account-years, FY", yr()[1], "–FY", yr()[2]))
  output$vb_top <- renderText({ a <- acct_sum() |> slice_max(median_abs, n = 1, with_ties = FALSE); a$account })
  output$vb_top_note <- renderText({ a <- acct_sum() |> slice_max(median_abs, n = 1, with_ties = FALSE)
    paste0("median gap ", pct(a$median_abs)) })

  # ---- dumbbell
  output$p_dumbbell <- renderPlot({
    d <- tot() |>
      transmute(fiscal_year, admin = factor(admin_of(fiscal_year), levels = c("Bush", "Obama", "Trump I", "Biden", "Trump II")),
                Requested = value_request / 1000, Enacted = value_latest / 1000,
                change = round(Enacted - Requested, 1) + 0,
                fy = factor(fiscal_year, levels = rev(sort(unique(fiscal_year)))))
    lo <- floor(min(d$Requested, d$Enacted) / 10) * 10; hi <- ceiling(max(d$Requested, d$Enacted) / 10) * 10
    chg <- hi + (hi - lo) * 0.16
    ggplot(d, aes(y = fy)) +
      geom_segment(aes(x = lo, xend = hi, yend = fy), colour = "#EEF0F3", linewidth = 5, lineend = "round") +
      geom_segment(aes(x = Requested, xend = Enacted, yend = fy), colour = "#7D8796", linewidth = 0.8) +
      geom_point(aes(x = Requested), colour = pal[["yellow"]], size = 4.6) +
      geom_point(aes(x = Enacted), colour = pal[["blue"]], size = 4.6) +
      geom_text(aes(x = chg, label = sprintf("%+.1f", change)), hjust = 1, size = 3, colour = ink) +
      geom_text(data = d |> filter(fiscal_year == min(fiscal_year)), aes(x = chg, label = "Change ($B)"),
                hjust = 1, vjust = -1.4, size = 3, fontface = "bold", colour = ink) +
      facet_grid(admin ~ ., scales = "free_y", space = "free_y", switch = "y") +
      scale_x_continuous(position = "top", limits = c(lo, chg), breaks = pretty(c(lo, hi), 4)[pretty(c(lo, hi), 4) <= hi],
                         labels = label_dollar(suffix = "B"), expand = c(0, 0)) +
      coord_cartesian(clip = "off") +
      labs(x = "Budget authority ($ billions)", y = "Fiscal year", subtitle = "Gold = requested · navy = enacted") +
      theme_va() +
      theme(panel.grid.major.y = element_blank(),
            panel.grid.major.x = element_line(colour = "#D5DAE1", linetype = "dashed", linewidth = 0.4),
            strip.placement = "outside",
            strip.text.y.left = element_text(angle = 0, hjust = 0, vjust = 1, face = "plain", colour = muted),
            plot.subtitle = element_text(colour = muted, size = 8.5, margin = margin(b = 18)))
  }, res = 96)
  output$t_dumbbell <- renderUI({
    d <- tot(); big <- d |> filter(abs(gap_pct_of_request) > 0.025)
    p(HTML(paste0("For <b>", tolower(input$ftype), "</b> funding in FY", yr()[1], "–FY", yr()[2],
      ", the enacted total stayed within ±2.5% of the request in <b>", sum(abs(d$gap_pct_of_request) <= 0.025),
      " of ", nrow(d), "</b> years.",
      if (nrow(big)) paste0(" Larger gaps: ", paste0("FY", big$fiscal_year, " (", spct(big$gap_pct_of_request), ")", collapse = ", "), ".") else "",
      if (input$ftype != "Discretionary") " Mandatory gaps reflect re-estimates of benefit costs, not congressional cuts." else "")))
  })

  # ---- gap by year
  output$p_diverging <- renderPlot({
    d <- tot() |> mutate(dir = if_else(gap_pct_of_request >= 0, "Enacted above request", "Enacted below request"))
    ggplot(d, aes(fiscal_year, gap_pct_of_request, fill = dir)) +
      geom_hline(yintercept = 0, colour = "#9AA5B4") +
      geom_col(width = 0.72) +
      scale_fill_manual(values = c("Enacted above request" = pal[["blue"]], "Enacted below request" = pal[["pink"]])) +
      scale_y_continuous(labels = label_percent(accuracy = 1), expand = expansion(mult = c(0.05, 0.05))) +
      scale_x_continuous(breaks = pretty_breaks(6)) +
      labs(x = "Fiscal year", y = "Gap (% of request)") + theme_va() +
      leg_in(0.995, 1.05 / 1.10, just = c(1, 1)) + theme(legend.margin = margin(0, 4, 3, 6))
  }, res = 96)
  output$t_diverging <- renderUI({
    d <- tot()
    p(HTML(paste0("Average gap ", spct(mean(d$gap_pct_of_request)), " · enacted above the request in <b>",
      sum(d$gap_pct_of_request > 0.0005), "</b> years, below in <b>", sum(d$gap_pct_of_request < -0.0005), "</b>.",
      " Largest: FY", d$fiscal_year[which.max(abs(d$gap_pct_of_request))], " (",
      spct(d$gap_pct_of_request[which.max(abs(d$gap_pct_of_request))]), ").")))
  })

  # ---- by account
  m_lab <- c(median_abs = "Median absolute gap (% of request)", mean_signed = "Mean signed gap (% of request)", changed = "Years changed by more than 1% (% of years)")
  output$p_accounts <- renderPlot({
    a <- acct_sum(); a$val <- a[[input$measure]]
    ggplot(a, aes(val, reorder(account, val), fill = group)) +
      geom_col(width = 0.7) +
      geom_text(aes(label = if (input$measure == "mean_signed") spct(val) else pct(val),
                    hjust = ifelse(val >= 0, -0.12, 1.12)), size = 3, colour = ink) +
      scale_fill_manual(values = grp_cols) +
      scale_x_continuous(labels = label_percent(accuracy = 1), expand = expansion(mult = c(0.12, 0.18))) +
      labs(x = m_lab[[input$measure]], y = "Account") + theme_va() +
      theme(panel.grid.major.y = element_blank()) + leg_in(0.99, 0.02)
  }, res = 96)
  output$t_accounts <- renderUI({
    g <- ag() |> group_by(group) |> summarise(m = median(abs(gap_pct_of_request)), .groups = "drop") |> arrange(m)
    p(HTML(paste0("Median absolute gap by group: ",
      paste0("<b>", g$group, "</b> ", pct(g$m), collapse = " · "),
      ". The two branches agree most on the accounts at the bottom of the chart (small gaps) and disagree most on those at the top.")))
  })

  # ---- heatmap
  output$p_heatmap <- renderPlot({
    a <- ag(); ord <- acct_sum() |> arrange(median_abs) |> pull(account); lim <- 0.25
    ggplot(a, aes(fiscal_year, factor(account, levels = ord), fill = pmax(pmin(gap_pct_of_request, lim), -lim))) +
      geom_tile(colour = "white", linewidth = 0.7) +
      scale_fill_gradient2(low = pal[["pink"]], mid = "#F7F7F5", high = pal[["blue"]], midpoint = 0,
                           limits = c(-lim, lim), labels = label_percent(accuracy = 1)) +
      scale_x_continuous(breaks = pretty_breaks(6), expand = c(0, 0)) +
      labs(x = "Fiscal year", y = "Account", fill = "Gap (% of request)") + theme_va() +
      theme(panel.grid = element_blank(), legend.position = "bottom", legend.justification = "center",
            legend.key.width = unit(2, "cm"), legend.title = element_text(size = 8.5, colour = muted, vjust = 0.8))
  }, res = 96)
  output$t_heatmap <- renderUI({
    a <- ag(); top <- a |> slice_max(abs(gap_pct_of_request), n = 3, with_ties = FALSE)
    p(HTML(paste0("Navy = Congress enacted more than requested, red = less (capped at ±25%). Biggest departures in the selection: ",
      paste0("<b>", top$account, "</b> FY", top$fiscal_year, " (", spct(top$gap_pct_of_request, 0), ")", collapse = "; "), ".")))
  })

  # ---- bubbles
  output$p_bubbles <- renderPlot({
    b <- acct_sum() |> mutate(y = pmax(pmin(med_signed, 0.15), -0.15))
    p <- ggplot(b, aes(changed, y)) +
      geom_hline(yintercept = 0, linetype = "dashed", colour = "#9AA5B4") +
      geom_vline(xintercept = 0.5, linetype = "dashed", colour = "#9AA5B4") +
      annotate("text", x = 0.99, y = 0.15, label = "Often changed,\nusually raised", hjust = 1, vjust = 1, fontface = "italic", size = 2.8, colour = muted) +
      annotate("text", x = 0.99, y = -0.15, label = "Often changed,\nusually cut", hjust = 1, vjust = 0, fontface = "italic", size = 2.8, colour = muted) +
      annotate("text", x = 0.01, y = 0.15, label = "Rarely changed", hjust = 0, vjust = 1, fontface = "italic", size = 2.8, colour = muted) +
      geom_point(aes(size = size, colour = group, alpha = group == "Medical care")) +
      scale_alpha_manual(values = c(`TRUE` = 0.45, `FALSE` = 0.85), guide = "none") +
      scale_colour_manual(values = grp_cols) +
      scale_size_area(max_size = 24, guide = "none") +
      scale_x_continuous(labels = label_percent(accuracy = 1), limits = c(0, 1)) +
      scale_y_continuous(labels = label_percent(accuracy = 1), limits = c(-0.155, 0.155)) +
      guides(colour = guide_legend(override.aes = list(size = 6))) +
      labs(x = "Years changed by more than 1% (% of years)", y = "Median gap (% of request)") + theme_va()
    if (requireNamespace("ggrepel", quietly = TRUE)) {
      p + ggrepel::geom_text_repel(aes(label = account), size = 2.3, colour = ink, box.padding = 0.35, point.size = NA,
                                   segment.colour = muted, segment.size = 0.3,
                                   min.segment.length = 0.3, seed = 7, max.overlaps = Inf)
    } else p + geom_text(aes(label = account), size = 2.3, colour = ink, vjust = -1.2)
  }, res = 96)
  output$t_bubbles <- renderUI({
    b <- acct_sum()
    rare <- b |> filter(changed < 0.5) |> pull(account); cut <- b |> filter(changed >= 0.5, med_signed < -0.005) |> pull(account)
    p(HTML(paste0("Bubble size = average enacted funding. <b>Rarely changed:</b> ", if (length(rare)) paste(rare, collapse = ", ") else "none",
      ". <b>Often changed and usually cut:</b> ", if (length(cut)) paste(cut, collapse = ", ") else "none", ".")))
  })

  # ---- ranked curve
  output$p_curve <- renderPlot({
    cap <- 0.6
    cd <- ag() |> mutate(abs_gap = abs(gap_pct_of_request)) |> arrange(abs_gap) |>
      mutate(pctile = (row_number() - 0.5) / n(), y = pmin(abs_gap, cap))
    qs <- quantile(cd$abs_gap, c(.25, .5, .75))
    ggplot(cd, aes(pctile, y)) +
      geom_vline(xintercept = c(.25, .5, .75), linetype = "dotted", colour = "#9AA5B4") +
      annotate("text", x = c(.25, .5, .75), y = cap * 1.08, label = pct(qs), fontface = "italic", size = 3, colour = ink) +
      geom_line(colour = ink, linewidth = 0.8) +
      geom_segment(aes(x = pctile, xend = pctile, y = -0.05, yend = -0.015, colour = group), linewidth = 1) +
      scale_colour_manual(values = grp_cols) +
      guides(colour = guide_legend(override.aes = list(linewidth = 2.4))) +
      scale_x_continuous(breaks = c(.25, .5, .75), labels = c("25th", "50th", "75th"), limits = c(0, 1)) +
      scale_y_continuous(labels = label_percent(accuracy = 1), limits = c(-0.055, cap * 1.12), breaks = seq(0, cap, 0.2)) +
      coord_cartesian(clip = "off") +
      labs(x = "Account-years ranked by gap (percentile)", y = "Absolute gap (% of request, capped at 60%)") + theme_va() + leg_in(0.01, 0.63, just = c(0, 0.5))
  }, res = 96)
  output$t_curve <- renderUI({
    cd <- ag(); qs <- quantile(abs(cd$gap_pct_of_request), c(.25, .5, .75))
    top <- cd |> filter(abs(gap_pct_of_request) >= qs[3]) |> count(group, sort = TRUE)
    p(HTML(paste0("Quartiles of the gap: <b>", pct(qs[1]), "</b>, <b>", pct(qs[2]), "</b> and <b>", pct(qs[3]),
      "</b>. In the top quarter: ", paste0(top$group, " (", top$n, ")", collapse = ", "),
      ". Ticks on the baseline show where each group falls.")))
  })
}

shinyApp(ui, server)

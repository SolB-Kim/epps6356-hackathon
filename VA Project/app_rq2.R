library(shiny)
library(bslib)
library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)

# ---------------------------------------------------------------- data
va <- read.csv("va_data.csv")
FY_MIN <- 2008; FY_MAX <- 2026

latest <- va |>
  filter(is_latest == 1) |>
  select(series_id, fiscal_year, value) |>
  pivot_wider(names_from = series_id, values_from = value) |>
  arrange(fiscal_year)

r2_all <- latest |>
  transmute(fiscal_year,
            total = tot_va, mandatory = tot_mandatory, discretionary = tot_va - tot_mandatory,
            cp = mand_comp_pension, readj = mand_readjustment, tef = coalesce(tef_total, 0),
            other = mandatory - cp - readj - tef)

short <- c("Compensation & Pensions" = "C&P", "Toxic Exposures Fund" = "TEF",
           "Readjustment benefits" = "Readjustment", "Other mandatory" = "Other")
PROGS <- c("Compensation & Pensions" = "cp", "Toxic Exposures Fund" = "tef",
           "Readjustment benefits" = "readj", "Other mandatory" = "other")

# ---------------------------------------------------------------- look
pal <- c(blue = "#0A3161", purple = "#B31942", sky = "#6C9BD2", yellow = "#D4A62A",
         orange = "#6E7B3E", pink = "#B31942", mint = "#A9B3C1", grey = "#B8C0CC")
prog_cols <- c("Compensation & Pensions" = pal[["purple"]], "Toxic Exposures Fund" = pal[["sky"]],
               "Readjustment benefits" = pal[["yellow"]], "Other mandatory" = pal[["grey"]])
ink <- "#13233F"; muted <- "#5A6578"
theme_va <- function() {
  theme_minimal(base_size = 8.5) +
    theme(text = element_text(colour = ink),
          axis.text = element_text(size = 8.5, colour = muted),
          axis.title = element_text(size = 8.5, colour = muted),
          legend.text = element_text(size = 8.5), legend.title = element_blank(),
          legend.position = "top", legend.justification = "left",
          panel.grid.minor = element_blank(),
          plot.margin = margin(8, 14, 8, 8))
}
bn  <- function(x, d = 1) paste0("$", formatC(x / 1000, format = "f", digits = d, big.mark = ","), "B")
pct <- function(x, d = 0) paste0(formatC(100 * x, format = "f", digits = d), "%")

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
    conditionalPanel("input.tab == 'Mandatory vs. discretionary' || input.tab == 'Mandatory programs'",
      radioButtons("units", "Show funding as", choices = c("$ billions", "% of total VA funding"), selected = "$ billions")),
    conditionalPanel("input.tab == 'Mandatory programs'",
      checkboxGroupInput("progs", "Mandatory programs", choices = names(PROGS), selected = names(PROGS))),
    helpText("Final (enacted) budget authority, nominal dollars. Discretionary = total VA − mandatory.")
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
    value_box(title = "Mandatory passed discretionary", value = textOutput("vb_cross"),
              theme = value_box_theme(bg = "#0A1F44", fg = "white"), p(textOutput("vb_cross_note"))),
    value_box(title = "Mandatory growth in the window", value = textOutput("vb_growth"),
              theme = value_box_theme(bg = "#0A1F44", fg = "white"), p(textOutput("vb_growth_note"))),
    value_box(title = "Discretionary share of VA funding", value = textOutput("vb_share"),
              theme = value_box_theme(bg = "#0A1F44", fg = "white"), p(textOutput("vb_share_note")))
  ),
  navset_card_underline(
    id = "tab",
    nav_panel("Mandatory vs. discretionary", plot_card("p_lines", "t_lines")),
    nav_panel("Mandatory programs",          plot_card("p_area", "t_area")),
    nav_panel("What drove the growth",
      card(full_screen = TRUE, card_header(textOutput("p_contrib_ttl", inline = TRUE)),
           plotOutput("p_contrib", height = "230px"),
           plotOutput("p_waffle", height = "230px"),
           card_footer(uiOutput("t_contrib"), div(class = "src", "Source: U.S. Department of Veterans Affairs, Congressional Budget Submissions (Vols. I–V), FY2008–FY2027 editions; compiled by the authors. Nominal budget authority.")))),
    nav_panel("Shrinking share?",            plot_card("p_share", "t_share"))
  )
)

# ---------------------------------------------------------------- server
server <- function(input, output, session) {
  r2 <- reactive({
    validate(need(input$years[2] > input$years[1], "Choose a window of at least two years."))
    r2_all |> filter(between(fiscal_year, input$years[1], input$years[2]))
  })
  first <- reactive(r2() |> slice(1)); last <- reactive(r2() |> slice(n()))
  growth <- reactive({
    tibble(program = names(PROGS),
           change = vapply(PROGS, function(v) last()[[v]] - first()[[v]], numeric(1))) |>
      mutate(share = change / sum(change))
  })

  # ---- value boxes
  cross <- reactive({ x <- r2() |> filter(mandatory > discretionary); if (nrow(x)) x$fiscal_year[1] else NA })
  output$vb_cross <- renderText(if (is.na(cross())) "Not in window" else paste0("FY", cross()))
  output$vb_cross_note <- renderText({
    if (is.na(cross())) "mandatory stays below discretionary"
    else if (cross() == input$years[1]) "already ahead at the start of the window"
    else "first year mandatory > discretionary" })
  output$vb_growth <- renderText(paste0("+", bn(last()$mandatory - first()$mandatory)))
  output$vb_growth_note <- renderText(paste0(formatC(last()$mandatory / first()$mandatory, format = "f", digits = 1),
                                             "× from FY", input$years[1], " to FY", input$years[2]))
  output$vb_share <- renderText(paste0(pct(first()$discretionary / first()$total), " → ", pct(last()$discretionary / last()$total)))
  output$vb_share_note <- renderText(paste0("FY", input$years[1], " to FY", input$years[2]))


  # ---- message titles (update with the filters)
  output$p_lines_ttl <- renderText({
    c10 <- cross()
    if (is.na(c10)) "Mandatory funding stays below discretionary funding in this window"
    else if (c10 == input$years[1]) paste0("Mandatory funding is already larger than discretionary in FY", c10)
    else paste0("Mandatory funding overtook discretionary funding in FY", c10)
  })
  output$p_area_ttl <- renderText({
    req(length(input$progs) > 0)
    l <- last(); tot <- l$cp + l$tef + l$readj + l$other
    v <- vapply(PROGS[input$progs], function(k) l[[k]], numeric(1)); top <- names(v)[which.max(v)]
    paste0(top, " makes up ", pct(max(v) / tot), " of mandatory funding in FY", input$years[2])
  })
  output$p_contrib_ttl <- renderText({
    g <- growth() |> arrange(desc(change))
    paste0(g$program[1], " accounts for $", round(100 * g$share[1]), " of every $100 added to mandatory funding")
  })
  output$p_share_ttl <- renderText({
    f <- first(); l <- last(); gm <- l$mandatory / f$mandatory; gd <- l$discretionary / f$discretionary
    s0 <- pct(f$discretionary / f$total); s1 <- pct(l$discretionary / l$total)
    if (gm > gd) paste0("Discretionary share fell from ", s0, " to ", s1, " because mandatory grew faster (",
                        formatC(gm, format = "f", digits = 1), "× vs. ", formatC(gd, format = "f", digits = 1), "×)")
    else paste0("Discretionary share moved from ", s0, " to ", s1, "; mandatory did not outgrow discretionary")
  })

  # ---- lines
  output$p_lines <- renderPlot({
    share <- input$units != "$ billions"
    d <- r2() |> select(fiscal_year, Mandatory = mandatory, Discretionary = discretionary, total) |>
      pivot_longer(c(Mandatory, Discretionary)) |>
      mutate(y = if (share) value / total else value / 1000)
    ggplot(d, aes(fiscal_year, y, colour = name)) +
      geom_line(linewidth = 1.4) + geom_point(size = 2.6) +
      geom_text(data = d |> filter(fiscal_year == max(fiscal_year)), aes(label = name),
                hjust = 0, nudge_x = 0.3, size = 3, fontface = "bold") +
      scale_colour_manual(values = c(Mandatory = pal[["purple"]], Discretionary = pal[["blue"]]), guide = "none") +
      scale_y_continuous(labels = if (share) label_percent(accuracy = 1) else label_dollar(suffix = "B"), limits = c(0, NA)) +
      scale_x_continuous(breaks = pretty_breaks(6), expand = expansion(mult = c(0.02, 0.2))) +
      coord_cartesian(clip = "off") +
      labs(x = "Fiscal year", y = if (share) "Share of total VA funding (%)" else "Budget authority ($ billions)") + theme_va()
  }, res = 96)
  output$t_lines <- renderUI({
    d <- r2(); c10 <- cross()
    txt <- if (is.na(c10)) "In this window, mandatory funding never exceeds discretionary." else
      if (c10 == input$years[1]) paste0("Mandatory funding is already larger than discretionary in FY", c10, ".") else {
        a <- d |> filter(fiscal_year %in% c(c10 - 1, c10))
        paste0("Mandatory funding overtakes discretionary in <b>FY", c10, "</b>, rising from ", bn(a$mandatory[1]), " to ",
               bn(a$mandatory[2]), "; ", bn(a$cp[2] - a$cp[1]), " of that jump is Compensation & Pensions.") }
    p(HTML(paste0(txt, " By FY", input$years[2], " mandatory is ", bn(last()$mandatory), " and discretionary ",
                  bn(last()$discretionary), ".")))
  })

  # ---- stacked area + end-year bar
  output$p_area <- renderPlot({
    validate(need(length(input$progs) > 0, "Select at least one program."))
    share <- input$units != "$ billions"
    sel <- names(PROGS)[names(PROGS) %in% input$progs]
    d <- r2() |> select(fiscal_year, total, all_of(unname(PROGS[sel]))) |>
      pivot_longer(-c(fiscal_year, total), names_to = "v") |>
      mutate(program = factor(names(PROGS)[match(v, PROGS)], levels = rev(names(PROGS))),
             y = if (share) value / total else value / 1000)
    fy_end <- max(d$fiscal_year); span <- max(diff(range(d$fiscal_year)), 1)
    lab <- d |> filter(fiscal_year == fy_end) |> arrange(desc(program)) |>
      mutate(top = cumsum(y), mid = top - y / 2, tot = sum(y), inside = y >= 0.3 * tot)
    lx <- fy_end - span * 0.17
    out <- lab |> filter(!inside) |> arrange(desc(mid)) |>
      mutate(ly = tot * (1.12 - 0.11 * (row_number() - 1)))
    ins <- lab |> filter(inside)
    ggplot(d, aes(fiscal_year, y, fill = program)) +
      geom_area(colour = "white", linewidth = 0.3) +
      geom_segment(data = out, aes(x = lx + span * 0.01, xend = fy_end - span * 0.005, y = ly, yend = mid),
                   inherit.aes = FALSE, colour = muted, linewidth = 0.35) +
      geom_point(data = out, aes(x = fy_end - span * 0.005, y = mid), inherit.aes = FALSE, colour = muted, size = 0.9) +
      geom_text(data = out, aes(x = lx, y = ly, label = program, colour = program), inherit.aes = FALSE,
                hjust = 1, size = 3, fontface = "bold") +
      geom_text(data = ins, aes(x = fy_end - span * 0.04, y = mid, label = program), inherit.aes = FALSE,
                hjust = 1, size = 3, fontface = "bold", colour = "white") +
      scale_fill_manual(values = prog_cols, breaks = names(PROGS), guide = "none") +
      scale_colour_manual(values = prog_cols, guide = "none") +
      scale_y_continuous(labels = if (share) label_percent(accuracy = 1) else label_dollar(suffix = "B"),
                         expand = expansion(mult = c(0.02, 0.06))) +
      scale_x_continuous(breaks = pretty_breaks(6), expand = expansion(mult = c(0.02, 0.01))) +
      labs(x = "Fiscal year", y = if (share) "Share of total VA funding (%)" else "Budget authority ($ billions)") + theme_va()
  }, res = 96)
  output$t_area <- renderUI({
    l <- last(); tot <- l$cp + l$tef + l$readj + l$other
    p(HTML(paste0("In FY", input$years[2], ", mandatory funding of ", bn(l$mandatory), " splits into ",
      "<b>Compensation & Pensions</b> ", bn(l$cp), " (", pct(l$cp / tot), "), ",
      "<b>Toxic Exposures Fund</b> ", bn(l$tef), " (", pct(l$tef / tot), "), ",
      "<b>Readjustment</b> ", bn(l$readj), " (", pct(l$readj / tot), ") and other programs ", bn(l$other), ".")))
  })

  # ---- contribution: columns + waffle
  output$p_contrib <- renderPlot({
    g <- growth() |> arrange(desc(change)) |> mutate(program = factor(program, levels = program), rank = row_number())
    p1 <- ggplot(g, aes(rank, change / 1000, fill = program)) +
      geom_col(width = 0.7) +
      geom_hline(yintercept = 0, colour = "#9AA5B4") +
      geom_text(aes(label = formatC(change / 1000, format = "f", digits = 1),
                    vjust = ifelse(change >= 0, -0.4, 1.3)), size = 3, colour = ink, fontface = "bold") +
      scale_fill_manual(values = prog_cols, guide = "none") +
      scale_x_continuous(breaks = g$rank, labels = short[as.character(g$program)]) +
      scale_y_continuous(labels = label_dollar(suffix = "B"), expand = expansion(mult = c(0.08, 0.15))) +
      labs(x = "Mandatory program", y = "Change ($ billions)", subtitle = paste0("Change in budget authority, FY", input$years[1], " → FY", input$years[2])) +
      theme_va() + theme(panel.grid.major.x = element_blank(), plot.subtitle = element_text(colour = muted, size = 8.5))
    p1
  }, res = 96)
  output$p_waffle <- renderPlot({
    g <- growth() |> arrange(desc(change)) |> mutate(program = factor(program, levels = program))
    raw <- 100 * pmax(g$share, 0); cents <- floor(raw); left <- 100 - sum(cents)
    if (left > 0) { o <- order(raw - floor(raw), decreasing = TRUE)[seq_len(left)]; cents[o] <- cents[o] + 1 }
    w <- tibble(program = g$program, dollars = cents) |> tidyr::crossing(cell = 1:100) |>
      mutate(col = (cell - 1) %% 10, row = (cell - 1) %/% 10, fill = ifelse(cell <= dollars, as.character(program), "empty"))
    p2 <- ggplot(w, aes(col, row, colour = fill)) +
      geom_point(size = 2.25) +
      geom_text(data = distinct(w, program, dollars), aes(x = 4.5, y = 11.8, label = paste0("$", dollars)),
                inherit.aes = FALSE, size = 3, fontface = "bold", colour = ink) +
      facet_wrap(~program, nrow = 1, labeller = label_wrap_gen(14), strip.position = "bottom") +
      scale_colour_manual(values = c(prog_cols, empty = "#E3E7EC"), guide = "none") +
      coord_equal(clip = "off") +
      labs(subtitle = "Of every $100 added", x = NULL, y = NULL) +
      theme_void(base_size = 8.5) + theme(strip.text = element_text(colour = ink, size = 8.5, margin = margin(t = 4)),
                                          panel.spacing.x = unit(4, "lines"), plot.margin = margin(0, 10, 4, 10),
                                          plot.subtitle = element_text(colour = muted, size = 8.5, margin = margin(b = 4)))
    p2
  }, res = 96)
  output$t_contrib <- renderUI({
    g <- growth() |> arrange(desc(change))
    p(HTML(paste0("From FY", input$years[1], " to FY", input$years[2], ", mandatory funding changed by <b>",
      bn(sum(g$change)), "</b>: ",
      paste0("<b>", g$program, "</b> ", ifelse(g$change >= 0, "+", "−"), bn(abs(g$change)), " (", pct(g$share), ")", collapse = "; "), ".")))
  })

  # ---- index + share
  output$p_share <- renderPlot({
    f <- first()
    full <- r2() |> transmute(fiscal_year, Mandatory = 100 * mandatory / f$mandatory, Discretionary = 100 * discretionary / f$discretionary)
    ylim_idx <- range(c(100, full$Mandatory, full$Discretionary))
    d <- r2() |> transmute(fiscal_year, Mandatory = 100 * mandatory / f$mandatory, Discretionary = 100 * discretionary / f$discretionary,
                           share = discretionary / total)
    di <- d |> select(-share) |> pivot_longer(-fiscal_year)
    p1 <- ggplot(di, aes(fiscal_year, value, colour = name)) +
      geom_hline(yintercept = 100, colour = "#9AA5B4") +
      geom_line(linewidth = 1.4) +
      geom_point(data = di |> filter(fiscal_year == max(fiscal_year)), size = 2.4) +
      geom_text(data = di |> filter(fiscal_year == max(fiscal_year)), aes(label = name),
                hjust = 0, nudge_x = 0.3, size = 3, fontface = "bold") +
      scale_y_continuous(limits = ylim_idx) +
      scale_colour_manual(values = c(Mandatory = pal[["purple"]], Discretionary = pal[["blue"]]), guide = "none") +
      scale_x_continuous(breaks = function(l) { b <- pretty(input$years, 4); b[b >= input$years[1] & b <= input$years[2]] },
                         expand = expansion(mult = c(0.02, 0.45))) +
      coord_cartesian(clip = "off") +
      labs(subtitle = "Growth since the first year", x = "Fiscal year", y = paste0("Index (FY", input$years[1], " = 100)")) +
      theme_va() + theme(plot.subtitle = element_text(colour = muted, size = 8.5))
    p2 <- ggplot(d, aes(fiscal_year, share)) +
      geom_line(linewidth = 1.4, colour = pal[["pink"]]) +
      geom_point(data = d |> filter(fiscal_year %in% range(fiscal_year)), size = 3, colour = pal[["pink"]]) +
      geom_text(data = d |> filter(fiscal_year %in% range(fiscal_year)), aes(label = pct(share)),
                vjust = -1, size = 3, colour = ink) +
      scale_y_continuous(labels = label_percent(accuracy = 1), limits = c(0, 0.65)) +
      scale_x_continuous(breaks = pretty_breaks(4), limits = input$years) +
      labs(subtitle = "Discretionary ÷ total VA funding", x = "Fiscal year", y = "Discretionary share (%)") +
      theme_va() + theme(plot.subtitle = element_text(colour = muted, size = 8.5))
    if (requireNamespace("patchwork", quietly = TRUE)) patchwork::wrap_plots(p1, p2, ncol = 2) else p1
  }, res = 96)
  output$t_share <- renderUI({
    f <- first(); l <- last()
    cf <- l$discretionary / (l$discretionary + f$mandatory * l$discretionary / f$discretionary)
    p(HTML(paste0("Discretionary funding grew <b>", formatC(l$discretionary / f$discretionary, format = "f", digits = 1),
      "×</b> while mandatory grew <b>", formatC(l$mandatory / f$mandatory, format = "f", digits = 1), "×</b>. ",
      "Had mandatory grown at the discretionary pace, the discretionary share would be ", pct(cf), " instead of ",
      pct(l$discretionary / l$total), ", so the shrinking share is ",
      if (l$mandatory / f$mandatory > l$discretionary / f$discretionary) "a <b>denominator effect</b>." else "not driven by mandatory growth in this window.")))
  })
}

shinyApp(ui, server)

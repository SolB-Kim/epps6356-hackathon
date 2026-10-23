library(shiny)
library(bslib)
library(thematic)
library(readxl)
library(dplyr)
library(ggplot2)

# ---- Data setup ----
hpi_raw <- read_excel("Happy-Planet-Index-2006-2025-public-data-set.xlsx",
                      sheet = "All Data", skip = 1)

continent_lookup <- c(
  "1" = "Latin America", "2" = "N America & Oceania", "3" = "Western Europe",
  "4" = "Middle East & N. Africa", "5" = "Africa", "6" = "South Asia",
  "7" = "Eastern Europe & Central Asia", "8" = "East Asia"
)

hpi <- hpi_raw %>%
  rename(GDP_per_capita = `GDP per capita (cleaned) - 2024 used for 2025`,
         Life_Expectancy = `Life Expectancy`,
         Life_Satisfaction = `Life Satisfaction`,
         Ecological_Footprint = `Ecological Footprint`) %>%
  filter(!is.na(Continent), !is.na(Year)) %>%
  mutate(Continent = continent_lookup[as.character(Continent)])

rainbow <- c(
  "Africa" = "#FFADAD",
  "East Asia" = "#FFC6FF",
  "Eastern Europe & Central Asia" = "#F0E68C",
  "Latin America" = "#CAFCCF",
  "Middle East & N. Africa" = "#9BF6FF",
  "N America & Oceania" = "#A0C4FF",
  "South Asia" = "#BDB2FF",
  "Western Europe" = "#FFD6A5"
)

# ---- UI ----
ui <- fluidPage(
  theme = bs_theme(bootswatch = "flatly", base_font = font_google("Quicksand")),
  
  titlePanel("Happy Planet Index: Team Hackathon 2.0"),
  
  wellPanel(
    strong("About: "),
    "Data source: Abdallah, S. & Barberà Mas, E. (2026). The Happy Planet Index 2026 Data File. ",
    "Accessed from www.happyplanetindex.org. Covers 2006-2025 across all countries."
  ),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput("year", "Year:",
                  min = min(hpi$Year), max = max(hpi$Year),
                  value = max(hpi$Year), step = 1, sep = ""),
      
      # --- Chart 9 inputs (Solbee) ---
      selectInput("xvar9", "Chart 9 - X variable:",
                  choices = c("GDP per capita" = "GDP_per_capita",
                              "Life Expectancy" = "Life_Expectancy",
                              "HPI" = "HPI"),
                  selected = "GDP_per_capita"),
      selectInput("yvar9", "Chart 9 - Y variable:",
                  choices = c("Life Satisfaction" = "Life_Satisfaction",
                              "Life Expectancy" = "Life_Expectancy",
                              "HPI" = "HPI"),
                  selected = "Life_Satisfaction")
      
      # --- TEAMMATE: add Chart 18 (bubble) inputs here ---
      # --- TEAMMATE: add Chart 3 (your choice) inputs here ---
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Chart 9: Scatter", plotOutput("chart9_scatter")),
        tabPanel("Chart 18: Bubble", plotOutput("chart18_bubble"))  # TEAMMATE: build this output
        # TEAMMATE: add tabPanel for Chart 3 here
      )
    )
  )
)

# ---- Server ----
server <- function(input, output) {
  thematic::thematic_shiny()
  
  # Shared reactive used by ALL THREE charts - everyone filters off this
  filtered_data <- reactive({
    hpi %>% filter(Year == input$year)
  })
  
  # --- Chart 9: scatter (Solbee) ---
  output$chart9_scatter <- renderPlot({     
    df <- filtered_data()
    ggplot(df, aes(x = .data[[input$xvar9]], y = .data[[input$yvar9]], color = Continent)) +
      geom_point(size = 2.5, alpha = 0.8) +
      scale_color_manual(values = rainbow) +
      labs(title = paste("Distribution:", input$xvar9, "vs", input$yvar9, "-", input$year),
           x = input$xvar9, y = input$yvar9,
           caption = "Source: Happy Planet Index 2006-2025 Data File (happyplanetindex.org)") +
      theme_minimal()
  })
  
  # --- TEAMMATE: Chart 18 (bubble) server logic here ---
  # output$chart18_bubble <- renderPlot({
  #   df <- filtered_data()
  #   ggplot(df, aes(x = ..., y = ..., size = ..., color = Continent)) + ...
  # })
  
  # --- TEAMMATE: Chart 3 (your choice) server logic here ---
}

shinyApp(ui = ui, server = server)
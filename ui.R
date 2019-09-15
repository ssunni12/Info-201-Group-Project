# Plotly requires seperate initalization.
library(plotly)

ui <- fluidPage(
  theme = "shiny.css",
  titlePanel("World Happiness Report"),
  sidebarLayout(
    sidebarPanel(
      # Widgets to select year and region.
      selectInput("year", "Select Year", choices = c("2015", "2016", "2017")),
      selectInput("region", 
                  ("Select Region"), 
                  choices = c("All",
                              "Western Europe", 
                              "Central and Eastern Europe",
                              "Eastern Asia",
                              "Latin America and Caribbean",
                              "Middle East and Northern Africa",
                              "North America",
                              "Southeastern Asia",
                              "Southern Asia",
                              "Sub-Saharan Africa",
                              "Australia and New Zealand")
      ),
      width = 2
    ),
    mainPanel(
      # Seperates all visualizations into tabs.
      tabsetPanel(type = "tabs",
                  tabPanel("Overview", plotOutput("heatPlot"), includeMarkdown("Analysis/overview.md")),
                  tabPanel("GDP Scatterplot", plotlyOutput("gdpPlot"), includeMarkdown("Analysis/sanjay.md")),
                  tabPanel("Trust Scatterplot", plotOutput("freePlot"), includeMarkdown("Analysis/torin.md")),
                  tabPanel("Generosity Bar Chart", uiOutput("plot.ui"), includeMarkdown("Analysis/gabe.md")),
                  tabPanel("Conclusion",  DT::dataTableOutput("conclusion"), includeMarkdown("Analysis/conclusion.md"))
      )
    )
  )
)
  
shinyUI(ui)


library(shiny)
library(ggplot2)
library(dplyr)
library(plotly)
library(data.table)
library(DT)

server <- function(input, output) {
  
  # Selects the required data, optimizing loading time. Sorts region if selected.
  selectedData <- reactive({
    dataPath <- paste0("Data/", input$year, ".csv")
    data <- read.csv(dataPath)
    if (input$region != "All") {
      data <- filter(data, Region == input$region)
    }
    return(data)
  })
  
  # Plot of the world as a heatmap of overall happiness score.
  output$heatPlot <- renderPlot({
    editedData <-selectedData() %>% 
      mutate(Country = sub("United States", "USA",  Country)) %>% 
      mutate(Country = sub("United Kingdom", "UK", Country))
    map.world <- map_data('world')
    mapped <- left_join(map.world, editedData, by = c('region' = 'Country'))
    ggplot(data = mapped, aes(x = long, y = lat, group = group)) +
      geom_polygon(aes(fill = Happiness.Score)) + 
      labs(title = "Happiness Score by Nation", x = "Longitude", 
           y = "Latitude", fill = "Happiness Score") +
      coord_fixed()
  })

  # Interactive scatterplot comparing GDP and Life Expectancy.
  output$gdpPlot <- renderPlotly({
    plot_ly(data = selectedData(), 
            x=~Economy..GDP.per.Capita. / Happiness.Score * 100, 
            y=~Health..Life.Expectancy. / Happiness.Score * 100, color=~Region, type = "scatter",
            text = ~paste("Country:", Country)) %>% 
      layout(title = "GDP and Life Expectancy per region as percentages of Overall Happiness", 
             xaxis = list(title = "GDP per Capita (%)"),
             yaxis = list(title = "Health / Life Expectancy (%)"))
  })
  
  # Scatterplot comparing freedom and happiness score, with a gradient of trust in government.
  output$freePlot <- renderPlot({
    ggplot(data = selectedData()) +
      geom_smooth(aes(x = Freedom, y = Happiness.Score)) +
      geom_point(aes(x = Freedom, y = Happiness.Score, color = Trust..Government.Corruption.)) +
      scale_color_gradient(low = "blue", high = "yellow") +
      labs(
        title = "Correlations: Happiness, Freedom, and Government Trust", 
        x = "Freedom (%)", 
        y = "Happiness Score",
        color = "Trust in Gov. (%)"
      )
  })
  
  # Bar graph of nation happiness score, with a gradient of generosity.
  output$genPlot <- renderPlot({
    ggplot(data = selectedData()) + 
      geom_bar(aes(x = reorder(Country, Happiness.Score), 
                   fill = Generosity, weight = Happiness.Score)) + 
      scale_fill_gradient(low = "red", high = "green") +
      coord_flip() +
      labs(title = "Happiness Score Boxplot",
           x = "Country",
           y = "Happiness Score",
           fill = "Generosity (%)") 
  })
  
  # Adjusts the size of the genPlot based on how many rows they have, 
  # allowing the main plot (with many countries) to be much taller.
  output$plot.ui <- renderUI({
    plotOutput("genPlot", height = paste0(100 + nrow(selectedData()) * 20, "px"))
  })

  # Conclusion table, with country, happiness rank, happiness score, and the region.
  output$conclusion = DT::renderDataTable({
    data <- selectedData() %>%
      select(Country, Happiness.Rank, Happiness.Score, Region) %>%
      rename("Happiness Rank" = Happiness.Rank) %>%
      rename("Happiness Score" = Happiness.Score) %>% 
      mutate_if(is.numeric, ~round(., 3))
    DT::datatable(data, options = list(lengthMenu = c(10, 20, 30)))
  })
}

shinyServer(server)

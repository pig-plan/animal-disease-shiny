library(shiny)
library(leaflet)
library(data.table)
library(jsonlite)

# key <- "AIzaSyDvwglFuj1Ha8Fu09jYoPnKO_442oXcgKA"

df <- read.csv('refined.csv', header = TRUE, stringsAsFactors = FALSE)


shinyServer(function(input, output) {
  
  reactive_data <- reactive({
    
    tmp <- data.table(df)
    tmp <- tmp[tmp$LKNTS_NM == input$disease & tmp$LVSTCKSPC_NM == input$animal, ]
    return(tmp)
    
  })
  
  
  output$disease <- renderUI({
    selectInput("disease", "▷ 질병 선택",  
                levels(factor(df$LKNTS_NM))
    )
  })
  
  output$animal <- renderUI({
    selectInput("animal", "▷ 가축 선택",  
                levels(factor(df$LVSTCKSPC_NM))
    )
  })
  
  output$range <- renderUI({
    sliderInput("range", "▷ 검색 기간",  
                min = min(as.Date(df$OCCRRNC_DE)),
                max = max(as.Date(df$OCCRRNC_DE)),
                value = c(as.Date("20100102", "%Y%m%d"), max(as.Date(df$OCCRRNC_DE)))
    )
  })
  
  points <- eventReactive(input$recalc, {
    cbind(rnorm(40) * 2 + 13, rnorm(40) + 48)
  }, ignoreNULL = FALSE)
  
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("Stamen.TonerLite",
        options = providerTileOptions(noWrap = TRUE)
      ) %>%
      addMarkers(data = points())
  })
    
  output$animation <- renderUI({
    sliderInput("animation", "▷ 시계열 애니메이션",
                min = min(df$OCCRRNC_DE),
                max = max(df$OCCRRNC_DE),
                value = as.Date("20100102", "%Y%m%d")
    )
  })
  
})


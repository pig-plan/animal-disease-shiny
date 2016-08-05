library(shiny)
library(leaflet)
library(data.table)
library(jsonlite)

# key <- "AIzaSyDvwglFuj1Ha8Fu09jYoPnKO_442oXcgKA"

json <- fromJSON('disease_20160803.json')
df_raw <- json$data
df_all <- unique(df_raw)
df_all$OCCRRNC_DE <- as.Date(df_all$OCCRRNC_DE, "%Y%m%d")
df <- df_all[c(2, 3, 5, 11, 12, 13)]


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
                min = min(df$OCCRRNC_DE),
                max = max(df$OCCRRNC_DE),
                value = c(as.Date("20100102", "%Y%m%d"), max(df$OCCRRNC_DE))
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


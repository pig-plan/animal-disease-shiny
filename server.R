library(shiny)
library(leaflet)
library(data.table)
library(jsonlite)
library(htmltools)
library(randomcoloR)


df <- read.csv('geocoding/geocoded.csv', header = TRUE, stringsAsFactors = FALSE)
df <- na.omit(df)
df$OCCRRNC_DE <- as.Date(df$OCCRRNC_DE)


shinyServer(function(input, output, session) {
  
  reactive_data <- reactive({
    
    tmp <- data.table(df)
    tmp <- tmp[tmp$LKNTS_NM == input$disease & tmp$OCCRRNC_DE >= input$range[1] & tmp$OCCRRNC_DE <= input$range[2], ]
    return(tmp)
    
  })
  
  ncolors <- nlevels(factor(df$LVSTCKSPC_NM))
  
  pal <- colorFactor(distinctColorPalette(ncolors), domain = levels(factor(df$LVSTCKSPC_NM)))
  
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
      addProviderTiles("Stamen.TonerLite", group = "흑백") %>%
      addProviderTiles("Esri.WorldStreetMap", group = "거리") %>%
      # addProviderTiles("OpenStreetMap.Mapnik", group = "거리") %>%
      addProviderTiles("Esri.WorldImagery", group = "지형") %>%
      setView(lng = 127.6, lat = 35.7, zoom = 7) %>%
      addLayersControl(
        baseGroup = c("흑백", "거리", "지형"),
        options = layersControlOptions(collapsed = FALSE)
      )
  })
  
  observe({
    leafletProxy("map", data = reactive_data()) %>%
      clearShapes() %>%
      clearMarkers() %>%
      clearMarkerClusters() %>%
      addCircleMarkers(~longitude, ~latitude, clusterOptions = markerClusterOptions(), popup = ~htmlEscape(paste(OCCRRNC_DE, ",", LVSTCKSPC_NM, ",", OCCRRNC_LVSTCKCNT, "마리")), stroke = FALSE, fillOpacity = 1, color = ~pal(LVSTCKSPC_NM))
  })
  
  observe({
    input$reset
    leafletProxy("map") %>%
      setView(lng = 127.6, lat = 35.7, zoom = 7)
  })
  
  # output$animation <- renderUI({
  #   sliderInput("animation", "▷ 시계열 애니메이션",
  #               min = min(df$OCCRRNC_DE),
  #               max = max(df$OCCRRNC_DE),
  #               value = min(df$OCCRRNC_DE),
  #               step = 1,
  #               animate = animationOptions(interval = 10)
  #   )
  # })
  
})


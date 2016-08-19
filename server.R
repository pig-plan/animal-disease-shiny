library(shiny)
library(leaflet)
library(data.table)
library(jsonlite)
library(htmltools)
library(randomcoloR)
library(doBy)
library(ggplot2)
library(ggthemes)
library(plotly)


df <- read.csv('geocoding/geocoded.csv', header = TRUE, stringsAsFactors = FALSE)
df <- na.omit(df)
df$OCCRRNC_DE <- as.Date(df$OCCRRNC_DE)
maxCNT <- summaryBy(OCCRRNC_LVSTCKCNT ~ LKNTS_NM, data = df, FUN = max)


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
  
  output$range <- renderUI({
    sliderInput("range", "▷ 검색 기간",  
                min = min(df$OCCRRNC_DE),
                max = max(df$OCCRRNC_DE),
                value = c(as.Date("20100102", "%Y%m%d"), max(df$OCCRRNC_DE))
    )
  })
  
  output$Map1 <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("Stamen.TonerLite", group = "흑백") %>%
      addProviderTiles("CartoDB.PositronNoLabels", group = "단순") %>%
      addProviderTiles("Esri.WorldStreetMap", group = "도로") %>%
      addProviderTiles("Esri.NatGeoWorldMap", group = "지형") %>%
      addProviderTiles("Esri.WorldImagery", group = "사진") %>%
      setView(lng = 128.5, lat = 36, zoom = 6) %>%
      addLayersControl(
        baseGroup = c("흑백", "단순", "도로", "지형", "사진"),
        overlayGroups = c("클러스터", "피해규모"),
        options = layersControlOptions(collapsed = FALSE)
      ) %>%
      hideGroup("피해규모")
  })
  
  observe({
    leafletProxy("Map1", data = reactive_data()) %>%
      clearShapes() %>%
      clearMarkers() %>%
      clearMarkerClusters() %>%
      addCircleMarkers(~longitude, ~latitude, clusterOptions = markerClusterOptions(), popup = ~htmlEscape(paste(OCCRRNC_DE, ",", LVSTCKSPC_NM, ",", OCCRRNC_LVSTCKCNT, "마리")), stroke = FALSE, fillOpacity = 1, color = ~pal(LVSTCKSPC_NM), group = "클러스터") %>%
      addCircles(~longitude, ~latitude, ~sqrt(OCCRRNC_LVSTCKCNT / maxCNT[maxCNT$LKNTS_NM == input$disease, ][[2]]) * 10000, popup = ~htmlEscape(paste(OCCRRNC_DE, ",", LVSTCKSPC_NM, ",", OCCRRNC_LVSTCKCNT, "마리")), stroke = FALSE, fillOpacity = 0.6, color = ~pal(LVSTCKSPC_NM), group = "피해규모")
  })
  
  observe({
    input$reset
    leafletProxy("Map1") %>%
      setView(lng = 128.5, lat = 36, zoom = 6)
  })
  
  output$diseaseName <- renderText({
    paste(input$disease, " ", input$range[1], " _ ", input$range[2])
  })
  
  output$hist <- renderPlotly({
    p <- ggplot(reactive_data(), aes(LVSTCKSPC_NM)) +
      geom_bar(alpha = 0.8) +
      theme_economist() +
      theme(axis.text.x = element_text(angle = 90)) 
    gg <- ggplotly(p)
    gg %>% layout(
      title = "축종별",
      titlefont = list(size = 14),
      xaxis = list(title = ""),
      yaxis = list(title = "가구수")
    )
    
  })
  
  output$series <- renderPlotly({
    p <- ggplot(reactive_data(), aes(OCCRRNC_DE, OCCRRNC_LVSTCKCNT)) +
      geom_point(alpha = 0.3) +
      theme_economist()
    gg <- ggplotly(p)
    gg %>% layout(
      title = "시계열",
      titlefont = list(size = 14),
      xaxis = list(title = "진단일자"),
      yaxis = list(title = "두수")
    )
  })
  
})


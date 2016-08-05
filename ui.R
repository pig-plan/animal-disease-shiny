library(shiny)
library(shinythemes)
library(leaflet)

shinyUI(fluidPage(
  
  theme = shinytheme("flatly"),
  
  HTML("<br>
        <div style='text-align:center;'>
          <h1>
            <span style='white-space: nowrap;'>가축질병 통계 (Demo) </span>
        </div>
        <br><hr><br>"),
  
  fluidRow(
    
    column(4,
      uiOutput("range")
    ),
    column(4,
      uiOutput("disease")
    ),
    column(4,
      uiOutput("animal")
    )
    
  ),
  
  fluidRow(
    
    column(12,
      leafletOutput("map"),
      p(),
      actionButton("recalc", "New points")
    )
           
  )
  
  # fluidRow(
  # 
  #   column(12,
  #     uiOutput("animation")
  #   )
  # 
  # )

))
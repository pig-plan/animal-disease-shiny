library(shiny)
library(shinythemes)
library(leaflet)


shinyUI(fluidPage(
  
  theme = shinytheme("flatly"),
  
  HTML("<br>
        <div style='text-align:center;'>
          <h1>
            <span style='white-space: nowrap;'>가축질병 통계</span>
        </div>
        <br><hr><br>"),
  
  fluidRow(
    
    column(5,
      uiOutput("range")
    ),
    column(5,
      uiOutput("disease")
    ),
    column(2,
      p(), 
      actionButton("reset", "Zoom 초기화")
    )
    
  ),
  
  fluidRow(
    
    column(12,
      leafletOutput("map", height = 500)
    )
           
  ),
  
  fluidRow(
    column(12,
      h4(textOutput("diseaseName"), align = "left")
    )
  ),
  
  fluidRow(
    
    column(6,
      plotOutput("hist", height = 200),
      br(), br(), br()
    ),
    column(6,
      plotOutput("series", height = 200),
      br(), br(), br()
    )
    
  )

))
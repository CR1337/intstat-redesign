ui <- fluidPage(
  titlePanel("Minimal Shiny App"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("slider", "Select a value:",
                  min = 1, max = 100, value = 50)
    ),
    mainPanel(
      h3("Selected Value"),
      verbatimTextOutput("value")
    )
  )
)
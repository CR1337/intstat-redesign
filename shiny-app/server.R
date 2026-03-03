server <- function(input, output) {
  output$value <- renderPrint({
    input$slider
  })
}
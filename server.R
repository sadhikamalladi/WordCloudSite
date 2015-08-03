function(input, output) {
  
  observeEvent(input$gsea.run, {
    output$plot <- renderPlot({runPipeline(input,output)})
  })
  
  observeEvent(input$updateCol, {
    output$plot <- renderPlot({createPlot(stats,input)})
  })
}

# Text of the books downloaded from:
# A Mid Summer Night's Dream:
#  http://www.gutenberg.org/cache/epub/2242/pg2242.txt
# The Merchant of Venice:
#  http://www.gutenberg.org/cache/epub/2243/pg2243.txt
# Romeo and Juliet:
#  http://www.gutenberg.org/cache/epub/1112/pg1112.txt

function(input, output) {
  
  stats <- reactive({
    input$update
    isolate({
      withProgress({
        setProgress(message = "Processing lists...")
        list1.var <- unlist(parseList(input$list1, input$sep))
        list2.var <- unlist(parseList(input$list2, input$sep))
        is <- intersect(list1.var, list2.var)
        list1.var <- list1.var[list1.var %in% is]
        list2.var <- list2.var[list2.var %in% is]
        x <- generateStatistics(list1.var, list2.var, input$list1.name, input$list2.name)
        x$obj
      })
    })
  })
  
  
  output$plot <- renderPlot({
    statistics <- stats()
    if (!is.null(statistics)) {
      withProgress({
        setProgress(message = 'Generating plot...may take time depending on the size of your lists')
        createPlot(statistics,input)
      })
    }
  })
}
fluidPage(
  # Application title
  titlePanel("Word Cloud"),
  
  sidebarLayout(
    # Sidebar with a slider and selection inputs
    sidebarPanel(
      helpText("Enter your lists (separated by spaces, commas, or new lines) to compare and hit update!"),
      textInput('list1', 'List 1:', value=paste('A','A','A','A','A','A','A','A','B','C','C')),
      textInput('list1.name', 'List 1 Name:', value='List 1'),
      textInput('list2', 'List 2:', value=paste('B','B','A','B','B','B','B','A','B','C')),
      textInput('list2.name', 'List 2 Name:', value='List 2'),
      textInput('cutoff', 'Significance Cut-off (BH-value)', value='0.05'),
      radioButtons('plot.type', label='Plot Type',
                   choices=list('Color by Significance' = 1,
                                'Color by Count' = 2),
                   selected=1),
      actionButton("update", "Compare!")
    ),
    
    # Show Word Cloud
    mainPanel(
      plotOutput("plot")
    )
  )
)
fluidPage(
  # Application title
  titlePanel("Word Cloud"),
  
  sidebarLayout(
    # Sidebar with a slider and selection inputs
    sidebarPanel(
      
      # GSEA inputs
      fileInput('exp',label='Upload expression file (.gct)', multiple=F),
      fileInput('pheno',label='Upload phenotype file (.cls)', multiple=F),
      radioButtons('gs', label='Select Broad MSigDB geneset to use', choices=list('C1','C2','C3','C4','C5','C6','C7'),
                   selected=1),
      actionButton("gsea.run", "Run GSEA"),
      
      hr(), 
      
      radioButtons('col1', label='Color 1',
                   choices=list('Red' = 'red','Blue' = 'blue','Green' = 'green',
                                'Purple'='purple','Orange'='orange', 'Black'='black'),
                   selected='red'),
      radioButtons('col2', label='Color 2',
                   choices=list('Red' = 'red','Blue' = 'blue','Green' = 'green',
                                'Purple'='purple','Orange'='orange', 'Black'='black'),
                   selected='black'),
      actionButton("updateCol", "Update colors!")
    ),
    
    # Show Word Cloud
    mainPanel(
      plotOutput("plot")
    )
  )
)
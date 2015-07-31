library(WordCloudAnalysis)

parseList <- function(list) {
  # Separation by comma
  if (length(grep(',',list)) != 0)
    strsplit(list,',',fixed=T)
  else
    strsplit(list,' ')
}

generateStatistics <- function(list1, list2, list1.name, list2.name) {
   if (length(list1)==0 | length(list2)==0) {
     list(status=FALSE,obj=NULL)
   } else {
     list(status=TRUE,obj=wordcloudstats(list1,list2,c(list1.name,list2.name)))
   }
}

createPlot <- function(stats, input) {
  plot.type <- input$plot.type
  cutoff <- input$cutoff
  list1.name <- input$list1.name
  list2.name <- input$list2.name
  
  freq <- stats$frequency
  ct <- stats$counts
  bh <- as.numeric(stats$outputs[,'bh.Value'])
  names(bh) <- rownames(stats$outputs)
  cutoff <- as.numeric(cutoff)
  
  if (min(bh) > cutoff) {
    plot(x=1:10,y=1:10)
    text(x=5,y=5,paste('None of your BH values were below the cutoff'))
  } else if (length(unique(bh)) == 1) {
    plot(x=1:10,y=1:10)
    text(x=5,y=5,paste('All of your BH values were',unique(bh)))
  } else if (plot.type==1) {
    WordCloudAnalysis::comparisonplot_colbysig(freq,bh,cutoff=cutoff,xlab=list1.name,ylab=list2.name,colors=c(input$col1,input$col2))
  } else if (plot.type==2) {
    WordCloudAnalysis::comparisonplot_colbycount(freq,ct,bh,xlab=list1.name,ylab=list2.name,colors=c(input$col1,input$col2))
  }
}
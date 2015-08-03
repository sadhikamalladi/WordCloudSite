library(WordCloudAnalysis)
library(xlsx)

runGSEA <- function(exp, pheno, gs) {
  GSEA.program.location <- "GSEA-P-R/GSEA.1.0.R"   #  R source program (change pathname to the rigth location in local machine)
  source(GSEA.program.location, verbose = F, max.deparse.length = 9999)
  
  exp.path <- paste0(exp$datapath)
  pheno.path <- paste0(pheno$datapath)
  gs.path <- paste0('GSEA-P-R/GeneSetDatabases/',gs,'.gmt')
  rnd.id <- as.character(sample(1:10000,1))
  out.path <- as.character(paste0('TempDir_',rnd.id,'/'))
  dir.create(out.path,showWarnings=F)
  
  GSEA(
    # Input/Output Files :-------------------------------------------
    input.ds =  exp.path,               # Input gene expression Affy dataset file in RES or GCT format
    input.cls = pheno.path,               # Input class vector (phenotype) file in CLS format
    gs.db =     gs.path,           # Gene set database in GMT format
    output.directory      = out.path,            # Directory where to store output and results (default: "")
    #  Program parameters :----------------------------------------------------------------------------------
    reshuffling.type      = "sample.labels", # Type of permutation reshuffling: "sample.labels" or "gene.labels" (default: "sample.labels"
    nperm                 = 1000,            # Number of random permutations (default: 1000)
    weighted.score.type   =  1,              # Enrichment correlation-based weighting: 0=no weight (KS), 1= weigthed, 2 = over-weigthed (default: 1)
    nom.p.val.threshold   = -1,              # Significance threshold for nominal p-vals for gene sets (default: -1, no thres)
    fwer.p.val.threshold  = -1,              # Significance threshold for FWER p-vals for gene sets (default: -1, no thres)
    fdr.q.val.threshold   = 0.25,            # Significance threshold for FDR q-vals for gene sets (default: 0.25)
    topgs                 = 20,              # Besides those passing test, number of top scoring gene sets used for detailed reports (default: 10)
    adjust.FDR.q.val      = F,               # Adjust the FDR q-vals (default: F)
    gs.size.threshold.min = 15,              # Minimum size (in genes) for database gene sets to be considered (default: 25)
    gs.size.threshold.max = 500,             # Maximum size (in genes) for database gene sets to be considered (default: 500)
    reverse.sign          = F,               # Reverse direction of gene list (pos. enrichment becomes negative, etc.) (default: F)
    preproc.type          = 0,               # Preproc.normalization: 0=none, 1=col(z-score)., 2=col(rank) and row(z-score)., 3=col(rank). (def: 0)
    random.seed           = 111,             # Random number generator seed. (default: 123456)
    perm.type             = 0,               # For experts only. Permutation type: 0 = unbalanced, 1 = balanced (default: 0)
    fraction              = 1.0,             # For experts only. Subsampling fraction. Set to 1.0 (no resampling) (default: 1.0)
    replace               = F,               # For experts only, Resampling mode (replacement or not replacement) (default: F)
    save.intermediate.results = F,           # For experts only, save intermediate results (e.g. matrix of random perm. scores) (default: F)
    OLD.GSEA              = F,               # Use original (old) version of GSEA (default: F)
    non.interactive.run   = T,
    use.fast.enrichment.routine = T          # Use faster routine to compute for random permutations (default: T)
  )
  
  results.dir <- dir(path=out.path, pattern='.*SUMMARY.RESULTS.REPORT.*.txt')
  phenos <- gsub('.*REPORT.([A-Za-z0-9]+).txt','\\1',results.dir)
  tab.1 <- read.table(paste0(out.path,results.dir[1]),sep='\t',header=T,fill=T)
  tab.2 <- read.table(paste0(out.path,results.dir[2]),sep='\t',header=T,fill=T)
  
  unlink(out.path,recursive=T,force=T)
  
  results <- list(phenotypes=phenos, tab1=tab.1, tab2=tab.2, geneset=gs)
  results
}

parseList <- function(list,sep) {
 x <- gsub('[[:punct:]]','',list)
 x <- strsplit(list,sep)
 x <- unlist(x)
 x
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
  bh <- stats$outputs[,'bh.Value']
  bh <- as.numeric(bh)
  names(bh) <- rownames(stats$outputs)
  cat(bh[1])
  cutoff <- as.numeric(cutoff)
  
  if (sum(is.na(bh) | is.nan(bh)) > 0) {
    plot(x=1:10,y=1:10)
    text(x=5,y=5,paste('Bad BH calculation'))
  } else if (min(bh) > cutoff) {
    plot(x=1:10,y=1:10)
    text(x=5,y=5,paste('None of your BH values were below the cutoff'))
  } else if (length(unique(bh)) == 1) {
    plot(x=1:10,y=1:10,type='n')
    text(x=5,y=5,paste('All of your BH values were',unique(bh)))
  } else if (plot.type==1) {
    WordCloudAnalysis::comparisonplot_colbysig(freq,bh,cutoff=cutoff,xlab=list1.name,ylab=list2.name,colors=c(input$col1,input$col2))
  } else if (plot.type==2) {
    WordCloudAnalysis::comparisonplot_colbycount(freq,ct,bh,xlab=list1.name,ylab=list2.name,colors=c(input$col1,input$col2))
  }
}

prepForWC <- function(gsea) {
  l1 <- as.character(gsea$tab1$GS)
  l2 <- as.character(gsea$tab2$GS)
  
  if(gsea$geneset == 'C2') {
    l1 <- gsub('_(B|T)_([A-Z0-9]+)',paste('_','\\1','\\2',sep = ''),l1)
    l1 <-
      gsub('_(IL)_(3)_(5)',paste('_','\\1','\\2','\\3',sep = ''),l1)
    l1 <-
      gsub('_(IL)_([0-9]+)',paste('_','\\1','\\2',sep = ''),l1)
    l1 <-
      gsub('(CLUSTER)_([0-9]+)',paste('_','\\1','\\2',sep = ''),l1)
    l1 <-
      gsub('(GRADE)_([0-9]+)_VS_([0-9]+)',paste('_','\\1','\\2','v','\\3',sep =
                                                  ''),l1)
    l1 <- gsub('_APC_C','_APCC',l1)
    l1 <-
      gsub('_CLASS_([A-Z0-9]+)',paste0('_CLASS','\\1'),l1)
    l1 <- gsub('_GAMMA_R','_GAMMAR',l1)
    l1 <- gsub('GM_CSF','GMCSF',l1)
    l1 <- gsub('ES_1','ES1',l1)
    l1 <- gsub('[A-Z]+_(.*)','\\1',l1)
    l1 <- unlist(strsplit(l1,'_'))
    
    l2 <-
      gsub('_(B|T)_([A-Z0-9]+)',paste('_','\\1','\\2',sep = ''),l2)
    l2 <-
      gsub('_(IL)_(3)_(5)',paste('_','\\1','\\2','\\3',sep = ''),l2)
    l2 <-
      gsub('_(IL)_([0-9]+)',paste('_','\\1','\\2',sep = ''),l2)
    l2 <-
      gsub('(CLUSTER)_([0-9]+)',paste('_','\\1','\\2',sep = ''),l2)
    l2 <-
      gsub('(GRADE)_([0-9]+)_VS_([0-9]+)',paste('_','\\1','\\2','v','\\3',sep =
                                                  ''),l2)
    l2 <- gsub('_APC_C','_APCC',l2)
    l2 <-
      gsub('_CLASS_([A-Z0-9]+)',paste0('_CLASS','\\1'),l2)
    l2 <- gsub('_GAMMA_R','_GAMMAR',l2)
    l2 <- gsub('GM_CSF','GMCSF',l2)
    l2 <- gsub('ES_1','ES1',l2)
    l2 <- gsub('[A-Z]+_(.*)','\\1',l2)
    l2 <- unlist(strsplit(l2,'_'))
  }
  if(gsea$geneset == 'C6') {
    l1 <- gsub('DN','',l1)
    l1 <- gsub('UP','',l1)
    l1 <- gsub('[0-9]+','',l1)
    l1 <- unlist(strsplit(l1,'.'))
    l2 <- gsub('DN','',l2)
    l2 <- gsub('UP','',l2)
    l2 <- gsub('[0-9]+','',l2)
    l2 <- unlist(strsplit(l2,'.'))
  }
  
  list(list1=l1, list2=l2)
}

runPipeline <- function(input,output) {
  gsea <- runGSEA(input$exp, input$pheno, input$gs)
  lists <- prepForWC(gsea)
  stats <- generateStatistics(lists$list1, lists$list2, gsea$phenos[1], gsea$phenos[2])
  createPlot(stats,input)
}
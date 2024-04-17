args=(commandArgs(TRUE))


myLibPath <- "~/R/libs"
if (!dir.exists(myLibPath)) dir.create(myLibPath, recursive = TRUE)
.libPaths(myLibPath)

if (!require("GARS", character.only = TRUE, quietly = TRUE)) {
    BiocManager::install("GARS", lib=myLibPath)
}

if (!require("SummarizedExperiment", character.only = TRUE, quietly = TRUE)) {
    BiocManager::install("SummarizedExperiment", lib=myLibPath)
}

library(GARS)
library(SummarizedExperiment)

filename<-paste(args[1])
extension <- sub(".*\\.(.*)$", "\\1", filename)
extension<-toupper(extension)

# Imrimir la extensión del archivo

if (extension == "TXT") {
    cat("TXT")

    SE_obj<-read.table(filename, header=T, sep="\t")
    rownames(SE_obj)<-SE_obj[,1]
    df_tmp<-cbind(SE_obj[,1],SE_obj[,length(SE_obj)])
    colnames(df_tmp)<-c("SAMPLE","CLASS")
    SE_obj[,1]<-NULL
    SE_obj[,ncol(SE_obj)]<-NULL

    assays <- list(counts = as.matrix(SE_obj))
    colData <- data.frame("class"=df_tmp[,"CLASS"])
    rowData <- data.frame("GeneID"=colnames(assays$counts))
    SE_obj <- SummarizedExperiment(assays = t(assays$counts), rowData = rowData, colData = colData)

}else if (extension == "RDATA") {
    cat("RDATA")

    SE_obj<-get(load(filename))
    SE_obj  

}


init<-args[2]
end<-args[3]
chrnum<-as.numeric(args[4])
generat<-as.numeric(args[5])
corate<-as.numeric(args[6])
mutrate<-as.numeric(args[7])
nelit<-as.numeric(args[8])
typesel<-args[9]
typeco<-args[10]
typeonepco<-args[11]
ngenconv<-as.numeric(args[12])

set.seed(123)
populs <- list()
plotl<-list()
data_reduced_GARS<-list()
genesig<-list()
plotf<-list()
k=1


for (ik in seq(init,end)){
    
    
    populs[[k]] <- GARS_GA(data=SE_obj,
    classes = colData(SE_obj),
    chr.num = chrnum,  # default
    chr.len = ik,
    generat = generat,    ### generaciones por defecto 1000
    co.rate = corate,
    mut.rate = mutrate,
    n.elit = nelit,   # one best chromosomes selected in each generation.
    type.sel = typesel,
    type.co = typeco,
    type.one.p.co = typeonepco,
    n.gen.conv = ngenconv,  # 250 
    plots = "no",
    verbose="yes")

    fitness_scores<- FitScore(populs[[k]])
    plotl[[k]]<-GARS_PlotFitnessEvolution(fitness_scores)
    data_reduced_GARS[[k]] <- MatrixFeatures(populs[[k]])
    genesig[[k]]<-colnames(data_reduced_GARS[[k]])

    Allfeat_names <- rownames(SE_obj)
    Allpopulations <- AllPop(populs[[k]])
    plotf[[k]]<-GARS_PlotFeaturesUsage(Allpopulations,
                                          Allfeat_names,
                                             nFeat = 30)

    k <- k +1


}

save.image(file=paste0("GA_batch_",init,"_",end,".Rdata"))
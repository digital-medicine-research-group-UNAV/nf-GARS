args=(commandArgs(TRUE))
library(GARS)

path<-args[1]   # pathfile of batches


files<-list.files(path, pattern=".Rdata")
files<-paste0(path,files)

genesigs<-list()
#populs_l<-list()    # no los voy almacenando por exceso de memoria
POSITION_F<-list()
max_score<-list()
#plotALL<-list()
file_loaded<-list()
for(i in 1:length(files)){
    
    cat(files[i], "\n")
    load(files[i])
 #   genesigs[[i]]<-genesig
    #populs_l[[i]]<-populs
    
    max_fit <- 0
    for (j in seq_len(length(populs))){
    max_fit[j] <- max(FitScore(populs[[j]]))
    }
    
    POSITION_F[[i]]<-which.max(max_fit)
    max_score[[i]]<-max_fit[which.max(max_fit)]
    genesigs[[i]]<-paste(unlist(genesig[which.max(max_fit)]),collapse=";") 
    #plotALL[[i]]<-plotf
    file_loaded[[i]]<-files[i]
    rm(list=setdiff(ls(), c("i", "POSITION_F", "max_score", "file_loaded","files","genesigs")))
    gc()

}

resultados_procesados<-data.frame(file=unlist(file_loaded),"MAXFIT"=unlist(max_score),"LOCATION_GENELIST"=unlist(POSITION_F),"SIGNATURE"=unlist(genesigs))
resultado_final<-resultados_procesados[which.max(resultados_procesados$MAXFIT),]

write.table(resultado_final, file=paste0("GA_RESULTS_PROCESSED.txt"), col.names=T, row.names=F, quote=F, sep="\t")
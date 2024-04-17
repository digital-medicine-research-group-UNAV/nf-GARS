# Instalar paquetes si no están instalados

myLibPath <- "~/R/libs"
if (!dir.exists(myLibPath)) dir.create(myLibPath, recursive = TRUE)
.libPaths(myLibPath)


 
if (!require("SummarizedExperiment", character.only = TRUE, quietly = TRUE)) {
    BiocManager::install("SummarizedExperiment", lib=myLibPath)
}




args=(commandArgs(TRUE))

SE_obj<-get(load(args[1]))    # cuentas normalizadas 
SE_obj

no_cores<-as.numeric(args[2])    # número de batches dependiendo de los cores que tenga la maquina
projectpath<-args[3]

total_elements<-nrow(SE_obj)
no_cores <- no_cores -2


# Calcula el tamaño de cada segmento basado en el número de cores
segment_size <- ceiling(total_elements / no_cores)


task_ranges <- lapply(1:no_cores, function(core) {
  start <- (core - 1) * segment_size + 1
  end <- min(core * segment_size, total_elements)
  c(start, end)
})

batches<-t(as.data.frame(task_ranges))

batches[,1][1]<-2
batches[,2][nrow(batches)]<-(batches[,2][nrow(batches)])-1


write.table(batches, file=projectpath, col.names=F, row.names=F, quote=F, sep="\t")




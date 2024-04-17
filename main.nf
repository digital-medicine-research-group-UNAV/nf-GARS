nextflow.enable.dsl=2


//defaults
params.fileinput = "$projectDir/data/OBJECT_SE.Rdata"
params.outdir = "$projectDir/results"
params.chrnum = 100  // default
params.generat = 100 // default
params.corate = 0.8   // default
params.murate = 0.1 // default
params.nelit = 2   // default
params.typesel = "RW" // default
params.typeco = "one.p"  // default
params.typeonepco = "II.quart"   // default
params.ngenconv = 250   // default

// variables
fileinput_ch = Channel.of(params.fileinput)
chrnum_ch = Channel.of(params.chrnum)
generat_ch = Channel.of(params.generat)
corate_ch = Channel.of(params.corate)
murate_ch = Channel.of(params.murate)
nelit_ch = Channel.of(params.nelit)
typesel_ch = Channel.of(params.typesel)
typeco_ch = Channel.of(params.typeco)
typeonepco_ch = Channel.of(params.typeonepco)
ngenconv_ch = Channel.of(params.ngenconv)

//scripts
r_script_ch = Channel.fromPath("$projectDir/rscripts/CREATE_BATCHES.R")
r2_script_ch = Channel.fromPath("$projectDir/rscripts/COMPUTE.R")
r3_script_ch = Channel.fromPath("$projectDir/rscripts/ANALYZE.R")

process CREATEBATCHES {
    cpus 10  // adjust this depending of the resources and the variables
    container './bioconductor.sif'

    input:
    path fileinput
    path r_script

    output:
    path 'tasks.txt'

    script:
    """
    Rscript ${r_script} ${fileinput} ${task.cpus} tasks.txt
    """
}

 process COMPUTE {
     cpus 8 // adjust this depending of the resources and the variables
     memory { 10.GB * task.cpus }    // adjust this depending of the resources and the variables
     container './bioconductor.sif'
     publishDir "${params.outdir}", mode: 'copy'

     input:
     tuple path(fileinput), path(r2_script),  val(start), val(end), val(chrnum), val(generat), val(corate), val(murate), val(nelit), val(typesel), val(typeco), val(typeonepco), val(ngenconv)
     
     output:
     path '*.Rdata', emit: GA_batch

     script:
     """
     mkdir -p ${params.outdir}     
     Rscript ${r2_script} ${fileinput} ${start} ${end} ${chrnum} ${generat} ${corate} ${murate} ${nelit} ${typesel} ${typeco} ${typeonepco} ${ngenconv}
     """
 }


process ANALYZE {
    cpus 4  // adjust this depending of the resources and the variables
    container './bioconductor.sif'
    publishDir "${params.outdir}", mode: 'copy'
    
    input:
    path rdata_files
    path r3_script

    output:
    path 'GA_RESULTS_PROCESSED.txt'

    script:
    """
    Rscript ${r3_script} $rdata_files
    """
}



workflow {

    // Suponiendo que fileinput_ch y r2_script_ch emiten un único valor
    fileinput_ch.first().set { fileinput_val }
    r2_script_ch.first().set { r2_script_val }
    r3_script_ch.first().set { r3_script_val }
    chrnum_ch.first().set {chrnum_val}
    generat_ch.first().set {generat_val}
    corate_ch.first().set {corate_val}
    murate_ch.first().set {murate_val}
    nelit_ch.first().set {nelit_val}
    typesel_ch.first().set {typesel_val}
    typeco_ch.first().set {typeco_val}
    typeonepco_ch.first().set {typeonepco_val}
    ngenconv_ch.first().set {ngenconv_val}

    CREATEBATCHES_ch = CREATEBATCHES(fileinput_ch, r_script_ch)
    
    // Crear un canal para 'start' y 'end' usando flatMap para procesar el archivo generado por CREATEBATCHES
    compute_input_ch = CREATEBATCHES_ch.flatMap { path ->
        return file(path.toString()).readLines().collect { line ->
            def (start, end) = line.split(/\s+/)
            tuple(start.toInteger(), end.toInteger())
        }
    }

    // Usar cross para combinar cada par de start/end con los valores únicos de fileinput y r2_script
    ready_to_compute = compute_input_ch
                        .combine(fileinput_val)
                        .combine(r2_script_val)
                        .combine(chrnum_val)
                        .combine(generat_val)
                        .combine(corate_val)
                        .combine(murate_val)
                        .combine(nelit_val)
                        .combine(typesel_val)
                        .combine(typeco_val)
                        .combine(typeonepco_val)
                        .combine(ngenconv_val)
                        .map { val1, val2, fileinput, r2_script, chrnum, generat, corate, murate, nelit, typesel, typeco, typeonepco, ngenconv ->
                             tuple(fileinput, r2_script, val1, val2, chrnum, generat, corate, murate, nelit, typesel, typeco, typeonepco, ngenconv)
                        }

    //ready_to_compute.view{it}


    COMPUTE_ch = COMPUTE(ready_to_compute).GA_batch.collect()
    
    ANALYZE_result = ANALYZE(COMPUTE_ch, r3_script_val)
    

}


# nf-GENETIC

AN IMPLEMENTATION OF GARS GENETIC ALGORITHM IN NEXTFLOW

DEPENDENCIES:

-Singularity/3.10.2 or later 

-Nextflow/23.04.2 or later

-Java11 or later

INPUT: 

An SummarizedExperiment object stored in a .Rdata file (See the example stored in /data/)

USAGE:

Open GENETIC_GARS.nf in a text editor and adjust the cpus used in each step of the workflow depending on your computational resources. 

For basic use, the input variables can be modified within the file. Another way is to write the command in which the default values are displayed:

BASIC:

nextflow run GENETIC_GARS.nf

ADVANCED:

nextflow run GENETIC_GARS.nf --fileinput './data/OBJECT_SE.Rdata' --outdir "results" --chrnum 100 --generat 100 --corate 0.8 --murate 0.1 --nelit 2 --typesel "RW" --typeco "one.p" --typeonepco "II.quart" --ngenconv 250

NOTE:

To optimize the performance of your processes or analysis, I recommend first assessing the computational resources available on your system, such as RAM and CPU capacity. Then, consider the size and complexity of your dataset. 

If you need a more detailed explanation of the parameters, and the creation of the SummarizedExperiment object, please consult the GARS vignette.

https://bioconductor.org/packages/release/bioc/manuals/GARS/man/GARS.pdf






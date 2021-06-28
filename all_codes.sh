# Preprocessing of the raw reads
# 1. Quality control, FastQC program was downloaded from https://www.bioinformatics.babraham.ac.uk/projects/fastqc/
# For analysis of all files in the current directory *fastq.gz expression can be used. Resulting files have added ".html" at the end.
~/bin/FastQC/fastqc *fastq.gz --outdir=.

# 2. Adapter and quality trimming. bbduk from bbmap suite was used. 

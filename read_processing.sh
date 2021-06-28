# For convenience in some steps loops were used.

# Preprocessing of the raw reads
# 1. Quality control, FastQC program was downloaded from https://www.bioinformatics.babraham.ac.uk/projects/fastqc/
# For analysis of all files in the current directory *fastq.gz expression can be used. Resulting files have added ".html" at the end.
~/bin/FastQC/fastqc *fastq.gz --outdir=.

# Adapter and quality trimming. bbduk from bbmap suite was used. Packake can be downloaded from https://sourceforge.net/projects/bbmap/.
# After unpacking all scripts are ready to use.
# Trimming of files sequenced in paired-end mode. Following codes remove adapters as well bases with quality score less than 10.
for i in {4..6};
do ~/bin/bbmap/bbduk.sh -in=/home/mj/mybookliveduo/dane_old/HDS-4-6/data/151230_SND405_A_L008_HDS-${i}_R1.fastq.gz -in2=/home/mj/mybookliveduo/dane_old/HDS-4-6/data/151230_SND405_A_L008_HDS-${i}_R2.fastq.gz ref=~/bin/bbmap/resources/truseq.fa.gz,artifacts,phix ktrim=r k=23 mink=11 hdist=1 tbo tpe qtrim=r trimq=10  out1=hds${i}r1_clean.fastq.gz out2=hds${i}r2_clean.fastq.gz ;
done

# Trimming of files sequenced in single-end mode
for i in {34..39};
do ~/bin/bbmap/bbduk.sh -in=/home/mj/mybookliveduo/dane_old/HDS-34-39/data/170303_SND393_B_L007_HDS-${i}_R1.fastq.gz ref=~/bin/bbmap/resources/truseq.fa.gz,artifacts,phix ktrim=r k=23 mink=11 hdist=1 tbo tpe qtrim=r trimq=10 out=hds${i}_clean.fastq.gz ;
done

# Quality control, as in step 1.

# Genome indexing. bbmap script from the bbmap suite. Maize genome version 4 (Zea_mays.B73_RefGen_v4.dna.toplevel.fa.gz) was downloaded from ftp://ftp.gramene.org/pub/gramene/CURRENT_RELEASE/fasta/zea_mays/dna/
bbmap.sh ref=Zea_mays.B73_RefGen_v4.dna.toplevel.fa

# Mapping to B73 maize genome version 4. bbmap script from the bbmap suite.
# in case of amibiguously mapping reads position was assigned randomly.
for i in 4 5 6 7 8 9 10 11 12;
do  ~/bin/bbmap/bbmap.sh in=/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/reads_bbtrim/hds${i}r1_clean.fastq.gz path=/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/b73_2020/ outm=bbd4${i}.bam maxindel=20 ambig=random threads=24 -Xmx110g showprogress=250000 statsfile=stats${i}dnase4 covstats=covstat${i}dnase4 ;
done

# Quality control of bam files. bamqc program was used, avaliable from https://github.com/s-andrews/BamQC
# For analysis of all files in the current directory *.bam expression can be used. Resulting files have added ".html" at the end.
bamqc *.bam

# Filtering, only reads with MAPQ score at least 10 were retained
for i in {4..39};
do samtools view -@24 -bq10 bbd4${i}.bam -o bb${i}q10_4.bam;
done

# Removal of reads mapping to organellar DNA
# This step first recode binary alignment file (bam) to human-readable form (sam), next rows with reads mapping to mitochondrion "Mt" or plastid "Pt" were removed.
# Finally file was recoded to binary form and temporary files were removed.
for i in {4..39};
do samtools view -@24 -h bb${i}q10_4.bam > x.sam && sed '/Mt/d;/Pt/d' x.sam > x2.sam && samtools view -@24 -b x2.sam > bb${i}q10_4.bam && rm x.sam x2.sam; 
done

# Sorting and indexing
for i in {4..39};
do samtools sort -@24 -o bb${i}q10_4srt.bam bb${i}q10_4.bam -O bam -T temp && samtools index -@24 bb${i}q10_4srt.bam;
done

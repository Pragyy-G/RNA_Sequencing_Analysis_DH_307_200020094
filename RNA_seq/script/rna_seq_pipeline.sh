#!/bin/bash

SECONDS=0

#Change working directory
cd /root/rna_sequencing/

#STEP 1: Run Fastqc

fastqc -t 4 data/SRR17053033_1.fastq.gz data/SRR17053033_2.fastq.gz -o data/
fastqc -t 4 data/SRR17053036_1.fastq.gz data/SRR17053036_2.fastq.gz -o data/
fastqc -t 4 data/SRR17053038_1.fastq.gz data/SRR17053038_2.fastq.gz -o data/
fastqc -t 4 data/SRR17053043_1.fastq.gz data/SRR17053043_2.fastq.gz -o data/


#run trimgalore

trim_galore --paired -o data/trimmed_results/ data/SRR17053033_1.fastq.gz data/SRR17053033_2.fastq.gz
trim_galore --paired -o data/trimmed_results/ data/SRR17053036_1.fastq.gz data/SRR17053036_2.fastq.gz
trim_galore --paired -o data/trimmed_results/ data/SRR17053038_1.fastq.gz data/SRR17053038_2.fastq.gz
trim_galore --paired -o data/trimmed_results/ data/SRR17053043_1.fastq.gz data/SRR17053043_2.fastq.gz

echo "Trimming finished"
fastqc -t 4 data/trimmed_results/SRR17053033_1_val_1.fq.gz data/trimmed_results/SRR17053033_2_val_2.fq.gz -o data/trimmed_results
fastqc -t 4 data/trimmed_results/SRR17053036_1_val_1.fq.gz data/trimmed_results/SRR17053036_2_val_2.fq.gz -o data/trimmed_results
fastqc -t 4 data/trimmed_results/SRR17053038_1_val_1.fq.gz data/trimmed_results/SRR17053038_2_val_2.fq.gz -o data/trimmed_results
fastqc -t 4 data/trimmed_results/SRR17053043_1_val_1.fq.gz data/trimmed_results/SRR17053043_2_val_2.fq.gz -o data/trimmed_results

# Run Hisat2
# mkdirr HISAT2
# get the genome indices
# wget https://genome-idx.s3.amazonaws.com/hisat/grch38_genome.tar.gz| gzip your_file.fastq

hisat2 --verbose -q --rna-strandness R -x HISAT2/grch38/genome -1 data/trimmed_results/SRR17053033_1_val_1.fq.gz -2 data/trimmed_results/SRR17053033_2_val_2.fq.gz -p 4 -S HISAT2/SRR17053033_trimmed.sam
hisat2 --verbose -q --rna-strandness R -x HISAT2/grch38/genome -1 data/trimmed_results/SRR17053036_1_val_1.fq.gz -2 data/trimmed_results/SRR17053036_2_val_2.fq.gz -p 4 -S HISAT2/SRR17053036_trimmed.sam
hisat2 --verbose -q --rna-strandness R -x HISAT2/grch38/genome -1 data/trimmed_results/SRR17053038_1_val_1.fq.gz -2 data/trimmed_results/SRR17053038_2_val_2.fq.gz -p 4 -S HISAT2/SRR17053038_trimmed.sam
hisat2 --verbose -q --rna-strandness R -x HISAT2/grch38/genome -1 data/trimmed_results/SRR17053043_1_val_1.fq.gz -2 data/trimmed_results/SRR17053043_2_val_2.fq.gz -p 4 -S HISAT2/SRR17053043_trimmed.sam

samtools sort -o HISAT2/SRR17053033_trimd.bam HISAT2/SRR17053033_trimmed.sam
samtools sort -o HISAT2/SRR17053036_trimd.bam HISAT2/SRR17053036_trimmed.sam
samtools sort -o HISAT2/SRR17053038_trimd.bam HISAT2/SRR17053038_trimmed.sam
samtools sort -o HISAT2/SRR17053043_trimd.bam HISAT2/SRR17053043_trimmed.sam

featureCounts -S 2 -a hg38/gencode.v44.annotation.gtf -o quants/GSE189672_featurecounts.txt HISAT2/SRR17053033_trimd.bam HISAT2/SRR17053036_trimd.bam HISAT2/SRR17053038_trimd.bam HISAT2/SRR17053043_trimd.bam

duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed"


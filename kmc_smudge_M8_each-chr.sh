#!/bin/bash

WD=$1
chr=$2

### extract trimmed reads from one chromosome
module load samtools-1.11
DIR1=/jarvis/scratch/usr/munoz/Acipenser/alignment/finaloutput
samtools view $DIR1/M8_S8353_001_sorted_dedup_rg_real_rmopt.bam $chr | awk '{print "@"$1 "\n" $10 "\n" "+" "\n" $11}' | gzip -c >input/M8_"$chr"_trimmed.fastq.gz

### KMC
module load tbenavi1-KMC

kmc -k21 -m50G -t20 -ci1 -cs15000 $WD/input/M8_"$chr"_trimmed.fastq.gz kmcm8-"$chr" $WD
kmc_tools transform kmcm8-"$chr" histogram kmcm8-"$chr".hist -cx500000000

#Remove zero lines (decreases file size):
awk '{ if( $2 != 0 ){ print $0 } }' kmcm8-"$chr".hist > kmcm8.hist-"$chr".no0

### Smudgeplot
source /opt/miniconda3/bin/activate genomes
L=7 #$(smudgeplot.py cutoff kmcm8.hist.no0 L)
U=2000 #$(smudgeplot.py cutoff kmcm8.hist.no0 U)
echo $L $U

NAME=kmcm8-"$chr"

kmc_tools transform kmcm8-"$chr" -ci"$L" -cx"$U" reduce "$NAME"_L"$L"_U"$U"
smudge_pairs "$NAME"_L"$L"_U"$U" "$NAME"_L"$L"_U"$U"_coverages.tsv "$NAME"_L"$L"_U"$U"_pairs.tsv > "$NAME"_L"$L"_U"$U"_familysizes.tsv
smudgeplot.py plot -o Ac_naccarii_"$NAME" -t "Acipenser naccarii" "$NAME"_L"$L"_U"$U"_coverages.tsv

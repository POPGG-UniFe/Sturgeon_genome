#!/bin/bash

WD=/jarvis/scratch/usr/munoz/Acipenser/smudgeplot/each-chr
cd $WD
cat /jarvis/scratch/usr/munoz/Acipenser/alignment/GCF_010645085.1_ASM1064508v1_genomic.dict | grep "NC_" | tail -n +2 | head -n 59 | cut -f 2 | cut -d ":" -f 2 >chr.list
mkdir -p errors
mkdir -p input
cat chr.list | while read chr
do
sbatch --time=96:00:00 --nodes=1 --ntasks=1 --mem=10G -J $chr -e errors/kmc_smuge_$chr.e -o errors/kmc_smuge_$chr.o kmc_smudge_M8_each-chr.sh $WD $chr
done

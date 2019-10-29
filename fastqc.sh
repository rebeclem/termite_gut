#!/bin/bash
#SBATCH -J fastqc
#SBATCH -o fastqc.out
#SBATCH -e fastqc.err
#SBATCH -p defq
#SBATCH -n 16
#SBATCH -t 2-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=rebeccaclement@gwu.edu

module load fastQC

fastqc -o outfastqc */*

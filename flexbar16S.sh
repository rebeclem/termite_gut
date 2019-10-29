#!/bin/bash
#SBATCH -N 1
#SBATCH -t 06:00:00
#SBATCH -p defq,short,small-gpu
#SBATCH --array=1-58
#SBATCH -o flex.%A_%a.out
#SBATCH -e flex.%A_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=rebeccaclement@gwu.edu

name=$(sed -n "$SLURM_ARRAY_TASK_ID"p samps.txt)

#--- Start the timer
t1=$(date +"%s")

echo $name

module load flexbar/3.5.0

flexbar --threads 10 \
 --adapters ../refs/NexteraPE-PE.fa \
 --adapter-trim-end RIGHT \
 --adapter-min-overlap 7 \
 --pre-trim-left 15 \
 --max-uncalled 100 \
 --min-read-length 25 \
 --qtrim TAIL \
 --qtrim-format sanger \
 --qtrim-threshold 20 \
 --reads $(ls Analysis/$name/${name}*_R1_001.fastq.gz) \
 --reads2 $(ls Analysis/$name/${name}*_R2_001.fastq.gz) \
 --target Analysis/$name/flexcleaned


#---Complete job
t2=$(date +"%s")
diff=$(($t2-$t1))
echo "[---$SN---] ($(date)) $(($diff / 60)) minutes and $(($diff % 60)) seconds elapsed."
echo "[---$SN---] ($(date)) $SN COMPLETE."

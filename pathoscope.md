# Part 6 - Pathoscope

We will map to Pathoscope twice. First, targetting termite. We want to know how much termite "contamination" is in our samples - how many reads belong to human. Second, we will map to the bacterial databases.

You must be in the Analysis folder before calling any of the Pathoscope scripts.
```
cd Analysis
```
Replace the 1-91 in the array line with 1-12 for these samples.
### **_Mapping to Human_**
You will need the [`pathoscope_human.sh`](pathoscope_human.sh) file. This file is set up to run 25 samples. You can change this manually and then run `sbatch pathoscope_human.sh` or you can delete the line that says "#SBATCH --array=1-25" and run the following command.

```
sbatch -a 1-$(wc -l < ../samps.txt) ../scripts/pathoscope_human.sh
```

### **_Mapping to Bacteria_**
You will need the [`pathoscope_bacteria.sh`](pathoscope_bacteria.sh) file.
This file is set up to run 12 samples. You can change this manually and then run `sbatch pathoscope_human.sh` or you can delete the line that says "#SBATCH --array=1-12" and run the following command.
```
sbatch -a 1-$(wc -l < ../samps.txt) ../scripts/pathoscope_bacteria.sh
```

In both of these files you will see the same format:
1. Make a directory for the files.
2. Load the software needed.
3. Call PathoScope MAP
    - This maps the reads to the genomes in the databases that we have listed. It then filters out any reads that map *better* to any of the genomes in the filter databases that we have listed.
4. Call PathoScope ID
    - This assigns taxonomic ID numbers to all of the mapped reads.
5. Removes all of the unnecessary `sam` files, because `sam` files take up a lot of room (we're talking Terabytes worth of data room).

<br />

---
---

Once finished, you need to do one more thing. 
Run the following commands. This puts all the `tsv` files from each sample into folders and then downloads them. The `tsv` files are the output from PathoID that we will take into R to visualize.

Outside of your analysis folder, make directories called `bac` and `human`
```
mkdir bac
mkdir human
cd Analysis
cat ../samps.txt | while read f; do cp $f/human/pathoid-sam-report.tsv ../human/${f}_pathoid-sam-report.tsv ; echo $f; done
cat ../samps.txt | while read f; do cp $f/bac/pathoid-sam-report.tsv ../bac/${f}_pathoid-sam-report.tsv ; echo $f; done
```
From your computer, make a folder called `pathoscope_output`, and copy the files from your bac and human folders to this folder.
```
mkdir pathoscope_output
rsync -avh rebeccaclement@login.colonialone.gwu.edu:lustre/Meni/bac .
rsync -avh rebeccaclement@login.colonialone.gwu.edu:lustre/Meni/human .
```
>

Next step: [Count your pathoscope reads](count_ps_reads.md) 

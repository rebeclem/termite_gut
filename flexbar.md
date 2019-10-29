# QC using Flexbar

Before we can use PathoScope to map our reads to genomes, we first need to "clean" our reads. Now, we call it cleaning because here we remove low quality reads, low quality nucleotides, and any adapter sequences that were left behind by the Illumina processing software. This step is also referred to as trimming our reads.

### __In this step, we will clean our raw sequencing reads.__
<br />

You will need to put the adapter sequences that you used when library prepping your samples into a fasta file. Save adapter sequences for paired-end as `refs/adapters_PE.fa.`

* You can get an adapters file from trimmomatic for Nextera XT by navigating to where trimmomatic is located `module show trimmomatic` and then finding the file called [NexteraPE-PE.fa](NexteraPE-PE.fa).

<br />

Make sure your `samp.txt` is in the folder that contains Analysis, refs, and scripts before submitting [flexbar.sh](flexbar.sh). 

This script uses an array, which allows you to run the job on multiple samples at once if there are nodes available, instead of waiting for one to finish before the next one starts. You will notice a line at the beginning of `flexbar.sh` that says `#SBATCH --array=1-25`. This means that there are 25 files on our `samps.txt` file that we want to run it on. Change the number of files to however many you will be running it on.

Submit a job to Slurm to call Flexbar on the raw sequence files.
```
sbatch flexbar.sh
```

<br />

The default parameters I use are:

```
flexbar --threads 10 \
 --adapters refs/adapters_PE.fa \
 --adapter-trim-end RIGHT \
 --adapter-min-overlap 7 \
 --pre-trim-left 15 \
 --max-uncalled 100 \
 --min-read-length 25 \
 --qtrim TAIL \
 --qtrim-format sanger \
 --qtrim-threshold 20 \
 --reads $(read1) \
 --reads2 $(read2) \
 --target flexcleaned
 ```

 If you want to, you can change any of these parameters in the file `flexbar.sh`. You can also add parameter options. To see addition options that you can include call:
 
 ```
 module use /groups/cbi/shared/modulefiles
 module load flexbar/3.5.0
 flexbar -h
 ```
 This will give you a help menu that lists and explains all of the available trimming/filtering options. 


 See [Flexbar's manual](https://github.com/seqan/flexbar/wiki/Manual) for more help if need be.

<br />

 After finishing flexbar, you will now have 3 additional files in each of your directories inside Analysis:
 1. flexcleaned_1.fastq
 2. flexcleaned_2.fastq
 3. flexcleaned.log

 The first two are the cleaned read1 and read2 fastq files that will be used in subsequent applications (PathoScope). The `flexcleaned.log` will be used in Part 5 where you count the number of raw and cleaned reads. This will tell you how strigent your filtering was. Ideally you want to retain as much of your reads as possible, so if you see in Part 5 or in the `flexcleaned.log` that you only retained, say, about 75% of your reads, maybe you should try less strict filtering options. Unless, of course, you started with very dirty (unreliable, low quality, high adapter contamination,etc) data, then maybe 75% read retainment is alright.

 Understand your starting quality to see if the amount of reads you removed is reasonable.
 
 Look inside each of your .err and .out files (using `cat *`) to make sure you didn't have any errors. Then remove these files using `rm flex*`.
 
 Next step: run [fastQC](fastqc.md) using [this script](fastqcflexbar.sh) on your cleaned samples inside the `Analysis` folder

`sbatch ../scripts/fastqcflexbar.sh`

You will get two output files for each fastq files (total of 4 files):
1.  `flexcleaned_1_fastqc.html`
2.  `flexcleaned_1_fastqc.zip`
3.  `flexcleaned_2_fastqc.html`
4.  `flexcleaned_2_fastqc.zip`

<br />

Again, the `html` files are the ones that we are interested in. We're going to move all the `html` files into a directory so we can look at all the files at the same time.
```
# remember we're still in the Analysis folder
mkdir -p fastqc_cleaned
# For each .html file, copy over a file with the folder name and flexcleaned_1 or flesxcleaned_2
for f in *; do
   mv $f/flexcleaned_1*.html fastqc_cleaned/${f}_flexcleaned_1.html
   mv $f/flexcleaned_2*.html fastqc_cleaned/${f}_flexcleaned_2.html
done
```
Now download that folder to your computer with this command. This command needs to be excuted on your local computer (not within colonial one). I recommend opening up another tab on your terminal and then executing this command:
```
scp -r your_username@login.colonialone.gwu.edu:path/to/Analysis/fastqc_cleaned /local/dir
```
>You will need to replace a few things, same thing as above. As an example for you, I have used my path and username.
>
>| your_username | path/to/Analysis | local/dir |
>| --- | --- | --- |
>| rebeccaclement | /lustre/Meni/Analysis | ~/Documents/Meni/fastqc_flexbar/ |
>

<br />
<br />

All of the files can be opened up through Safari/Chrome/etc. (whatever internet browser you use). If you open the downloaded folder in your Finder (if on mac), you can select a file (so it is highlighted) and press the *space* button. A temporary window should show up with your results. Now you can press the *down arrow* and scroll through all the files relatively quickly.

See this [PDF](https://github.com/kmgibson/EV_konzo/blob/master/FastQC_Manual.pdf) explaining the FastQC results or this [website by the creators of FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) that also has explaination of the results. 
- The PDF was downloaded from the [University of Missouri sequencing core](https://dnacore.missouri.edu).

<br />

Finally, we need to remove unncessary files:
```
rm */flexcleaned*fastqc.zip
```
***
Next Step: [Count number of raw and cleaned reads](countreads.md)

## Copy files to /lustre/groups/cbi/Users/rclement/Rawdata

### Creating a directory for each sample.
For every file inside a folder that has a L001 and an R1, make an object samp that is the folder name. First the basename makes it so that you get rid of the outside folder. Then you take off the ending that matches -*-*.
Print the folder name and then make a directory that is called the sample name with a designated prefix. Run this without the mkdir to make sure it's running right.
* In this case you should end up with filenames called L935-Bec1
* Instead of basename, if you want to take out a small portion of something, you can also use `echo $f | cut -d"/" -f2` which will divide at the slash and then take the second part
* The ${f%%_*}; is essentially calling the file name and taking out the longest possible thing that includes _* in it.
* If you accidentally mess up and make a lot of empty directories `rmdir` will remove only empty directories
```
   for f in */*L001*R1*.gz; do 
   samp=$(basename $f); 
   samp=${samp%-*-*}; 
   echo $samp; 
   mkdir -p $samp; 
   done
```
If you type `ls`, you should see a directory for each of your samples.
### Moving all sequence files into sample directory.
Move all the files into the folders that match their directory.
```
for f in */*.gz; do 
samp=$(basename $f); 
samp=${samp%-*-*}; 
rsync -avh $f $samp; 
done
```
Each of your directories should now have 8 files that end with fastq.gz.
### Combining all NextSeq sequencing runs into a single fastq file
```
for d in *Bec*; 
  do samp=${d/-/_}; 
  cat $d/*R1*.fastq.gz > $d/${samp}_R1.fastq.gz; 
  cat $d/*R2*.fastq.gz > $d/${samp}_R2.fastq.gz; 
  echo $samp; 
  done
```
You should get a message saying that there are no .fastq.gz files or directories in the empty directories you emptied. When you finish you should have 10 total files in each directory.
Make sure that your files are the right sizes (the ones you made should be the totals of the R1s and R2s) using `ls -lh *Bec*`
### removes all the extra fastq files
```
rm *Bec*/*L00*.gz
```
Now you should have only two fastq.gz files in each directory.
### Get rid of dashes in filename
```
for d in *; do name=$d; newname=${name/-/_}; mv $d $newname; echo $newname; done
```
### Move folders into an analysis place
```
mv *Bec* ../../Analysis/
```
Now you should only have the directories in the folder you're in

***
## Setting up workspace

### Make directories for your references and scripts
```
mkdir refs
mkdir scripts
```

### Move into the analysis directory and put the directory names into a file called samp.txt
```
cd Analysis
ls -d * > ../samps.txt
```

### Set up reference databases
```
cd refs 
```

#### Human reference
```
for f in /lustre/groups/cbi/shared/References/Homo_sapiens/UCSC/hg38full/Sequence/Bowtie2Index/*.bt2;
 do
    ln -s $f
done
```
#### Bacteria references
```
for f in /lustre/groups/cbi/shared/Databases/NCBI_rep_genomes/latest/*.bt2;
do
    ln -s $f
done
```
### PhiX references -include this if you have PhiX in your samples (added during sequencing)
```
for f in /lustre/groups/cbi/shared/Databases/HMP/latest/phi*.bt2; do
    ln -s $f
done
```
Your refs folder should now have ~60 files that end with .bt2
You should also copy the scripts from here to your scripts folder
***
Next Step: [Perform FastQC](fastqc.md)

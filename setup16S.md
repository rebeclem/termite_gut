### Setting up 16S samples
This is basically the same setup but for the 16S dataset

* Make a directory in Rawdata (navigate to /groups/cbi/Users/rclement/Rawdata and use `mkdir termite_16S_2`)

* Upload 16S data from box to groups: Navigate to Box on a Mac, 
`rsync -avh 20190716_Clement_termitegut_16S_rerun-138622490/FASTQ_Generation_2019-07-19_08_31_23Z-190047880/ rebeccaclement@pegasus.colonialone.gwu.edu:/groups/cbi/Users/rclement/Rawdata/termite_16S_2`
* Copy data to glustre:
`rsync -avh * ~/glustre/Rawdata/termite_16S/`

## For screen sharing with the middle computer in the glass classroom at SEH
* Sign into vpn on to GW network
* Click command+space bar and search screen sharing
* The ID for the computer closest to door is vnc://128.164.161.53/
* Username is Crandall lab and Password is normal

### Creating a directory for each sample.
For every file inside a folder that has a L001 and an R1, make an object samp that is the folder name. First the basename makes it so that you get rid of the outside folder. Then you take off the ending that matches -*-*.
Print the folder name and then make a directory that is called the sample name with a designated prefix. Run this without the mkdir to make sure it's running right.
* In this case you should end up with filenames called L935-Bec1
* Instead of basename, if you want to take out a small portion of something, you can also use `echo $f | cut -d"/" -f2` which will divide at the slash and then take the second part
* The ${f%%_*}; is essentially calling the file name and taking out the longest possible thing that includes _* in it.
* If you accidentally mess up and make a lot of empty directories `rmdir` will remove only empty directories
* the `//-/_` replaces all `-` with `_`
```
   for f in */*L001*R1*.gz; do
   samp=$(basename $f);
   samp=${samp%-*-*};
   samp=${samp//-/_}; 
   mkdir -p $samp; 
   echo $samp;  
   done
```
If you type `ls`, you should see a directory for each of your samples.
### Moving all sequence files into sample directory.
Move all the files into the folders that match their directory.
```
for f in */*.gz; do
samp=$(basename $f);
samp=${samp%-*-*};
samp=${samp//-/_};
echo $samp;  mv $f $samp; done
```
Each of your directories should now have 2 files that end with fastq.gz.

You should get a message saying that there are no .fastq.gz files or directories in the empty directories you emptied. When you finish you should have 10 total files in each directory.
Make sure that your files are the right sizes (the ones you made should be the totals of the R1s and R2s) using `ls -lh *Bec*`
### removes all the empty directories
```
rmdir *
```
Now you should have only two fastq.gz files in each directory.
### Get rid of dashes in filename
```
for d in */*; do name=$d; newname=${name//-/_}; mv $d $newname; done
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

### Now we are going to move these into r to do dada2 following this tutorial. https://benjjneb.github.io/dada2/tutorial.html
First we need to rename the samples and move them into one folder that I made called dada2
```
for d in */*.fastq; do name=$d;  newname=${name/"/"/_}; cp $name ../dada2/$newname; echo $newname; done
```
Now from my termite microbiome folder on my computer, copy these files over.
`rsync -avh rebeccaclement@log001.colonialone.gwu.edu:/GWSPH/home/rebeccaclement/glustre/termite_16S/dada2 .`


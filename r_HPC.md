# Here, I will be showing how to run r with the dada2 pipeline on the command line.

1) First, copy the 16S data from ggroups. `rsync -avh termite_16S/ /lustre/groups/cbi/Users/rclement/termite_16S`
2) Next, allocate a node with `salloc -n 1 -p short -t 300` and load r with `module load R`

3) Make a conda environment for R (I think you only need to do this once) `conda create -n r_env r-essentials r-base`
4) Activate your environment: `conda activate r_env`
5) Or use this: For reference you can use R in Pegasus with conda, just run `conda install -c r r` and then when you do install a package you have to select a repo ie install.packages('dada2', repos='http://cran.us.r-project.org') 

None of these things work. It says I don't have write permissions?



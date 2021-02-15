# Here, I will be showing how to run r with the dada2 pipeline on the command line.

1) First, copy the 16S data from ggroups. `rsync -avh termite_16S/ /lustre/groups/cbi/Users/rclement/termite_16S`
2) Next, allocate a node with `salloc -n 1 -p short -t 300` and load r with `module load R`

### Making reference databases

Here is the [16S database](http://www.termites.de/databases/DictDb/) that is from Andreas Brune

Here is the termite genome from [Zootermopsis nevadensis](https://www.ncbi.nlm.nih.gov/nuccore/AUST00000000) from [this paper](https://www.nature.com/articles/ncomms4636).

Here is the termite genome from [Macrotermes natalensis](https://www.ncbi.nlm.nih.gov/sra?term=SRA069856) from [this paper](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4209977/#d35e678)

1) find a script that builds a dabase

umask 0022 changes permissions

look in /groups/cbi/Databases/Genomes/scripts/

make a list of the accession numbers. Run pull_seqs_from_acc.py to pull the sequences from NCBI.

It has to be the right version of python. and you have to `pip install biopython`. 

Look up what split does. 

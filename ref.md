### Making reference databases

Here is the [16S database](http://www.termites.de/databases/DictDb/) that is from Andreas Brune

Here is the termite genome from [Zootermopsis nevadensis](https://www.ncbi.nlm.nih.gov/nuccore/AUST00000000) from [this paper](https://www.nature.com/articles/ncomms4636).

Here is the termite genome from [Macrotermes natalensis](https://www.ncbi.nlm.nih.gov/sra?term=SRA069856) from [this paper](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4209977/#d35e678). This is its [mitochondria](https://www.ncbi.nlm.nih.gov/nuccore/NC_025522).

Termite mitochondrial genome from [Nasutitermes exitiosus](https://www.ncbi.nlm.nih.gov/Traces/wgs/CEME01?display=contigs)

Here is the link to [Cryptotermes secundus](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA381866).

Here are the manual gene annotations from Z. nev and M. nat. https://datadryad.org/stash/dataset/doi:10.5061/dryad.51d4r

1) find a script that builds a dabase

umask 0022 changes permissions

look in /groups/cbi/Databases/Genomes/scripts/

make a list of the accession numbers. Run pull_seqs_from_acc.py to pull the sequences from NCBI.

It has to be the right version of python. and you have to `pip install biopython`. 

Look up what split does. 


## To make the Nasutitermes exitiosus database:
First I downloaded the list of accessions [from NCBI](https://www.ncbi.nlm.nih.gov/Traces/wgs/CEME01?display=contigs).

Then I got out just the list of accessions:
awk '{print $2}' CEME01_contigs.tsv > nasExi.txt
Then I wanted to take off the .1s
cat nasExi.txt | cut -d"." -f1 > nasExit.txt

Now I'm going to upload this to pegasus
`copystuff nasExit.txt /groups/cbi/Databases/Genomes/References/Nasutitermes_exitiosus`

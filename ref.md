### Making reference databases

Here is the [16S database](http://www.termites.de/databases/DictDb/) that is from Andreas Brune

Here is the termite genome from [Zootermopsis nevadensis](https://www.ncbi.nlm.nih.gov/nuccore/AUST00000000) from [this paper](https://www.nature.com/articles/ncomms4636).

Here is the termite genome from [Macrotermes natalensis](https://www.ncbi.nlm.nih.gov/sra?term=SRA069856) from [this paper](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4209977/#d35e678). This is its [mitochondria](https://www.ncbi.nlm.nih.gov/nuccore/NC_025522).

Termite mitochondrial genome from [Nasutitermes exitiosus](https://www.ncbi.nlm.nih.gov/Traces/wgs/CEME01?display=contigs)

Here is the link to [Cryptotermes secundus](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA381866).

Here are the manual gene annotations from Z. nev and M. nat. https://datadryad.org/stash/dataset/doi:10.5061/dryad.51d4r

1) find a script that builds a database

umask 0022 changes permissions

look in /groups/cbi/Databases/Genomes/scripts/

make a list of the accession numbers. The first line needs to be the first accession number, not the. Run pull_seqs_from_acc.py to pull the sequences from NCBI. You have to have python 3 to run it. (module load python 3).] First line actually has to be an accession. 

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
Using vim, remove the first line that says "accession".
`module load python3`
`python ../../scripts/nasute_fasta_from_acc.py --email rebeccaclement@gwu.edu nasExit.txt > nasute_out.fasta`

Now that I have this file, I need to use bowtie to make it into a database. First you have to make sure it's in the right format with ti numbers first. 
Use the script /groups/cbi/Databases/Genomes/scripts/build_nasute.sh

I need to change the tid in scripts/nasute_fasta_from_acc.py to whatever the nasutitermes tid is. 


start in archive. 
seqIO is your best friend. It allows you to input and output fasta files. `from Bio import SeqIO`
load fasta into a list
.id shows you the name
.seq shows you the sequence
OUr sequence has U's instead of T's. We need to change that.
Make a dictionary that has keys and values. 
for line in open(filename, "r") # r means read. strip off , and ". 
back_transcribe() might be able to turn Us to Ts. 
You need to change it so it has this format: >ti|1335r|gi|0|ref|something|
What I need to do: decide if I want NAs or not. Build the database I want with bowtie.
Keylie will work on fixing script and put in and rewrite output.
I will put R script in. 
when I'm done I can put bowtie2 indexes into bowtie 2. Move the fasta file into wholegenomeFasta
Use the same script as I used on BowTie2 for the other one. 

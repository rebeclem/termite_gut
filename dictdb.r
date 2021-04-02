# This file is to fix up the dictdb dataset
#Rebecca Clement
# April 2, 2021

#Set working directory
setwd("~/Box/Clement_TermiteGut_16S_0108/refs/")
#First take a look at other references. 
silva1<-readDNAStringSet("silva_nr99_v138_train_set.fa.gz")
silva2<-readDNAStringSet("silva_nr99_v138_wSpecies_train_set.fa.gz")
silva3<-readDNAStringSet("silva_species_assignment_v138.fa.gz")

# Fix fasta file to have the right format. Don't have to do this every time. We already made the fasta DictDb_names.fasta
ref.fa<-readDNAStringSet("../ref/refs/DictDb_v3.fasta")
# read in csv
taxtsv<-read.table("../ref/refs/DictDb_v3.taxonomy")
# Add the name to the end of the taxonomy
taxname<-paste(taxtsv$V2,taxtsv$V1,";")
#remove white spaces
taxtsv$newV2<-gsub(" ", "", taxname, fixed = TRUE)
# Change the rownames of the fasta file to taxtsv$V2
str(ref.fa) #Class: DNAStringSet
length(ref.fa) #55732
str(taxtsv) #55732 variables
ref.fa[7178] #make sure these variables are the same
taxtsv[7178,"newV2"]
names(ref.fa)<-taxtsv$newV2
writeXStringSet(ref.fa, "../ref/refs/DictDb_names.fasta",format="fasta")
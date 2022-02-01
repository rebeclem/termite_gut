# This file is to fix up the dictdb dataset (https://drive.google.com/file/d/0B5NJB7U2TQKNVEZneUhFODZFdmc/view)
#Rebecca Clement
# began April 24,2021
# last updated Jan 1, 2022

#https://github.com/jonathanylin/16S_database_formatting_DADA2
# This website shows a way to use the taxonomy files given here.

#Load libraries
library(stringr)
library(dplyr)
setwd("~/Box/termite_microbiome/bacterial_refs")
fasta<-read.table("DictDb_v3.fasta")
taxonomy<-read.table("DictDB_V3_modified.taxonomy")
head(fasta)
# make a new dataframe with same number of rows and columns as taxonomy file
combined<-select(taxonomy,V1)
combined$V1<-NA
combined$V2<-NA

# This loop goes through taxonomy and taxa files and pastes matching taxa id with a ">" into new dataframe "combined", pastes matching sequence to second column, should take about 1 hour.
for (i in taxonomy$V1) {
  for (ii in fasta$V1) {
    if (i == ii) {
      combined$V1[which(taxonomy$V1 == i)] = paste(">Bacteria;", taxonomy$V2[which(taxonomy$V1 == i)], sep = "")
      R = which(fasta$V1 == ii) + 1
      combined$V2[which(taxonomy$V1 == i)] = paste(fasta$V1[R], sep = "")
    }
  }
}
# Combine two columns into a fasta-ready format
combined_fasta <- do.call(rbind, lapply(seq(nrow(combined)), function(i) t(combined[i, ])))

head(combined_fasta)
write.table(combined_fasta, "DictDB_DADA2_FINAL.fasta", row.names = FALSE, col.names = FALSE, quote = FALSE)

# First stuff I did--I think I got Bryan to help me.
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
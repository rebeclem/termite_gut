# This is for Caroline to run dada2 on the second dataset on my termite microbiome samples
# Rebecca Clement March 5, 2021


#first install dada2 https://benjjneb.github.io/dada2/dada-installation.html
#install.packages("devtools")
library("devtools")
#devtools::install_github("benjjneb/dada2", ref="v1.16") # change the ref argument to get other versions. type 1 updates. type yes.Then you have to restart r, and dada2 should work
library("dada2")
library("seqinr")

library("Biostrings")
library(phyloseq); packageVersion("phyloseq")
library('ggplot2')
#you might have to restart after you install dada2 for it to work - becca's note
# for documentation use this - becca's note
help(package="dada2")
?derepFastq
?dada
getwd()
setwd("~/Box/termite_microbiome/")
# Here is tutorial https://benjjneb.github.io/dada2/tutorial.html mixed with this one for big data: https://benjjneb.github.io/dada2/bigdata_paired.html
path2 <- "cleaned_reads/cleaned_set2" # CHANGE ME to the directory containing the fastq files after unzipping.
list.files(path2)

# Forward and reverse fastq filenames have format: SAMPLENAME_R1_001.fastq and SAMPLENAME_R2_001.fastq
fnFs2 <- sort(list.files(path2, pattern="_flexcleaned_1.fastq", full.names = TRUE))
fnRs2 <- sort(list.files(path2, pattern="_flexcleaned_2.fastq", full.names = TRUE))
# Extract sample names, assuming filenames have format: SAMPLENAME_XXX.fastq
# we want to take just the BEC portion.
sample.names2 <- sapply(strsplit(basename(fnFs2), "_"), `[`, 2)
# note: the files did not have an F, so are all of these reverse? the only differentiation was R1 and R2.
# i designated R1 as forward and R2 as reverse, but I do not know if this is an accurate representation 
# asked Becca, she said that is correct 

plotQualityProfile(fnFs2[1:20])
plotQualityProfile(fnFs2[21:40])
plotQualityProfile(fnFs2[41:60])
plotQualityProfile(fnRs2[1:20])
#  quality scores for reverse reads seem to deteriorate more quickly than forward read quality scores

#filter and trim
# Place filtered files in filtered/ subdirectory - for this set, it is under " filtered"  under " dada2files" 
filtFs2 <- file.path(path2, "filtered", paste0(sample.names2, "_F_filt.fastq.gz"))
filtRs2 <- file.path(path2, "filtered", paste0(sample.names2, "_R_filt.fastq.gz"))

names(filtFs2) <- sample.names2
names(filtRs2) <- sample.names2

filtout2 <- filterAndTrim(fnFs2, filtFs2, fnRs2, filtRs2, truncLen=c(270,150),
                         maxN=0, maxEE=c(2,2), truncQ=2, rm.phix=TRUE,
                         compress=TRUE, multithread=TRUE) # On Windows set multithread=FALSE

  # takes ~20 minutes 
# I already did this on the other computer so I"m skipping this step. 
filtout2 <- file.path("cleaned_reads/cleaned_set2/filtered/")
head(filtout2)

#learn error rates
errF2 <- learnErrors(filtFs2,nbases=1000000, multithread=TRUE)
# this step is taking a veryyyyy long time
# i think it finished!!! 
errR2 <- learnErrors(filtRs2, nbases=1000000,multithread=TRUE)
#this also takes a long time 

#Visualize estimated error rates
plotErrors(errR2, nominalQ=TRUE)
plotErrors(errF2,nominalQ = TRUE)
### added from big data paired end - becca's note
# Sample inference and merger of paired-end reads
mergers2 <- vector("list", length(sample.names2))
  # i don't think this is creating what we want to create  
names(mergers2) <- sample.names2


# THIS MIGHT BE A REALLLY REALLY BAD IDEA BUT ILL TRY IT (the next 2 functions are from the dada2 tutorial but they were not on this project until i added them just now)
dadaFs2 <- dada(filtFs2, err=errF2, multithread=TRUE)
dadaRs2 <- dada(filtRs2, err=errR2, multithread=TRUE)
# OKay well those didn't run anyway because " Some of the filenames provided do not exist. This may have happened because some samples had zero reads after filtering." 
  # think the issues I'm having with other functions have to do with the fact that some samples have no reads


for(sam in sample.names2[6:73]) {
  cat("Processing:", sam, "\n")
    derepF2 <- derepFastq(filtFs2[[sam]])
    ddF2 <- dada(derepF2, err=errF2, multithread=TRUE)
    derepR2 <- derepFastq(filtRs2[[sam]])
    ddR2 <- dada(derepR2, err=errR2, multithread=TRUE)
    merger2 <- mergePairs(ddF2, derepF2, ddR2, derepR2)
    mergers2[[sam]] <- merger2 
}

  #this is going to take a long time (~ 3-5 minutes per BEC###)
  # something is wrong here - it says not all files exist - I think something is off with sam
    # just kidding it is willing to run now 
rm(derepF2); rm(derepR2)


# Construct sequence table and remove chimeras
seqtab2 <- makeSequenceTable(mergers2)
saveRDS(seqtab2, "../termite_microbiome/Dada2/outfiles/seqtab_set2.rds") # CHANGE ME to where you want sequence table saved


#apply sample inference algorithm
#dadaFs2 <- dada(filtFs2, err=errF2, multithread=TRUE)
#dadaRs2 <- dada(filtRs2, err=errR2, multithread=TRUE)

#inspect dada-class objects
#dadaFs2[[1]]
#dadaRs2[[1]]

#merge paired reads
#mergers2 <- mergePairs(dadaFs2, filtFs2, dadaRs2, filtRs2, verbose=TRUE)
# Inspect the merger data.frame from the first sample
head(mergers2[[1]])

#construct sequence table
#seqtab2 <- makeSequenceTable(mergers2)

seqtab2 <- readRDS("../termite_microbiome/Dada2/outfiles/seqtab_set2.rds")
  # since the previous function did not work 
dim(seqtab2) #73 x 39879

# Inspect distribution of sequence lengths
table(nchar(getSequences(seqtab2))) # almost all are exactly 255 (47127 of them)
#remove chimeras. Chimeras are artifact sequences formed by two or more biological sequenes incorrectly joined together.
seqtab.nochim2 <- removeBimeraDenovo(seqtab2, method="consensus", multithread=TRUE, verbose=TRUE) #11:37
dim(seqtab.nochim2) #73 x 29757
#what percent of samples remain
sum(seqtab.nochim2)/sum(seqtab2) #78.2%
saveRDS(seqtab.nochim2, "../termite_microbiome/Dada2/outfiles/seqtab.nochim_set2.rds")

#track reads through pipeline
getN2 <- function(x) sum(getUniques(x))
track2 <- cbind(filtout2, sapply(dadaFs2, getN2), sapply(dadaRs2, getN2), sapply(mergers2, getN2), rowSums(seqtab.nochim2))
# If processing a single sample, remove the sapply calls: e.g. replace sapply(dadaFs, getN) with getN(dadaFs)
colnames(track2) <- c("input", "filtered", "denoisedF", "denoisedR", "merged", "nonchim")
rownames(track2) <- sample.names2
head(track2)

# Fix fasta file to have the right format
ref.fa2<-readDNAStringSet("../ref/refs/DictDb_v3.fasta")
  # warning message: "ignored 15615245 invalid one-letter sequence codes" 
    # i think that is a lot. Will that be an issue? 

# read in csv
taxtsv2<-read.table("../ref/refs/DictDb_v3.taxonomy")
# Add the name to the end of the taxonomy
taxname2<-paste(taxtsv2$V2,taxtsv2$V1,";")
#remove white spaces
taxtsv2$newV2<-gsub(" ", "", taxname2, fixed = TRUE)
# Change the rownames of the fasta file to taxtsv$V2
str(ref.fa2) #Class: DNAStringSet
length(ref.fa2) #55732
str(taxtsv2) #55732 variables
ref.fa2[7178] #make sure these variables are the same
taxtsv2[7178,"newV2"]
names(ref.fa2)<-taxtsv2$newV2
write.fasta(seq(ref.fa2), names(ref.fa2), "../ref/refs/DictDb_names.fasta")

# Assign taxonomy with our database
tax2 <- assignTaxonomy(seqtab.nochim2, "../ref/refs/DictDb_names.fasta", multithread=TRUE)
  # error message and warning message 
    # this seems to be resolved now - started processing  
#try with the silva database
tax_silva2 <- assignTaxonomy(seqtab.nochim2, "../MiSeq_SOP 2/silva_nr99_v138_train_set.fa.gz", multithread=TRUE)
  # i completed this step

rownames(seqtab.nochim2)
dim(seqtab.nochim2)
summary(colSums(seqtab.nochim2))
sample(getSequences(seqtab.nochim2), 10)


# Add species
tax2 <- addSpecies(tax2, "../ref/")
  # takes a long time (6+ hours)

# Let's also do it with the ones without chimeras
tax_chim2 <-assignTaxonomy(seqtab2,"../ref/refs/DictDb_names.fasta", multithread=TRUE)
 
# Write to disk
saveRDS(seqtab2, "../outfiles/seqtab_final2.rds") # CHANGE ME to where you want sequence table saved
saveRDS(tax2, "../outfiles/tax_final2.rds") # CHANGE ME ..
saveRDS(tax_silva2, "../outfiles/tax_silva2.rds")


# Read in our csv metadata file
termite_meta2 <-read.csv("../16S_metadata_updated.csv",header = TRUE, sep = ",")
  # this includes the entire metadata instead of the termite_ID's starting at BEC000252, will this be an issue? 
head(termite_meta2)
  # starts 
samples.out2 <- rownames(seqtab.nochim2)
rownames(termite_meta2)<-termite_meta2[,1]

tax_silva2 <- readRDS("../outfiles/tax_silva2.rds")

ps2 <- phyloseq(otu_table(seqtab.nochim2, taxa_are_rows=FALSE), 
                sample_data(termite_meta2), 
                tax_table(tax_silva2))
ps2 <- prune_samples(sample_names(ps2) != "Mock", ps2) # Remove mock sample
# use short names for asvs
dna2 <- Biostrings::DNAStringSet(taxa_names(ps2))
names(dna2) <- taxa_names(ps2)
ps2 <- merge_phyloseq(ps2, dna2)
taxa_names(ps2) <- paste0("ASV", seq(ntaxa(ps2)))
ps2

#visualize alpha diversity
plot_richness(ps2, x="Species", measures=c("Shannon", "Simpson"), color="Site")

# Transform data to proportions as appropriate for Bray-Curtis distances
ps.prop2 <- transform_sample_counts(ps2, function(otu) otu/sum(otu))
ord.nmds.bray2 <- ordinate(ps.prop2, method="NMDS", distance="bray")
plot_ordination(ps.prop2, ord.nmds.bray2, color="Species", title="Bray NMDS")
# We see three distinct clusters by species
top20_2 <- names(sort(taxa_sums(ps2), decreasing=TRUE))[1:20]
ps.top20_2 <- transform_sample_counts(ps2, function(OTU2) OTU2/sum(OTU2))
ps.top20_2 <- prune_taxa(top20_2, ps.top20_2)
plot_bar(ps.top20_2, x="Species", fill="Family") + facet_wrap(~Species, scales="free_x")
  # i am having the same issue we saw previously where there is one giant black column 

plot_bar(ps.top20_2, x="Species", fill="Genus") + facet_wrap(~Species, scales="free_x")
  # same with genus 

plot_bar(ps.top20_2, x="Species", fill="Order") + facet_wrap(~Species, scales="free_x")
  # same with order

plot_bar(ps.top20_2, x="Species", fill="Class") + facet_wrap(~Species, scales="free_x")
  # same with class

plot_bar(ps.top20_2, x="Species", fill="Kingdom") + facet_wrap(~Species, scales="free_x")
  #same with kingdom 
# it is M_serratus every time 

plot_bar(ps.top20_2, x="Site", fill="Genus") + facet_wrap(~Species, scales="free_x")
  # this looks a lttle better, but still M_serratus is the only one with anything there 

plot_bar(ps.top20_2, x="Habitat", fill="Family") + facet_wrap(~Species, scales="free_x")


plot_ordination(ps.prop2, ord.nmds.bray2, color="Cluster", title="Bray NMDS")
plot_ordination(ps.prop2, ord.nmds.bray2, color="Habitat", title="Bray NMDS")
plot_ordination(ps.prop2, ord.nmds.bray2, color="Site", title="Bray NMDS")

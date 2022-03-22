# This is me starting to try to run dada2 on my termite microbiome samples
# Rebecca Clement Feb 15, 2021

#first install dada2 https://benjjneb.github.io/dada2/dada-installation.html
#install.packages("devtools")
library("devtools")
#devtools::install_github("benjjneb/dada2", ref="v1.16") # change the ref argument to get other versions. type 1 updates. type yes.Then you have to restart r, and dada2 should work
library("dada2")
library("seqinr")

library("Biostrings")
library(phyloseq); packageVersion("phyloseq")
library('ggplot2')
#you might have to restart after you install dada2 for it to work
# for documentation use this
help(package="dada2")
?derepFastq
?dada
setwd('~/Desktop/Becca/termite_16S/dada2/')

# Here is tutorial https://benjjneb.github.io/dada2/tutorial.html mixed with this one for big data: https://benjjneb.github.io/dada2/bigdata_paired.html
path <- "../dada2/" # CHANGE ME to the directory containing the fastq files after unzipping.
list.files(path)

# Forward and reverse fastq filenames have format: SAMPLENAME_R1_001.fastq and SAMPLENAME_R2_001.fastq
fnFs <- sort(list.files(path, pattern="_flexcleaned_1.fastq", full.names = TRUE))
fnRs <- sort(list.files(path, pattern="_flexcleaned_2.fastq", full.names = TRUE))
# Extract sample names, assuming filenames have format: SAMPLENAME_XXX.fastq
# we want to take just the BEC portion.
sample.names <- sapply(strsplit(basename(fnFs), "_"), `[`, 2)

#visualize quality
plotQualityProfile(fnFs[1:20])
plotQualityProfile(fnFs[21:40])
plotQualityProfile(fnFs[41:60])
plotQualityProfile(fnRs[1:20])
plotQualityProfile(fnRs[21:40])
plotQualityProfile(fnRs[41:60])

#The forward reads are generally good until 270. The reverse look less good. Should probably be cut around 150. 

#filter and trim
# Place filtered files in filtered/ subdirectory
filtFs <- file.path(path, "filtered", paste0(sample.names, "_F_filt.fastq.gz"))
filtRs <- file.path(path, "filtered", paste0(sample.names, "_R_filt.fastq.gz"))
names(filtFs) <- sample.names
names(filtRs) <- sample.names

filtout <- filterAndTrim(fnFs, filtFs, fnRs, filtRs, truncLen=c(270,150),trimLeft=15,trimRight=15, maxN=0, maxEE=c(2,2), truncQ=2, rm.phix=TRUE,compress=TRUE, multithread=TRUE) # On Windows set multithread=FALSE
  # 35, 30, 25, and 20 would not work, all got warning messages that none of the reads passed the filter 
head(filtout)


#learn error rates. These take a really long time.
errF <- learnErrors(filtFs, multithread=TRUE) 
errR <- learnErrors(filtRs, multithread=TRUE)

#Visualize estimated error rates
plotErrors(errR, nominalQ=TRUE)
plotErrors(errF,nominalQ = TRUE)
### added from big data paired end
# Sample inference and merger of paired-end reads
mergers <- vector("list", length(sample.names))
names(mergers) <- sample.names
# This for loop takes a long time
for(sam in sample.names) {
  cat("Processing:", sam, "\n")
  derepF <- derepFastq(filtFs[[sam]])
  ddF <- dada(derepF, err=errF, multithread=TRUE)
  derepR <- derepFastq(filtRs[[sam]])
  ddR <- dada(derepR, err=errR, multithread=TRUE)
  merger <- mergePairs(ddF, derepF, ddR, derepR)
  mergers[[sam]] <- merger                                   
}
 rm(derepF); rm(derepR)

# Construct sequence table and remove chimeras
seqtab <- makeSequenceTable(mergers)
saveRDS(seqtab, "../../outfiles/seqtab_BEC001_BEC0057.rds") # CHANGE ME to where you want sequence table saved
  # (caroline) i am so dumb and forgot to change this to trimmed_outfiles so i will need to run up until here again wiht the old parameters and save this to outfiles 

###
#apply sample inference algorithm
#dadaFs <- dada(filtFs, err=errF, multithread=TRUE)
#dadaRs <- dada(filtRs, err=errR, multithread=TRUE)

#inspect dada-class objects
#dadaFs[[1]]
#dadaRs[[1]]

#merge paired reads
#mergers <- mergePairs(dadaFs, filtFs, dadaRs, filtRs, verbose=TRUE)
  # takes several minutes 
# Inspect the merger data.frame from the first sample
head(mergers2[[1]])

#construct sequence table
#seqtab <- makeSequenceTable(mergers)
dim(seqtab) #58x63820

# Inspect distribution of sequence lengths
table(nchar(getSequences(seqtab))) # Most are exactly 270 long. A few are above 330.
#remove chimeras
seqtab.nochim <- removeBimeraDenovo(seqtab, method="consensus", multithread=TRUE, verbose=TRUE) # this one takes 2-3 min
dim(seqtab.nochim) #58x41379
  # 15: 58 x 38155
#what percent of samples remain
sum(seqtab.nochim)/sum(seqtab) #72%
  # 15: 72%

#track reads through pipeline
getN <- function(x) sum(getUniques(x))
track <- cbind(filtout, sapply(dadaFs, getN), sapply(dadaRs, getN), sapply(mergers, getN), rowSums(seqtab.nochim))
# If processing a single sample, remove the sapply calls: e.g. replace sapply(dadaFs, getN) with getN(dadaFs)
colnames(track) <- c("input", "filtered", "denoisedF", "denoisedR", "merged", "nonchim")
rownames(track) <- sample.names
head(track)

track <- as.data.frame(track)
write.table(track, file = "outfiles/tracking/april2021_tracking.csv" , sep = ",")


# Assign taxonomy with our database
tax_dict <- assignTaxonomy(seqtab.nochim, "../../ref/refs/DictDb_names.fasta", multithread=TRUE)
  # takes a day at least
#try with the silva database
tax_silva <- assignTaxonomy(seqtab.nochim, "../MiSeq_SOP 2/silva_nr99_v138_train_set.fa.gz", multithread=TRUE)
  # several hours
# Add species
tax_dict <- addSpecies(tax_dict, "../ref/")
  # skipped - path issue - should the DictDb be there? 
# Let's also do it with the ones without chimeras
tax_chim<-assignTaxonomy(seqtab,"../ref/refs/DictDb_names.fasta", multithread=TRUE)
  # takes at least a day 
# Write to disk
saveRDS(seqtab, "../trimmed_outfiles/seqtab.rds") # CHANGE ME to where you want sequence table saved
saveRDS(tax_dict, "../trimmed_outfiles/tax_dict.rds") # CHANGE ME ..
saveRDS(tax_silva, "../trimmed_outfiles/tax_silva.rds")
saveRDS(seqtab.nochim, "trimmed_outfiles/seqtab.nochim.rds")

seqtab<-readRDS("../trimmed_outfiles/seqtab.rds")
tax_dict<-readRDS("../trimmed_outfiles/tax_dict.rds")
tax_silva<-readRDS("../trimmed_outfiles/tax_silva.rds")
seqtab.nochim <-readRDS("../trimmed_outfiles/seqtab.nochim.rds")

# Combine seqtab.nochim from both runs.
st.all <- mergeSequenceTables(seqtab.nochim, seqtab.nochim2)
dim(st.all) #131 x 76196
  # 15: 131 x 73755
# Remove chimeras
seqtab_all <- removeBimeraDenovo(st.all, method="consensus", multithread=TRUE) #takes a few minutes
# Assign taxonomy
tax_all_silva <- assignTaxonomy(seqtab_all, "../MiSeq_SOP 2/silva_nr99_v138_wSpecies_train_set.fa.gz", taxLevels = c("Kingdom", "Phylum", "Class",
                                                                                                                     "Order", "Family", "Genus", "Species"), multithread=TRUE)  #takes at least 8 hours
  
tax_all_dictdb<-assignTaxonomy(seqtab_all, "../ref/refs/DictDb_names.fasta", taxLevels = c("Phylum", "Class",
                                                                                           "Order", "Family", "Genus", "Species"), multithread=TRUE) 
  # i don't even want to know how long this takes (a long time)
# Write to disk
saveRDS(seqtab_all, "../trimmed_outfiles/seqtab_all.rds") # CHANGE ME to where you want sequence table saved
seqtab_all<-readRDS("../trimmed_outfiles/seqtab_all.rds")
saveRDS(tax_all_silva, "../trimmed_outfiles//tax_all_silva.rds") # CHANGE ME ...
saveRDS(tax_all_dictdb,"../trimmed_outfiles/tax_all_dictdb.rds")


# Read in our csv metadata file
termite_meta<-read.csv("../16S_metadata.csv",header = TRUE, sep = ",")
head(termite_meta)
samples.out <- rownames(seqtab.nochim)
rownames(termite_meta)<-termite_meta[,1]

ps <- phyloseq(otu_table(seqtab.nochim, taxa_are_rows=FALSE), 
               sample_data(termite_meta), 
               tax_table(tax_silva))
ps <- prune_samples(sample_names(ps) != "Mock", ps) # Remove mock sample
# use short names for asvs
dna <- Biostrings::DNAStringSet(taxa_names(ps))
names(dna) <- taxa_names(ps)
ps <- merge_phyloseq(ps, dna)
taxa_names(ps) <- paste0("ASV", seq(ntaxa(ps)))
ps

#visualize alpha diversity
plot_richness(ps, x="Species", measures=c("Shannon", "Simpson"), color="Site")

# Transform data to proportions as appropriate for Bray-Curtis distances
ps.prop <- transform_sample_counts(ps, function(otu) otu/sum(otu))
ord.nmds.bray <- ordinate(ps.prop, method="NMDS", distance="bray")
plot_ordination(ps.prop, ord.nmds.bray, color="Species", title="Bray NMDS")
# We see three distinct clusters by species
top20 <- names(sort(taxa_sums(ps), decreasing=TRUE))[1:20]
ps.top20 <- transform_sample_counts(ps, function(OTU) OTU/sum(OTU))
ps.top20 <- prune_taxa(top20, ps.top20)
plot_bar(ps.top20, x="Species", fill="Family") + facet_wrap(~Species, scales="free_x")

BiocManager::install("dada2")
library("dada2")
packageVersion("dada2")
#help
help(package="dada2")
?derepFastq
?dada

library(phyloseq)
library(mctoolsr)
library(ape)

# The libraries below are only needed for microbiome analyses, not to run dada2

#source('http://bioconductor.org/biocLite.R')
#biocLite('phyloseq')
library(phyloseq)
library(ggplot2)
library(plyr)
#install.packages("vegan") 
library(vegan)
#install.packages("picante")
library(picante)
#install.packages("TSA")
library(TSA)
#install.packages("nortest")
library(nortest)
#install.packages("multcomp")
library(multcomp)
#install.packages("car")
library(car)
#source('http://bioconductor.org/biocLite.R')
#biocLite(c("ade4", "fastcluster", "df2json", "rjson", "gplots", "devtools", "ggplot2","MASS","minet","mixOmics", "plyr","qvalue","reshape2","RPA","svDialogs","vegan","WGCNA"))
#library(devtools)
#install_github("microbiome/microbiome")
library(microbiome)
#install.packages("mvabund")
library(mvabund)
library(MASS)
library(nlme)
#install.packages("lmerTest")
library(lmerTest)
#install.packages("geepack")
library(geepack)
#install.packages("doBy")
library(doBy)
library(lattice)
#install.packages("MuMIn")
library(MuMIn)

#source('http://bioconductor.org/biocLite.R')
#biocLite("DESeq2")
library("DESeq2")

# review dada2 tutorial for help and comments at https://benjjneb.github.io/dada2/tutorial.html

# in unix move gz fastq files from MiSeq run to the same folder Fastq_gz
# mkdir Fastq_gz
# mv /Users/marcos/Dropbox/Projects/Bioporto/FASTQ/*/*.fastq.gz /Users/marcos/Dropbox/Projects/Bioporto/Fast_gz
# mkdir Fastq
# cd /Users/marcos/Dropbox/Projects/Bioporto/Fastq_gz; for file in *.gz ; do gunzip -c "$file" > /Users/marcos/Dropbox/Projects/Bioporto/Fastq/"${file%.*}" ; done

# Define path variable so that it points to the directory contianing the fastq files AFTER unzipping
path <- "/Users/marcos/Dropbox/Projects/UPR-Ponce/UPR-Ponce_FASTQ/fastq/test" 
path <- "/Users/marcosperez-losada/Dropbox/Projects/UPR-Ponce/UPR-Ponce_FASTQ/fastq/test"
list.files(path)

# Forward and reverse fastq filenames have format: SAMPLENAME_R1_001.fastq and SAMPLENAME_R2_001.fastq
fnFs <- sort(list.files(path, pattern="_R1_001.fastq", full.names = TRUE))
fnRs <- sort(list.files(path, pattern="_R2_001.fastq", full.names = TRUE))
# Extract sample names, assuming filenames have format: SAMPLENAME_XXX.fastq. If not correct
sample.names <- sapply(strsplit(basename(fnFs), "_R"), `[`, 1)

# Inspect read quality profiles
plotQualityProfile(fnFs[1:2])
plotQualityProfile(fnRs[1:2])

## Filter and trim
# Place filtered files in filtered/ subdirectory
filtFs <- file.path(path, "filtered", paste0(sample.names, "_F_filt.fastq.gz"))
filtRs <- file.path(path, "filtered", paste0(sample.names, "_R_filt.fastq.gz"))

# Filter and trim reads
out <- filterAndTrim(fnFs, filtFs, fnRs, filtRs, trimLeft=0, trimRight=0, truncLen=c(145,145), # adjsut as needed
                     maxN=0, maxEE=c(2,2), truncQ=2, rm.phix=TRUE,
                     compress=TRUE, multithread=TRUE) 

# Learn the Error Rates
errF <- learnErrors(filtFs, multithread=TRUE)
errR <- learnErrors(filtRs, multithread=TRUE)
plotErrors(errF, nominalQ=TRUE)
plotErrors(errR, nominalQ=TRUE)

# Dereplication
derepFs <- derepFastq(filtFs, verbose=TRUE)
derepRs <- derepFastq(filtRs, verbose=TRUE)

# Name the derep-class objects by the sample names
names(derepFs) <- sample.names
names(derepRs) <- sample.names

# Apply the core sample inference algorithm to the dereplicated data
dadaFs <- dada(derepFs, err=errF, multithread=TRUE)
dadaRs <- dada(derepRs, err=errR, multithread=TRUE)

# Inspecting the returned dada-class object - see help for more info 
dadaFs[[1]]
dadaRs[[1]]

# Merge paired reads
# IMP: justConcatenate=TRUE for non-overlapping reads 
mergers <- mergePairs(dadaFs, derepFs, dadaRs, derepRs, verbose=TRUE, justConcatenate=TRUE)

# Inspect the merger data.frame from the first sample
head(mergers[[1]])

# construct an amplicon sequence variant table (ASV) table
seqtab <- makeSequenceTable(mergers)
dim(seqtab)

# Inspect distribution of sequence lengths
table(nchar(getSequences(seqtab)))

# If needed remove non-target-length sequences 
# seqtab2 <- seqtab[,nchar(colnames(seqtab)) %in% seq(250,256)]

# Remove chimeras
seqtab.nochim <- removeBimeraDenovo(seqtab, method="consensus", multithread=TRUE, verbose=TRUE)
dim(seqtab.nochim)
sum(seqtab.nochim)/sum(seqtab)

# Check number of reads that made it through each step in the pipeline
getN <- function(x) sum(getUniques(x))
track <- cbind(out, sapply(dadaFs, getN), sapply(dadaRs, getN), sapply(mergers, getN), rowSums(seqtab.nochim))

# If processing a single sample, remove the sapply calls: e.g. replace sapply(dadaFs, getN) with getN(dadaFs)
colnames(track) <- c("input", "filtered", "denoisedF", "denoisedR", "merged", "nonchim")
rownames(track) <- sample.names
head(track)
track

# Assign taxonomy at the species level

taxa1 <- assignTaxonomy(seqtab.nochim, "/software/dada2/silva_nr99_v138_wSpecies_train_set.fa.gz", multithread=TRUE)
taxa1->taxa

# you can format other taxonomies for dada2
# For enviromental samples would be better to use the full Silva132

# Assign taxonomy at the species level

# dada2 implements a method to make species level assignments based on exact matching between ASVs and sequenced reference strains. 
# Recent analysis suggests that exact matching (or 100% identity) is the only appropriate way to assign species to 16S gene fragments. 
# Species-assignment training fastas are available for the Silva and RDP 16S databases at https://benjjneb.github.io/dada2/training.html
# However given the low resolution of 16S at the species level the resulting taxonomy will include many unclassified

# The recently developed IdTaxa taxonomic classification method is also available via the DECIPHER Bioconductor package. 
# The paper introducing the IDTAXA algorithm reports classification performance that is better than the long-time standard set by the naive Bayesian classifier
# This method is available in dada2

# inspect the taxonomic assignments:
  
taxa.print <- taxa # Removing sequence rownames for display only
rownames(taxa.print) <- NULL
head(taxa.print)

# Evaluate accuracy on the mock community if sequenced in MiSeq run

unqs.mock <- seqtab.nochim["Mock",]
unqs.mock <- sort(unqs.mock[unqs.mock>0], decreasing=TRUE) # Drop ASVs absent in the Mock
cat("DADA2 inferred", length(unqs.mock), "sample sequences present in the Mock community.\n")

mock.ref <- getSequences(file.path(path, "HMP_MOCK.v35.fasta"))
match.ref <- sum(sapply(names(unqs.mock), function(x) any(grepl(x, mock.ref))))
cat("Of those,", sum(match.ref), "were exact matches to the expected reference sequences.\n")

# Conclusion: This mock community contained 20 bacterial strains. DADA2 identified 20 ASVs all of which exactly match the reference genomes of the expected community members. 

### pruning taxtab and seqtab.nochim (taxonomy of Kingdom to Genus)

colnames(taxa) <- c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species")
taxa[is.na(taxa)] <- "unclassified"  # change NA to unclasssified
sort(unique(taxa[,1])) # include taxonomic levels of kingdom,[,2], phylum, [,3] and clas to find chloroplasts and mitochondria

# Chloroplasts and mitochondrias need to be eliminated from the taxonomy
# It is important to check in the reference database used in which taxonomic level are placed chloroplasts and mitochondrias
# The Silva123 includes 16S from chloroplasts and mitochondria that need to be eliminated. Chloroplasts show up in class and mitochondria in family

taxa2<-data.frame(taxa) ## convert to data.frame
taxa2<-subset(taxa2,Kingdom=="Bacteria" & Order!="Chloroplast" & Family!="Mitochondria")  # I keep bacteria and eliminate chloroplasts and mitochondria
#taxa2<-subset(taxa2,Kingdom=="Bacteria" & Kingdom=="Archaea" & Class!="Chloroplast" & Family!="Mitochondria") # I keep bacteria and Archaea and eliminate chloroplasts and mitochondria
taxa<-as.matrix(taxa2);rm(taxa2)

b<-t(seqtab.nochim)
ASVsfiltered <- b[rownames(taxa),] # I keep the ASVs in table with filtered taxonomy
seqtab.nochim<-t(ASVsfiltered);rm(b);rm(ASVsfiltered)

# change long names in reads to amplicon single variants (ASV)
seqtab.nochim1 <- seqtab.nochim
colnames(seqtab.nochim1) <- paste0("ASV", 1:ncol(seqtab.nochim1))
taxa3 <- taxa
rownames(taxa3) <- paste0("ASV", 1:nrow(taxa3))
write.table(taxa3,"dada2_test_conc_taxonomy.txt",quote=F,sep="\t")

## export tables with ASVs
# run function
export_taxa_table_and_seqs = function(seqtab.nochim, file_seqtab, file_seqs) {
  seqtab.t = as.data.frame(t(seqtab.nochim))
  seqs = row.names(seqtab.t)
  row.names(seqtab.t) = paste0("ASV", 1:nrow(seqtab.t))
  outlist = list(data_loaded = seqtab.t)
  mctoolsr::export_taxa_table(outlist, file_seqtab)
  seqs = as.list(seqs)
  seqinr::write.fasta(seqs, row.names(seqtab.t), file_seqs)
}

# install this library unless already installed
devtools::install_github("leffj/mctoolsr")
library(mctoolsr)
install.packages("seqinr")

export_taxa_table_and_seqs(seqtab.nochim,"ASV_table_test_conc.txt","ASV_seqs_test_conc.fa")

## Align and estimate a phylogenetic tree

# Align
# in unix run clustalo -i ASV_seqs.fa --threads=2 -o ASV_seqsALI.fasta
# the alingment is clsutalo is so so, MAFFT does a better job, so run MAFFT online

# mothur filter.seqs(fasta=ASV_seqsALI.fasta, vertical=T, trump=.) # if needed

# Estimate phylogeny
# Option 1: launch macqiime and execute: make_phylogeny.py -i ASV_seqs_aln.fa -o ASV_tree.txt -r midpoint
# Option 2: launch QIIME2 and execute: 
  # qiime tools import --type 'FeatureData[Sequence]' --input-path ASV_seqs_test_conc.fa --output-path ASV_seqs_test_conc.qza
  # qiime phylogeny align-to-tree-mafft-fasttree --i-sequences ASV_seqs_test_conc.qza --output-dir mafft-fasttree-output-test_conc
  # qiime tools export --input-path mafft-fasttree-output-test_conc/tree.qza  --output-path test_conc

## Create phyloseq object using dada2 tables and trees generated above
#  Tables have to be adjusted

setwd("/Users/marcos/Dropbox/Projects/UPR-Ponce/dada2")

tree <- read_tree("tree_test_conc.nwk")
taxa1 <- read.delim("dada2_test_conc_taxonomy.txt")
otu <- read.delim("ASV_table_test_conc.txt", skip = 1, row.names = 1, check.names = FALSE)
metadata <- read.csv("metadata_test_conc_R.csv", header=TRUE, row.names = 1)
ps <- phyloseq(tax_table(as.matrix(taxa1)), phy_tree(tree), sample_data(metadata), otu_table(otu, taxa_are_rows = TRUE))
ps2 <- ps

## Create phyloseq object using BIOM file from QIIME2
# Adjust file as indicated in cmd.txt or indicated below

# create biomfile for R
# First paste in excell ASV_table.txt and taxonomy then
# in qiime 
# biom convert -i ASV_table_tax.txt -o ASV_table_tax.biom --to-json --table-type="OTU table" --process-obs-metadata taxonomy
# biom summarize-table -i ASV_table_tax.biom
# biom convert -i ASV_table_tax.biom --to-json --header-key taxonomy -o ASV_table_tax_js.biom
# summarize_taxa_through_plots.py -i ASV_table_tax_js.biom -o taxa_plots -m metadata.txt

setwd("/Users/marcosperez-losada/Dropbox/Projects/Bioporto/exported")
theme_set(theme_bw())

arbol<-read.tree(file.choose()) 
datos<-import_biom(file.choose(),arbol)
metadatos<-read.table(file.choose(),h=T,row.names = 1,sep='\t')

ls.str(metadatos)

sample_data(datos)<-metadatos 
min(colSums(otu_table(datos)))

# renane ps object
datos -> ps1

# remove extra taxonomic ranks in Silva file
tax_table(ps1) <- tax_table(ps1)[,1:7]
ps1

# rename taxonomic ranks
rank_names(ps1, errorIfNULL=TRUE)
colnames(tax_table(ps1)) <- c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species")

# keep bacteria and eliminate Unassigned, chloroplasts and mitochondria
# Silva
ps2<-subset_taxa(ps1, Kingdom=="D_0__Bacteria" & Kingdom!="Unassigned" & Order!=" D_3__Chloroplast" & Family!=" D_4__Mitochondria")
# Greengenes
ps2<-subset_taxa(ps1, Kingdom=="k__Bacteria" & Kingdom!="Unassigned" & Order!="c__Chloroplast" & Family!="f__mitochondria")
ps2

# remove ASVs whose mean value per sample is less than 1
ps3 <- filter_taxa(ps2, function(x) mean(x) > 1, TRUE)

# fiter singletons
ps4 <- prune_taxa(taxa_sums(ps3) > 1, ps3) 

# We can also remove taxa that are not observed more than X times in at least 10% of the samples
#ps4 <- filter_taxa(ps3, function(x) sum(x > 2) > (0.1*length(x)), TRUE)

# And finally filter samples with less than 1000 reads
ps5 = prune_samples(sample_sums(ps4) >= 1000, ps4)
ps5

summarize_phyloseq(ps5)

#Export table of ASVs
table_otu<-otu_table(ps5)
write.csv(table_otu,file="silva_table_ps5_test_conc.csv")

#Export taxonomy of ASVs
table_tax<-tax_table(ps5)
write.csv(table_tax,file="silva_tax_ps5_test_conc.csv")

# Export table of ASVs with taxonomy
table_all<-cbind(tax_table(ps5),otu_table(ps5))
write.csv(table_all,file="table_tax_ps5.csv")

######################## I. DATA NORMALIZATION ######################## 

# Using Negative Binomial distribution

# IMP: if samples are going to be rarefaccionated skip this section and move to Rarefacction of samples to the minimum sample size

diagdds = phyloseq_to_deseq2(datos, ~Sample_Type_4) # Any variable of the metadata would work. You need one to create the DESeq object
# Calculate geometric means
gm_mean = function(x, na.rm=TRUE){
  exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
}
geoMeans = apply(counts(diagdds), 1, gm_mean)
# Estimate size factors
diagdds = estimateSizeFactors(diagdds, geoMeans = geoMeans)
# Get Normalized read counts
normcounts <- counts(diagdds, normalized = TRUE)
# Round read counts
round(normcounts, digits = 0) -> normcountsrd
# Transform matrix of normalized counts to phyloseq object
otu_table(normcountsrd, taxa_are_rows = TRUE) -> ncr
# Replace otu_table in original phyloseq object
otu_table(datos) <- ncr
#write.csv(ncr,file="deseq_file.csv")

########## ANALYSIS OF ALL SAMPLES #############

otuD<-as.data.frame(t(otu_table(datos)))
phylodiversityRAREF_Q<-pd(otuD, phy_tree(datos), include.root=TRUE) ### filogenetic diversity. Include root =True tree rooted via midpoint
diversityRAREF_Q<-estimate_richness(datos)
diversityRAREF_Q1<-cbind(sample_data(datos),diversityRAREF_Q,phylodiversityRAREF_Q) 

########## ANALYSIS OF A SUBSET OF SAMPLES #############

Q_raref <- subset_samples(datos, Sample_Type_4=="INF_D_W"); Q_raref # IMP: I used the same names as below (Q_raref) to mantain structure of script, but samples are not rarefactionated
min(colSums(otu_table(Q_raref)))

#Export table of OTUs
table_otu<-otu_table(Q_raref)
write.csv(table_otu,file="LRIY_deseq_file.csv")

#Export table of OTUs with taxonomy
table_all<-cbind(tax_table(Q_raref),otu_table(Q_raref))
write.csv(table_all,file="LRIY_deseq_file_tax.csv")

######################## II. DATA NORMALIZATION ######################## 

# Using Rarefaction Analysis

# Skip this part if you have performed binomial negative normalization

# All samples
Q_raref<-rarefy_even_depth(datos, sample.size =1514,replace=FALSE, rngseed=T);Q_raref ### rarefaccion to min number 
min(colSums(otu_table(Q_raref)))

# A subset of samples
LRI_DW <- subset_samples(datos, Sample_Type_4=="INF_D_W"); LRI_DW 
min(colSums(otu_table(Q_raref)))

Q_raref<-rarefy_even_depth(LRI_DW, sample.size =1030,replace=FALSE, rngseed=T);Q_raref ### rarefaccion to min number before
min(colSums(otu_table(Q_raref)))

################################################ 

otuD<-as.data.frame(t(otu_table(Q_raref)))
phylodiversityRAREF_Q<-pd(otuD, phy_tree(Q_raref), include.root=TRUE) ### filogenetic diversity. Include root =True tree rooted via midpoint
diversityRAREF_Q<-estimate_richness(Q_raref)
diversityRAREF_Q1<-cbind(sample_data(Q_raref),diversityRAREF_Q,phylodiversityRAREF_Q) 

# Export selected alpha-diversity indices
write.csv(diversityRAREF_Q1,file="alpha_div_Q_Deseq.csv")


### con esto hago una grafica de 2x2 con las medidas de alfa-div que suelo poner en los papers.Tu puedes poner las que quieras
par(mfrow = c(2, 2))

######## funcion multiplot ######## 

multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}



##### graficas boxplots con jitter los outlaiers, si los hay van en negro, los circulos blancos son los valores de tus muestras

observed <- ggplot(diversityRAREF_Q1, aes(factor(Sample_Type_2), Observed))
observed2<-observed + geom_boxplot(aes(fill = factor(Sample_Type_2)),outlier.colour = "black", outlier.size = 1)+ geom_jitter(size=1,shape=1)+ ggtitle("Otu richness")+labs(y = "OTU richness")
chao <- ggplot(diversityRAREF_Q1, aes(factor(Sample_Type_2), Chao1))
chao2<-chao + geom_boxplot(aes(fill = factor(Sample_Type_2)),outlier.colour = "black", outlier.size = 1)+ geom_jitter(size=1,shape=1)+ ggtitle("Chao1 richness")+labs(y = "Chao1 richness")
shan <- ggplot(diversityRAREF_Q1, aes(factor(Sample_Type_2), Shannon))
shan2<-shan + geom_boxplot(aes(fill = factor(Sample_Type_2)),outlier.colour = "black", outlier.size = 1)+ geom_jitter(size=1,shape=1)+ ggtitle("Shannon diversity")+labs(y = "Shannon diversity")
invsimp <- ggplot(diversityRAREF_Q1, aes(factor(Sample_Type_2), InvSimpson))
invsimp2<- invsimp + geom_boxplot(aes(fill = factor(Sample_Type_2)),outlier.colour = "black", outlier.size = 1)+ geom_jitter(size=1,shape=1)+ ggtitle("InvSimpson diversity")+labs(y = "InvSimpson diversity")
ACE <- ggplot(diversityRAREF_Q1, aes(factor(Sample_Type_2), ACE))
ACE2<- ACE + geom_boxplot(aes(fill = factor(Sample_Type_2)),outlier.colour = "black", outlier.size = 1)+ geom_jitter(size=1,shape=1)+ ggtitle("ACE diversity")+labs(y = "ACE diversity")
phyl <- ggplot(diversityRAREF_Q1, aes(factor(Sample_Type_2), PD))
phyl2<-phyl + geom_boxplot(aes(fill = factor(Sample_Type_2)),outlier.colour = "black", outlier.size = 1)+ geom_jitter(size=1,shape=1)+ ggtitle("Phylogenetic diversity")+labs(y = "Faith's diversity")
fish <- ggplot(diversityRAREF_Q1, aes(factor(Sample_Type_2), Fisher))
fish2<- fish + geom_boxplot(aes(fill = factor(Sample_Type_2)),outlier.colour = "black", outlier.size = 1)+ geom_jitter(size=1,shape=1)+ ggtitle("Fisher diversity")+labs(y = "Fisher diversity")

#multiplot(observed2, chao2, shan2, fish2, ACE2, phyl2, cols=2)  #### to run this fucntion I have to run function multiplot first
multiplot(observed2, chao2, invsimp2, phyl2, cols=2)  #### to run this fucntion I have to run function multiplot first
multiplot(shan2, fish2, ACE2, phyl2, cols=2)  #### to run this fucntion I have to run function multiplot first
multiplot(observed2, chao2, invsimp2, shan2, fish2, ACE2, phyl2, cols=4)  #### to run this fucntion I have to run function multiplot first


# Export selected alpha-diversity indices
write.csv(diversityRAREF_Q1,file="alpha_div_LRIY.csv")

##### Alpha-Diversity comparisons 

t1<-lmer(Observed~category+met_seasons1+Age_years+Gender+Feeding_Route1+Ventilator_Use1+Oxygen_Requirement+Tracheostomy_Change_Frequency1+Prophylactic_Antibiotics+Daily_Inhaled_Steroids+Antibiotics_during_LRI+ (1|patient1), diversityRAREF_Q1)
summary(t1)
final<-lmerTest::step(t1, keep.effs=c("category")); final
t2<-lmer(Observed~category+Gender+(1|patient1),diversityRAREF_Q1) # DESeq2
t2<-lmer(Observed~category+Feeding_Route1+(1|patient1),diversityRAREF_Q1) # raref
summary(t2)
anova(t2, test="F")

t1<-lmer(Chao1~category+met_seasons1+Age_years+Gender+Feeding_Route1+Ventilator_Use1+Oxygen_Requirement+Tracheostomy_Change_Frequency1+Prophylactic_Antibiotics+Daily_Inhaled_Steroids+Antibiotics_during_LRI+ (1|patient1), diversityRAREF_Q1)
summary(t1)
final<-lmerTest::step(t1, keep.effs=c("category")); final
t2<-lmer(Chao1~category+Gender+(1|patient1),diversityRAREF_Q1) # DESeq2
t2<-lmer(Chao1~category+Feeding_Route1+Daily_Inhaled_Steroids+Antibiotics_during_LRI+ (1|patient1),diversityRAREF_Q1) # raref
summary(t2)
anova(t2, test="F")

t1<-lmer(PD~category+met_seasons1+Age_years+Gender+Feeding_Route1+Ventilator_Use1+Oxygen_Requirement+Tracheostomy_Change_Frequency1+Prophylactic_Antibiotics+Daily_Inhaled_Steroids+Antibiotics_during_LRI+ (1|patient1), diversityRAREF_Q1)
summary(t1)
final<-lmerTest::step(t1, keep.effs=c("category")); final
t2<-lmer(PD~category+Feeding_Route1+(1|patient1),diversityRAREF_Q1) # DESeq2 & raref
summary(t2)
anova(t2, test="F")

t1<-lmer(Shannon~category+met_seasons1+Age_years+Gender+Feeding_Route1+Ventilator_Use1+Oxygen_Requirement+Tracheostomy_Change_Frequency1+Prophylactic_Antibiotics+Daily_Inhaled_Steroids+Antibiotics_during_LRI+ (1|patient1), diversityRAREF_Q1)
summary(t1)
final<-lmerTest::step(t1, keep.effs=c("category")); final
t2<-lmer(Shannon~category+Feeding_Route1+(1|patient1),diversityRAREF_Q1) # DESeq2 & raref
summary(t2)
anova(t2, test="F")

t1<-lmer(Fisher~category+met_seasons1+Age_years+Gender+Feeding_Route1+Ventilator_Use1+Oxygen_Requirement+Tracheostomy_Change_Frequency1+Prophylactic_Antibiotics+Daily_Inhaled_Steroids+Antibiotics_during_LRI+ (1|patient1), diversityRAREF_Q1)
summary(t1)
final<-lmerTest::step(t1, keep.effs=c("category")); final
t2<-lmer(Fisher~category+Feeding_Route1+(1|patient1),diversityRAREF_Q1) # DESeq2 & raref
summary(t2)
anova(t2, test="F")

t1<-lmer(ACE~category+met_seasons1+Age_years+Gender+Feeding_Route1+Ventilator_Use1+Oxygen_Requirement+Tracheostomy_Change_Frequency1+Prophylactic_Antibiotics+Daily_Inhaled_Steroids+Antibiotics_during_LRI+ (1|patient1), diversityRAREF_Q1)
summary(t1)
final<-lmerTest::step(t1, keep.effs=c("category")); final
t2<-lmer(ACE~category+Gender+(1|patient1),diversityRAREF_Q1) # DESeq2
t2<-lmer(ACE~category+Feeding_Route1+(1|patient1),diversityRAREF_Q1) # raref
summary(t2)
anova(t2, test="F")

t1<-lmer(Simpson~category+met_seasons1+Age_years+Gender+Feeding_Route1+Ventilator_Use1+Oxygen_Requirement+Tracheostomy_Change_Frequency1+Prophylactic_Antibiotics+Daily_Inhaled_Steroids+Antibiotics_during_LRI+ (1|patient1), diversityRAREF_Q1)
summary(t1)
final<-lmerTest::step(t1, keep.effs=c("category")); final
t2<-lmer(Simpson~category+Feeding_Route1+(1|patient1),diversityRAREF_Q1) # DESeq2
t2<-lmer(Simpson~category+met_seasons1+Feeding_Route1+(1|patient1),diversityRAREF_Q1) # raref
summary(t2)
anova(t2, test="F")

# Beta-Diversity comparisons with adonis

uniun<-phyloseq::distance(Q_raref, method="unifrac")
#uniun<-distance(Q_raref, method="unifrac")
#uniund<-as.matrix(uniun)
uniweigh<-phyloseq::distance(Q_raref, method="wunifrac")
#uniweigh<-distance(Q_raref, method="wunifrac")
#uniweighd<-as.matrix(uniweigh)
brayd<-phyloseq::distance(Q_raref, method="bray")
jaccd<-phyloseq::distance(Q_raref, method="jaccard")

# How you compare models in adonis?
# Use AIC=2k+n[Ln(2(pi)*RSS/n)+1] and pick the model with lowest AIC score
# k=parameters, n=samples, RSS=SumsOfSqs

t1<-adonis(uniun~diversityRAREF_Q1$category+diversityRAREF_Q1$Feeding_Route1, strata=diversityRAREF_Q1$patient1,perm=10000); t1
t1<-adonis(uniweigh~diversityRAREF_Q1$category+diversityRAREF_Q1$Feeding_Route1, strata=diversityRAREF_Q1$patient1,perm=10000); t1
t1<-adonis(brayd~diversityRAREF_Q1$category+diversityRAREF_Q1$Feeding_Route1, strata=diversityRAREF_Q1$patient1,perm=10000); t1
t1<-adonis(jaccd~diversityRAREF_Q1$category+diversityRAREF_Q1$Feeding_Route1, strata=diversityRAREF_Q1$patient1,perm=10000); t1

# Referee suggests for adonis (no strata): Y ~ patient + LRI

t1<-adonis(uniun~diversityRAREF_Q1$patient1+diversityRAREF_Q1$category,perm=10000); t1
t1<-adonis(uniweigh~diversityRAREF_Q1$patient1+diversityRAREF_Q1$category,perm=10000); t1
t1<-adonis(brayd~diversityRAREF_Q1$patient1+diversityRAREF_Q1$category,perm=10000); t1
t1<-adonis(jaccd~diversityRAREF_Q1$patient1+diversityRAREF_Q1$category,perm=10000); t1

# PCoA plots

p1 = plot_ordination(Q_raref, ordinate(Q_raref, method="PCoA", dist="unifrac", weighted=TRUE), type = "samples", color = "Sample_Type_2") 
p1 + geom_point(size = 5) + ggtitle("PCoA Weigthed UNIFRAC") 
p1 = plot_ordination(Q_raref, ordinate(Q_raref, method="PCoA", dist="unifrac"), type = "samples", color = "Sample_Type_2") 
p1 + geom_point(size = 5) + ggtitle("PCoA Unweigthed UNIFRAC") 
p1 = plot_ordination(Q_raref, ordinate(Q_raref, method="PCoA", dist="brayd"), type = "samples", color = "Sample_Type_2") 
p1 + geom_point(size = 5) + ggtitle("PCoA Bray-Curtis") 
p1 = plot_ordination(Q_raref, ordinate(Q_raref, method="PCoA", dist="jaccd"), type = "samples", color = "Sample_Type_2") 
p1 + geom_point(size = 5) + ggtitle("PCoA Jaccard") 



####### 3. Anaysis of taxa as proportions

taxa<-read.table(file.choose(),h=T,row.names = 1,sep='\t')
head(taxa)
str(taxa)

# phyla
t1<-lmer(Actinobacteria~category+Feeding_Route1 +(1|patient1), taxa)
summary(t1)
anova(t1, test="F")

t1<-lmer(Bacteroidetes~category+Feeding_Route1 +(1|patient1), taxa)
summary(t1)
anova(t1, test="F")

t1<-lmer(Firmicutes~category+Feeding_Route1 +(1|patient1), taxa)
summary(t1)
anova(t1, test="F")

t1<-lmer(Fusobacteria~category+Feeding_Route1 +(1|patient1), taxa)
summary(t1)
anova(t1, test="F")

t1<-lmer(Proteobacteria~category+Feeding_Route1 +(1|patient1), taxa)
summary(t1)
anova(t1, test="F")

# genera 
t1<-lmer(Streptococcus~category+Feeding_Route1 +(1|patient1), taxa)
summary(t1)
anova(t1, test="F")

t1<-lmer(Pseudomonas~category1+Feeding_Route1 +(1|patient1), taxa)
summary(t1)
anova(t1, test="F")

t1<-lmer(Neisseria~category+Feeding_Route1 +(1|patient1), taxa)
summary(t1)
anova(t1, test="F")

t1<-lmer(Corynebacterium~category+Feeding_Route1 +(1|patient1), taxa)
summary(t1)
anova(t1, test="F")

t1<-lmer(Haemophilus~category+Feeding_Route1 +(1|patient1), taxa)
summary(t1)
anova(t1, test="F")

t1<-lmer(Prevotella~category+Feeding_Route1 +(1|patient1), taxa)
summary(t1)
anova(t1, test="F")

t1<-lmer(Stenotrophomonas~category+Feeding_Route1 +(1|patient1), taxa)
summary(t1)
anova(t1, test="F")

t1<-lmer(Moraxella~category+Feeding_Route1 +(1|patient1), taxa)
summary(t1)
anova(t1, test="F")

########## DIFFERENTIAL ABUNDANCE USING DESEQ2 NEGATIVE BINOMIAL MODEL #############

setwd("~/Dropbox/Projects/Tracheoscopy kids/qiime-mothur/R/Final_Files_LRIY")
#import_biom("DESeq_LRIY_Genus.biom") -> physeq
import_biom("DESeq_LRIY_Phyla.biom") -> physeq
#import_biom("mothur_fs2R.biom") -> physeq
read.table("Metadata_all_v6.txt",h=T,row.names = 1, sep = "\t") -> meta
sample_data(physeq)<-meta
physeq

###### significant taxa in LRIY across time points while accounting for Feeding route using DESeq

#filter by Time point

D0 = subset_samples(physeq, Sample_Type_2 == "I_day_ant")
D1 = subset_samples(physeq, Sample_Type_2 == "I_day_post")
W1 = subset_samples(physeq, Sample_Type_2 == "I_W1")
W2 = subset_samples(physeq, Sample_Type_2 == "I_W2")
W3 = subset_samples(physeq, Sample_Type_2 == "I_W3")
W4 = subset_samples(physeq, Sample_Type_2 == "I_W4")

# Merge
physeqok = merge_phyloseq(D0,D1,W1,W2,W3,W4)

sample_data(physeqok)$Sample_Type_2 <- relevel(sample_data(physeqok)$Sample_Type_2, "I_day_ant")
sample_data(physeqok)$Feeding_Route1 <-  factor(sample_data(physeqok)$Feeding_Route1)
diagdds = phyloseq_to_deseq2(physeqok, ~ Feeding_Route1 + Sample_Type_2)

# calculate geometric means prior to estimate size factors
gm_mean = function(x, na.rm=TRUE){
  exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
}
geoMeans = apply(counts(diagdds), 1, gm_mean)

# Estimate size factors
diagdds = estimateSizeFactors(diagdds, geoMeans = geoMeans)
diagdds = DESeq(diagdds, test="Wald", fitType="local")

res = results(diagdds, cooksCutoff = FALSE)
res = res[order(res$padj, na.last=NA), ]
#View(res)
#alpha = 0.05
alpha = 1.1
sigtab = res[(res$padj < alpha), ]
sigtab = cbind(as(sigtab, "data.frame"), as(tax_table(physeqok)[rownames(sigtab), ], "matrix"))
View(sigtab)
write.csv(sigtab,file="DESeqTaxa_Signif.csv")

library("ggplot2")
theme_set(theme_bw())
scale_fill_discrete <- function(palname = "Set1", ...) {
  scale_fill_brewer(palette = palname, ...)
}
# Phylum order
x = tapply(sigtab$log2FoldChange, sigtab$Phylum, function(x) max(x))
x = sort(x, TRUE)
sigtab$Phylum = factor(as.character(sigtab$Phylum), levels=names(x))

# Species order
x = tapply(sigtab$log2FoldChange, sigtab$Species, function(x) max(x))
x = sort(x, TRUE)
sigtab$Species = factor(as.character(sigtab$Species), levels=names(x))

ggplot(sigtab, aes(x=Species, y=log2FoldChange, color=Phylum)) + geom_point(size=6) + 
  theme(axis.text.x = element_text(angle = -90, hjust = 0, vjust=0.5))

ggplot(sigtab, aes(x=Species, y=log2FoldChange, color=Species)) + geom_point(size=6) + 
  theme(axis.text.x = element_text(angle = -90, hjust = 0, vjust=0.5))


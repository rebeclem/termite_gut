# termite_gut
where I'm gonna do my termite gut analyses

[Raw data in illumina shotgun](https://basespace.illumina.com/run/189768585/Gibson_Clement_breastmilk_termitegut_0110_20190709) or [here](https://gwu.app.box.com/folder/81687457352) on box

[Raw data in illumina 16S part one](https://basespace.illumina.com/projects/138622490/about) or [here](https://gwu.app.box.com/folder/82761197082) on box.

[Raw data in illumina 16S part two](https://basespace.illumina.com/projects/205602397) or [here](https://gwu.app.box.com/folder/125030774550) on box.

Where raw data is stored on pegasus: /groups/cbi/Users/rclement

## Steps
1. [Setup](setup.md)
* [Setup for 16S](setup16S.md)
2. Set up [reference databases](ref.md)
3. [FastQC and Flexbar](fastqc.md)
4. [Count](readcounts.md) cleaned and raw reads
5. [Run pathoscope](pathoscope.md) and count reads
6. Dada2 for [Batch 1](termite_dada2.R) and [Batch 2](termite_dada2_part2.R)
7. [Visualize data](combined_dada2.Rmd) and further analyses in R
8. [Make some maps in R](Map_making.Rmd)

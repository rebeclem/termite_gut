[rebeccaclement@log003 glustre]$ ls
Rawdata  refs  scripts  termite_16S  termite_shotgun
[rebeccaclement@log003 glustre]$ cd termite_shotgun/
[rebeccaclement@log003 termite_shotgun]$ ls
Analysis  fastqc_cleaned  outfastqc  outflexbar  samps.txt
[rebeccaclement@log003 termite_shotgun]$ cd Analysis/
[rebeccaclement@log003 Analysis]$ ls
L935_Bec1  L937_Bec3  L939_Bec5  L941_Bec7  L943_Bec9   L945_Bec11
L936_Bec2  L938_Bec4  L940_Bec6  L942_Bec8  L944_Bec10  L946_Bec12
[rebeccaclement@log003 Analysis]$ for f in *; do
> cd $f &&
> python ../../../scripts/pulling_readcount.py &&
> cd .. &&
> echo $f^C
[rebeccaclement@log003 Analysis]$ salloc -N 1 -p short -t 300
salloc: Pending job allocation 327890
salloc: job 327890 queued and waiting for resources
^Csalloc: Job allocation 327890 has been revoked.
salloc: Job aborted due to signal
[rebeccaclement@log003 Analysis]$ salloc -N 1 -p tiny -t 300
salloc: Granted job allocation 327891
[rebeccaclement@log003 Analysis]$ sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
defq*        up 14-00:00:0    124  alloc cpu[001-046,075-152]
defq*        up 14-00:00:0     40   idle cpu[047-074,153-164]
short        up 1-00:00:00     19  alloc cpu[101-119]
tiny         up    8:00:00     72  alloc cpu[001-046,075-100]
tiny         up    8:00:00     28   idle cpu[047-074]
highMem      up 14-00:00:0      2  alloc hmm[001-002]
highThru     up 7-00:00:00      1  alloc hth001
highThru     up 7-00:00:00      5   idle hth[002-006]
debug        up    4:00:00      6  alloc cpu[001-003],gpu[013-015]
debug-cpu    up    4:00:00      3  alloc cpu[001-003]
debug-gpu    up    4:00:00      3  alloc gpu[013-015]
large-gpu    up 7-00:00:00      1  down* gpu037
large-gpu    up 7-00:00:00     21  alloc gpu[001-012,021-023,032-036,038]
small-gpu    up 7-00:00:00      1  drain gpu028
small-gpu    up 7-00:00:00     15  alloc gpu[013-020,024-027,029-031]
[rebeccaclement@log003 Analysis]$ squeue
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
            327891      tiny     bash rebeccac  R       0:19      1 cpu046
[rebeccaclement@log003 Analysis]$ ssh cpu046
Warning: Permanently added 'cpu046,172.30.190.56' (ECDSA) to the list of known hosts.
[rebeccaclement@cpu046 ~]$ cd glustre/termite_shotgun/
[rebeccaclement@cpu046 termite_shotgun]$ ls
Analysis  fastqc_cleaned  outfastqc  outflexbar  samps.txt
[rebeccaclement@cpu046 termite_shotgun]$ cd Analysis/
[rebeccaclement@cpu046 Analysis]$ ls
L935_Bec1  L937_Bec3  L939_Bec5  L941_Bec7  L943_Bec9   L945_Bec11
L936_Bec2  L938_Bec4  L940_Bec6  L942_Bec8  L944_Bec10  L946_Bec12
[rebeccaclement@cpu046 Analysis]$ for f in *; do
>     cd $f &&
>     python ../../../scripts/pulling_readcount.py &&
>     cd .. &&
>     echo $f
> done
L935_Bec1
L936_Bec2
L937_Bec3
L938_Bec4
L939_Bec5
L940_Bec6
L941_Bec7
L942_Bec8
L943_Bec9
L944_Bec10
L945_Bec11
L946_Bec12
[rebeccaclement@cpu046 Analysis]$ ls
L935_Bec1  L937_Bec3  L939_Bec5  L941_Bec7  L943_Bec9   L945_Bec11
L936_Bec2  L938_Bec4  L940_Bec6  L942_Bec8  L944_Bec10  L946_Bec12
[rebeccaclement@cpu046 Analysis]$ cd ..
[rebeccaclement@cpu046 termite_shotgun]$ ls
Analysis  fastqc_cleaned  outfastqc  outflexbar  samps.txt
[rebeccaclement@cpu046 termite_shotgun]$ cd Analysis/
[rebeccaclement@cpu046 Analysis]$ echo -e "Samp\tRaw\tCleaned" >> read_count.txt
[rebeccaclement@cpu046 Analysis]$ ls
L935_Bec1  L938_Bec4  L941_Bec7  L944_Bec10  read_count.txt
L936_Bec2  L939_Bec5  L942_Bec8  L945_Bec11
L937_Bec3  L940_Bec6  L943_Bec9  L946_Bec12
[rebeccaclement@cpu046 Analysis]$ ls L935_Bec1/
flexbar_reads.txt    flexcleaned_2.fastq  L935_Bec1_R1.fastq.gz
flexcleaned_1.fastq  flexcleaned.log      L935_Bec1_R2.fastq.gz
[rebeccaclement@cpu046 Analysis]$ cat L935_Bec1/flexbar_reads.txt
6443742	6430566
[rebeccaclement@cpu046 Analysis]$ for f in *; do
>     reads=$(cat $f/flexbar_reads.txt) &&
>     echo -e "${f}\t${reads}" >> read_count.txt &&
>     echo $f
> done
L935_Bec1
L936_Bec2
L937_Bec3
L938_Bec4
L939_Bec5
L940_Bec6
L941_Bec7
L942_Bec8
L943_Bec9
L944_Bec10
L945_Bec11
L946_Bec12
cat: read_count.txt/flexbar_reads.txt: Not a directory
[rebeccaclement@cpu046 Analysis]$ ls
L935_Bec1  L938_Bec4  L941_Bec7  L944_Bec10  read_count.txt
L936_Bec2  L939_Bec5  L942_Bec8  L945_Bec11
L937_Bec3  L940_Bec6  L943_Bec9  L946_Bec12
[rebeccaclement@cpu046 Analysis]$ cat read_count.txt
Samp	Raw	Cleaned
L935_Bec1	6443742	6430566
L936_Bec2	8051096	8032718
L937_Bec3	5924844	5901602
L938_Bec4	10306826	10173936
L939_Bec5	8455958	8420508
L940_Bec6	573340	565398
L941_Bec7	6734676	6724104
L942_Bec8	10142316	10104284
L943_Bec9	7751050	7728394
L944_Bec10	4880974	4866082
L945_Bec11	14002	13914
L946_Bec12	4617610	4607742
[rebeccaclement@cpu046 Analysis]$ pwd
/GWSPH/home/rebeccaclement/glustre/termite_shotgun/Analysis
[rebeccaclement@cpu046 Analysis]$ cd ..
[rebeccaclement@cpu046 termite_shotgun]$ ls
Analysis  fastqc_cleaned  outfastqc  outflexbar  samps.txt
[rebeccaclement@cpu046 termite_shotgun]$ cd ..
[rebeccaclement@cpu046 glustre]$ ls
Rawdata  refs  scripts  termite_16S  termite_shotgun
[rebeccaclement@cpu046 glustre]$ cd termite_16S
[rebeccaclement@cpu046 termite_16S]$ ls
Analysis  fastqc_cleaned  outfastqc16S  outflexbar16S  samps.txt
[rebeccaclement@cpu046 termite_16S]$ cd Analysis/
[rebeccaclement@cpu046 Analysis]$ ls
L759_BEC0001_16S  L774_BEC0016_16S  L789_BEC0031_16S  L804_BEC0046_16S
L760_BEC0002_16S  L775_BEC0017_16S  L790_BEC0032_16S  L805_BEC0047_16S
L761_BEC0003_16S  L776_BEC0018_16S  L791_BEC0033_16S  L806_BEC0048_16S
L762_BEC0004_16S  L777_BEC0019_16S  L792_BEC0034_16S  L807_BEC0049_16S
L763_BEC0005_16S  L778_BEC0020_16S  L793_BEC0035_16S  L808_BEC0050_16S
L764_BEC0006_16S  L779_BEC0021_16S  L794_BEC0036_16S  L809_BEC0051_16S
L765_BEC0007_16S  L780_BEC0022_16S  L795_BEC0037_16S  L810_BEC0052_16S
L766_BEC0008_16S  L781_BEC0023_16S  L796_BEC0038_16S  L811_BEC0053_16S
L767_BEC0009_16S  L782_BEC0024_16S  L797_BEC0039_16S  L812_BEC0054_16S
L768_BEC0010_16S  L783_BEC0025_16S  L798_BEC0040_16S  L813_BEC0055_16S
L769_BEC0011_16S  L784_BEC0026_16S  L799_BEC0041_16S  L814_BEC0056_16S
L770_BEC0012_16S  L785_BEC0027_16S  L800_BEC0042_16S  L815_BEC0057_16S
L771_BEC0013_16S  L786_BEC0028_16S  L801_BEC0043_16S  MPL
L772_BEC0014_16S  L787_BEC0029_16S  L802_BEC0044_16S
L773_BEC0015_16S  L788_BEC0030_16S  L803_BEC0045_16S
[rebeccaclement@cpu046 Analysis]$ for f in *; do
>     cd $f &&
>     python ../../../scripts/pulling_readcount.py &&
>     cd .. &&
>     echo $f
> done
L759_BEC0001_16S
L760_BEC0002_16S
L761_BEC0003_16S
L762_BEC0004_16S
L763_BEC0005_16S
L764_BEC0006_16S
L765_BEC0007_16S
L766_BEC0008_16S
L767_BEC0009_16S
L768_BEC0010_16S
L769_BEC0011_16S
L770_BEC0012_16S
L771_BEC0013_16S
L772_BEC0014_16S
L773_BEC0015_16S
L774_BEC0016_16S
L775_BEC0017_16S
L776_BEC0018_16S
L777_BEC0019_16S
L778_BEC0020_16S
L779_BEC0021_16S
L780_BEC0022_16S
L781_BEC0023_16S
L782_BEC0024_16S
L783_BEC0025_16S
Traceback (most recent call last):
  File "../../../scripts/pulling_readcount.py", line 5, in <module>
    with open("flexcleaned.log") as lf:
IOError: [Errno 2] No such file or directory: 'flexcleaned.log'
-bash: cd: L785_BEC0027_16S: No such file or directory
-bash: cd: L786_BEC0028_16S: No such file or directory
-bash: cd: L787_BEC0029_16S: No such file or directory
-bash: cd: L788_BEC0030_16S: No such file or directory
-bash: cd: L789_BEC0031_16S: No such file or directory
-bash: cd: L790_BEC0032_16S: No such file or directory
-bash: cd: L791_BEC0033_16S: No such file or directory
-bash: cd: L792_BEC0034_16S: No such file or directory
-bash: cd: L793_BEC0035_16S: No such file or directory
-bash: cd: L794_BEC0036_16S: No such file or directory
-bash: cd: L795_BEC0037_16S: No such file or directory
-bash: cd: L796_BEC0038_16S: No such file or directory
-bash: cd: L797_BEC0039_16S: No such file or directory
-bash: cd: L798_BEC0040_16S: No such file or directory
-bash: cd: L799_BEC0041_16S: No such file or directory
-bash: cd: L800_BEC0042_16S: No such file or directory
-bash: cd: L801_BEC0043_16S: No such file or directory
-bash: cd: L802_BEC0044_16S: No such file or directory
-bash: cd: L803_BEC0045_16S: No such file or directory
-bash: cd: L804_BEC0046_16S: No such file or directory
-bash: cd: L805_BEC0047_16S: No such file or directory
-bash: cd: L806_BEC0048_16S: No such file or directory
-bash: cd: L807_BEC0049_16S: No such file or directory
-bash: cd: L808_BEC0050_16S: No such file or directory
-bash: cd: L809_BEC0051_16S: No such file or directory
-bash: cd: L810_BEC0052_16S: No such file or directory
-bash: cd: L811_BEC0053_16S: No such file or directory
-bash: cd: L812_BEC0054_16S: No such file or directory
-bash: cd: L813_BEC0055_16S: No such file or directory
-bash: cd: L814_BEC0056_16S: No such file or directory
-bash: cd: L815_BEC0057_16S: No such file or directory
-bash: cd: MPL: No such file or directory
[rebeccaclement@cpu046 L784_BEC0026_16S]$ cd ..
[rebeccaclement@cpu046 Analysis]$ ls
L759_BEC0001_16S  L774_BEC0016_16S  L789_BEC0031_16S  L804_BEC0046_16S
L760_BEC0002_16S  L775_BEC0017_16S  L790_BEC0032_16S  L805_BEC0047_16S
L761_BEC0003_16S  L776_BEC0018_16S  L791_BEC0033_16S  L806_BEC0048_16S
L762_BEC0004_16S  L777_BEC0019_16S  L792_BEC0034_16S  L807_BEC0049_16S
L763_BEC0005_16S  L778_BEC0020_16S  L793_BEC0035_16S  L808_BEC0050_16S
L764_BEC0006_16S  L779_BEC0021_16S  L794_BEC0036_16S  L809_BEC0051_16S
L765_BEC0007_16S  L780_BEC0022_16S  L795_BEC0037_16S  L810_BEC0052_16S
L766_BEC0008_16S  L781_BEC0023_16S  L796_BEC0038_16S  L811_BEC0053_16S
L767_BEC0009_16S  L782_BEC0024_16S  L797_BEC0039_16S  L812_BEC0054_16S
L768_BEC0010_16S  L783_BEC0025_16S  L798_BEC0040_16S  L813_BEC0055_16S
L769_BEC0011_16S  L784_BEC0026_16S  L799_BEC0041_16S  L814_BEC0056_16S
L770_BEC0012_16S  L785_BEC0027_16S  L800_BEC0042_16S  L815_BEC0057_16S
L771_BEC0013_16S  L786_BEC0028_16S  L801_BEC0043_16S  MPL
L772_BEC0014_16S  L787_BEC0029_16S  L802_BEC0044_16S
L773_BEC0015_16S  L788_BEC0030_16S  L803_BEC0045_16S
[rebeccaclement@cpu046 Analysis]$ ls L759_BEC0001_16S/
flexbar_reads.txt    flexcleaned.log
flexcleaned_1.fastq  L759_BEC0001_16S_Clement_20190529_S1_L001_R1_001.fastq.gz
flexcleaned_2.fastq  L759_BEC0001_16S_Clement_20190529_S1_L001_R2_001.fastq.gz
[rebeccaclement@cpu046 Analysis]$ ls L795_BEC0037_16S/
L795_BEC0037_16S_Clement_20190529_S37_L001_R1_001.fastq.gz
L795_BEC0037_16S_Clement_20190529_S37_L001_R2_001.fastq.gz
[rebeccaclement@cpu046 Analysis]$ cd ..
[rebeccaclement@cpu046 termite_16S]$ ls
Analysis  fastqc_cleaned  outfastqc16S  outflexbar16S  samps.txt
[rebeccaclement@cpu046 termite_16S]$ ls outflexbar16S/
flex.327861_10.err  flex.327861_16.out  flex.327861_22.err  flex.327861_4.out
flex.327861_10.out  flex.327861_17.err  flex.327861_22.out  flex.327861_5.err
flex.327861_11.err  flex.327861_17.out  flex.327861_23.err  flex.327861_5.out
flex.327861_11.out  flex.327861_18.err  flex.327861_23.out  flex.327861_6.err
flex.327861_12.err  flex.327861_18.out  flex.327861_24.err  flex.327861_6.out
flex.327861_12.out  flex.327861_19.err  flex.327861_24.out  flex.327861_7.err
flex.327861_13.err  flex.327861_19.out  flex.327861_25.err  flex.327861_7.out
flex.327861_13.out  flex.327861_1.err   flex.327861_25.out  flex.327861_8.err
flex.327861_14.err  flex.327861_1.out   flex.327861_2.err   flex.327861_8.out
flex.327861_14.out  flex.327861_20.err  flex.327861_2.out   flex.327861_9.err
flex.327861_15.err  flex.327861_20.out  flex.327861_3.err   flex.327861_9.out
flex.327861_15.out  flex.327861_21.err  flex.327861_3.out
flex.327861_16.err  flex.327861_21.out  flex.327861_4.err
[rebeccaclement@cpu046 termite_16S]$ ls Analysis/
L759_BEC0001_16S  L774_BEC0016_16S  L789_BEC0031_16S  L804_BEC0046_16S
L760_BEC0002_16S  L775_BEC0017_16S  L790_BEC0032_16S  L805_BEC0047_16S
L761_BEC0003_16S  L776_BEC0018_16S  L791_BEC0033_16S  L806_BEC0048_16S
L762_BEC0004_16S  L777_BEC0019_16S  L792_BEC0034_16S  L807_BEC0049_16S
L763_BEC0005_16S  L778_BEC0020_16S  L793_BEC0035_16S  L808_BEC0050_16S
L764_BEC0006_16S  L779_BEC0021_16S  L794_BEC0036_16S  L809_BEC0051_16S
L765_BEC0007_16S  L780_BEC0022_16S  L795_BEC0037_16S  L810_BEC0052_16S
L766_BEC0008_16S  L781_BEC0023_16S  L796_BEC0038_16S  L811_BEC0053_16S
L767_BEC0009_16S  L782_BEC0024_16S  L797_BEC0039_16S  L812_BEC0054_16S
L768_BEC0010_16S  L783_BEC0025_16S  L798_BEC0040_16S  L813_BEC0055_16S
L769_BEC0011_16S  L784_BEC0026_16S  L799_BEC0041_16S  L814_BEC0056_16S
L770_BEC0012_16S  L785_BEC0027_16S  L800_BEC0042_16S  L815_BEC0057_16S
L771_BEC0013_16S  L786_BEC0028_16S  L801_BEC0043_16S  MPL
L772_BEC0014_16S  L787_BEC0029_16S  L802_BEC0044_16S
L773_BEC0015_16S  L788_BEC0030_16S  L803_BEC0045_16S
[rebeccaclement@cpu046 termite_16S]$ cd ..
[rebeccaclement@cpu046 glustre]$ cd termite_16S
[rebeccaclement@cpu046 termite_16S]$ ls
Analysis  fastqc_cleaned  outfastqc16S  outflexbar16S  samps.txt
[rebeccaclement@cpu046 termite_16S]$ cd Analysis/
[rebeccaclement@cpu046 Analysis]$ ls
L759_BEC0001_16S  L774_BEC0016_16S  L789_BEC0031_16S  L804_BEC0046_16S
L760_BEC0002_16S  L775_BEC0017_16S  L790_BEC0032_16S  L805_BEC0047_16S
L761_BEC0003_16S  L776_BEC0018_16S  L791_BEC0033_16S  L806_BEC0048_16S
L762_BEC0004_16S  L777_BEC0019_16S  L792_BEC0034_16S  L807_BEC0049_16S
L763_BEC0005_16S  L778_BEC0020_16S  L793_BEC0035_16S  L808_BEC0050_16S
L764_BEC0006_16S  L779_BEC0021_16S  L794_BEC0036_16S  L809_BEC0051_16S
L765_BEC0007_16S  L780_BEC0022_16S  L795_BEC0037_16S  L810_BEC0052_16S
L766_BEC0008_16S  L781_BEC0023_16S  L796_BEC0038_16S  L811_BEC0053_16S
L767_BEC0009_16S  L782_BEC0024_16S  L797_BEC0039_16S  L812_BEC0054_16S

▽

L768_BEC0010_16S  L783_BEC0025_16S  L798_BEC0040_16S  L813_BEC0055_16S
L769_BEC0011_16S  L784_BEC0026_16S  L799_BEC0041_16S  L814_BEC0056_16S
L770_BEC0012_16S  L785_BEC0027_16S  L800_BEC0042_16S  L815_BEC0057_16S
L771_BEC0013_16S  L786_BEC0028_16S  L801_BEC0043_16S  MPL
L772_BEC0014_16S  L787_BEC0029_16S  L802_BEC0044_16S
L773_BEC0015_16S  L788_BEC0030_16S  L803_BEC0045_16S
[rebeccaclement@cpu046 Analysis]$ cd ..
[rebeccaclement@cpu046 termite_16S]$ ls
Analysis  fastqc_cleaned  outfastqc16S  outflexbar16S  samps.txt
[rebeccaclement@cpu046 termite_16S]$ ls outflexbar16S/
flex.327861_10.err  flex.327861_16.out  flex.327861_22.err  flex.327861_4.out
flex.327861_10.out  flex.327861_17.err  flex.327861_22.out  flex.327861_5.err
flex.327861_11.err  flex.327861_17.out  flex.327861_23.err  flex.327861_5.out
flex.327861_11.out  flex.327861_18.err  flex.327861_23.out  flex.327861_6.err
flex.327861_12.err  flex.327861_18.out  flex.327861_24.err  flex.327861_6.out
flex.327861_12.out  flex.327861_19.err  flex.327861_24.out  flex.327861_7.err
flex.327861_13.err  flex.327861_19.out  flex.327861_25.err  flex.327861_7.out
flex.327861_13.out  flex.327861_1.err   flex.327861_25.out  flex.327861_8.err
flex.327861_14.err  flex.327861_1.out   flex.327861_2.err   flex.327861_8.out
flex.327861_14.out  flex.327861_20.err  flex.327861_2.out   flex.327861_9.err
flex.327861_15.err  flex.327861_20.out  flex.327861_3.err   flex.327861_9.out
flex.327861_15.out  flex.327861_21.err  flex.327861_3.out
flex.327861_16.err  flex.327861_21.out  flex.327861_4.err
[rebeccaclement@cpu046 termite_16S]$ vim ../scripts/flexbar.sh
[rebeccaclement@cpu046 termite_16S]$ sbatch ../scripts/flexbar.sh
Submitted batch job 327916
[rebeccaclement@cpu046 termite_16S]$ squeue
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
            327891      tiny     bash rebeccac  R      15:43      1 cpu046
[rebeccaclement@cpu046 termite_16S]$ ls
Analysis            flex.327916_16.err  flex.327916_22.err  flex.327916_5.err
fastqc_cleaned      flex.327916_16.out  flex.327916_22.out  flex.327916_5.out
flex.327916_10.err  flex.327916_17.err  flex.327916_23.err  flex.327916_6.err
flex.327916_10.out  flex.327916_17.out  flex.327916_23.out  flex.327916_6.out
flex.327916_11.err  flex.327916_18.err  flex.327916_24.err  flex.327916_7.err
flex.327916_11.out  flex.327916_18.out  flex.327916_24.out  flex.327916_7.out
flex.327916_12.err  flex.327916_19.err  flex.327916_25.err  flex.327916_8.err
flex.327916_12.out  flex.327916_19.out  flex.327916_25.out  flex.327916_8.out
flex.327916_13.err  flex.327916_1.err   flex.327916_2.err   flex.327916_9.err
flex.327916_13.out  flex.327916_1.out   flex.327916_2.out   flex.327916_9.out
flex.327916_14.err  flex.327916_20.err  flex.327916_3.err   outfastqc16S
flex.327916_14.out  flex.327916_20.out  flex.327916_3.out   outflexbar16S
flex.327916_15.err  flex.327916_21.err  flex.327916_4.err   samps.txt
flex.327916_15.out  flex.327916_21.out  flex.327916_4.out
[rebeccaclement@cpu046 termite_16S]$ cat flex*
ls: cannot access Analysis/L768_BEC0010_16S/L768_BEC0010_16S_R1.fastq.gz: No such file or directory
ls: cannot access Analysis/L768_BEC0010_16S/L768_BEC0010_16S_R2.fastq.gz: No such file or directory

ERROR: Could not open file --reads2

L768_BEC0010_16S
[------] (Tue Oct 29 14:11:03 EDT 2019) 0 minutes and 0 seconds elapsed.
[------] (Tue Oct 29 14:11:03 EDT 2019)  COMPLETE.
ls: cannot access Analysis/L769_BEC0011_16S/L769_BEC0011_16S_R1.fastq.gz: No such file or directory
ls: cannot access Analysis/L769_BEC0011_16S/L769_BEC0011_16S_R2.fastq.gz: No such file or directory

ERROR: Could not open file --reads2

L769_BEC0011_16S
[------] (Tue Oct 29 14:11:03 EDT 2019) 0 minutes and 0 seconds elapsed.
[------] (Tue Oct 29 14:11:03 EDT 2019)  COMPLETE.
ls: cannot access Analysis/L770_BEC0012_16S/L770_BEC0012_16S_R1.fastq.gz: No such file or directory
ls: cannot access Analysis/L770_BEC0012_16S/L770_BEC0012_16S_R2.fastq.gz: No such file or directory

ERROR: Could not open file --reads2

L770_BEC0012_16S
[------] (Tue Oct 29 14:11:03 EDT 2019) 0 minutes and 0 seconds elapsed.
[------] (Tue Oct 29 14:11:03 EDT 2019)  COMPLETE.
ls: cannot access Analysis/L771_BEC0013_16S/L771_BEC0013_16S_R1.fastq.gz: No such file or directory
ls: cannot access Analysis/L771_BEC0013_16S/L771_BEC0013_16S_R2.fastq.gz: No such file or directory

ERROR: Could not open file --reads2

L771_BEC0013_16S
[------] (Tue Oct 29 14:11:03 EDT 2019) 0 minutes and 0 seconds elapsed.
[------] (Tue Oct 29 14:11:03 EDT 2019)  COMPLETE.
ls: cannot access Analysis/L772_BEC0014_16S/L772_BEC0014_16S_R1.fastq.gz: No such file or directory
ls: cannot access Analysis/L772_BEC0014_16S/L772_BEC0014_16S_R2.fastq.gz: No such file or directory

ERROR: Could not open file --reads2

L772_BEC0014_16S
[------] (Tue Oct 29 14:11:03 EDT 2019) 0 minutes and 0 seconds elapsed.
[------] (Tue Oct 29 14:11:03 EDT 2019)  COMPLETE.
ls: cannot access Analysis/L773_BEC0015_16S/L773_BEC0015_16S_R1.fastq.gz: No such file or directory
ls: cannot access Analysis/L773_BEC0015_16S/L773_BEC0015_16S_R2.fastq.gz: No such file or directory

ERROR: Could not open file --reads2

L773_BEC0015_16S
[------] (Tue Oct 29 14:11:03 EDT 2019) 0 minutes and 0 seconds elapsed.
[------] (Tue Oct 29 14:11:03 EDT 2019)  COMPLETE.
ls: cannot access Analysis/L774_BEC0016_16S/L774_BEC0016_16S_R1.fastq.gz: No such file or directory
ls: cannot access Analysis/L774_BEC0016_16S/L774_BEC0016_16S_R2.fastq.gz: No such file or directory

ERROR: Could not open file --reads2

L774_BEC0016_16S
[------] (Tue Oct 29 14:11:03 EDT 2019) 0 minutes and 0 seconds elapsed.
[------] (Tue Oct 29 14:11:03 EDT 2019)  COMPLETE.
ls: cannot access Analysis/L775_BEC0017_16S/L775_BEC0017_16S_R1.fastq.gz: No such file or directory
ls: cannot access Analysis/L775_BEC0017_16S/L775_BEC0017_16S_R2.fastq.gz: No such file or directory

ERROR: Could not open file --reads2

L775_BEC0017_16S
[------] (Tue Oct 29 14:11:03 EDT 2019) 0 minutes and 0 seconds elapsed.
[------] (Tue Oct 29 14:11:03 EDT 2019)  COMPLETE.
ls: cannot access Analysis/L776_BEC0018_16S/L776_BEC0018_16S_R1.fastq.gz: No such file or directory
ls: cannot access Analysis/L776_BEC0018_16S/L776_BEC0018_16S_R2.fastq.gz: No such file or directory

ERROR: Could not open file --reads2

L776_BEC0018_16S
[------] (Tue Oct 29 14:11:03 EDT 2019) 0 minutes and 0 seconds elapsed.
[------] (Tue Oct 29 14:11:03 EDT 2019)  COMPLETE.
ls: cannot access Analysis/L777_BEC0019_16S/L777_BEC0019_16S_R1.fastq.gz: No such file or directory
ls: cannot access Analysis/L777_BEC0019_16S/L777_BEC0019_16S_R2.fastq.gz: No such file or directory

ERROR: Could not open file --reads2

L777_BEC0019_16S
[------] (Tue Oct 29 14:11:03 EDT 2019) 0 minutes and 0 seconds elapsed.
[------] (Tue Oct 29 14:11:03 EDT 2019)  COMPLETE.
ls: cannot access Analysis/L759_BEC0001_16S/L759_BEC0001_16S_R1.fastq.gz: No such file or directory
ls: cannot access Analysis/L759_BEC0001_16S/L759_BEC0001_16S_R2.fastq.gz: No such file or directory

ERROR: Could not open file --reads2

L759_BEC0001_16S
[------] (Tue Oct 29 14:11:03 EDT 2019) 0 minutes and 0 seconds elapsed.
[------] (Tue Oct 29 14:11:03 EDT 2019)  COMPLETE.
ls: cannot access Analysis/L778_BEC0020_16S/L778_BEC0020_16S_R1.fastq.gz: No such file or directory
ls: cannot access Analysis/L778_BEC0020_16S/L778_BEC0020_16S_R2.fastq.gz: No such file or directory

ERROR: Could not open file --reads2

L778_BEC0020_16S
[------] (Tue Oct 29 14:11:03 EDT 2019) 0 minutes and 0 seconds elapsed.
[------] (Tue Oct 29 14:11:03 EDT 2019)  COMPLETE.
ls: cannot access Analysis/L779_BEC0021_16S/L779_BEC0021_16S_R1.fastq.gz: No such file or directory
ls: cannot access Analysis/L779_BEC0021_16S/L779_BEC0021_16S_R2.fastq.gz: No such file or directory

ERROR: Could not open file --reads2

L779_BEC0021_16S
[------] (Tue Oct 29 14:11:03 EDT 2019) 0 minutes and 0 seconds elapsed.
[------] (Tue Oct 29 14:11:03 EDT 2019)  COMPLETE.
ls: cannot access Analysis/L780_BEC0022_16S/L780_BEC0022_16S_R1.fastq.gz: No such file or directory
ls: cannot access Analysis/L780_BEC0022_16S/L780_BEC0022_16S_R2.fastq.gz: No such file or directory

ERROR: Could not open file --reads2

L780_BEC0022_16S
[------] (Tue Oct 29 14:11:03 EDT 2019) 0 minutes and 0 seconds elapsed.
[------] (Tue Oct 29 14:11:03 EDT 2019)  COMPLETE.
ls: cannot access Analysis/L781_BEC0023_16S/L781_BEC0023_16S_R1.fastq.gz: No such file or directory
ls: cannot access Analysis/L781_BEC0023_16S/L781_BEC0023_16S_R2.fastq.gz: No such file or directory

ERROR: Could not open file --reads2

L781_BEC0023_16S
[------] (Tue Oct 29 14:11:03 EDT 2019) 0 minutes and 0 seconds elapsed.
[------] (Tue Oct 29 14:11:03 EDT 2019)  COMPLETE.
ls: cannot access Analysis/L782_BEC0024_16S/L782_BEC0024_16S_R1.fastq.gz: No such file or directory
ls: cannot access Analysis/L782_BEC0024_16S/L782_BEC0024_16S_R2.fastq.gz: No such file or directory

ERROR: Could not open file --reads2

L782_BEC0024_16S
[------] (Tue Oct 29 14:11:03 EDT 2019) 0 minutes and 0 seconds elapsed.
[------] (Tue Oct 29 14:11:03 EDT 2019)  COMPLETE.
ls: cannot access Analysis/L783_BEC0025_16S/L783_BEC0025_16S_R1.fastq.gz: No such file or directory
ls: cannot access Analysis/L783_BEC0025_16S/L783_BEC0025_16S_R2.fastq.gz: No such file or directory

ERROR: Could not open file --reads2

L783_BEC0025_16S
[------] (Tue Oct 29 14:11:03 EDT 2019) 0 minutes and 0 seconds elapsed.
[------] (Tue Oct 29 14:11:03 EDT 2019)  COMPLETE.
ls: cannot access Analysis/L760_BEC0002_16S/L760_BEC0002_16S_R1.fastq.gz: No such file or directory
ls: cannot access Analysis/L760_BEC0002_16S/L760_BEC0002_16S_R2.fastq.gz: No such file or directory

ERROR: Could not open file --reads2

L760_BEC0002_16S
[------] (Tue Oct 29 14:11:04 EDT 2019) 0 minutes and 1 seconds elapsed.
[------] (Tue Oct 29 14:11:04 EDT 2019)  COMPLETE.
ls: cannot access Analysis/L761_BEC0003_16S/L761_BEC0003_16S_R1.fastq.gz: No such file or directory
ls: cannot access Analysis/L761_BEC0003_16S/L761_BEC0003_16S_R2.fastq.gz: No such file or directory

ERROR: Could not open file --reads2

L761_BEC0003_16S
[------] (Tue Oct 29 14:11:03 EDT 2019) 0 minutes and 0 seconds elapsed.
[------] (Tue Oct 29 14:11:03 EDT 2019)  COMPLETE.
ls: cannot access Analysis/L762_BEC0004_16S/L762_BEC0004_16S_R1.fastq.gz: No such file or directory
ls: cannot access Analysis/L762_BEC0004_16S/L762_BEC0004_16S_R2.fastq.gz: No such file or directory

ERROR: Could not open file --reads2

L762_BEC0004_16S
[------] (Tue Oct 29 14:11:03 EDT 2019) 0 minutes and 0 seconds elapsed.
[------] (Tue Oct 29 14:11:03 EDT 2019)  COMPLETE.
ls: cannot access Analysis/L763_BEC0005_16S/L763_BEC0005_16S_R1.fastq.gz: No such file or directory
ls: cannot access Analysis/L763_BEC0005_16S/L763_BEC0005_16S_R2.fastq.gz: No such file or directory

ERROR: Could not open file --reads2

L763_BEC0005_16S
[------] (Tue Oct 29 14:11:03 EDT 2019) 0 minutes and 0 seconds elapsed.
[------] (Tue Oct 29 14:11:03 EDT 2019)  COMPLETE.
ls: cannot access Analysis/L764_BEC0006_16S/L764_BEC0006_16S_R1.fastq.gz: No such file or directory
ls: cannot access Analysis/L764_BEC0006_16S/L764_BEC0006_16S_R2.fastq.gz: No such file or directory

ERROR: Could not open file --reads2

L764_BEC0006_16S
[------] (Tue Oct 29 14:11:03 EDT 2019) 0 minutes and 0 seconds elapsed.
[------] (Tue Oct 29 14:11:03 EDT 2019)  COMPLETE.
ls: cannot access Analysis/L765_BEC0007_16S/L765_BEC0007_16S_R1.fastq.gz: No such file or directory
ls: cannot access Analysis/L765_BEC0007_16S/L765_BEC0007_16S_R2.fastq.gz: No such file or directory

ERROR: Could not open file --reads2

L765_BEC0007_16S
[------] (Tue Oct 29 14:11:03 EDT 2019) 0 minutes and 0 seconds elapsed.
[------] (Tue Oct 29 14:11:03 EDT 2019)  COMPLETE.
ls: cannot access Analysis/L766_BEC0008_16S/L766_BEC0008_16S_R1.fastq.gz: No such file or directory
ls: cannot access Analysis/L766_BEC0008_16S/L766_BEC0008_16S_R2.fastq.gz: No such file or directory

ERROR: Could not open file --reads2

L766_BEC0008_16S
[------] (Tue Oct 29 14:11:03 EDT 2019) 0 minutes and 0 seconds elapsed.
[------] (Tue Oct 29 14:11:03 EDT 2019)  COMPLETE.
ls: cannot access Analysis/L767_BEC0009_16S/L767_BEC0009_16S_R1.fastq.gz: No such file or directory
ls: cannot access Analysis/L767_BEC0009_16S/L767_BEC0009_16S_R2.fastq.gz: No such file or directory

ERROR: Could not open file --reads2

L767_BEC0009_16S
[------] (Tue Oct 29 14:11:03 EDT 2019) 0 minutes and 0 seconds elapsed.
[------] (Tue Oct 29 14:11:03 EDT 2019)  COMPLETE.
[rebeccaclement@cpu046 termite_16S]$ ls
Analysis            flex.327916_16.err  flex.327916_22.err  flex.327916_5.err
fastqc_cleaned      flex.327916_16.out  flex.327916_22.out  flex.327916_5.out
flex.327916_10.err  flex.327916_17.err  flex.327916_23.err  flex.327916_6.err
flex.327916_10.out  flex.327916_17.out  flex.327916_23.out  flex.327916_6.out
flex.327916_11.err  flex.327916_18.err  flex.327916_24.err  flex.327916_7.err
flex.327916_11.out  flex.327916_18.out  flex.327916_24.out  flex.327916_7.out
flex.327916_12.err  flex.327916_19.err  flex.327916_25.err  flex.327916_8.err
flex.327916_12.out  flex.327916_19.out  flex.327916_25.out  flex.327916_8.out
flex.327916_13.err  flex.327916_1.err   flex.327916_2.err   flex.327916_9.err
flex.327916_13.out  flex.327916_1.out   flex.327916_2.out   flex.327916_9.out
flex.327916_14.err  flex.327916_20.err  flex.327916_3.err   outfastqc16S
flex.327916_14.out  flex.327916_20.out  flex.327916_3.out   outflexbar16S
flex.327916_15.err  flex.327916_21.err  flex.327916_4.err   samps.txt
flex.327916_15.out  flex.327916_21.out  flex.327916_4.out
[rebeccaclement@cpu046 termite_16S]$ rm flex*
[rebeccaclement@cpu046 termite_16S]$ ls
Analysis  fastqc_cleaned  outfastqc16S  outflexbar16S  samps.txt
[rebeccaclement@cpu046 termite_16S]$ sbatch ../scripts/flexbar16S.sh
Submitted batch job 327941
[rebeccaclement@cpu046 termite_16S]$ squeue
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          327941_1      defq flexbar1 rebeccac  R       0:06      1 cpu153
          327941_2      defq flexbar1 rebeccac  R       0:06      1 cpu154
          327941_3      defq flexbar1 rebeccac  R       0:06      1 cpu155
          327941_5      defq flexbar1 rebeccac  R       0:06      1 cpu157
          327941_6      defq flexbar1 rebeccac  R       0:06      1 cpu158
          327941_7      defq flexbar1 rebeccac  R       0:06      1 cpu159
          327941_8      defq flexbar1 rebeccac  R       0:06      1 cpu160
          327941_9      defq flexbar1 rebeccac  R       0:06      1 cpu161
         327941_10      defq flexbar1 rebeccac  R       0:06      1 cpu162
         327941_11      defq flexbar1 rebeccac  R       0:06      1 cpu163
         327941_12      defq flexbar1 rebeccac  R       0:06      1 cpu164
         327941_13      defq flexbar1 rebeccac  R       0:06      1 cpu047
         327941_14      defq flexbar1 rebeccac  R       0:06      1 cpu048
         327941_15      defq flexbar1 rebeccac  R       0:06      1 cpu049
         327941_16      defq flexbar1 rebeccac  R       0:06      1 cpu050
         327941_17      defq flexbar1 rebeccac  R       0:06      1 cpu051
         327941_18      defq flexbar1 rebeccac  R       0:06      1 cpu052
         327941_19      defq flexbar1 rebeccac  R       0:06      1 cpu053
         327941_20      defq flexbar1 rebeccac  R       0:06      1 cpu054
         327941_21      defq flexbar1 rebeccac  R       0:06      1 cpu055
         327941_22      defq flexbar1 rebeccac  R       0:06      1 cpu056
         327941_23      defq flexbar1 rebeccac  R       0:06      1 cpu057
         327941_24      defq flexbar1 rebeccac  R       0:06      1 cpu058
         327941_25      defq flexbar1 rebeccac  R       0:06      1 cpu059
            327891      tiny     bash rebeccac  R      18:53      1 cpu046
[rebeccaclement@cpu046 termite_16S]$ ls
Analysis            flex.327941_16.err  flex.327941_22.err  flex.327941_5.err
fastqc_cleaned      flex.327941_16.out  flex.327941_22.out  flex.327941_5.out
flex.327941_10.err  flex.327941_17.err  flex.327941_23.err  flex.327941_6.err
flex.327941_10.out  flex.327941_17.out  flex.327941_23.out  flex.327941_6.out
flex.327941_11.err  flex.327941_18.err  flex.327941_24.err  flex.327941_7.err
flex.327941_11.out  flex.327941_18.out  flex.327941_24.out  flex.327941_7.out
flex.327941_12.err  flex.327941_19.err  flex.327941_25.err  flex.327941_8.err
flex.327941_12.out  flex.327941_19.out  flex.327941_25.out  flex.327941_8.out
flex.327941_13.err  flex.327941_1.err   flex.327941_2.err   flex.327941_9.err
flex.327941_13.out  flex.327941_1.out   flex.327941_2.out   flex.327941_9.out
flex.327941_14.err  flex.327941_20.err  flex.327941_3.err   outfastqc16S
flex.327941_14.out  flex.327941_20.out  flex.327941_3.out   outflexbar16S
flex.327941_15.err  flex.327941_21.err  flex.327941_4.err   samps.txt
flex.327941_15.out  flex.327941_21.out  flex.327941_4.out
[rebeccaclement@cpu046 termite_16S]$ squeue
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
            327891      tiny     bash rebeccac  R      19:03      1 cpu046
[rebeccaclement@cpu046 termite_16S]$ ls
Analysis            flex.327941_16.err  flex.327941_22.err  flex.327941_5.err
fastqc_cleaned      flex.327941_16.out  flex.327941_22.out  flex.327941_5.out
flex.327941_10.err  flex.327941_17.err  flex.327941_23.err  flex.327941_6.err
flex.327941_10.out  flex.327941_17.out  flex.327941_23.out  flex.327941_6.out
flex.327941_11.err  flex.327941_18.err  flex.327941_24.err  flex.327941_7.err
flex.327941_11.out  flex.327941_18.out  flex.327941_24.out  flex.327941_7.out
flex.327941_12.err  flex.327941_19.err  flex.327941_25.err  flex.327941_8.err
flex.327941_12.out  flex.327941_19.out  flex.327941_25.out  flex.327941_8.out
flex.327941_13.err  flex.327941_1.err   flex.327941_2.err   flex.327941_9.err
flex.327941_13.out  flex.327941_1.out   flex.327941_2.out   flex.327941_9.out
flex.327941_14.err  flex.327941_20.err  flex.327941_3.err   outfastqc16S
flex.327941_14.out  flex.327941_20.out  flex.327941_3.out   outflexbar16S
flex.327941_15.err  flex.327941_21.err  flex.327941_4.err   samps.txt
flex.327941_15.out  flex.327941_21.out  flex.327941_4.out
[rebeccaclement@cpu046 termite_16S]$ cat flex*
L768_BEC0010_16S
[------] (Tue Oct 29 14:14:18 EDT 2019) 0 minutes and 10 seconds elapsed.
[------] (Tue Oct 29 14:14:18 EDT 2019)  COMPLETE.
L769_BEC0011_16S
[------] (Tue Oct 29 14:14:18 EDT 2019) 0 minutes and 10 seconds elapsed.
[------] (Tue Oct 29 14:14:18 EDT 2019)  COMPLETE.
L770_BEC0012_16S
[------] (Tue Oct 29 14:14:17 EDT 2019) 0 minutes and 9 seconds elapsed.
[------] (Tue Oct 29 14:14:17 EDT 2019)  COMPLETE.
L771_BEC0013_16S
[------] (Tue Oct 29 14:14:17 EDT 2019) 0 minutes and 9 seconds elapsed.
[------] (Tue Oct 29 14:14:17 EDT 2019)  COMPLETE.
L772_BEC0014_16S
[------] (Tue Oct 29 14:14:17 EDT 2019) 0 minutes and 9 seconds elapsed.
[------] (Tue Oct 29 14:14:17 EDT 2019)  COMPLETE.
L773_BEC0015_16S
[------] (Tue Oct 29 14:14:17 EDT 2019) 0 minutes and 9 seconds elapsed.
[------] (Tue Oct 29 14:14:17 EDT 2019)  COMPLETE.
L774_BEC0016_16S
[------] (Tue Oct 29 14:14:16 EDT 2019) 0 minutes and 8 seconds elapsed.
[------] (Tue Oct 29 14:14:16 EDT 2019)  COMPLETE.
L775_BEC0017_16S
[------] (Tue Oct 29 14:14:16 EDT 2019) 0 minutes and 8 seconds elapsed.
[------] (Tue Oct 29 14:14:16 EDT 2019)  COMPLETE.
L776_BEC0018_16S
[------] (Tue Oct 29 14:14:17 EDT 2019) 0 minutes and 9 seconds elapsed.
[------] (Tue Oct 29 14:14:17 EDT 2019)  COMPLETE.
L777_BEC0019_16S
[------] (Tue Oct 29 14:14:17 EDT 2019) 0 minutes and 9 seconds elapsed.
[------] (Tue Oct 29 14:14:17 EDT 2019)  COMPLETE.
L759_BEC0001_16S
[------] (Tue Oct 29 14:14:19 EDT 2019) 0 minutes and 11 seconds elapsed.
[------] (Tue Oct 29 14:14:19 EDT 2019)  COMPLETE.
L778_BEC0020_16S
[------] (Tue Oct 29 14:14:17 EDT 2019) 0 minutes and 9 seconds elapsed.
[------] (Tue Oct 29 14:14:17 EDT 2019)  COMPLETE.
L779_BEC0021_16S
[------] (Tue Oct 29 14:14:16 EDT 2019) 0 minutes and 8 seconds elapsed.
[------] (Tue Oct 29 14:14:16 EDT 2019)  COMPLETE.
L780_BEC0022_16S
[------] (Tue Oct 29 14:14:15 EDT 2019) 0 minutes and 7 seconds elapsed.
[------] (Tue Oct 29 14:14:15 EDT 2019)  COMPLETE.
L781_BEC0023_16S
[------] (Tue Oct 29 14:14:17 EDT 2019) 0 minutes and 9 seconds elapsed.
[------] (Tue Oct 29 14:14:17 EDT 2019)  COMPLETE.
L782_BEC0024_16S
[------] (Tue Oct 29 14:14:16 EDT 2019) 0 minutes and 8 seconds elapsed.
[------] (Tue Oct 29 14:14:16 EDT 2019)  COMPLETE.
L783_BEC0025_16S
[------] (Tue Oct 29 14:14:16 EDT 2019) 0 minutes and 8 seconds elapsed.
[------] (Tue Oct 29 14:14:16 EDT 2019)  COMPLETE.
L760_BEC0002_16S
[------] (Tue Oct 29 14:14:16 EDT 2019) 0 minutes and 8 seconds elapsed.
[------] (Tue Oct 29 14:14:16 EDT 2019)  COMPLETE.
L761_BEC0003_16S
[------] (Tue Oct 29 14:14:15 EDT 2019) 0 minutes and 7 seconds elapsed.
[------] (Tue Oct 29 14:14:15 EDT 2019)  COMPLETE.
L762_BEC0004_16S
[------] (Tue Oct 29 14:14:14 EDT 2019) 0 minutes and 6 seconds elapsed.
[------] (Tue Oct 29 14:14:14 EDT 2019)  COMPLETE.
L763_BEC0005_16S
[------] (Tue Oct 29 14:14:17 EDT 2019) 0 minutes and 9 seconds elapsed.
[------] (Tue Oct 29 14:14:17 EDT 2019)  COMPLETE.
L764_BEC0006_16S
[------] (Tue Oct 29 14:14:19 EDT 2019) 0 minutes and 11 seconds elapsed.
[------] (Tue Oct 29 14:14:19 EDT 2019)  COMPLETE.
L765_BEC0007_16S
[------] (Tue Oct 29 14:14:16 EDT 2019) 0 minutes and 8 seconds elapsed.
[------] (Tue Oct 29 14:14:16 EDT 2019)  COMPLETE.
L766_BEC0008_16S
[------] (Tue Oct 29 14:14:17 EDT 2019) 0 minutes and 9 seconds elapsed.
[------] (Tue Oct 29 14:14:17 EDT 2019)  COMPLETE.
L767_BEC0009_16S
[------] (Tue Oct 29 14:14:16 EDT 2019) 0 minutes and 8 seconds elapsed.
[------] (Tue Oct 29 14:14:16 EDT 2019)  COMPLETE.
[rebeccaclement@cpu046 termite_16S]$ ls
Analysis            flex.327941_16.err  flex.327941_22.err  flex.327941_5.err
fastqc_cleaned      flex.327941_16.out  flex.327941_22.out  flex.327941_5.out
flex.327941_10.err  flex.327941_17.err  flex.327941_23.err  flex.327941_6.err
flex.327941_10.out  flex.327941_17.out  flex.327941_23.out  flex.327941_6.out
flex.327941_11.err  flex.327941_18.err  flex.327941_24.err  flex.327941_7.err
flex.327941_11.out  flex.327941_18.out  flex.327941_24.out  flex.327941_7.out
flex.327941_12.err  flex.327941_19.err  flex.327941_25.err  flex.327941_8.err
flex.327941_12.out  flex.327941_19.out  flex.327941_25.out  flex.327941_8.out
flex.327941_13.err  flex.327941_1.err   flex.327941_2.err   flex.327941_9.err
flex.327941_13.out  flex.327941_1.out   flex.327941_2.out   flex.327941_9.out
flex.327941_14.err  flex.327941_20.err  flex.327941_3.err   outfastqc16S
flex.327941_14.out  flex.327941_20.out  flex.327941_3.out   outflexbar16S
flex.327941_15.err  flex.327941_21.err  flex.327941_4.err   samps.txt
flex.327941_15.out  flex.327941_21.out  flex.327941_4.out
[rebeccaclement@cpu046 termite_16S]$ mv flex* outflexbar16S/
[rebeccaclement@cpu046 termite_16S]$ ls
Analysis  fastqc_cleaned  outfastqc16S  outflexbar16S  samps.txt
[rebeccaclement@cpu046 termite_16S]$ cd Analysis/
[rebeccaclement@cpu046 Analysis]$ ls
L759_BEC0001_16S  L774_BEC0016_16S  L789_BEC0031_16S  L804_BEC0046_16S
L760_BEC0002_16S  L775_BEC0017_16S  L790_BEC0032_16S  L805_BEC0047_16S
L761_BEC0003_16S  L776_BEC0018_16S  L791_BEC0033_16S  L806_BEC0048_16S
L762_BEC0004_16S  L777_BEC0019_16S  L792_BEC0034_16S  L807_BEC0049_16S
L763_BEC0005_16S  L778_BEC0020_16S  L793_BEC0035_16S  L808_BEC0050_16S
L764_BEC0006_16S  L779_BEC0021_16S  L794_BEC0036_16S  L809_BEC0051_16S
L765_BEC0007_16S  L780_BEC0022_16S  L795_BEC0037_16S  L810_BEC0052_16S
L766_BEC0008_16S  L781_BEC0023_16S  L796_BEC0038_16S  L811_BEC0053_16S
L767_BEC0009_16S  L782_BEC0024_16S  L797_BEC0039_16S  L812_BEC0054_16S
L768_BEC0010_16S  L783_BEC0025_16S  L798_BEC0040_16S  L813_BEC0055_16S
L769_BEC0011_16S  L784_BEC0026_16S  L799_BEC0041_16S  L814_BEC0056_16S
L770_BEC0012_16S  L785_BEC0027_16S  L800_BEC0042_16S  L815_BEC0057_16S
L771_BEC0013_16S  L786_BEC0028_16S  L801_BEC0043_16S  MPL
L772_BEC0014_16S  L787_BEC0029_16S  L802_BEC0044_16S
L773_BEC0015_16S  L788_BEC0030_16S  L803_BEC0045_16S
[rebeccaclement@cpu046 Analysis]$ ls L759_BEC0001_16S/
flexbar_reads.txt    flexcleaned.log
flexcleaned_1.fastq  L759_BEC0001_16S_Clement_20190529_S1_L001_R1_001.fastq.gz
flexcleaned_2.fastq  L759_BEC0001_16S_Clement_20190529_S1_L001_R2_001.fastq.gz
[rebeccaclement@cpu046 Analysis]$ ls L815_BEC0057_16S/
L815_BEC0057_16S_Clement_20190529_S57_L001_R1_001.fastq.gz
L815_BEC0057_16S_Clement_20190529_S57_L001_R2_001.fastq.gz
[rebeccaclement@cpu046 Analysis]$ ls L768
ls: cannot access L768: No such file or directory
[rebeccaclement@cpu046 Analysis]$ ls L768_BEC0010_16S/
flexbar_reads.txt    flexcleaned.log
flexcleaned_1.fastq  L768_BEC0010_16S_Clement_20190529_S10_L001_R1_001.fastq.gz
flexcleaned_2.fastq  L768_BEC0010_16S_Clement_20190529_S10_L001_R2_001.fastq.gz
[rebeccaclement@cpu046 Analysis]$ ls L767
ls: cannot access L767: No such file or directory
[rebeccaclement@cpu046 Analysis]$ ls L767_BEC0009_16S/
flexbar_reads.txt    flexcleaned.log
flexcleaned_1.fastq  L767_BEC0009_16S_Clement_20190529_S9_L001_R1_001.fastq.gz
flexcleaned_2.fastq  L767_BEC0009_16S_Clement_20190529_S9_L001_R2_001.fastq.gz
[rebeccaclement@cpu046 Analysis]$ ls L769_BEC0011_16S/
flexbar_reads.txt    flexcleaned.log
flexcleaned_1.fastq  L769_BEC0011_16S_Clement_20190529_S11_L001_R1_001.fastq.gz
flexcleaned_2.fastq  L769_BEC0011_16S_Clement_20190529_S11_L001_R2_001.fastq.gz
[rebeccaclement@cpu046 Analysis]$ ls L780_BEC0022_16S/
flexbar_reads.txt    flexcleaned.log
flexcleaned_1.fastq  L780_BEC0022_16S_Clement_20190529_S22_L001_R1_001.fastq.gz
flexcleaned_2.fastq  L780_BEC0022_16S_Clement_20190529_S22_L001_R2_001.fastq.gz
[rebeccaclement@cpu046 Analysis]$ ls L781_BEC0023_16S/
flexbar_reads.txt    flexcleaned.log
flexcleaned_1.fastq  L781_BEC0023_16S_Clement_20190529_S23_L001_R1_001.fastq.gz
flexcleaned_2.fastq  L781_BEC0023_16S_Clement_20190529_S23_L001_R2_001.fastq.gz
[rebeccaclement@cpu046 Analysis]$ ls
L759_BEC0001_16S  L774_BEC0016_16S  L789_BEC0031_16S  L804_BEC0046_16S
L760_BEC0002_16S  L775_BEC0017_16S  L790_BEC0032_16S  L805_BEC0047_16S
L761_BEC0003_16S  L776_BEC0018_16S  L791_BEC0033_16S  L806_BEC0048_16S
L762_BEC0004_16S  L777_BEC0019_16S  L792_BEC0034_16S  L807_BEC0049_16S
L763_BEC0005_16S  L778_BEC0020_16S  L793_BEC0035_16S  L808_BEC0050_16S
L764_BEC0006_16S  L779_BEC0021_16S  L794_BEC0036_16S  L809_BEC0051_16S
L765_BEC0007_16S  L780_BEC0022_16S  L795_BEC0037_16S  L810_BEC0052_16S
L766_BEC0008_16S  L781_BEC0023_16S  L796_BEC0038_16S  L811_BEC0053_16S
L767_BEC0009_16S  L782_BEC0024_16S  L797_BEC0039_16S  L812_BEC0054_16S
L768_BEC0010_16S  L783_BEC0025_16S  L798_BEC0040_16S  L813_BEC0055_16S
L769_BEC0011_16S  L784_BEC0026_16S  L799_BEC0041_16S  L814_BEC0056_16S
L770_BEC0012_16S  L785_BEC0027_16S  L800_BEC0042_16S  L815_BEC0057_16S
L771_BEC0013_16S  L786_BEC0028_16S  L801_BEC0043_16S  MPL
L772_BEC0014_16S  L787_BEC0029_16S  L802_BEC0044_16S
L773_BEC0015_16S  L788_BEC0030_16S  L803_BEC0045_16S
[rebeccaclement@cpu046 Analysis]$ ls L814_BEC0056_16S/
L814_BEC0056_16S_Clement_20190529_S56_L001_R1_001.fastq.gz
L814_BEC0056_16S_Clement_20190529_S56_L001_R2_001.fastq.gz
[rebeccaclement@cpu046 Analysis]$ ls L804
ls: cannot access L804: No such file or directory
[rebeccaclement@cpu046 Analysis]$ cd ..
[rebeccaclement@cpu046 termite_16S]$ ls
Analysis  fastqc_cleaned  outfastqc16S  outflexbar16S  samps.txt
[rebeccaclement@cpu046 termite_16S]$ cat samps.txt
L759_BEC0001_16S
L760_BEC0002_16S
L761_BEC0003_16S
L762_BEC0004_16S
L763_BEC0005_16S
L764_BEC0006_16S
L765_BEC0007_16S
L766_BEC0008_16S
L767_BEC0009_16S
L768_BEC0010_16S
L769_BEC0011_16S
L770_BEC0012_16S
L771_BEC0013_16S
L772_BEC0014_16S
L773_BEC0015_16S
L774_BEC0016_16S
L775_BEC0017_16S
L776_BEC0018_16S
L777_BEC0019_16S
L778_BEC0020_16S
L779_BEC0021_16S
L780_BEC0022_16S
L781_BEC0023_16S
L782_BEC0024_16S
L783_BEC0025_16S
L784_BEC0026_16S
L785_BEC0027_16S
L786_BEC0028_16S
L787_BEC0029_16S
L788_BEC0030_16S
L789_BEC0031_16S
L790_BEC0032_16S
L791_BEC0033_16S
L792_BEC0034_16S
L793_BEC0035_16S
L794_BEC0036_16S
L795_BEC0037_16S
L796_BEC0038_16S
L797_BEC0039_16S
L798_BEC0040_16S
L799_BEC0041_16S
L800_BEC0042_16S
L801_BEC0043_16S
L802_BEC0044_16S
L803_BEC0045_16S
L804_BEC0046_16S
L805_BEC0047_16S
L806_BEC0048_16S
L807_BEC0049_16S
L808_BEC0050_16S
L809_BEC0051_16S
L810_BEC0052_16S
L811_BEC0053_16S
L812_BEC0054_16S
L813_BEC0055_16S
L814_BEC0056_16S
L815_BEC0057_16S
MPL
[rebeccaclement@cpu046 termite_16S]$ ls
Analysis  fastqc_cleaned  outfastqc16S  outflexbar16S  samps.txt
[rebeccaclement@cpu046 termite_16S]$ ls Analysis/
L759_BEC0001_16S  L774_BEC0016_16S  L789_BEC0031_16S  L804_BEC0046_16S
L760_BEC0002_16S  L775_BEC0017_16S  L790_BEC0032_16S  L805_BEC0047_16S
L761_BEC0003_16S  L776_BEC0018_16S  L791_BEC0033_16S  L806_BEC0048_16S
L762_BEC0004_16S  L777_BEC0019_16S  L792_BEC0034_16S  L807_BEC0049_16S
L763_BEC0005_16S  L778_BEC0020_16S  L793_BEC0035_16S  L808_BEC0050_16S
L764_BEC0006_16S  L779_BEC0021_16S  L794_BEC0036_16S  L809_BEC0051_16S
L765_BEC0007_16S  L780_BEC0022_16S  L795_BEC0037_16S  L810_BEC0052_16S
L766_BEC0008_16S  L781_BEC0023_16S  L796_BEC0038_16S  L811_BEC0053_16S
L767_BEC0009_16S  L782_BEC0024_16S  L797_BEC0039_16S  L812_BEC0054_16S
L768_BEC0010_16S  L783_BEC0025_16S  L798_BEC0040_16S  L813_BEC0055_16S
L769_BEC0011_16S  L784_BEC0026_16S  L799_BEC0041_16S  L814_BEC0056_16S
L770_BEC0012_16S  L785_BEC0027_16S  L800_BEC0042_16S  L815_BEC0057_16S
L771_BEC0013_16S  L786_BEC0028_16S  L801_BEC0043_16S  MPL
L772_BEC0014_16S  L787_BEC0029_16S  L802_BEC0044_16S
L773_BEC0015_16S  L788_BEC0030_16S  L803_BEC0045_16S
[rebeccaclement@cpu046 termite_16S]$ cd Analysis/
[rebeccaclement@cpu046 Analysis]$ ls L759
ls: cannot access L759: No such file or directory
[rebeccaclement@cpu046 Analysis]$ ls L759_BEC0001_16S/
flexbar_reads.txt    flexcleaned.log
flexcleaned_1.fastq  L759_BEC0001_16S_Clement_20190529_S1_L001_R1_001.fastq.gz
flexcleaned_2.fastq  L759_BEC0001_16S_Clement_20190529_S1_L001_R2_001.fastq.gz
[rebeccaclement@cpu046 Analysis]$ ls */flex*
L759_BEC0001_16S/flexbar_reads.txt    L771_BEC0013_16S/flexcleaned_2.fastq
L759_BEC0001_16S/flexcleaned_1.fastq  L771_BEC0013_16S/flexcleaned.log
L759_BEC0001_16S/flexcleaned_2.fastq  L772_BEC0014_16S/flexbar_reads.txt
L759_BEC0001_16S/flexcleaned.log      L772_BEC0014_16S/flexcleaned_1.fastq
L760_BEC0002_16S/flexbar_reads.txt    L772_BEC0014_16S/flexcleaned_2.fastq
L760_BEC0002_16S/flexcleaned_1.fastq  L772_BEC0014_16S/flexcleaned.log
L760_BEC0002_16S/flexcleaned_2.fastq  L773_BEC0015_16S/flexbar_reads.txt
L760_BEC0002_16S/flexcleaned.log      L773_BEC0015_16S/flexcleaned_1.fastq
L761_BEC0003_16S/flexbar_reads.txt    L773_BEC0015_16S/flexcleaned_2.fastq
L761_BEC0003_16S/flexcleaned_1.fastq  L773_BEC0015_16S/flexcleaned.log
L761_BEC0003_16S/flexcleaned_2.fastq  L774_BEC0016_16S/flexbar_reads.txt
L761_BEC0003_16S/flexcleaned.log      L774_BEC0016_16S/flexcleaned_1.fastq
L762_BEC0004_16S/flexbar_reads.txt    L774_BEC0016_16S/flexcleaned_2.fastq
L762_BEC0004_16S/flexcleaned_1.fastq  L774_BEC0016_16S/flexcleaned.log
L762_BEC0004_16S/flexcleaned_2.fastq  L775_BEC0017_16S/flexbar_reads.txt
L762_BEC0004_16S/flexcleaned.log      L775_BEC0017_16S/flexcleaned_1.fastq
L763_BEC0005_16S/flexbar_reads.txt    L775_BEC0017_16S/flexcleaned_2.fastq
L763_BEC0005_16S/flexcleaned_1.fastq  L775_BEC0017_16S/flexcleaned.log
L763_BEC0005_16S/flexcleaned_2.fastq  L776_BEC0018_16S/flexbar_reads.txt
L763_BEC0005_16S/flexcleaned.log      L776_BEC0018_16S/flexcleaned_1.fastq
L764_BEC0006_16S/flexbar_reads.txt    L776_BEC0018_16S/flexcleaned_2.fastq
L764_BEC0006_16S/flexcleaned_1.fastq  L776_BEC0018_16S/flexcleaned.log
L764_BEC0006_16S/flexcleaned_2.fastq  L777_BEC0019_16S/flexbar_reads.txt
L764_BEC0006_16S/flexcleaned.log      L777_BEC0019_16S/flexcleaned_1.fastq
L765_BEC0007_16S/flexbar_reads.txt    L777_BEC0019_16S/flexcleaned_2.fastq
L765_BEC0007_16S/flexcleaned_1.fastq  L777_BEC0019_16S/flexcleaned.log
L765_BEC0007_16S/flexcleaned_2.fastq  L778_BEC0020_16S/flexbar_reads.txt
L765_BEC0007_16S/flexcleaned.log      L778_BEC0020_16S/flexcleaned_1.fastq
L766_BEC0008_16S/flexbar_reads.txt    L778_BEC0020_16S/flexcleaned_2.fastq
L766_BEC0008_16S/flexcleaned_1.fastq  L778_BEC0020_16S/flexcleaned.log
L766_BEC0008_16S/flexcleaned_2.fastq  L779_BEC0021_16S/flexbar_reads.txt
L766_BEC0008_16S/flexcleaned.log      L779_BEC0021_16S/flexcleaned_1.fastq
L767_BEC0009_16S/flexbar_reads.txt    L779_BEC0021_16S/flexcleaned_2.fastq
L767_BEC0009_16S/flexcleaned_1.fastq  L779_BEC0021_16S/flexcleaned.log
L767_BEC0009_16S/flexcleaned_2.fastq  L780_BEC0022_16S/flexbar_reads.txt
L767_BEC0009_16S/flexcleaned.log      L780_BEC0022_16S/flexcleaned_1.fastq
L768_BEC0010_16S/flexbar_reads.txt    L780_BEC0022_16S/flexcleaned_2.fastq
L768_BEC0010_16S/flexcleaned_1.fastq  L780_BEC0022_16S/flexcleaned.log
L768_BEC0010_16S/flexcleaned_2.fastq  L781_BEC0023_16S/flexbar_reads.txt
L768_BEC0010_16S/flexcleaned.log      L781_BEC0023_16S/flexcleaned_1.fastq
L769_BEC0011_16S/flexbar_reads.txt    L781_BEC0023_16S/flexcleaned_2.fastq
L769_BEC0011_16S/flexcleaned_1.fastq  L781_BEC0023_16S/flexcleaned.log
L769_BEC0011_16S/flexcleaned_2.fastq  L782_BEC0024_16S/flexbar_reads.txt
L769_BEC0011_16S/flexcleaned.log      L782_BEC0024_16S/flexcleaned_1.fastq
L770_BEC0012_16S/flexbar_reads.txt    L782_BEC0024_16S/flexcleaned_2.fastq
L770_BEC0012_16S/flexcleaned_1.fastq  L782_BEC0024_16S/flexcleaned.log
L770_BEC0012_16S/flexcleaned_2.fastq  L783_BEC0025_16S/flexbar_reads.txt
L770_BEC0012_16S/flexcleaned.log      L783_BEC0025_16S/flexcleaned_1.fastq
L771_BEC0013_16S/flexbar_reads.txt    L783_BEC0025_16S/flexcleaned_2.fastq
L771_BEC0013_16S/flexcleaned_1.fastq  L783_BEC0025_16S/flexcleaned.log
[rebeccaclement@cpu046 Analysis]$ ls
L759_BEC0001_16S  L774_BEC0016_16S  L789_BEC0031_16S  L804_BEC0046_16S
L760_BEC0002_16S  L775_BEC0017_16S  L790_BEC0032_16S  L805_BEC0047_16S
L761_BEC0003_16S  L776_BEC0018_16S  L791_BEC0033_16S  L806_BEC0048_16S
L762_BEC0004_16S  L777_BEC0019_16S  L792_BEC0034_16S  L807_BEC0049_16S
L763_BEC0005_16S  L778_BEC0020_16S  L793_BEC0035_16S  L808_BEC0050_16S
L764_BEC0006_16S  L779_BEC0021_16S  L794_BEC0036_16S  L809_BEC0051_16S
L765_BEC0007_16S  L780_BEC0022_16S  L795_BEC0037_16S  L810_BEC0052_16S
L766_BEC0008_16S  L781_BEC0023_16S  L796_BEC0038_16S  L811_BEC0053_16S
L767_BEC0009_16S  L782_BEC0024_16S  L797_BEC0039_16S  L812_BEC0054_16S
L768_BEC0010_16S  L783_BEC0025_16S  L798_BEC0040_16S  L813_BEC0055_16S
L769_BEC0011_16S  L784_BEC0026_16S  L799_BEC0041_16S  L814_BEC0056_16S
L770_BEC0012_16S  L785_BEC0027_16S  L800_BEC0042_16S  L815_BEC0057_16S
L771_BEC0013_16S  L786_BEC0028_16S  L801_BEC0043_16S  MPL
L772_BEC0014_16S  L787_BEC0029_16S  L802_BEC0044_16S
L773_BEC0015_16S  L788_BEC0030_16S  L803_BEC0045_16S
[rebeccaclement@cpu046 Analysis]$ cd ..
[rebeccaclement@cpu046 termite_16S]$ ls
Analysis  fastqc_cleaned  outfastqc16S  outflexbar16S  samps.txt
[rebeccaclement@cpu046 termite_16S]$ ls outflexbar16S/
flex.327861_10.err  flex.327861_21.out  flex.327941_10.err  flex.327941_21.out
flex.327861_10.out  flex.327861_22.err  flex.327941_10.out  flex.327941_22.err

▽
#!/bin/bash
flex.327861_11.err  flex.327861_22.out  flex.327941_11.err  flex.327941_22.out

▽
#!/bin/bash
#SBATCH -N 1
#SBATCH -t 06:00:00
#SBATCH -p defq,short,small-gpu
#SBATCH --array=1-58
#SBATCH -o flex.%A_%a.out
#SBATCH -e flex.%A_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=rebeccaclement@gwu.edu

name=$(sed -n "$SLURM_ARRAY_TASK_ID"p samps.txt)

#--- Start the timer
t1=$(date +"%s")

echo $name

module load flexbar/3.5.0

flexbar --threads 10 \
 --adapters ../refs/NexteraPE-PE.fa \
 --adapter-trim-end RIGHT \
 --adapter-min-overlap 7 \
 --pre-trim-left 15 \
                                                              1,1           Top

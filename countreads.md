# Count number of raw and cleaned reads

For this part you will need this [python script](pulling_readcount.py)
Make sure to move all fastqc and other files out of your Analysis directory before doing this.

### *__Pulling number of raw reads and cleaned reads__*
```
cd Analysis &&
for f in *; do
    cd $f &&
    python ../../scripts/pulling_readcount.py &&
    cd .. &&
    echo $f
done

echo -e "Samp\tRaw\tCleaned" >> read_count.txt
for f in *; do
    reads=$(cat $f/flexbar_reads.txt) &&
    echo -e "${f}\t${reads}" >> read_count.txt &&
    echo $f
done
```
<br />

You will need to edit the `read_count.txt` file in excel prior to using it in R. See the file: [`read_count_meni.csv`](read_count_meni.csv). Basically you need to stack the "cleaned" reads below the raw.

Format needs to be as such:<br />

| Samp     | Reads   | Status | Group |
| -------------- | ----------- | ------ | ------- |
| 3S | 5652615    | raw    | Kinshasa Control|
| 3V1	| 7062682	| cleaned	| Kahemba Cases |

Next you get to [run pathoscope!](pathoscope.md)
* "&&" is used to chain commands together, such that the next command is run if and only if the preceding command exited without errors (or, more accurately, exits with a return code of 0)

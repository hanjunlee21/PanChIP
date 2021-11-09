#!/bin/bash
# you must execute analysis by ./analysis.sh

inputfiles="ChIP.RB ChIP.RB.Promoters ChIP.RB.Enhancers ChIP.RB.Insulators ChIP.RB.A ChIP.RB.B ChIP.RB.C ChIP.RB.D ChIP.RB.E ChIP.RB.F ChIP.RB.G ChIP.RB.H ChIP.CTCF ChIP.CTCF.RB ChIP.CTCF.nonRB"
input="../input"
threads="16"
repeat="1"

output="../output"
lib="../lib/v.1.0"
numlib=$(awk -v max=0 '{if($1>max){max=$1}}END{printf "%d", max}' $lib/SUM.count)
TR="928"
blnk=$(grep -o ' ' <<< "$inputfiles" | wc -l)
sedinput=$(sed 's/\//\\\//g' <<< "$input")
sedoutput=$(sed 's/\//\\\//g' <<< "$output")
sedlib=$(sed 's/\//\\\//g' <<< "$lib")

printf "Running PanChIP analysis...\n"
printf "Creating repeats of library...\n"
for rep in $(seq 1 1 $repeat)
do
mkdir -p $lib/$rep
done
for cnt in $(seq 1 1 $TR)
do
var=$(awk '{if(NR=='$cnt') {output=$1}} END{print output}' $lib/SUMdivbyWC.count)
float=$((${numlib%.*}/${var%.*}))
for rep in $(seq 1 1 $repeat)
do
shuf -r -n ${float%.*} $lib/$cnt.bed | awk '{printf "%s\t%s\t%s\t%s\t%s\t%s\n",$1,$2,$3,NR,$5,$6}' > $lib/$rep/$cnt.bed &
done
printf ""
wait
done

lib2sum() {
sort -u -k1,1 -k2,2n -k3,3n -k4,4n $input/$1.bed | awk 'function abs(v) {return v < 0 ? -v : v} BEGIN{var=0} {var=var+$5*abs($3-$2)} END{print var}' > $input/$1.sum
}
rep2sum() {
sort -u -k1,1 -k2,2n -k3,3n -k4,4n $lib/$2/$1.bed | awk 'function abs(v) {return v < 0 ? -v : v} BEGIN{var=0} {var=var+$5*abs($3-$2)} END{print var}' > $lib/$2/$1.sum
}
lib2wc() {
wc -l $input/$1.bed | awk '{print $1}' > $input/$1.wc
}

printf "Creating repeats of input files...\n"
for i in $inputfiles
do
lib2sum "$i"
lib2wc "$i"
done
echo $inputfiles | sed -e 's/ /.sum '$sedinput'\//g' -e 's/^/'$sedinput'\//' -e 's/$/.sum/' | xargs cat > $input/SUM.count
echo $inputfiles | sed -e 's/ /.sum '$sedinput'\//g' -e 's/^/'$sedinput'\//' -e 's/$/.sum/' | xargs rm
numinput=$(awk -v min=$numlib '{if($1<min){min=$1}}END{printf "%d", min}' $input/SUM.count)
echo $inputfiles | sed -e 's/ /.wc '$sedinput'\//g' -e 's/^/'$sedinput'\//' -e 's/$/.wc/' | xargs cat > $input/WC.count
echo $inputfiles | sed -e 's/ /.wc '$sedinput'\//g' -e 's/^/'$sedinput'\//' -e 's/$/.wc/' | xargs rm
paste $input/SUM.count $input/WC.count | awk '{print $1/$2}' > $input/SUMdivbyWC.count
for rep in $(seq 1 1 $repeat)
do
mkdir -p $input/$rep
done
for cnt in $(seq 1 1 $((blnk+1)))
do
var=$(awk '{if(NR=='$cnt') {output=$1}} END{print output}' $input/SUMdivbyWC.count)
float=$((${numinput%.*}/${var%.*}))
for rep in $(seq 1 1 $repeat)
do
shuf -r -n ${float%.*} $input/$(echo $inputfiles | awk -F ' ' '{printf "%s", $'$cnt'}').bed | awk '{printf "%s\t%s\t%s\t%s\t%s\t%s\n",$1,$2,$3,NR,$5,$6}' > $input/$rep/$(echo $inputfiles | awk -F ' ' '{printf "%s", $'$cnt'}').bed &
done
printf ""
wait
done
for rep in $(seq 1 1 $repeat)
do
for cnt in $(seq 1 1 $TR)
do
rep2sum "$cnt" "$rep" &
done
printf ""
wait
seq $TR | sed 's:.*:'$sedlib'\/'$rep'\/&.sum:' | xargs cat > $lib/$rep/SUM.count
seq $TR | sed 's:.*:'$sedlib'\/'$rep'\/&.sum:' | xargs rm
done

subtask1() {
bedtools intersect -a $input/$3/$1.bed -b $lib/$3/$2.bed | sort -u -k1,1 -k2,2n -k3,3n -k4,4n | awk 'function abs(v) {return v < 0 ? -v : v} BEGIN{var=0} {var=var+$5*abs($3-$2)} END{print var}' > $output/$3/$1/intersect.$2.count
bedtools intersect -a $lib/$3/$2.bed -b $input/$3/$1.bed | sort -u -k1,1 -k2,2n -k3,3n -k4,4n | awk 'function abs(v) {return v < 0 ? -v : v} BEGIN{var=0} {var=var+$5*abs($3-$2)} END{print var}' > $output/$3/$1/intersect2.$2.count
}
catfunc() {
seq $TR | sed 's:.*:'$2'.&.count:' | xargs cat > $1.dist
}
subtask2() {
catfunc "$output/$2/$1/intersect" "$sedoutput\/$2\/$1\/intersect"
catfunc "$output/$2/$1/intersect2" "$sedoutput\/$2\/$1\/intersect2"
rm $output/$2/$1/intersect.*.count
rm $output/$2/$1/intersect2.*.count
sort -u -k1,1 -k2,2n -k3,3n -k4,4n $input/$2/$1.bed | awk 'function abs(v) {return v < 0 ? -v : v} BEGIN{var=0} {var=var+$5*abs($3-$2)} END{print var}' > $output/$2/$1/$1.dist
awk '{for(i=1;i<='$TR';i++) {print}}' $output/$2/$1/$1.dist > $output/$2/$1/$1.tmp
paste $output/$2/$1/intersect.dist $output/$2/$1/intersect2.dist $lib/$2/SUM.count $output/$2/$1/$1.tmp | awk '{print sqrt($1*$2/$3/$4)}' > $output/$2/$1/intersect.normalized.dist
rm $output/$2/$1/$1.tmp $output/$2/$1/intersect.dist $output/$2/$1/intersect2.dist
}
task1() {
mkdir -p $output/$2/$1
for factor in $(seq 1 1 $TR)
do
subtask1 "$1" "$factor" "$2"
done
subtask2 "$1" "$2"
}
task2() {
seq $repeat | sed 's:.*:'$sedoutput'\/&\/'$1'\/intersect.normalized.dist:' | xargs paste -d ' ' | numsum -r | awk '{print $1/'$repeat'}' > $output/$1.txt
}

mkdir -p $output
for rep in $(seq 1 1 $repeat)
do
mkdir -p $output/$rep
printf "Running "$rep" out of "$repeat" tasks...\n"
for file in $inputfiles
do
  if [ $(jobs -r | wc -l) -ge $threads ]; then
    wait $(jobs -r -p | head -1)
  fi
  (echo Begin processing $file; task1 "$file" "$rep") &
done
wait
done
printf "Processing output files...\n"
for file in $inputfiles
do
  if [ $(jobs -r | wc -l) -ge $threads ]; then
    wait $(jobs -r -p | head -1)
  fi
  (task2 "$file") &
done
wait
echo $inputfiles | sed -e 's/ /.txt '$sedoutput'\//g' -e 's/^/'$sedlib'\/TR.txt '$sedoutput'\//' -e 's/$/.txt/' | xargs paste | awk 'BEGIN{print "'$(sed -e 's/ /\\t/g' -e 's/^/TR\\t/' <<< $inputfiles)'"} {print}' > $output/primary.output.tsv
for file in $inputfiles
do
rm $output/$file.txt
done
for rep in $(seq 1 1 $repeat)
do
rm -r $lib/$rep
rm -r $input/$rep
rm -r $output/$rep
done
mkdir -p $output/input.stat
for file in SUM SUMdivbyWC WC
do
mv $input/$file.count $output/input.stat/$file.count
done
printf "Completed PanChIP analysis!\n"
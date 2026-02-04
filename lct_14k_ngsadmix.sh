#!/bin/bash -l
#SBATCH -J admlct
#SBATCH -e adm_ib_lct.%j.err
#SBATCH -o adm_ib_lct.%j.out
#SBATCH --mem=75G
#SBATCH -p bmh
#SBATCH --time=4-20:00:00

set -e
set -x

##runs ngsadmix. I usually run k2-10 and 10 reps per k. Usually runs overnight but depends on sample #s and complexity. Then I use CLUMPAK online to get best K. I plot with pophelper usually###

loc=$1 ##the run ID. For me this is something like "bly_pg_manulist". No file extension. This will be used to make all my subfolders and results etc.
pop_dir="/home/skieran/lct/new_calls/supp_new_mq25_m005/"
out_dir="/home/skieran/lct/new_calls/supp_new_mq25_m005/${loc}_ngsadmix"

module load angsd
module load ngstools


mkdir -p  ${loc}_ngsadmix
cd ${loc}_ngsadmix

cp ${pop_dir}/${loc}_filt_mq25_m005.beagle .

#strip the .1/.2 off the repeat sample names, R adds these
#sed -i "s/\\.[1-2]\t/\t/g" ${loc}_filt_mq25_m005.beagle
#sed -i "s/\\.2$//g" ${loc}_filt_mq25_m005.beagle

#run K2 thru whatever makes sense - 14 for all my pops, 8 for oobs, 6 for WWH
x=2 #min K
nl=$2 #max K
reps=10 #reps per K
while [ $x -le $nl ]
do
y=1
while [ $y -le $reps ]	
do
NGSadmix -likes ${loc}_filt_mq25_m005.beagle -K $x -o ${loc}.${x}.${y}
y=$(( $y + 1 ))
done
x=$(( $x + 1 ))
done
##

##make logfile for clumpak##
for log in `ls *.log`
do
        lg=$(grep -Po 'like=\K[^ ]+' $log | awk '{print $1}')
        ll=$(echo $lg | awk '{print $1}')
        nm=$(echo $log | awk -F"." '{print $2}')
        echo $nm	$ll >> ${loc}_logfile
        echo $ll $nm
done

##you can now use the .qopts with pophelper (pophelper.com) for plotting and the formatted logfile  with clumpak http://clumpak.tau.ac.il/bestK.html for best K##




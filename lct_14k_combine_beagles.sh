#!/bin/bash


#quick and dirty helper file to combine multiple beagle files (different individuals but all exactly the same SNPs, this is vital) into one file. Need: beagle files, bamlists that made the beagle files in the same folder as your beagle files. Adds names to beagle files instead of "IndX" which is the standard.

#move bamlists into directory
cp ../*_a*.bamlist .

#this works on every beagle in your folder, so I recommend only keeping the ones you want to combine and doing file management proactively. Mine were all something like "species_params_aa.beagle" "species_params_ab.beagle" etc.

for fil in *.beagle;
do

	nam=$( echo $fil | awk -F".beagle" '{print $1}')
	echo "doing $nam"
	#these two lines strip the filepath from my sample names. A more generic line might be like "awk -F"/" '{print $NF}' | awk -F".bam" '{print $1}" which would theoretically produce sample names that are stripped of the file path and the .bam part of your bam name.
	sed 's:/home/skieran/lct/lct_genome/::g' ${nam}.bamlist > ${nam}.list
	sed -i 's/_filt.bam//g' ${nam}.list
	#each sample is in a beagle file three times for the three potential genotype probabilities (aa, aA, AA), so just make a list with each sample in there 3 times
	cp ${nam}.list ${nam}.list2
	cp ${nam}.list ${nam}.list3

	paste ${nam}.list ${nam}.list2 ${nam}.list3 > ${nam}.names
	
	#transposes list from long to wide and adds the marker bit back in to keep column numbers identical

	cat ${nam}.names | tr '\n' '\t' | sed 's/^/marker\tallele1\tallele2\t/g' > ${nam}.header
	sed -i '$a\' ${nam}.header

	#isolate the GLs from the original beagle
	tail -n +2 ${nam}.beagle > headless_${nam}.beagle
	
	#add the new header to the headless beagle
	cat ${nam}.header headless_${nam}.beagle > reheader_${nam}.beagle
	
	#get rid of the positional info at the front of the file so we can paste them all together
	cut -f4- reheader_${nam}.beagle > final_${nam}.beagle
done

#get rid of trailing tabs at ends of  header line
sed -i 's/\t$//g' final_lct_supp_mq25_m005_a*.beagle

#snag the SNP positions and alleles for the front of the file
cut -f1-3 reheader_lct_supp_mq25_m005_aa.beagle > beagle_header

#paste all your beagles together. You can do this using wildcards, but I spelled it out just to be extra careful
paste beagle_header final_lct_supp_mq25_m005_aa.beagle final_lct_supp_mq25_m005_ab.beagle final_lct_supp_mq25_m005_ac.beagle final_lct_supp_mq25_m005_ad.beagle final_lct_supp_mq25_m005_ae.beagle final_lct_supp_mq25_m005_af.beagle final_lct_supp_mq25_m005_ag.beagle final_lct_supp_mq25_m005_ah.beagle > final_lct_supp_mq25_m005_all.beagle

#cleanup. This would be tidier inside the loop but I wanted them to persist for troubleshooting. Also, you need to save one somewhere with your positional information.
rm reheader*.beagle
rm *.names
rm headles*.beagle
rm *.header
rm *.list*

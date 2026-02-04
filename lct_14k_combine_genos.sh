#!/bin/bash


#helper file to combine multiple .geno files using different individuals but the same set of SNPs (vital!! double check the output of all the files to make sure SNPs weren't dropped even when using your rf/sites flag. Sometimes ANGSD plays dirty). This is not generic at all and uses my file names, which were created with 'split -l 350' on my pure_lct_all.bamlist sample list of 2613 samples, the names were _aa, _ab, etc.

#to start, just clean up any trailing tabs on the first file and move it out of the way.
awk 'BEGIN{FS=OFS="\t"} {NF--; print}' lct_supp_mq25_m005_aa.geno > nt_lct_supp_mq25_m005_aa.geno

mkdir -p ./aa/

mv *_aa.geno ./aa/

#then for the remaining files, remove the first two columns that contain positional info, strip trailing tabs, and you're done.
for fil in *.geno;
do
	awk 'BEGIN{FS=OFS="\t"} {NF--; print}' $fil | cut -f3- > nh_nt_${fil}
done

#grab your first file again, the one with the positional info
mv ./aa/nt_lct_supp_mq25_m005_aa.geno .

#paste everything together
paste nt_lct_supp_mq25_m005_aa.geno nh_nt_lct_supp_mq25_m005_ab.geno nh_nt_lct_supp_mq25_m005_ac.geno nh_nt_lct_supp_mq25_m005_ad.geno nh_nt_lct_supp_mq25_m005_ae.geno nh_nt_lct_supp_mq25_m005_af.geno nh_nt_lct_supp_mq25_m005_ag.geno nh_nt_lct_supp_mq25_m005_ah.geno > lct_mq25_m005_all.geno

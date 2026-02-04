#!/bin/bash

#SBATCH -t 6-12:00:00
#SBATCH -p bmh
#SBATCH --mem=70G
#SBATCH -e mq25_vcf.%j.err
#SBATCH -o mq25_vcf.%j.out
#SBATCH -J geno


###need 1. bamfile name 2. reference assembly

source ~/.bash_profile
module load angsd
loc=$1 ##run name, bamlist without the bam part usually##
##calls SNPs and produces a VCF
pop_dir=/home/skieran/lct/new_calls/supp_new_mq25_m005/
cd ${pop_dir}
mkdir -p genos ### All output goes here ###

echo "pop is $loc"

out=/home/skieran/lct/new_calls/supp_new_mq25_m005/genos/
bamlist=${loc}.bamlist
### Calculate saf files and the ML estimate of the sfs using the EM algorithm for each population ###
angsd -b ${loc}.bamlist -P 1 -ref /home/skieran/lct/lct_genome/lct_genome.fasta -anc /home/skieran/lct/lct_genome/lct_genome.fasta -sites lct_mq25_m005_14k_snp_set.txt  -rf lct_mq25_m005_14k_rf.txt  -gl 2 -dopost 2 -domajorminor 1 -domaf 1 --ignore-RG 0 -doGlf 2 -minMapQ 25 -minQ 20 -dogeno 4 -geno_minDepth 4 -geno_maxDepth 70 -docounts 1 -postCutoff 0.9 -snp_pval 1 -out ${out}/${loc}



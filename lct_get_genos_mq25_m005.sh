#!/bin/bash

#SBATCH -t 2880
#SBATCH -p bmh
#SBATCH --mem=75G
#SBATCH -e test_minq_genos.%j.err
#SBATCH -o test_minq_genos.%j.out
#SBATCH -J genos


###need 1. bamfile name 2. reference assembly

source ~/.bash_profile
module load angsd
loc=$1 ##run name, bamlist without the bam part usually#

##calls SNPs and produces a VCF
pop_dir=/home/skieran/lct/new_calls/
cd ${pop_dir}
mkdir -p genos_lct_bal_poly_mq25_m005 ### All output goes here ###

out=/home/skieran/lct/new_calls/genos_lct_bal_poly_mq25_m005/
bamlist=${loc}
### Calculate saf files and the ML estimate of the sfs using the EM algorithm for each population ###
nInd=$(wc -l $bamlist | awk '{print $1}')
medInd=$(( $nInd / 10 ))
minInd=$(( $medInd * 8 ))
mindepth=$(( $nInd * 8 ))
maxdepth=$(( $nInd * 75 ))
angsd -b ${loc} -P 1 -ref /home/skieran/lct/lct_genome/lct_genome.fasta -anc /home/skieran/lct/lct_genome/lct_genome.fasta -rf lct_unique_chroms -gl 2 -dopost 2 -domajorminor 1 -domaf 1 --ignore-RG 0 -doGlf 2 -minMapQ 25 -minQ 20 -dogeno 3 -minInd 476 -geno_minDepth 4 -docounts 1 -postCutoff 0.9 -minMaf 0.05 -snp_pval 1e-6 -out ${out}/${loc}

cd ${out}


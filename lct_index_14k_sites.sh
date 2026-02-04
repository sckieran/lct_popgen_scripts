#!/bin/bash

#SBATCH -p bmh
#SBATCH -t 1440
#SBATCH -J index
#SBATCH -e index.err
#SBATCH -o index.out

module load angsd

cd /home/skieran/lct/new_calls/supp_new_mq25_m005/

angsd sites index lct_mq25_m005_14k_snp_set.txt 

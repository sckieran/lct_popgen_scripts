library(tidyverse)
library(snpR)
library(ggpubr)
library(ggpmisc)

setwd("~/lct/disc_mq25")
geno_raw <- read.delim("lct_bal_poly_mq25_m005.bamlist.geno", header=FALSE)
snp_meta <- geno_raw[,1:4]
colnames(snp_meta) <- c("chromo","position","major","minor")
snp_meta$chromo <- gsub('\\.','_',snp_meta$chromo)
snp_meta$chrom_pos <- paste0(snp_meta$chromo,"_",snp_meta$position)
genos <- geno_raw[,5:(ncol(geno_raw)-1)]
meta <- read.delim("lct_bal_poly_mq25_meta.txt")
lct <- import.snpR.data(genos ,sample.meta = meta,snp.meta = snp_meta ,mDat = "-1")
lct_filt <- filter_snps(x = lct, min_ind =  0.7, min_loci = 0.7, maf=0.05, LD_prune_r = 0.15,LD_prune_sigma = 25) 

snp_filt <- snp.meta(lct_filt)
snp_filt$chromo <- gsub("\\_",".",snp_filt$chromo)

write_delim(snp_filt,"~/lct/disc_mq25/lct_mq25_m005_snp_set.txt", delim="\t",quote="none")

filt_meta <- sample.meta(lct_filt)

##now check the seg_sites, prop_poly and assess percent missing to check that this isn't excluding any regions unnecessarily or that too many SNPs are basically private.



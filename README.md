## LCT Popgen Analysis 

### Step 1: Align files with bwa-mem, filter with samtools 

Inputs: Raw, demultiplexed RAD-seq .fastq files and the reference genome (found at https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_043774065.1/ , unzipped and indexed using bwa index)
Script: lct_popgen_align_script.sh
Outputs: .bam files for all samples

Further processing of samples based on alignment statistics (ie reads passing filter) and hybridization % are detailed in Luzzio et al., 2026 and the code therein: ([github link when available])

### Step 2: Get genotypes for balanced set of samples (10-15 per population, all populations with >10 samples)

Inputs: lct_discovery_samples_balanced.bamlist, which is a list of filepaths for all samples to be analyzed, and the indexed reference genome from above
Script: lct_get_genos_mq25_m005.sh
Outputs: lct_bal_poly_mq25_m005.bamlist.geno.gz

### Step 3: Find set of SNPs that works well for discovery samples

Inputs: lct_bal_poly_mq25_m005.bamlist.geno, which is the ANGSD-formatted genotypes, and an associated metadata file, lct_bal_poly_mq25_meta.txt
Script: lct_prune_script_mq25_m005.R
Outputs:  list of SNP positions (relative to the LCT genome linked above), lct_mq25_m005_snp_set.txt

### Step 4: Prepare to genotype the remaining samples
  1. Process the list of SNPs to prepare for indexing with ANGSD: `tail -n+2 lct_mq25_m005_snp_set.txt | sort > lct_mq25_m005_14k_snp_set.txt`
  2.  minimally process that file to create -rf file for angsd, using both ensures that only/all SNPs in included set are genotyped, important when processing 2,613 samples at the same time: `sed 's/\t/:/g' lct_mq25_m005_14k_snp_set.txt > lct_mq25_m005_14k_rf.txt`
  3.  Index the sites using lct_index_14k_sites.sh
  4.  shuffle the full bamlist and cut it into chunks of ~350 samples, which is necessary for ANGSD. If we were calling genos from nothing this could be a problem, with all samples genotyped at different loci, but our script will genotype these samples at exactly the same loci and ONLY those loci, allowing us to compare fish genotyped in different runs. `shuf lct_14k_full_2613_sample.bamlist | split -l 350 --additional_suffix=.bamlist - lct_supp_mq25_m005_`

### Step 5: Genotype all 2,613 samples at the same 14K SNPS

Inputs: reference genome, lct_mq25_m005_14k_snp_set.txt, lct_mq25_m005_14k_rf.txt, multiple bamlists as described in Step 4
Script: lct_get_genos_supplemental_14k.sh
Call: `for fil in lct_supp_mq25_m005_a*.bamlist; do sbatch lct_get_genos_supplemental_14k.sh $fil`
Outputs: ANGSD-formatted geno files for each bamlist

### Step 6: combine geno and beagle files from multiple runs together

Inputs: Directory with genos and beagle files from the runs above, also needs bamlists in same directory
Scripts: lct_14k_combine_genos.sh, lct_14k_combine_beagles.sh
Outputs: A single, combined geno file and a single, combined beagle file, each containing the genotypes/GLs for all 2,613 fish

### Step 7: Analyze in snpR

Inputs: The full genotype file (lct_mq25_m005_all.geno) and genotype likelihood (beagle) files produced in Step 6, a metadata file (lct_mq25_m005_meta.txt). Beagle file is too large for github, will be stored on dryad after submission
Script: lct_popgen_analysis.Rmd
Outputs: Many, including all tables and figures, subset beagle files for NGSadmix

### Step 8: Admixture analysis

Actually happens in the middle of Step 7, after beagle file creation but before plotting.
Inputs: Beagle file (stored on dryad) for each set of samples: all in-range, out-of-range, and willow-whitehorse.
Script: lct_14k_ngadmix.sh 
Outputs: .qopt and logfiles for each K and replicate of K, full logfile for CLUMPAK.


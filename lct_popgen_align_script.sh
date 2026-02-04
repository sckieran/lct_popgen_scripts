#!/bin/bash -l
#SBATCH -J align
#SBATCH -e aln_RADseqs.%j.err
#SBATCH -o aln_RADseqs.%j.out
#SBATCH -c 4
#SBATCH -p high
#SBATCH --time=1-20:00:00
#SBATCH --mem=12G

##This script was written by Shannon Joslin and modified by Shannon Kieran##
##On command line, specify 1. alignment directory (I use short reference name), 2. full path to reference directory, 3. reference filename

set -e # exits upon failing command
set -v # verbose -- all lines
#set -x # trace of all commands after expansion before execution


# set up directories
#sub=$1 #name of what you want the subdirectory to be inside your alignment dir
data_dir="/home/skieran/lct/lct_genome/"
align_dir="/home/skieran/lct/lct_genome"
out_dir=/home/skieran/lct/lct_genome/
#mkdir -p ${align_dir}/${sub} 


## NOTE: Need list of all sequence file names in a .list file.
#	 Need ID'd locddi

####################
###  makeRADseqID .list  ###
####################
cd ${data_dir}

ls ${PWD}/*_R1.fastq.gz > ${out_dir}/id1 #CHANGE THIS to whatever the suffix of your forward reads are (.R1.fastq, _R1.fastq.gz, .1.fq.gz, etc.)
ls ${PWD}/*_R2.fastq.gz > ${out_dir}/id2
cd ${out_dir}
cat id1 | awk -F"/" '{print $NF}' | awk -F "_R1.fastq" '{print $1}' > id3
paste id3 id1 id2 > sample_list
rm id1 id2 id3

#########################

###  index reference  ###
########################
cd ${align_dir}
sleep 5s
ref=lct_genome.fasta
###this copies your reference from wherever you put it (specify when executing this script) into your alignment directory and indexes it.
module load bwa
cp ${ref_dir}/${ref} ${align_dir}/${ref}
bwa index ${align_dir}/${ref} #this takes a long time but you only need to do it once
#once you do this one - comment out lines 54 & 55

#######################
###  align RAD seq  ###
#######################

cd ${out_dir}

##this parses the list of individuals and creates an alignment script for each one, and starts it running on medium. 
while read p;
do
	c1=$(echo $p | awk '{print $1}')
	c2=$(echo $p | awk '{print $2}')
	c3=$(echo $p | awk '{print $3}')
	echo "name is $c1 path is $c2"	
	echo "#!/bin/bash -l" > aln_${c1}.sh #make a script to align each sample
	echo "#SBATCH -e ${c1}-%j.err" >> aln_${c1}.sh
	echo "#SBATCH -o ${c1}-%j.out" >> aln_${c1}.sh
	echo "#SBATCH -p high" >> aln_${c1}.sh #priority
	echo "#SBATCH --mem=12G" >> aln_${c1}.sh #memory
	echo "#SBATCH --time=1-20:00:00" >> aln_${c1}.sh
	echo "making aln_${c1}.sh"
	echo "" >> aln_${c1}.sh
	echo "#cd ${data_dir}" >> aln_${c1}.sh
	echo "module load bwa" >> aln_${c1}.sh
	echo "module load samtools" >> aln_${c1}.sh
	echo "bwa mem ${ref} ${c2} ${c3} > ${out_dir}/${c1}.sam"  >> aln_${c1}.sh
	echo "samtools view -bS ${out_dir}/${c1}.sam > ${out_dir}/${c1}.bam" >> aln_${c1}.sh
	echo "samtools sort ${out_dir}/${c1}.bam -o ${out_dir}/${c1}_sorted.bam" >> aln_${c1}.sh
	echo "samtools view -b -f 0x2 ${out_dir}/${c1}_sorted.bam > ${out_dir}/${c1}_sorted_proper.bam" >> aln_${c1}.sh
	echo "samtools rmdup ${out_dir}/${c1}_sorted_proper.bam ${out_dir}/${c1}_sorted_proper_rmdup.bam" >> aln_${c1}.sh
	echo "sleep 2m" >> aln_${c1}.sh
	echo "samtools view -F 2048 -bo ${c1}_filt.bam ${c1}_sorted_proper_rmdup.bam" >> aln_${c1}.sh
	echo "samtools index ${out_dir}/${c1}_filt.bam ${out_dir}/${c1}_filt.bam.bai" >> aln_${c1}.sh
	echo "reads=\$(samtools view -c ${out_dir}/${c1}_sorted.bam)" >> aln_${c1}.sh
	echo "ppalign=\$(samtools view -c ${out_dir}/${c1}_sorted_proper.bam)" >> aln_${c1}.sh
	echo "rmdup=\$(samtools view -c ${out_dir}/${c1}_filt.bam)" >> aln_${c1}.sh
	echo "echo \"\${reads},\${ppalign},\${rmdup}\" > ${out_dir}/${c1}.stats" >> aln_${c1}.sh # NEXT TIME ADD NAME
	echo "samtools flagstat ${c1}_filt.bam" >> aln_${c1}.sh
	echo "rm ${c1}.sam" >> aln_${c1}.sh
	echo "rm ${c1}_sorted.bam ${c1}_sorted_proper.bam" >> aln_${c1}.sh
	echo "rm ${c1}.bam" >> aln_${c1}.sh
	sbatch -t 3-00:00:00 -J ${c1}_radaln aln_${c1}.sh
done<samples_to_align



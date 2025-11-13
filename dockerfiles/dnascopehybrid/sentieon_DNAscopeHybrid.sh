#!/usr/bin/env bash

## Command line arguments
while getopts ":n:r:b:s:l:m:d:" opt; do
  case $opt in
    # Sample name
    n) sample_name="$OPTARG" ;;
    # Reference file
    r) reference_fasta="$OPTARG" ;;
    # Reference bwt
    b) reference_bwt="$OPTARG" ;;
    # Input bam/cram files
    # One or more files can be supplied in a space-separated string
    s) short_read_input="$OPTARG" ;;
    l) long_read_input="$OPTARG" ;;
    # Hybrid Illumina PacBio model from Sentieon
    m) sentieon_model="$OPTARG" ;;
    # SNP database vcf
    d) dbsnp="$OPTARG";;
    \?) echo "Invalid option -$OPTARG" >&2
    exit 1
    ;;
  esac
done

## Other settings
nt=$(nproc) # number of threads to use in computation,
            # set to number of cores in the server

input_folder="files/input_folder/reference"
mkdir -p $input_folder

# **********************************************
# 1. Symlink all reference files so they have the same base name
# **********************************************

ln -s ${reference_fasta}.fa ${input_folder}/reference.fasta
ln -s ${reference_fasta}.fa.fai ${input_folder}/reference.fasta.fai
ln -s ${reference_fasta}.dict ${input_folder}/reference.dict
ln -s ${reference_bwt}.bwt ${input_folder}/reference.fasta.bwt
ln -s ${reference_bwt}.ann ${input_folder}/reference.fasta.ann
ln -s ${reference_bwt}.amb ${input_folder}/reference.fasta.amb
ln -s ${reference_bwt}.pac ${input_folder}/reference.fasta.pac
ln -s ${reference_bwt}.sa ${input_folder}/reference.fasta.sa

# **********************************************
# 1. Create DNAscope Hybrid command line
# **********************************************

command="sentieon-cli dnascope-hybrid --rgsm $sample_name -r ${input_folder}/reference.fasta -t $nt"
command+=" --sr_aln $short_read_input --lr_aln $long_read_input"
command+=" -m $sentieon_model"
command+=" -d $dbsnp"
command+=" $sample_name-DSH.vcf.gz"

# **********************************************
# 2. Run DNAscope Hybrid command line
# **********************************************

eval $command || exit 1

# **********************************************
# 3. Compress output metrics directory
# **********************************************

tar -czvf ${sample_name}-DSH_metrics.tar.gz ${sample_name}-DSH_metrics

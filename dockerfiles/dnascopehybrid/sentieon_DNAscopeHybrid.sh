#!/usr/bin/env bash

## Command line arguments
while getopts ":n:r:s:l:m:d:" opt; do
  case $opt in
    # Sample name
    n) sample_name="$OPTARG" ;;
    # Reference file
    r) reference_fasta="$OPTARG" ;;
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

# **********************************************
# 1. Create DNAscope Hybrid command line
# **********************************************

command="sentieon-cli dnascope-hybrid --rgsm $sample_name -r $reference_fasta -t $nt"
command+=" --sr_aln $short_read_input --lr_aln $long_read_input"
command+=" -m $sentieon_model"
command+=" -d $dbsnp"
command+=" $sample_name-DSH.vcf.gz"

# **********************************************
# 2. Run DNAscope Hybrid command line
# **********************************************

eval $command || exit 1

#!/usr/bin/env bash

# *******************************************
# Script to run TNhaplotyper2 on tumor only data.
# Implemented to run in distributed mode using shards.
# *******************************************

## Command line arguments
# Input shards file
shards_file=$1
# Text file containing a list of contiguous regions to use.
# Regions are divided by shards following the format
# @<shard_index>TAB<chr>:<start>-<end>,
# one region per line
shard_index=$2

# Reference files
genome_reference_fasta=$3
population_allele_frequencies=$4

# Other arguments
sample_name=$5
interval_padding=$6

# Input BAM files
shift 6 # $@ store all the input files

## Other settings
nt=$(nproc) # number of threads to use in computation,
            # set to number of cores in the server

# ******************************************
# 1. Create list of input files
# ******************************************
input_files=""

# Adding files
for file in $@;
  do
    input_files+=" -i $file"
  done

# ******************************************
# 2. Get regions from shard
# ******************************************
grep -P "\@${shard_index}\t" $shards_file | cut -f 2 > SHARDS_LIST

regions=""

# Reading shards
while read -r line;
  do
    regions+=" --interval $line"
  done <SHARDS_LIST

# ******************************************
# 3. Run TNhaplotyper2 command line
# ******************************************
sentieon driver -t $nt -r $genome_reference_fasta $input_files $regions \
         --interval_padding $interval_padding \
         --algo TNhaplotyper2 --tumor_sample $sample_name \
         --germline_vcf $population_allele_frequencies \
         output.vcf.gz || exit 1

#!/usr/bin/env bash

# *******************************************
# Script to run TNhaplotyper2 on tumor only data.
# Implemented to run in distributed mode using shards.
# Accepts multiple input CRAM/BAM files.
# *******************************************

## Functions
generate_random_string() {
    echo "$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 5 | head -n 1)"
}

process_bam_header() {
    # Variable to store replacement @RG args
    replace_rg_args=""

    # Extract @RG lines from the header of the input BAM
    input_file="$1"
    reference="$2"
    sample="$3"
    rg_lines=$(samtools view -H -T "$reference" "$input_file" | grep "^@RG")

    # Loop through @RG lines and modify ID field
    # Create --replace_rg arguments
    while IFS= read -r rg_line; do
        orig_rg_id=$(echo "$rg_line" | awk -F'\t' '/ID:/ {print $2}' | sed "s/ID://")
        new_rg_id="${orig_rg_id}-$(generate_random_string)"
        new_rg_line=$(echo "$rg_line" | cut -f 2- | \
            sed "s/ID:${orig_rg_id}/ID:${new_rg_id}/; s/\(SM:\)[^[:space:]]*/\1${sample}/")
        formatted_new_rg_line=$(echo -e "$new_rg_line" | sed 's/\t/\\t/g')
        replace_rg_args+=" --replace_rg ${orig_rg_id}='${formatted_new_rg_line}' "
    done <<< "$rg_lines"

    # Return replacement @RG args
    echo "$replace_rg_args"
}

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

# Input files
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
    replace_args=$(process_bam_header $file $genome_reference_fasta $sample_name)
    input_files+=" $replace_args -i $file "
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
# 3. TNhaplotyper2 command line
# ******************************************
command="sentieon driver -t $nt -r $genome_reference_fasta $input_files $regions"
command+=" --interval_padding $interval_padding"
command+=" --algo TNhaplotyper2 --tumor_sample $sample_name"
command+=" --germline_vcf $population_allele_frequencies output.vcf.gz"

# ******************************************
# 4. Run TNhaplotyper2 command line
# ******************************************
eval $command || exit 1

# sentieon driver -t $nt -r $genome_reference_fasta $input_files $regions \
#          --interval_padding $interval_padding \
#          --algo TNhaplotyper2 --tumor_sample $sample_name \
#          --germline_vcf $population_allele_frequencies \
#          output.vcf.gz || exit 1

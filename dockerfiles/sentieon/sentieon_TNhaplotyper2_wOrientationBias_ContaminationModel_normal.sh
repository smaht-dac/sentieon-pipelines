#!/usr/bin/env bash

# *******************************************
# Script to run TNhaplotyper2 on tumor-normal data.
# Generate OrientationBias and ContaminationModel metrics.
# Implemented to run in distributed mode using shards.
# *******************************************

## Functions
generate_random_string() {
    echo "$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 5 | head -n 1)"
}

process_bam_header() {
    # Variable to store replacement @RG args
    replace_rg_args=""

    # Extract @RG lines from the header of the input BAM
    input_bam="$1"
    rg_lines=$(samtools view -H "$input_bam" | grep "^@RG")

    # Loop through @RG lines and modify ID field
    # Create --replace_rg arguments
    while IFS= read -r rg_line; do
        orig_rg_id=$(echo "$rg_line" | awk -F'\t' '/ID:/ {print $2}' | sed "s/ID://")
        new_rg_id="${orig_rg_id}-$(generate_random_string)"
        new_rg_line=$(echo "$rg_line" | cut -f 2- | sed "s/${orig_rg_id}/${new_rg_id}/")
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
normal_name=$6

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
    replace_args=$(process_bam_header $file)
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
    regions+=" --shard $line"
  done <SHARDS_LIST

# ******************************************
# 3. TNhaplotyper2 command line
# ******************************************
command="sentieon driver -t $nt -r $genome_reference_fasta $input_files $regions"
command+=" --algo TNhaplotyper2 --tumor_sample $sample_name --normal_sample $normal_name --germline_vcf $population_allele_frequencies output.vcf.gz"
command+=" --algo OrientationBias --tumor_sample $sample_name output.priors"
command+=" --algo ContaminationModel --tumor_sample $sample_name --normal_sample $normal_name -v $population_allele_frequencies output.contamination"

# ******************************************
# 4. Run TNhaplotyper2 command line
# ******************************************
eval $command || exit 1

# sentieon driver -t $nt -r $genome_reference_fasta $input_files $regions \
#          --algo TNhaplotyper2 --tumor_sample $sample_name --normal_sample $normal_name \
#          --germline_vcf $population_allele_frequencies \
#          output.vcf.gz \
#          --algo OrientationBias --tumor_sample $sample_name \
#          output.priors \
#          --algo ContaminationModel --tumor_sample $sample_name --normal_sample $normal_name \
#          -v $population_allele_frequencies \
#          output.contamination || exit 1

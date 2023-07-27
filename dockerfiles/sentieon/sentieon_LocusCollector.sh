#!/bin/bash

# *******************************************
# Create duplicates summary for a single sample.
# Accept a list of BAM files to enable processing by lane.
# The BAM files need to be sorted and pre-processed
# to add read groups.
# Implemented to run in distributed mode using shards.
# *******************************************

## Command line arguments
# Input shards file
shards_file=$1
# Text file containing a list of contiguous shards to use
# following the format <chr>:<start>-<end>,
# one shard per line

# Output file
output_file=$2

# Input BAM files
shift 2 # $@ stores all the input files

## Other settings
nt=$(nproc) # number of threads to use in computation,
            # set to number of cores in the server

# ******************************************
# 1. Create list of input files
# ******************************************
input_files=""

# Adding files
for arg in $@;
  do
    input_files+=" -i $arg"
  done

# ******************************************
# 2. Create shards
# ******************************************
shards=""

# Reading shards
while read -r line;
  do
    shards+=" --shard $line"
  done <$shards_file

# ******************************************
# 3. Create duplicates summary
# ******************************************
sentieon driver -t $nt $input_files $shards --algo LocusCollector --fun score_info $output_file || exit 1

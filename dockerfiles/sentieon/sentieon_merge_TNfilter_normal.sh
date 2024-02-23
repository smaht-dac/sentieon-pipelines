#!/usr/bin/env bash

# *******************************************
# Script to merge TNhaplotyper2, OrientationBias,
# and ContaminationModel files generated by shards
# on tumor-normal data.
# Run TNfilter to generate a filtered VCF file.
# *******************************************

# Reference files
genome_reference_fasta=$1
sample_name=$2
normal_name=$3

# Input files
shift 3 # $@ store all the remaining input files

## Other settings
nt=$(nproc) # number of threads to use in computation,
            # set to number of cores in the server

# ******************************************
# 1. Create list of TNhaplotyper2 shards (.vcf.gz)
#    Create list of OrientationBias shards (.priors)
#    Create list of ContaminationModel shards (.contamination)
# ******************************************
input_vcf_gz_shards=""
input_priors_shards=""
input_contamination_shards=""

for arg in $@; do
    # Check if the file has a .vcf.gz extension
    if [[ $arg == *.vcf.gz ]]; then
        # Get basename
        basename=${arg##*/}
        # Copy .vcf.gz .vcf.gz.stats to local
        # and remove ##reference tag in the header of .vcf.gz
        # otherwise sentieon will not merge the files because the
        # different tmp paths created for the different shards by docker mount
        gunzip -c $arg | grep -v "^##reference" | \
        sentieon util vcfconvert - $basename || exit 1
        cp ${arg}.stats ${basename}.stats
        # Add to argument
        input_vcf_gz_shards+=" $basename"
    # Check if the file has a .priors extension
    elif [[ $arg == *.priors ]]; then
        input_priors_shards+=" $arg"
    # Check if the file has a .contamination extension
    elif [[ $arg == *.contamination ]]; then
        input_contamination_shards+=" $arg"
    else
        echo "File with unknown extension: $arg"
        exit 1
    fi
done

# ******************************************
# 2. Merge TNhaplotyper2 shards
# ******************************************
sentieon driver -t $nt -r $genome_reference_fasta --passthru \
  --algo TNhaplotyper2 \
  --merge merged.vcf.gz \
  $input_vcf_gz_shards || exit 1

# ******************************************
# 3. Merge OrientationBias shards
# ******************************************
sentieon driver -t $nt -r $genome_reference_fasta --passthru \
  --algo OrientationBias \
  --merge merged.priors \
  $input_priors_shards || exit 1

# ******************************************
# 4. Merge ContaminationModel shards
# ******************************************
sentieon driver -t $nt -r $genome_reference_fasta --passthru \
  --algo ContaminationModel \
  --tumor_segments merged.segments \
  merged.contamination \
  --merge $input_contamination_shards || exit 1

# ******************************************
# 5. Run TNfilter
# ******************************************
sentieon driver -t $nt -r $genome_reference_fasta \
  --algo TNfilter \
  -v merged.vcf.gz \
  --tumor_sample $sample_name \
  --normal_sample $normal_name \
  --contamination merged.contamination \
  --tumor_segments merged.segments \
  --orientation_priors merged.priors \
  output.vcf.gz || exit 1

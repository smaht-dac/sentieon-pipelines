#!/bin/sh

# *******************************************
# Script to run TNhaplotyper2 [Sentieon]
#   on tumor only data
#
# Arguments:
#   -i input file for tumor in BAM format
#   -s sample name for tumor as string
#   -r genome reference file in FASTA format
#   [-p panel of normal file in VCF format]
#   [-g population allele frequencies file in VCF format]
# *******************************************

## Variables
USAGE="Usage: TNhaplotyper2_tumor_only.sh -i <input_file_bam> -s <sample_name> -r <genome_reference_fasta> [-p panel_of_normal] [-g population_allele_frequencies]"

## Functions
check_args()
{
    arg_names=($@)
    for arg_name in ${arg_names[@]}; do
        [ -z ${!arg_name} ] && \
        echo "Mising Argument <${arg_name}>" 1>&2 && \
        echo $USAGE 1>&2 && \
        exit 1
    done
    return 0
}

## Bash command line definition
while getopts 'i:s:r:p:g:h' opt; do
  case $opt in
    # Required arguments
    i) input_file_bam=${OPTARG} ;;
    s) sample_name=${OPTARG} ;;
    r) genome_reference_fasta=${OPTARG} ;;
    # Optional arguments
    p) panel_of_normal=${OPTARG} ;;
    g) population_allele_frequencies=${OPTARG} ;;
    ?|h)
      echo $USAGE 1>&2
      exit 1
      ;;
  esac
done
shift $(($OPTIND -1))

## Check arguments
check_args input_file_bam sample_name genome_reference_fasta

## Other settings
nt=$(nproc) #number of threads to use in computation, set to number of cores in the server

# ******************************************
# 1. Create TNhaplotyper2 command line
# ******************************************
## Basic command
command="sentieon driver -t ${nt} -r ${genome_reference_fasta} -i ${input_file_bam}"
command+=" --algo TNhaplotyper2 --tumor_sample ${sample_name}"

# Add optional arguments
if ! [ -z ${panel_of_normal} ]; then
  command+=" --pon ${panel_of_normal}"
fi

if ! [ -z ${population_allele_frequencies} ]; then
  command+=" --germline_vcf ${population_allele_frequencies}"
fi

# Specify output file
command+=" output.vcf"

# ******************************************
# 2. Run TNhaplotyper2
# ******************************************
eval $command || exit 1

# ******************************************
# 3. Compress and index output
# ******************************************
bgzip output.vcf || exit 1
tabix output.vcf.gz || exit 1

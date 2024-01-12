#!/usr/bin/env bash

# *******************************************
# Merge multiple BAM files.
# Multiple regions can be speficied to use for the merge.
# RG IDs from the multiple files will be made unique
# by adding a random 5 letter string.
# *******************************************

# *******************************************
# FUNCTIONS
# *******************************************
display_usage() {
    echo "Usage: $0 -r genome_reference_fasta -i input_file_bam [-i input_file_bam ...] [-l region ...]"
    exit 1
}

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

# *******************************************
# VARIABLES
# *******************************************
# Initialize variables
input_files_bam=()
regions=()
genome_reference_fasta=""

nt=$(nproc) # number of threads to use in computation,
            # set to number of cores in the server

# *******************************************
# Command line parser
# *******************************************
while getopts "r:i:l:" opt; do
    case $opt in
        r)
            genome_reference_fasta="$OPTARG"
            ;;
        i)
            input_files_bam+=("$OPTARG")
            ;;
        l)
            regions+=("$OPTARG")
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            display_usage
            ;;
        :)
            echo "Option -$OPTARG requires an argument."
            display_usage
            ;;
    esac
done

# Check if required options are provided
if [ -z "$genome_reference_fasta" ] || [ ${#input_files_bam[@]} -eq 0 ]; then
    echo "Error: Both reference file and at least one input file must be specified."
    display_usage
fi

# *******************************************
# MAIN
# *******************************************
# ******************************************
# 1. Generate command
# ******************************************
command="sentieon driver -t ${nt} -r ${genome_reference_fasta} "

# Files
for input_file_bam in "${input_files_bam[@]}"; do
    replace_args=$(process_bam_header "$input_file_bam")
    command+=" ${replace_args} -i ${input_file_bam} "
done

# Regions
for region in "${regions[@]}"; do
    command+=" --interval ${region} "
done

command+=" --algo ReadWriter merged.bam"

#******************************************
# 2. Run command
# ******************************************
eval "$command" || exit 1

# ******************************************
# 3. Check merged BAM integrity
# ******************************************
py_script="
import sys, os

def check_EOF(filename):
    EOF_hex = b'\x1f\x8b\x08\x04\x00\x00\x00\x00\x00\xff\x06\x00\x42\x43\x02\x00\x1b\x00\x03\x00\x00\x00\x00\x00\x00\x00\x00\x00'
    size = os.path.getsize(filename)
    fb = open(filename, 'rb')
    fb.seek(size - 28)
    EOF = fb.read(28)
    fb.close()
    if EOF != EOF_hex:
        sys.stderr.write('EOF is missing\n')
        sys.exit(1)
    else:
        sys.stderr.write('EOF is present\n')

check_EOF('recalibrated.bam')
"

python -c "$py_script" || exit 1

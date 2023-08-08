#!/usr/bin/env bash

# *******************************************
# Generate a sorted BAM file from long reads FASTQ
# file for a single sample.
# The file will be sorted by coordinates.
# *******************************************

## Command line arguments
# Input FASTQ file
fastq=$1

# Reference data file
reference_fa=$2

# Other arguments
preset=$3
# minimap2 -ax $preset reference.fa reads.fq.gz > alignment.sam
#   map-pb    -> PacBio CLR genomic reads
#   map-ont   -> Oxford Nanopore genomic reads
#   map-hifi  -> PacBio HiFi/CCS genomic reads (v2.19 or later)
#   asm5/asm10/asm20
#             -> asm-to-ref mapping, for ~0.1/1/5% sequence divergence
#                PacBio HiFi/CCS genomic reads (v2.18 or earlier)

## Other settings
nt=$(nproc) # number of threads to use in computation,
            # set to number of cores in the server

# ******************************************
# 1. Mapping reads with minimap2 and
# sort by coordinates.
# ******************************************
( sentieon minimap2 -t $nt -L -ax $preset $reference_fa $fastq || exit 1 ) | samtools sort -@ $nt -o sorted.bam - || exit 1

# ******************************************
# 2. Index BAM
# ******************************************
samtools index sorted.bam || exit 1

# ******************************************
# 3. Check BAM integrity.
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

check_EOF('sorted.bam')
"

python -c "$py_script" || exit 1

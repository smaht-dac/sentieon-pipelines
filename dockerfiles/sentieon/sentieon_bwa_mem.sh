#!/bin/sh

# *******************************************
# Generate a sorted BAM file from paired FASTQ
# files for a single sample.
# The file will be sorted by coordinates.
# *******************************************

## Command line arguments
# Input FASTQ files
fastq_1=$1
fastq_2=$2

# Reference data files
reference_fa=$3
reference_bwt=$4

## Other settings
nt=$(nproc) # number of threads to use in computation,
            # set to number of cores in the server

## SymLink to reference files
fasta="reference.fasta"

# FASTA reference
ln -s ${reference_fa}.fa reference.fasta
ln -s ${reference_fa}.fa.fai reference.fasta.fai
ln -s ${reference_fa}.dict reference.dict

# BWT reference
ln -s ${reference_bwt}.bwt reference.fasta.bwt
ln -s ${reference_bwt}.ann reference.fasta.ann
ln -s ${reference_bwt}.amb reference.fasta.amb
ln -s ${reference_bwt}.pac reference.fasta.pac
ln -s ${reference_bwt}.sa reference.fasta.sa
ln -s ${reference_bwt}.alt reference.fasta.alt

# ******************************************
# 1. Mapping reads with BWA-MEM and
# sort by coordinates.
# ******************************************
( sentieon bwa mem -t $nt $fasta $fastq_1 $fastq_2 || exit 1 ) | sentieon util sort -o sorted.bam -t $nt --sam2bam -i -

# ******************************************
# 2. Check BAM integrity.
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

#!/bin/sh

# *******************************************
# Generate an analysis-ready BAM
# from a sorted BAM file for a single sample.
# The sorted BAM file need to be pre-processed
# to add read groups.
# *******************************************

## Command line arguments
# Input BAM
sorted_bam=$1

# Reference data files
reference_fa=$2
known_sites_snp=$3
known_sites_indel=$4

# Other
optical_dup_pix_dist=$5
# The maximum offset between two duplicate clusters in order to consider them optical duplicates.
# This should be set to 100 for (circa 2011+) read names and typical flowcells.
# Structured flow cells (NovaSeq, HiSeq 4000, X) should use ~2500.
# For older conventions, distances could be to some fairly small number (e.g. 5-10 pixels).

## Other settings
nt=$(nproc) # number of threads to use in computation,
            # set to number of cores in the server

## SymLink to reference files
fasta="reference.fasta"

# FASTA reference
ln -s ${reference_fa}.fa reference.fasta
ln -s ${reference_fa}.fa.fai reference.fasta.fai
ln -s ${reference_fa}.dict reference.dict

# ******************************************
# 1. Mark/remove duplicate reads.
# By ommiting the --rmdup option in Dedup
# we are only marking to match GATK Best Practices.
# ******************************************
sentieon driver -t $nt -i $sorted_bam --algo LocusCollector --fun score_info score.txt || exit 1
sentieon driver -t $nt -i $sorted_bam --algo Dedup --optical_dup_pix_dist $optical_dup_pix_dist --score_info score.txt --metrics dedup_metrics.txt deduped.bam || exit 1

# ******************************************
# 2. Indel realignment
# ******************************************
sentieon driver -r $fasta -t $nt -i deduped.bam --algo Realigner -k $known_sites_indel realigned.bam || exit 1

# *****************************************************************************
# 3. Base recalibration - see:
# https://support.sentieon.com/appnotes/arguments/#bqsr-calculate-recalibration
# Not generating RECAL_DATA.TABLE.POST for plotting, just need recal_data.table.
# *****************************************************************************
sentieon driver -r $fasta -t $nt -i realigned.bam --algo QualCal -k $known_sites_snp -k $known_sites_indel recal_data.table || exit 1
sentieon driver -r $fasta -t $nt -i realigned.bam -q recal_data.table --algo ReadWriter recalibrated.bam || exit 1

# ******************************************
# 4. Check recalibrated BAM integrity.
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

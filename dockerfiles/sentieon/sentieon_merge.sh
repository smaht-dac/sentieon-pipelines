#!/usr/bin/env bash

# *******************************************
# Take any number of BAM files as input and merge them
# producing a final merged BAM file.
# *******************************************

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

# *****************************************************************************
# 2. Merging
# *****************************************************************************
sentieon driver -t $nt $input_files --algo ReadWriter merged.bam || exit 1

# ******************************************
# 3. Check merged BAM integrity.
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

check_EOF('merged.bam')
"

python -c "$py_script" || exit 1

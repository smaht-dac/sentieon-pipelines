#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

  - class: EnvVarRequirement
    envDef:
      -
        envName: SENTIEON_LICENSE
        envValue: LICENSEID

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/sentieon:VERSION

baseCommand: [sentieon_bwa-mem_sort.sh]

inputs:
  - id: input_file_r1_fastq_gz
    type: File
    inputBinding:
      position: 1
    doc: Read 1 input file name.|
         Expect a compressed FASTQ file

  - id: input_file_r2_fastq_gz
    type: File
    inputBinding:
      position: 2
    doc: Read 2 input file name. |
         Expect a compressed FASTQ file

  - id: genome_reference_fasta
    type: File
    inputBinding:
      position: 3
      valueFrom: $(self.path.match(/(.*)\.[^.]+$/)[1])
    secondaryFiles:
      - ^.dict
      - .fai
    doc: Genome reference in FASTA format with the corresponding index files

  - id: genome_reference_bwt
    type: File
    inputBinding:
      position: 4
      valueFrom: $(self.path.match(/(.*)\.[^.]+$/)[1])
    secondaryFiles:
      - ^.ann
      - ^.amb
      - ^.pac
      - ^.sa
    doc: Genome reference in BWT format with the corresponding index files

outputs:
  - id: output_file_bam
    type: File
    outputBinding:
      glob: sorted.bam
    secondaryFiles:
      - .bai

doc: |
  Run Sentieon BWA-MEM on paired FASTQ files. |
  Sort the alignment BAM file by coordinates

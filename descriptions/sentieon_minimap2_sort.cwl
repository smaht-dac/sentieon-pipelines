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

baseCommand: [sentieon_minimap2_sort.sh]

inputs:
  - id: input_file_fastq_gz
    type: File
    inputBinding:
      position: 1
    doc: Reads input file name.|
         Expect a compressed FASTQ file

  - id: genome_reference_fasta
    type: File
    inputBinding:
      position: 2
    doc: Genome reference in FASTA format

  - id: preset
    type: string
    inputBinding:
      position: 3
    doc: Preset argument depending on technology. |
         map-pb   -> PacBio CLR genomic reads |
         map-ont  -> Oxford Nanopore genomic reads |
         map-hifi -> PacBio HiFi/CCS genomic reads (v2.19 or later)

outputs:
  - id: output_file_bam
    type: File
    outputBinding:
      glob: sorted.bam
    secondaryFiles:
      - .bai

doc: |
  Run Sentieon minimap2 on input FASTQ file. |
  Sort the alignment BAM file by coordinates

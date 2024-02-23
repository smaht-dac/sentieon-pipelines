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

baseCommand: [sentieon_ReadWriter.sh]

inputs:
  - id: input_files_bam
    type:
      -
        items: File
        type: array
        inputBinding:
          prefix: -i
    inputBinding:
      position: 2
    secondaryFiles:
      - .bai
    doc: List of input BAM files with the corresponding index file. |
         Must be sorted by coordinates

  - id: genome_reference_fasta
    type: File
    secondaryFiles:
      - ^.dict
      - .fai
    inputBinding:
      prefix: -r
      position: 1
    doc: Genome reference in FASTA format with the corresponding index files

  - id: regions
    default: null
    type:
      -
        items: string
        type: array
        inputBinding:
          prefix: -l
    inputBinding:
      position: 3
    doc: List of regions to use in the format <chr>:<start>-<end>

outputs:
  - id: output_file_bam
    type: File
    outputBinding:
      glob: merged.bam
    secondaryFiles:
      - .bai

doc: |
  Run Sentieon ReadWriter to merge multiple input files in BAM format. |
  Multiple regions can be speficied to use for the merge

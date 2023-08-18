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

baseCommand: [sentieon_merge.sh]

inputs:
  - id: input_files_bam
    type:
      -
        items: File
        type: array
    inputBinding:
      position: 1
    secondaryFiles:
      - .bai
    doc: List of input BAM files with the corresponding index file. |
         Must be sorted by coordinates, |
         and pre-processed to add read groups, mark duplicates, |
         and realign indels

outputs:
  - id: output_file_bam
    type: File
    outputBinding:
      glob: merged.bam
    secondaryFiles:
      - .bai

doc: |
  Takes any number of BAM files as input and merge them together |
  producing a final merged BAM file

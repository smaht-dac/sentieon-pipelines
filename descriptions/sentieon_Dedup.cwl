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

baseCommand: [sentieon_Dedup.sh]

inputs:
  - id: input_file_bam
    type: File
    inputBinding:
      position: 1
    secondaryFiles:
        - .bai
    doc: Input BAM file with the corresponding index file. |
         Must be sorted by coordinates, |
         and pre-processed to add read groups

  - id: optical_dup_pix_dist
    default: 2500
    type: int
    inputBinding:
      position: 2
    doc: The maximum offset between two duplicate clusters in order |
         to consider them optical duplicates. |
         This should be set to 100 for (circa 2011+) read names |
         and typical flowcells. |
         Structured flow cells (NovaSeq, HiSeq 4000, X) should use ~2500. |
         For older conventions, distances could be to some |
         fairly small number (e.g. 5-10 pixels)

outputs:
  - id: output_file_bam
    type: File
    outputBinding:
      glob: deduped.bam
    secondaryFiles:
      - .bai

doc: |
  Run Sentieon to mark duplicates (Dedup)

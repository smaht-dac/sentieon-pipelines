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

baseCommand: [sentieon_Realigner.sh]

inputs:
  - id: input_file_bam
    type: File
    inputBinding:
      position: 1
    secondaryFiles:
        - .bai
    doc: Input BAM file with the corresponding index file. |
         Must be sorted by coordinates, |
         and pre-processed to add read groups and mark duplicates

  - id: genome_reference_fasta
    type: File
    inputBinding:
      position: 2
      valueFrom: $(self.path.match(/(.*)\.[^.]+$/)[1])
    secondaryFiles:
      - ^.dict
      - .fai
    doc: Genome reference in FASTA format with the corresponding index files

  - id: known_sites_indel
    type: File
    inputBinding:
      position: 3
    secondaryFiles:
      - .tbi
    doc: VCF file used as a set of known indel sites (e.g. Mills and 1000G). |
         The known sites will be used to help identify likely sites |
         where the realignment is necessary. |
         Expect a compressed VCF with the corresponding index file

outputs:
  - id: output_file_bam
    type: File
    outputBinding:
      glob: realigned.bam
    secondaryFiles:
      - .bai

doc: |
  Run Sentieon to realign indels (Realigner)

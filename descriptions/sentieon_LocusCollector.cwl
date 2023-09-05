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

baseCommand: [sentieon_LocusCollector.sh]

inputs:
  - id: shards_file_txt
    type: File
    inputBinding:
      position: 1
    doc: Text file containing a list of contiguous regions to use. |
         Regions are divided by shards following the format |
         @<shard_index>TAB<chr>:<start>-<end>, |
         one region per line

  - id: shard_index
    type: string
    inputBinding:
      position: 2
    doc: Index to use to extract the right set of regions for the shard |
         from inputs.shards_file_txt

  - id: output_table_name
    type: string
    default: "score.vcf.gz"
    inputBinding:
      position: 3
    doc: Name for the compressed output table with the duplicates scoring |
         in VCF format

  - id: input_files_bam
    type:
      -
        items: File
        type: array
    inputBinding:
      position: 4
    secondaryFiles:
      - .bai
    doc: List of input BAM files with the corresponding index file. |
         Must be sorted by coordinates, |
         and pre-processed to add read groups

outputs:
  - id: output_table_vcf_gz
    type: File
    outputBinding:
      glob: $(inputs.output_table_name)
    secondaryFiles:
      - .tbi

doc: |
  Run Sentieon to calculate duplicate metrics with LocusCollector algorithm. |
  Accept a list of BAM files to enable processing by lane. |
  Implemented to run on shards in distributed mode

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

baseCommand: [sentieon_TNhaplotyper2.sh]

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

  - id: genome_reference_fasta
    type: File
    secondaryFiles:
      - ^.dict
      - .fai
    inputBinding:
      position: 3
    doc: Genome reference in FASTA format with the corresponding index files

  - id: population_allele_frequencies
    type: File
    secondaryFiles:
      - .tbi
    inputBinding:
      position: 4
    doc: Population allele frequencies in compressed VCF format (gzip|bgzip) |
         with the corresponding index file. |
         Can be obtained by post-processing gnomAD data as described in |
         https://support.sentieon.com/manual/TNseq_usage/tnseq, |
         or downloaded from the Broad as part of GATK Best Practice resources |
         https://console.cloud.google.com/storage/browser/gatk-best-practices

  - id: sample_name
    type: string
    inputBinding:
      position: 5
    doc: Name of the sample

  - id: input_files_bam
    type:
      -
        items: File
        type: array
    inputBinding:
      position: 6
    secondaryFiles:
      - .bai
    doc: List of input BAM files with the corresponding index file. |
         Must be sorted by coordinates, |
         and pre-processed to add read groups

outputs:
  - id: output_file_vcf_gz
    type: File
    outputBinding:
      glob: output.vcf.gz
    secondaryFiles:
      - .tbi

doc: |
  Run Sentieon TNhaplotyper2 algorithm for tumor only. |
  Require a file with population allele frequencies in VCF format. |
  Accept a list of BAM files and produce raw calls in VCF format. |
  Implemented to run on shards in distributed mode

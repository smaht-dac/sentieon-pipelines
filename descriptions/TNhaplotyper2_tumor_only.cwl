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

baseCommand: [TNhaplotyper2_tumor_only.sh]

inputs:
  - id: input_file_bam
    type: File
    secondaryFiles:
      - .bai
    inputBinding:
      prefix: -i
    doc: Input file in BAM format with the corresponding index file

  - id: sample_name
    type: string
    inputBinding:
      prefix: -s
    doc: Name of the sample

  - id: genome_reference_fasta
    type: File
    secondaryFiles:
      - ^.dict
      - .fai
    inputBinding:
      prefix: -r
    doc: Genome reference in FASTA format with the corresponding index files

  - id: panel_of_normal
    type: File
    default: null
    secondaryFiles:
      - .tbi
    inputBinding:
      prefix: -p
    doc: Panel of normal in compressed VCF format (gzip|bgzip) |
         with the corresponding index file. |
         Can be downloaded from the Broad as part of GATK Best Practice resources |
         https://console.cloud.google.com/storage/browser/gatk-best-practices

  - id: population_allele_frequencies
    type: File
    default: null
    secondaryFiles:
      - .tbi
    inputBinding:
      prefix: -g
    doc: Population allele frequencies in compressed VCF format (gzip|bgzip) |
         with the corresponding index file. |
         Can be obtained by post-processing gnomAD data as described in |
         https://support.sentieon.com/manual/TNseq_usage/tnseq, |
         or downloaded from the Broad as part of GATK Best Practice resources |
         https://console.cloud.google.com/storage/browser/gatk-best-practices

outputs:
  - id: TNhaplotyper2_vcf_gz
    type: File
    secondaryFiles:
      - .tbi
    outputBinding:
      glob: output.vcf.gz

doc: |
  Run Sentieon TNhaplotyper2 algorithm for tumor only. |
  It is possible to specify a panel of normal and/or a file with population allele frequencies

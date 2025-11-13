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
    dockerPull: ACCOUNT/dnascopehybrid:VERSION

baseCommand: [sentieon_DNAscopeHybrid.sh]

inputs:
  - id: sample_name
    type: string
    inputBinding:
      prefix: -n
    doc: Name of the sample

  - id: input_files_short_cram
    type: 
      - 
        items: File
        type: array
    secondaryFiles:
      - .crai
    inputBinding:
      prefix: -s
      itemSeparator: " "
    doc: Short-read input file in CRAM(s) format with the corresponding index file(s)

  - id: input_files_long_cram
    type: 
      - 
        items: File
        type: array
    secondaryFiles:
      - .crai
    inputBinding:
      prefix: -l
      itemSeparator: " "
    doc: Long-read input file in CRAM(s) format with the corresponding index file(s)

  - id: genome_reference_fasta
    type: File
    secondaryFiles:
      - .fai
      - ^.dict
    inputBinding:
      prefix: -r
      valueFrom: $(self.path.match(/(.*)\.[^.]+$/)[1])
    doc: Genome reference in FASTA format with the corresponding index files

  - id: genome_reference_bwt
    type: File
    secondaryFiles:
      - ^.sa
      - ^.pac
      - ^.ann
      - ^.amb
    inputBinding:
      prefix: -b
      valueFrom: $(self.path.match(/(.*)\.[^.]+$/)[1])
    doc: Genome reference in BWT format with the corresponding index files

  - id: dbsnp_vcf_gz
    type: File
    secondaryFiles:
      - .tbi
    inputBinding:
      prefix: -d
    doc: SNP database file in VCF format with corresponding index file
  
  - id: sentieon_model_bundle
    type: File
    inputBinding: 
      prefix: -m
    doc: Sentieon DNAscope Illumina and PacBio whole genome hybrid model in bundle format

outputs:
  - id: output_file_vcf_gz
    type: File
    secondaryFiles:
      - .tbi
    outputBinding:
      glob: $(inputs.sample_name + "-DSH.vcf.gz")

  - id: output_file_sv_vcf_gz
    type: File
    secondaryFiles:
      - .tbi
    outputBinding:
      glob: $(inputs.sample_name + "-DSH.sv.vcf.gz")

  - id: output_file_cnv_vcf_gz
    type: File
    secondaryFiles:
      - .tbi
    outputBinding:
      glob: $(inputs.sample_name + "-DSH.cnv.vcf.gz")

  - id: output_dir_metrics_tar_gz
    type: File
    outputBinding:
      glob: $(inputs.sample_name + "-DSH_metrics.tar.gz")

doc: |
  Run Sentieon DNAscope Hybrid on Illumina and PacBio data. |
  Produce germline variant calls in VCF format, including SNVs, SVs, and CNVs. |
  Produce metrics directory.
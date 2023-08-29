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

baseCommand: [sentieon_LocusCollector_apply.sh]

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

  - id: output_file_name
    type: string
    default: "deduped.bam"
    inputBinding:
      position: 2
    doc: Name for the ouput file in BAM format where duplicates are marked

  - id: optical_dup_pix_dist
    type: int
    default: 2500
    inputBinding:
      position: 3
    doc: The maximum offset between two duplicate clusters in order |
         to consider them optical duplicates. |
         This should be set to 100 for (circa 2011+) read names |
         and typical flowcells. |
         Structured flow cells (NovaSeq, HiSeq 4000, X) should use ~2500. |
         For older conventions, distances could be to some |
         fairly small number (e.g. 5-10 pixels)

  - id: input_tables_vcf_gz
    type:
      -
        items: File
        type: array
    inputBinding:
      position: 4
    secondaryFiles:
      - .tbi
    doc: List of score tables generated by LocusCollector in compressed VCF format |
         with the corresponding index file

outputs:
  - id: output_file_bam
    type: File
    outputBinding:
      glob: $(inputs.output_file_name)
    secondaryFiles:
      - .bai

doc: Run Sentieon Dedup with a list of score tables generated by LocusCollector |
     in distributed mode. |
     Mark duplicate reads in the inpute BAM file

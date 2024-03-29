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

  - id: output_file_name
    type: string
    default: "deduped.bam"
    inputBinding:
      position: 3
    doc: Name for the ouput file in BAM format where duplicates are marked

  - id: optical_dup_pix_dist
    type: int
    default: 2500
    inputBinding:
      position: 4
    doc: The maximum offset between two duplicate clusters in order |
         to consider them optical duplicates. |
         This should be set to 100 for (circa 2011+) read names |
         and typical flowcells. |
         Structured flow cells (NovaSeq, HiSeq 4000, X) should use ~2500. |
         For older conventions, distances could be to some |
         fairly small number (e.g. 5-10 pixels)

  - id: input_files_bam
    type:
      -
        items: File
        type: array
    inputBinding:
      position: 5
    secondaryFiles:
      - .bai
    doc: List of input BAM files with the corresponding index file. |
         Must be sorted by coordinates, |
         and pre-processed to add read groups

  - id: input_tables_vcf_gz
    type:
      -
        items: File
        type: array
    inputBinding:
      position: 6
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

doc: Run Sentieon to mark duplicates with Dedup algorithm. |
     Accept a list of BAM files to enable processing by lane. |
     Accept a list of score tables generated by LocusCollector |
     in distributed mode. |
     Implemented to run on shards in distributed mode

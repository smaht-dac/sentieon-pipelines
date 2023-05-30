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

baseCommand: [sentieon_dedup_realign_recal.sh]

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

  - id: genome_reference_fasta
    type: File
    inputBinding:
      position: 2
      valueFrom: $(self.path.match(/(.*)\.[^.]+$/)[1])
    secondaryFiles:
      - ^.dict
      - .fai
    doc: Genome reference in FASTA format with the corresponding index files

  - id: known_sites_snp
    type: File
    inputBinding:
      position: 3
    secondaryFiles:
      - .tbi
    doc: VCF file used as a set of known SNP sites (e.g. dbSNP). |
         The known sites will be used to make sure that known locations |
         do not get artificially low quality scores by misidentifying |
         true variants errors in the sequencing methodology. |
         Expect a compressed VCF with the corresponding index file

  - id: known_sites_indel
    type: File
    inputBinding:
      position: 4
    secondaryFiles:
      - .idx
    doc: VCF file used as a set of known indel sites (e.g. Mills and 1000G). |
         The known sites will be used to help identify likely sites |
         where the realignment is necessary. |
         Expect a normal VCF with the corresponding index file

  - id: optical_dup_pix_dist
    default: 2500
    type: int
    inputBinding:
      position: 5
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
      glob: recalibrated.bam
    secondaryFiles:
        - .bai

doc: |
  Run Sentieon to mark duplicates (Dedup), |
  realign indels (Realigner), |
  calculate (QualCal) and apply base and indel scores recalibration

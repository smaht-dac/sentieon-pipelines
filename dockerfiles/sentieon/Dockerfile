#######################################################################
#     Basic image
#######################################################################
FROM public.ecr.aws/smaht-dac/base-ubuntu2204-py38:0.0.1

LABEL maintainers="Michele Berselli (berselli.michele@gmail.com), Dominika Maziec (dominika_maziec@hms.harvard.edu)"

#######################################################################
#     General updates & installing necessary Linux components
#       - libncurses-dev, libbz2-dev, liblzma-dev used by samtools
#######################################################################
RUN apt-get update -y && apt-get install -y \
    locales \
    tabix=1.13+ds-2build1 \
    libncurses-dev=6.3-2 \
    libbz2-dev=1.0.8-5build1 \
    liblzma-dev=5.2.5-2ubuntu1 \
    --no-install-recommends \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

#######################################################################
#     Setting env
#######################################################################
## Set working directory
WORKDIR /usr/local/bin

## Supporting UTF-8
RUN locale-gen "en_US.UTF-8" && update-locale LC_ALL="en_US.UTF-8"
ENV LC_ALL=en_US.UTF-8

#######################################################################
#     Software
#######################################################################
## Sentieon install
RUN wget https://s3.amazonaws.com/sentieon-release/software/sentieon-genomics-202308.01.tar.gz && \
    tar -xzvf sentieon-genomics-202308.01.tar.gz && \
    ln -s sentieon-genomics-202308.01 sentieon

## Samtools install
RUN wget https://github.com/samtools/samtools/releases/download/1.17/samtools-1.17.tar.bz2 && \
    tar -xjf samtools-1.17.tar.bz2 && \
    rm -rf samtools-1.17.tar.bz2

WORKDIR /usr/local/bin/samtools-1.17
RUN ./configure && \
    make

WORKDIR /usr/local/bin/
RUN ln -s samtools-1.17 samtools

#######################################################################
#     Scripts
#######################################################################
## sentieon_bwa-mem_sort_Hi-C
COPY sentieon_bwa-mem_sort_Hi-C.sh .
RUN chmod +x sentieon_bwa-mem_sort_Hi-C.sh

## sentieon_bwa-mem_sort
COPY sentieon_bwa-mem_sort.sh .
RUN chmod +x sentieon_bwa-mem_sort.sh

## sentieon_Dedup
COPY sentieon_Dedup.sh .
RUN chmod +x sentieon_Dedup.sh

## sentieon_LocusCollector_apply
COPY sentieon_LocusCollector_apply.sh .
RUN chmod +x sentieon_LocusCollector_apply.sh

## sentieon_LocusCollector
COPY sentieon_LocusCollector.sh .
RUN chmod +x sentieon_LocusCollector.sh

## sentieon_minimap2_sort
COPY sentieon_minimap2_sort.sh .
RUN chmod +x sentieon_minimap2_sort.sh

## sentieon_QualCal_merge
COPY sentieon_QualCal_merge.sh .
RUN chmod +x sentieon_QualCal_merge.sh

## sentieon_QualCal
COPY sentieon_QualCal.sh .
RUN chmod +x sentieon_QualCal.sh

## sentieon_Realigner
COPY sentieon_Realigner.sh .
RUN chmod +x sentieon_Realigner.sh

## TNhaplotyper2_tumor_only
COPY TNhaplotyper2_tumor_only.sh .
RUN chmod +x TNhaplotyper2_tumor_only.sh

## sentieon_TNhaplotyper2
COPY sentieon_TNhaplotyper2.sh .
RUN chmod +x sentieon_TNhaplotyper2.sh

## sentieon_TNhaplotyper2_wOrientationBias_ContaminationModel_normal
COPY sentieon_TNhaplotyper2_wOrientationBias_ContaminationModel_normal.sh .
RUN chmod +x sentieon_TNhaplotyper2_wOrientationBias_ContaminationModel_normal.sh

## sentieon_TNhaplotyper2_wOrientationBias_ContaminationModel
COPY sentieon_TNhaplotyper2_wOrientationBias_ContaminationModel.sh .
RUN chmod +x sentieon_TNhaplotyper2_wOrientationBias_ContaminationModel.sh

## sentieon_merge_TNfilter_normal
COPY sentieon_merge_TNfilter_normal.sh .
RUN chmod +x sentieon_merge_TNfilter_normal.sh

## sentieon_merge_TNfilter
COPY sentieon_merge_TNfilter.sh .
RUN chmod +x sentieon_merge_TNfilter.sh

## sentieon_ReadWriter
COPY sentieon_ReadWriter.sh .
RUN chmod +x sentieon_ReadWriter.sh

#######################################################################
#     Updating env
#######################################################################
ENV PATH=/usr/local/bin/sentieon/bin/:$PATH
ENV PATH=/usr/local/bin/samtools/:$PATH

CMD ["bash"]

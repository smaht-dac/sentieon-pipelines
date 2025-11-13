#######################################################################
#     Basic image
#######################################################################
FROM public.ecr.aws/smaht-dac/base-ubuntu2204-py38:0.0.1

LABEL maintainers="Charlotte Zhang (charlotte_zhang@hms.harvard.edu), Dominika Maziec (dominika_maziec@hms.harvard.edu), Michele Berselli (berselli.michele@gmail.com)"

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
RUN wget https://s3.amazonaws.com/sentieon-release/software/sentieon-genomics-202503.01.tar.gz && \
    tar -xzvf sentieon-genomics-202503.01.tar.gz && \
    ln -s sentieon-genomics-202503.01 sentieon

## Sentieon models install
RUN wget https://s3.amazonaws.com/sentieon-release/other/HybridIlluminaPacBio1.1.bundle && \
    ln -s HybridIlluminaPacBio1.1.bundle sentieon_model 

## Samtools install
RUN wget https://github.com/samtools/samtools/releases/download/1.22.1/samtools-1.22.1.tar.bz2 && \
    tar -xjf samtools-1.22.1.tar.bz2 && \
    rm -rf samtools-1.22.1.tar.bz2

WORKDIR /usr/local/bin/samtools-1.22.1
RUN ./configure && \
    make

WORKDIR /usr/local/bin/
RUN ln -s samtools-1.22.1 samtools

## Bcftools install
RUN wget https://github.com/samtools/bcftools/releases/download/1.22/bcftools-1.22.tar.bz2 && \
    tar -xjf bcftools-1.22.tar.bz2 && \
    rm -rf bcftools-1.22.tar.bz2

WORKDIR /usr/local/bin/bcftools-1.22
RUN ./configure && \
    make

WORKDIR /usr/local/bin/
RUN ln -s bcftools-1.22 bcftools

## Bedtools install
RUN wget https://github.com/arq5x/bedtools2/releases/download/v2.31.1/bedtools-2.31.1.tar.gz && \
    tar -xzf bedtools-2.31.1.tar.gz && \
    rm -rf bedtools-2.31.1.tar.gz

WORKDIR /usr/local/bin/bedtools2
RUN make

WORKDIR /usr/local/bin/
RUN ln -s bedtools2 bedtools

## MultiQC install
RUN pip install multiqc==1.32

## Mosdepth install
RUN wget https://github.com/brentp/mosdepth/releases/download/v0.3.11/mosdepth && \
    chmod +x mosdepth

#######################################################################
#     Scripts
#######################################################################
## sentieon_DNAscopeHybrid
COPY sentieon_DNAscopeHybrid.sh .
RUN chmod +x sentieon_DNAscopeHybrid.sh

#######################################################################
#     Updating env
#######################################################################
ENV PATH=/usr/local/bin/sentieon/bin/:$PATH
ENV PATH=/usr/local/bin/sentieon_model/:$PATH
ENV PATH=/usr/local/bin/samtools/:$PATH
ENV PATH=/usr/local/bin/bcftools/:$PATH
ENV PATH=/usr/local/bin/bedtools/:$PATH
ENV PATH=/usr/local/bin/multiqc/:$PATH
ENV PATH=/usr/local/bin/mosdepth/:$PATH

CMD ["bash"]
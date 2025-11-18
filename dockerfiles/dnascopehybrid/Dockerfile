#######################################################################
#     Basic image
#######################################################################
FROM public.ecr.aws/smaht-dac/base-ubuntu2204-py38:0.0.1

LABEL maintainers="Charlotte Zhang (charlotte_zhang@hms.harvard.edu), Dominika Maziec (dominika_maziec@hms.harvard.edu), Michele Berselli (berselli.michele@gmail.com)"

#######################################################################
#     General updates & installing necessary Linux components
#       - libncurses-dev, libbz2-dev, liblzma-dev used by samtools
#       - libjemalloc2 used by Sentieon for better performance
#######################################################################
RUN apt-get update -y && apt-get install -y \
    locales \
    tabix=1.13+ds-2build1 \
    libncurses-dev=6.3-2 \
    libbz2-dev=1.0.8-5build1 \
    liblzma-dev=5.2.5-2ubuntu1 \
    libjemalloc2=5.2.1-4ubuntu1 \
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

# Set jemalloc as the default memory allocator for better performance
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2

#######################################################################
#     Software
#######################################################################
## Sentieon install & CLI
RUN wget https://s3.amazonaws.com/sentieon-release/software/sentieon-genomics-202503.01.tar.gz && \
    tar -xzvf sentieon-genomics-202503.01.tar.gz && \
    rm -rf sentieon-genomics-202503.01.tar.gz && \
    ln -s sentieon-genomics-202503.01 sentieon

RUN curl -LO https://github.com/Sentieon/sentieon-cli/releases/download/v1.4.0/sentieon_cli-1.4.0.tar.gz && \
    pip install sentieon_cli-1.4.0.tar.gz && \
    tar -xzvf sentieon_cli-1.4.0.tar.gz && \
    ln -s sentieon_cli-1.4.0 sentieon-cli

## Samtools install
RUN wget https://github.com/samtools/samtools/releases/download/1.17/samtools-1.17.tar.bz2 && \
    tar -xjf samtools-1.17.tar.bz2 && \
    rm -rf samtools-1.17.tar.bz2

WORKDIR /usr/local/bin/samtools-1.17
RUN ./configure && \
    make

WORKDIR /usr/local/bin/
RUN ln -s samtools-1.17 samtools

## Bcftools install
RUN wget https://github.com/samtools/bcftools/releases/download/1.17/bcftools-1.17.tar.bz2 && \
    tar -xjf bcftools-1.17.tar.bz2 && \
    rm -rf bcftools-1.17.tar.bz2

WORKDIR /usr/local/bin/bcftools-1.17
RUN ./configure && \
    make

WORKDIR /usr/local/bin/
RUN ln -s bcftools-1.17 bcftools

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
RUN wget https://github.com/brentp/mosdepth/releases/download/v0.3.9/mosdepth && \
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
ENV PATH=/usr/local/bin/samtools/:$PATH
ENV PATH=/usr/local/bin/bcftools/:$PATH
ENV PATH=/usr/local/bin/bedtools/bin/:$PATH

CMD ["bash"]

#######################################################################
#     Basic image
#######################################################################
FROM smaht/ubuntu2204-py38:0.0.1

MAINTAINER Michele Berselli (berselli.michele@gmail.com)

#######################################################################
#     General updates & installing necessary Linux components
#       - libncurses-dev, libbz2-dev, liblzma-dev used by samtools
#######################################################################
RUN apt-get update -y && apt-get install -y \
    locales \
    tabix \
    libncurses-dev \
    libbz2-dev \
    liblzma-dev

#######################################################################
#     Setting working env
#######################################################################
WORKDIR /usr/local/bin

#######################################################################
#     Software
#######################################################################
## sentieon
RUN wget https://s3.amazonaws.com/sentieon-release/software/sentieon-genomics-202112.01.tar.gz && \
    tar -xzvf sentieon-genomics-202112.01.tar.gz && \
    ln -s sentieon-genomics-202112.01 sentieon

## Samtools install
RUN wget https://github.com/samtools/samtools/releases/download/1.17/samtools-1.17.tar.bz2 && \
    tar -xjf samtools-1.17.tar.bz2 && \
    rm -rf samtools-1.17.tar.bz2 && \
    cd samtools-1.17 && \
    ./configure && \
    make && \
    cd .. && \
    ln -s samtools-1.17 samtools

#######################################################################
#     Scripts
#######################################################################
## TNhaplotyper2_tumor_only.sh
COPY TNhaplotyper2_tumor_only.sh .
RUN chmod +x TNhaplotyper2_tumor_only.sh

#######################################################################
#     Setting env variables
#######################################################################
ENV PATH=/usr/local/bin/sentieon/bin/:$PATH
ENV PATH=/usr/local/bin/samtools/:$PATH

## Supporting UTF-8
RUN locale-gen "en_US.UTF-8" && update-locale LC_ALL="en_US.UTF-8"
ENV LC_ALL=en_US.UTF-8

CMD ["bash"]

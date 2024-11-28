FROM ubuntu:24.04

LABEL maintainer="@noraj"

# Install dependencies.
ARG DEBIAN_FRONTEND="noninteractive"
RUN apt-get update \
 && apt-get install -y \
      wget \
      texlive-latex-recommended \
      texlive-fonts-extra \
      texlive-latex-extra \
      pandoc \
      p7zip-full \
 && apt-get clean \ 
 && rm -rf /var/lib/apt/lists/*

# Add required files from 'OSCP-Exam-Report-Template-Markdown' repository.
RUN cd /root && mkdir report-generator
ADD . /root/report-generator

# Get Eisvogel 2.0.0 template (latest as of 2021-07-14).
RUN mkdir /tmp/eisvogel \
    && wget --directory-prefix /tmp/eisvogel https://github.com/Wandmalfarbe/pandoc-latex-template/releases/download/v2.5.0/Eisvogel-2.5.0.tar.gz \
    && tar xf /tmp/eisvogel/Eisvogel-2.5.0.tar.gz --directory=/tmp/eisvogel \
    && mv /tmp/eisvogel/eisvogel.latex /usr/share/pandoc/data/templates/ \
    && rm -rf /tmp/eisvogel

# Default directories.
VOLUME /root/report-generator/output
VOLUME /root/report-generator/src
WORKDIR /root/report-generator

# Add entrypoint script.
ADD docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

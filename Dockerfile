FROM nvidia/cuda:12.8.1-runtime-rockylinux8

RUN yum -y install curl tar bzip2 ca-certificates procps-ng && \
    yum clean all && rm -rf /var/cache/yum

# Copy version metadata files
COPY VERSION CHECKSUM /tmp/

RUN set -euxo pipefail \
 && DORADO_VER=$(cat /tmp/VERSION | tr -d '[:space:]') \
 && DORADO_SHA256=$(cat /tmp/CHECKSUM | tr -d '[:space:]') \
 && DORADO_URL="https://cdn.oxfordnanoportal.com/software/analysis/dorado-${DORADO_VER}-linux-x64.tar.gz" \
 && echo "Building Dorado version: ${DORADO_VER}" \
 && echo "Expected SHA256: ${DORADO_SHA256}" \
 && mkdir -p /opt/dorado \
 && curl -L "${DORADO_URL}" -o /tmp/dorado.tar.gz \
 && echo "${DORADO_SHA256}  /tmp/dorado.tar.gz" | sha256sum -c - \
 && tar -xzf /tmp/dorado.tar.gz -C /opt/dorado --strip-components=1 \
 && rm -f /tmp/dorado.tar.gz /tmp/CHECKSUM /tmp/VERSION

ENV PATH="/opt/dorado/bin:/opt/conda/bin:${PATH}"

# Sanity check
RUN command -v dorado && dorado --version || (echo "dorado not found" && exit 1)

# Install micromamba and bioconda packages
RUN set -euxo pipefail \
 && curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj -C /usr/local bin/micromamba \
 && micromamba install -y \
        --root-prefix /opt/conda \
        --prefix /opt/conda \
        -c conda-forge -c bioconda -c defaults \
        bioconda::minimap2=2.30 \
        bioconda::samtools=1.21 \
        conda-forge::pigz=2.8 \
 && micromamba clean -afy

LABEL org.opencontainers.image.title="Dorado"
LABEL org.opencontainers.image.description="Dorado basecaller for Oxford Nanopore sequencing data"

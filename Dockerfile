# Start from NVIDIA’s CUDA runtime image (no dev tools, just runtime libs)
FROM nvidia/cuda:12.8.1-runtime-rockylinux8

# Install dependencies: curl + tar for fetching Dorado
RUN yum -y install curl tar ca-certificates && \
    yum clean all && rm -rf /var/cache/yum

# Add Dorado
ARG DORADO_VER=1.1.1
ARG DORADO_URL=https://cdn.oxfordnanoportal.com/software/analysis/dorado-${DORADO_VER}-linux-x64.tar.gz

RUN mkdir -p /opt/dorado && \
    curl -L ${DORADO_URL} -o /tmp/dorado.tar.gz && \
    tar -xzf /tmp/dorado.tar.gz -C /opt/dorado --strip-components=1 && \
    rm /tmp/dorado.tar.gz

# Put Dorado on PATH
ENV PATH="/opt/dorado:${PATH}"

# Optional: sanity check
RUN dorado --version

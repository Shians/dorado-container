FROM nvidia/cuda:12.8.1-runtime-rockylinux8

RUN yum -y install curl tar ca-certificates coreutils && \
    yum clean all && rm -rf /var/cache/yum

ARG DORADO_VER=1.1.1
ARG DORADO_URL=https://cdn.oxfordnanoportal.com/software/analysis/dorado-${DORADO_VER}-linux-x64.tar.gz

# Install to a stable prefix keeping the bin/lib structure
RUN set -euxo pipefail \
 && mkdir -p /opt/dorado \
 && curl -L "${DORADO_URL}" -o /tmp/dorado.tar.gz \
 && tar -xzf /tmp/dorado.tar.gz -C /opt/dorado --strip-components=1 \
 && rm -f /tmp/dorado.tar.gz

# Create a wrapper that exports LD_LIBRARY_PATH and execs the real binary
RUN install -d /usr/local/bin && \
    bash -lc 'cat > /usr/local/bin/dorado << "EOF"\n\
#!/usr/bin/env bash\n\
set -euo pipefail\n\
export LD_LIBRARY_PATH="/opt/dorado/lib:${LD_LIBRARY_PATH:-}"\n\
exec /opt/dorado/bin/dorado "$@"\n\
EOF' && \
    chmod +x /usr/local/bin/dorado

# (Optional) also expose the directory on PATH for manual use
ENV PATH="/opt/dorado/bin:${PATH}"

# Sanity checks
RUN command -v dorado && dorado --version && \
    ldd /opt/dorado/bin/dorado | grep -E 'cudart|cublas|stdc\+\+' || true

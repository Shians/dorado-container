FROM nvidia/cuda:12.8.1-runtime-rockylinux8

RUN yum -y install curl tar ca-certificates && \
    yum clean all && rm -rf /var/cache/yum

ARG DORADO_VER=1.1.1
ARG DORADO_URL=https://cdn.oxfordnanoportal.com/software/analysis/dorado-${DORADO_VER}-linux-x64.tar.gz
ARG DORADO_SHA256=08f6ef13b23867bddaa2abee292627e617ca2d2d68d9379dcae703add9940360

RUN set -euxo pipefail \
 && mkdir -p /opt/dorado \
 && curl -L "${DORADO_URL}" -o /tmp/dorado.tar.gz \
 && echo "${DORADO_SHA256}  /tmp/dorado.tar.gz" | sha256sum -c - \
 && tar -xzf /tmp/dorado.tar.gz -C /opt/dorado --strip-components=1 \
 && rm -f /tmp/dorado.tar.gz

RUN mkdir -p /usr/local/bin && \
    /bin/bash -lc 'cat > /usr/local/bin/dorado << "EOF"\n\
#!/usr/bin/env bash\n\
set -euo pipefail\n\
export LD_LIBRARY_PATH="/opt/dorado/lib:${LD_LIBRARY_PATH:-}"\n\
exec /opt/dorado/bin/dorado "$@"\n\
EOF' && \
    chmod +x /usr/local/bin/dorado

ENV PATH="/opt/dorado/bin:${PATH}"

# Sanity check
RUN command -v dorado && dorado --version || (echo "dorado not found" && exit 1)

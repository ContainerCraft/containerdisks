FROM registry.access.redhat.com/ubi8/ubi-minimal
ARG FLAVOR
ARG TARGETARCH
COPY images/${FLAVOR}/                    /meta/
COPY images/${FLAVOR}-${TARGETARCH}.qcow2 /disk/${FLAVOR}.qcow2

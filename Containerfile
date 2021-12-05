FROM registry.access.redhat.com/ubi8/ubi-minimal
ARG FLAVOR
ARG TARGETARCH
COPY kmi/${FLAVOR}/virt.sysprep           /meta/virt.sysprep
COPY kmi/${FLAVOR}/env.sh                 /meta/env.sh
COPY images/${FLAVOR}-${TARGETARCH}.qcow2 /disk/${FLAVOR}.qcow2

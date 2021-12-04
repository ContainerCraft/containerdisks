FROM scratch
ARG TARGETARCH
ARG FLAVOR
COPY kmi/${FLAVOR}/virt.sysprep           /disk/
COPY kmi/${FLAVOR}/env.sh                 /disk/
COPY images/${FLAVOR}-${TARGETARCH}.qcow2 /disk/${FLAVOR}.qcow2

FROM registry.access.redhat.com/ubi8/ubi-minimal
ARG FLAVOR
ARG TARGETARCH
COPY kmi/${FLAVOR}/                       /meta/
COPY images/${FLAVOR}-${TARGETARCH}.qcow2 /disk/${FLAVOR}.qcow2
LABEL \
      org.opencontainers.image.description="Kubevirt Machine Image | ${TARGETARCH} | ${FLAVOR}" \
      org.opencontainers.image.url="github.com/containercraft/kmi" \
      org.opencontainers.image.title="${FLAVOR}-${TARGETARCH}" \
      org.opencontainers.image.authors="ContainerCraft.io"

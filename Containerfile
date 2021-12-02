FROM scratch
ARG FLAVOR=${FLAVOR}
COPY images/${FLAVOR}.qcow2 /disk/${FLAVOR}.qcow2

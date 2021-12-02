FROM scratch
ARG FLAVOR=${FLAVOR}
COPY /tmp/images/${FLAVOR}.qcow2 /disk/${FLAVOR}.qcow2

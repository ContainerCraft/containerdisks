FROM scratch
ARG FLAVOR=${FLAVOR}
COPY /tmp/images/${FLAVOR}.sparse.qcow2 /disk/${FLAVOR}.qcow2

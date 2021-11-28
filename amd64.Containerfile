# ENTIRE Containerfile is POC
# TODO: Build UBI based sys-preptools / libguestfs multi-arch containers to resolve most lines of code below
FROM docker.io/bkahlert/libguestfs as sysprep
#FROM docker.io/containercraft/sysprep:testing as sysprep

ARG TARGETARCH
ARG ARCH=${ARCH}
ARG FLAVOR=${FLAVOR}
ARG VERSION=${VERSION}
ARG PKG_LIST=${PKG_LIST}
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

WORKDIR /disk

COPY index.json          index.json
COPY kmi/preview/ubuntu/firstboot.sh firstboot.sh

# Download Image
# TODO: need to convert ${VERSION} from integer to string 
RUN set -x \
    && apt-get update \
    && apt-get install apt-utils -y \
    && apt-get install jq -y \
    && echo;

RUN set -x \
    && echo ${BAKE_LOCAL_PLATFORM} \
    && export DOWNLOAD_URL=$(jq -r .distributions.${FLAVOR}.v${VERSION}.${ARCH}.url index.json) \
    && echo ${ARCH} \
    && curl --output source.${FLAVOR}.qcow2 -L ${DOWNLOAD_URL} \
    && echo;

RUN set -ex \
    && qemu-img resize source.${FLAVOR}.qcow2 +20G                                \
    && virt-sparsify -v --compress source.${FLAVOR}.qcow2 ${FLAVOR}.qcow2         \
    && rm source.${FLAVOR}.qcow2                                                  \
    && echo;

# Sysprep Image
RUN set -ex \
    && virt-sysprep -va ${FLAVOR}.qcow2                                           \
         --network                                                                \
         --update                                                                 \
         --firstboot firstboot.sh \
         --enable user-account,logfiles,customize,bash-history,net-hostname,net-hwaddr,machine-id,dhcp-server-state,dhcp-client-state,yum-uuid,udev-persistent-net,tmp-files,smolt-uuid,rpm-db,package-manager-cache \
    && virt-sparsify --compress ${FLAVOR}.qcow2 ${FLAVOR}.sparse.qcow2            \
    && rm ${FLAVOR}.qcow2                                                         \
    && qemu-img info ${FLAVOR}.sparse.qcow2                                       \
    && echo;

# Copy disk image into cradle
FROM scratch
ARG FLAVOR=${FLAVOR}
COPY --from=sysprep /disk/${FLAVOR}.sparse.qcow2 /disk/${FLAVOR}.qcow2

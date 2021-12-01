FROM quay.io/containercraft/ubi:base
ARG FLAVOR=${FLAVOR}
LABEL \
  license=GPLv3                                                                 \
  name="${ORIGIN_LICENSE_URL}"                                                  \
  version="${RELEASE_VERSION}"                                                  \
  distribution-scope="public"                                                   \
  io.openshift.tags="containercraft,kubevirt,kmi,${FLAVOR},${VERSION},${ARCH}"  \
  io.k8s.display-name="${FLAVOR}-${VERSION}-${ARCH}"                            \
  summary="${FLAVOR} Kubevirt Machine Image"                                    \
  description="ContainerCraft.io Maintained Public Reference KMI"               \
  image_origin="${DOWNLOAD_URL}"                                                \
  image_origin_checksum="${SHASUM}"                                             \
  io.k8s.description="ContainerCraft.io Maintained Public Reference KMI"

ADD rootfs/arm64/ /
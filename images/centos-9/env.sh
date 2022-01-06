VIRT_SYSPREP_OPERATIONS=net-hostname,net-hwaddr,machine-id,dhcp-server-state,dhcp-client-state,yum-uuid,udev-persistent-net,tmp-files,smolt-uuid,rpm-db,package-manager-cache
_BUILD_DATE=20220118.0
_ARCH=$(echo ${ARCH} | sed 's/amd64/x86_64/;s/arm64/aarch64/')
BASE_URL=https://cloud.centos.org/centos/9-stream/"${_ARCH}"/images
DOWNLOAD_FILE=CentOS-Stream-GenericCloud-9-"${_BUILD_DATE}"."${_ARCH}".qcow2
AMD64_SHA256SUM=6d9f08f1d5fcf38790dd43dbd0f20816a8909a1f69612f2e8cde33dc6b147efd
ARM64_SHA256SUM=784872a8a7d49d92db9f11ead9b9c5ae8e284210bb5f484259d171285501dbd0

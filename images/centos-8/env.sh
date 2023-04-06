VIRT_SYSPREP_OPERATIONS=net-hostname,net-hwaddr,machine-id,dhcp-server-state,dhcp-client-state,yum-uuid,udev-persistent-net,tmp-files,smolt-uuid,rpm-db,package-manager-cache
_BUILD_DATE=
_ARCH=$(echo ${ARCH} | sed 's/amd64/x86_64/;s/arm64/aarch64/')
BASE_URL=https://cloud.centos.org/centos/8-stream/"${_ARCH}"/images
DOWNLOAD_FILE=CentOS-Stream-GenericCloud-8-"${_BUILD_DATE}"."${_ARCH}".qcow2
AMD64_SHA256SUM=
ARM64_SHA256SUM=

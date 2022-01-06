VIRT_SYSPREP_OPERATIONS=net-hostname,net-hwaddr,machine-id,dhcp-server-state,dhcp-client-state,yum-uuid,udev-persistent-net,tmp-files,smolt-uuid,rpm-db,package-manager-cache
_BUILD_DATE=20210210.0
_ARCH=$(echo ${ARCH} | sed 's/amd64/x86_64/;s/arm64/aarch64/')
BASE_URL=https://cloud.centos.org/centos/8-stream/"${_ARCH}"/images
DOWNLOAD_FILE=CentOS-Stream-GenericCloud-8-"${_BUILD_DATE}"."${_ARCH}".qcow2
AMD64_SHA256SUM=c02b29ffc014761895d67a5294f1957b246f8dbcf33b6e26520bba05d7f627ad
ARM64_SHA256SUM=3b82f91518ca4c11edec4aa32db5eb5cfdf94f6f4b90ee7d665d881c2a536b0a

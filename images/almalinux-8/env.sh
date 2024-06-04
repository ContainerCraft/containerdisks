VIRT_SYSPREP_OPERATIONS=net-hostname,net-hwaddr,machine-id,dhcp-server-state,dhcp-client-state,yum-uuid,udev-persistent-net,tmp-files,smolt-uuid,rpm-db,package-manager-cache
_ARCH=$(echo ${ARCH} | sed 's/amd64/x86_64/;s/arm64/aarch64/')
BASE_URL=https://repo.almalinux.org/almalinux/8/cloud/"${_ARCH}"/images/
DOWNLOAD_FILE=AlmaLinux-8-GenericCloud-latest."${_ARCH}".qcow2
AMD64_SHA256SUM=41a6bcdefb35afbd2819f0e6c68005cd5e9a346adf2dc093b1116a2b7c647d86
ARM64_SHA256SUM=5508d4df26925806da507f59b4990e996ef982de3d546a356891acc87e161c32

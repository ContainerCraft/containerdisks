VIRT_SYSPREP_OPERATIONS=net-hostname,net-hwaddr,machine-id,dhcp-server-state,dhcp-client-state,yum-uuid,udev-persistent-net,tmp-files,smolt-uuid,rpm-db,package-manager-cache
_ARCH=$(echo ${ARCH} | sed 's/amd64/x86_64/;s/arm64/aarch64/')
BASE_URL=https://repo.almalinux.org/almalinux/8/cloud/"${_ARCH}"/images/
DOWNLOAD_FILE=AlmaLinux-8-GenericCloud-latest."${_ARCH}".qcow2
AMD64_SHA256SUM=a1686bc537bce699b512e3233666f5b8f69ed797ff1ce0af52c17fdc52942621
ARM64_SHA256SUM=603531fce80537f1ac4f78b6a43f79a47d1b2d70247fb2004da48ff1e5300813

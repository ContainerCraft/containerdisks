VIRT_SYSPREP_OPERATIONS=user-account,logfiles,customize,bash-history,net-hostname,net-hwaddr,machine-id,dhcp-server-state,dhcp-client-state,yum-uuid,udev-persistent-net,tmp-files,smolt-uuid,rpm-db,package-manager-cache
_ARCH=$(echo ${ARCH} | sed 's/amd64/x86_64/;s/arm64/aarch64/')
BASE_URL=https://download.fedoraproject.org/pub/fedora/linux/releases/35/Cloud/"${_ARCH}"/images
DOWNLOAD_FILE=Fedora-Cloud-Base-35-1.2."${_ARCH}".qcow2
AMD64_SHA256SUM=
ARM64_SHA256SUM=
SKIP="ssh"

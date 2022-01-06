VIRT_SYSPREP_OPERATIONS=user-account,logfiles,customize,bash-history,net-hostname,net-hwaddr,machine-id,dhcp-server-state,dhcp-client-state,yum-uuid,udev-persistent-net,tmp-files,smolt-uuid,rpm-db,package-manager-cache
_ARCH=$(echo ${ARCH} | sed 's/amd64/x86_64/;s/arm64/aarch64/')
BASE_URL=https://download.fedoraproject.org/pub/fedora/linux/releases/34/Cloud/"${_ARCH}"/images
DOWNLOAD_FILE=Fedora-Cloud-Base-34-1.2."${_ARCH}".qcow2
AMD64_SHA256SUM=b9b621b26725ba95442d9a56cbaa054784e0779a9522ec6eafff07c6e6f717ea
ARM64_SHA256SUM=141f16f52bfbe159947267658a0dbfbbe96fd5b988a95d1271f9c9ed61156da2

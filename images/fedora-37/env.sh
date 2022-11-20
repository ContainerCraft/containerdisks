VIRT_SYSPREP_OPERATIONS=user-account,logfiles,customize,bash-history,net-hostname,net-hwaddr,machine-id,dhcp-server-state,dhcp-client-state,yum-uuid,udev-persistent-net,tmp-files,smolt-uuid,rpm-db,package-manager-cache
_ARCH=$(echo ${ARCH} | sed 's/amd64/x86_64/;s/arm64/aarch64/')
BASE_URL=https://download.fedoraproject.org/pub/fedora/linux/releases/36/Cloud/"${_ARCH}"/images
DOWNLOAD_FILE=Fedora-Cloud-Base-36-1.5."${_ARCH}".qcow2
AMD64_SHA256SUM=b5b9bec91eee65489a5745f6ee620573b23337cbb1eb4501ce200b157a01f3a0
ARM64_SHA256SUM=cc8b0f49bc60875a16eef65ad13e0e86ba502ba3585cc51146f11f4182a628c0
SKIP="ssh"

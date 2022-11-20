VIRT_SYSPREP_OPERATIONS=user-account,logfiles,customize,bash-history,net-hostname,net-hwaddr,machine-id,dhcp-server-state,dhcp-client-state,yum-uuid,udev-persistent-net,tmp-files,smolt-uuid,rpm-db,package-manager-cache
_ARCH=$(echo ${ARCH} | sed 's/amd64/x86_64/;s/arm64/aarch64/')
BASE_URL=https://download.fedoraproject.org/pub/fedora/linux/releases/36/Cloud/"${_ARCH}"/images
DOWNLOAD_FILE=Fedora-Cloud-Base-36-1.5."${_ARCH}".qcow2
AMD64_SHA256SUM=ca9e514cc2f4a7a0188e7c68af60eb4e573d2e6850cc65b464697223f46b4605
ARM64_SHA256SUM=5c0e7e99b0c542cb2155cd3b52bbf51a42a65917e52d37df457d1e9759b37512
SKIP="ssh"

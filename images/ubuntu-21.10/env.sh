VIRT_SYSPREP_OPERATIONS=user-account,logfiles,customize,bash-history,net-hostname,net-hwaddr,machine-id,dhcp-server-state,dhcp-client-state,yum-uuid,udev-persistent-net,tmp-files,smolt-uuid,rpm-db,package-manager-cache
BASE_URL=https://cloud-images.ubuntu.com/impish/current
if [[ "${ARCH}" == "amd64" ]]; then
	DOWNLOAD_FILE=impish-server-cloudimg-amd64-disk-kvm.img
elif [[ "${ARCH}" == "arm64" ]]; then
	DOWNLOAD_FILE=impish-server-cloudimg-arm64.img
fi
AMD64_SHA256SUM=1cb99b83f5700bfcc7a53ad00874e42684cbbb1c469de5a3457281449151d033
ARM64_SHA256SUM=1b5b3fe616e1eea4176049d434a360344a7d471f799e151190f21b0a27f0b424

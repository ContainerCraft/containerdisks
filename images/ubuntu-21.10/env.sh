VIRT_SYSPREP_OPERATIONS=user-account,logfiles,customize,bash-history,net-hostname,net-hwaddr,machine-id,dhcp-server-state,dhcp-client-state,yum-uuid,udev-persistent-net,tmp-files,smolt-uuid,rpm-db,package-manager-cache
BASE_URL=https://cloud-images.ubuntu.com/impish/current
if [[ "${ARCH}" == "amd64" ]]; then
	DOWNLOAD_FILE=impish-server-cloudimg-amd64-disk-kvm.img
elif [[ "${ARCH}" == "arm64" ]]; then
	DOWNLOAD_FILE=impish-server-cloudimg-arm64.img
fi
AMD64_SHA256SUM=d36ea26eda3bd68bddc176a14b5b8537a746587d23792f80b52b78d735f6ea70
ARM64_SHA256SUM=f5ed430fdad41372bd2271ae53ce6fded7e21cc94f7139e1be425bc7e961df2d

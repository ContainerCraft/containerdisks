VIRT_SYSPREP_OPERATIONS=user-account,logfiles,customize,bash-history,net-hostname,net-hwaddr,machine-id,dhcp-server-state,dhcp-client-state,yum-uuid,udev-persistent-net,tmp-files,smolt-uuid,rpm-db,package-manager-cache
BASE_URL=https://cloud-images.ubuntu.com/impish/current
if [[ "${ARCH}" == "amd64" ]]; then
	DOWNLOAD_FILE=impish-server-cloudimg-amd64-disk-kvm.img
elif [[ "${ARCH}" == "arm64" ]]; then
	DOWNLOAD_FILE=impish-server-cloudimg-arm64.img
fi
AMD64_SHA256SUM=67e201f36aa9db4904a42fa7ab5bcfca601812e55259bd7381675ecc5bc5ddca
ARM64_SHA256SUM=1d6a7298ea902e638834a9486efe59f95770c3f5a1c29de045302f474182a65b

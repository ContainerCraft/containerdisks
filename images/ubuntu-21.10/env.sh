VIRT_SYSPREP_OPERATIONS=user-account,logfiles,customize,bash-history,net-hostname,net-hwaddr,machine-id,dhcp-server-state,dhcp-client-state,yum-uuid,udev-persistent-net,tmp-files,smolt-uuid,rpm-db,package-manager-cache
BASE_URL=https://cloud-images.ubuntu.com/impish/current
if [[ "${ARCH}" == "amd64" ]]; then
	DOWNLOAD_FILE=impish-server-cloudimg-amd64-disk-kvm.img
elif [[ "${ARCH}" == "arm64" ]]; then
	DOWNLOAD_FILE=impish-server-cloudimg-arm64.img
fi
AMD64_SHA256SUM=a355ad8576060349158dda31ad05ba656d1e6227350e1e4d1aa7461bb47454d7
ARM64_SHA256SUM=1c3b3308558d9d8e33273c862017eef533a6be444f3cea672bbe2e7c47bee4d7

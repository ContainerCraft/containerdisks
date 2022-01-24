VIRT_SYSPREP_OPERATIONS=user-account,logfiles,customize,bash-history,net-hostname,net-hwaddr,machine-id,dhcp-server-state,dhcp-client-state,yum-uuid,udev-persistent-net,tmp-files,smolt-uuid,rpm-db,package-manager-cache
BASE_URL=https://cloud-images.ubuntu.com/impish/current
if [[ "${ARCH}" == "amd64" ]]; then
	DOWNLOAD_FILE=impish-server-cloudimg-amd64-disk-kvm.img
elif [[ "${ARCH}" == "arm64" ]]; then
	DOWNLOAD_FILE=impish-server-cloudimg-arm64.img
fi
AMD64_SHA256SUM=432ec0aed11aa044b8626bc485e93bd2c53ab9a376c111627ff399138bc3769f
ARM64_SHA256SUM=78e62afbb6cbe3f2752e855bf0aee8bd5d49407f1bdbad445da0528717986c67

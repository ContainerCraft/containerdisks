VIRT_SYSPREP_OPERATIONS=net-hostname,net-hwaddr,machine-id,dhcp-server-state,dhcp-client-state,yum-uuid,udev-persistent-net,tmp-files,smolt-uuid,rpm-db,package-manager-cache
_ARCH=$(echo ${ARCH} | sed 's/amd64/x86_64/;s/arm64/aarch64/')
BASE_URL=https://repo.almalinux.org/almalinux/8/cloud/"${_ARCH}"/images/
DOWNLOAD_FILE=AlmaLinux-8-GenericCloud-latest."${_ARCH}".qcow2
AMD64_SHA256SUM=c0ad09255d91288dac590d99c95197d83a2846f1bcbec3f4222fb04265a2a4d7
ARM64_SHA256SUM=ea6058be50597b7a54904a47c0b4a83eb4bff040301376ac828a6ac0932399a0

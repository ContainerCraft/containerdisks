VIRT_SYSPREP_OPERATIONS=net-hostname,net-hwaddr,machine-id,dhcp-server-state,dhcp-client-state,yum-uuid,udev-persistent-net,tmp-files,smolt-uuid,rpm-db,package-manager-cache
_ARCH=$(echo ${ARCH} | sed 's/amd64/x86_64/;s/arm64/aarch64/')
BASE_URL=https://repo.almalinux.org/almalinux/8/cloud/"${_ARCH}"/images/
DOWNLOAD_FILE=AlmaLinux-8-GenericCloud-latest."${_ARCH}".qcow2
AMD64_SHA256SUM=e4b215dc807200db3a8934bdd785026c3776d3798e36f830897861074f29fc54
ARM64_SHA256SUM=f5bea7f4dbc6326a8d5e8d03165b9ef6eb8cc0c10d298715a8ce5cee01e8ec3e

#!/usr/bin/env bash
# Requires libguestfs-tools, jq, and curl

FLAVOR=${FLAVOR:-$1}
ARCH=${ARCH:-$2}

([[ -z ${FLAVOR} ]] || [[ -z ${ARCH} ]]) && {
	echo "Error: \$FLAVOR and \$ARCH must be passed in"
	exit 1
}

set -ex

# Disable libvirtd layer
# Required to support edge cases for some distributions
export LIBGUESTFS_BACKEND=direct

NAME=${FLAVOR%%-*}
VERSION=${FLAVOR#*-}

QCOW2_FILE=${FLAVOR}-${ARCH}.qcow2
QCOW2_TMPFILE=tmp.${FLAVOR}-${ARCH}.qcow2

BASE_URL=$(jq -r ."${NAME}".\""${VERSION}"\"."${ARCH}".url index.json)
SHA256SUM=$(jq -r ."${NAME}".\""${VERSION}"\"."${ARCH}".sha256sum index.json)
DOWNLOAD_FILE=$(jq -r ."${NAME}".\""${VERSION}"\"."${ARCH}".image index.json)
CUSTOMIZE=$(jq -r "."${NAME}".\""${VERSION}"\"."${ARCH}" | if has(\"customize\") then .customize else true end" index.json)

# Download qcow2
curl --verbose \
	--output "${DOWNLOAD_FILE}" \
	--location "${BASE_URL}"/"${DOWNLOAD_FILE}"

# Verify Checksum
echo "${SHA256SUM} ${DOWNLOAD_FILE}" |
	sha256sum --check --status ||
	echo "Invalid checksum: sha256sum check failed"

# Unarchive image
if [[ "${DOWNLOAD_FILE}" =~ \.gz$ ]]; then
	gzip -d "${DOWNLOAD_FILE}"
	mv "${DOWNLOAD_FILE/.gz/}" "${QCOW2_TMPFILE}"
else
	mv "${DOWNLOAD_FILE}" "${QCOW2_TMPFILE}"
fi


# Grow disk size
qemu-img resize "${QCOW2_TMPFILE}" +20G

if [[ "${CUSTOMIZE}" == "true" ]]; then
	# Source OS build variables
	source kmi/"${FLAVOR}"/env.sh

	# Customize Disk Image
	sudo virt-sysprep \
		--verbose \
		--network \
		--add "${QCOW2_TMPFILE}" \
		--commands-from-file kmi/"${FLAVOR}"/virt.sysprep \
		--enable "${VIRT_SYSPREP_OPERATIONS}"
fi

# Log disk image info
qemu-img info "${QCOW2_TMPFILE}"

# Sparsify
sudo virt-sparsify \
	--verbose \
	--compress \
	"${QCOW2_TMPFILE}" \
	"${QCOW2_FILE}"

sudo chown "${USER}":"${USER}" "${QCOW2_FILE}" && sudo rm "${QCOW2_TMPFILE}"

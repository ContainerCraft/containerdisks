_ARCH=$(echo ${ARCH} | sed 's/amd64/x86_64/;s/arm64/aarch64/')
_BUILD_VERSION="35.20220103.3.0"
BASE_URL=https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/"${_BUILD_VERSION}"/"${_ARCH}"
DOWNLOAD_FILE=fedora-coreos-"${_BUILD_VERSION}"-openstack."${_ARCH}".qcow2.xz
AMD64_SHA256SUM=3109807db69846049f7c4db85563fe596f2043493e3ded8cd7e9488afb94a9e5
ARM64_SHA256SUM=bf6b4d3ed75d25f4d2573ceb867410ab46dcaa67d02f8f0074e8e5be5de0685a
CUSTOMIZE=false
SKIP="qemu-guest-agent|ssh"

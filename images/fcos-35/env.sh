_ARCH=$(echo ${ARCH} | sed 's/amd64/x86_64/;s/arm64/aarch64/')
_BUILD_VERSION="35.20220131.3.0"
BASE_URL=https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/"${_BUILD_VERSION}"/"${_ARCH}"
DOWNLOAD_FILE=fedora-coreos-"${_BUILD_VERSION}"-qemu."${_ARCH}".qcow2.xz
AMD64_SHA256SUM=7342de6bbe9537e2e71415425706b1173704f5746aeeebfccff01435cccf0179
ARM64_SHA256SUM=02de579dc9d9a5f1c1a1870aba16600f53a304b759743d74168ff2520313a9ce
CUSTOMIZE=false
SKIP="qemu-guest-agent|ssh"

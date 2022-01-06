_ARCH=$(echo ${ARCH} | sed 's/amd64/x86_64/;s/arm64/aarch64/')
BASE_URL=https://mirror.openshift.com/pub/openshift-v4/"${_ARCH}"/dependencies/rhcos/latest/latest
DOWNLOAD_FILE=rhcos-openstack."${_ARCH}".qcow2.gz
AMD64_SHA256SUM=3466690807fb710102559ea57daac0484c59ed4d914996882d601b8bb7a7ada8
ARM64_SHA256SUM=bd8badcb85d3c50d126b46bd3a2501db9b61e5456eac33a1299bc851dea337ad
CUSTOMIZE=false

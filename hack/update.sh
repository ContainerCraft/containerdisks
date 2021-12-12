#!/usr/bin/env bash

set -ex

arch::latest() {
	local url=$(jq -r .arch.latest.amd64.url index.json)
	local response=$(curl -s "${url}" | grep cloudimg | awk -F\" '{print $2}')
	local image=$(echo ${response} | cut -d ' ' -f1)
	local sha256sum=$(curl -s "${url}${image}.SHA256" | awk -F ' ' '{print $1}')
	local data=$(
		cat <<-END
			{"amd64":{"image":"${image}","sha256sum":"${sha256sum}"}}
		END
	)

	cat <<< \
		$(jq --argjson data "${data}" '.arch.latest |= . * $data' index.json) \
		>index.json
}

ubuntu::18-04() {
	local url=$(jq -r .ubuntu.\"18.04\".amd64.url index.json)
	local response=$(curl -s "${url}"/SHA256SUMS)
	local amd64_sha256sum=$(echo "${response}" | grep bionic-server-cloudimg-amd64.img | awk -F ' ' '{print $1}')
	local arm64_sha256sum=$(echo "${response}" | grep bionic-server-cloudimg-arm64.img | awk -F ' ' '{print $1}')
	local data=$(
		cat <<-END
			{"amd64":{"sha256sum":"${amd64_sha256sum}"},"arm64":{"sha256sum":"${arm64_sha256sum}"}}
		END
	)

	cat <<< \
		$(jq --argjson data "${data}" '.ubuntu."18.04" |= . * $data' index.json) \
		>index.json
}

ubuntu::20-04() {
	local url=$(jq -r .ubuntu.\"20.04\".amd64.url index.json)
	local response=$(curl -s "${url}"/SHA256SUMS)
	local amd64_sha256sum=$(echo "${response}" | grep focal-server-cloudimg-amd64.img | awk -F ' ' '{print $1}')
	local arm64_sha256sum=$(echo "${response}" | grep focal-server-cloudimg-arm64.img | awk -F ' ' '{print $1}')
	local data=$(
		cat <<-END
			{"amd64":{"sha256sum":"${amd64_sha256sum}"},"arm64":{"sha256sum":"${arm64_sha256sum}"}}
		END
	)

	cat <<< \
		$(jq --argjson data "${data}" '.ubuntu."20.04" |= . * $data' index.json) \
		>index.json
}

ubuntu::21-10() {
	local url=$(jq -r .ubuntu.\"21.10\".amd64.url index.json)
	local response=$(curl -s "${url}"/SHA256SUMS)
	local amd64_sha256sum=$(echo "${response}" | grep impish-server-cloudimg-amd64.img | awk -F ' ' '{print $1}')
	local arm64_sha256sum=$(echo "${response}" | grep impish-server-cloudimg-arm64.img | awk -F ' ' '{print $1}')
	local data=$(
		cat <<-END
			{"amd64":{"sha256sum":"${amd64_sha256sum}"},"arm64":{"sha256sum":"${arm64_sha256sum}"}}
		END
	)

	cat <<< \
		$(jq --argjson data "${data}" '.ubuntu."21.10" |= . * $data' index.json) \
		>index.json
}

fedora::34() {
	local response=$(curl -s https://getfedora.org/releases.json)
	local amd64_sha256sum=$(echo "${response}" |
		jq -r \
			'.[] | select(.link|test(".*qcow2")) | select(.variant=="Cloud" and .arch=="x86_64" and .version=="34").sha256')
	local arm64_sha256sum=$(echo "${response}" |
		jq -r \
			'.[] | select(.link|test(".*qcow2")) | select(.variant=="Cloud" and .arch=="aarch64" and .version=="34").sha256')

	local data=$(
		cat <<-END
			{"amd64":{"sha256sum":"${amd64_sha256sum}"},"arm64":{"sha256sum":"${arm64_sha256sum}"}}
		END
	)

	cat <<< \
		$(jq --argjson data "${data}" '.fedora."34" |= . * $data' index.json) \
		>index.json
}

fedora::35() {
	local response=$(curl -s https://getfedora.org/releases.json)
	local amd64_sha256sum=$(echo "${response}" |
		jq -r \
			'.[] | select(.link|test(".*qcow2")) | select(.variant=="Cloud" and .arch=="x86_64" and .version=="35").sha256')
	local arm64_sha256sum=$(echo "${response}" |
		jq -r \
			'.[] | select(.link|test(".*qcow2")) | select(.variant=="Cloud" and .arch=="aarch64" and .version=="35").sha256')

	local data=$(
		cat <<-END
			{"amd64":{"sha256sum":"${amd64_sha256sum}"},"arm64":{"sha256sum":"${arm64_sha256sum}"}}
		END
	)

	cat <<< \
		$(jq --argjson data "${data}" '.fedora."34" |= . * $data' index.json) \
		>index.json
}

arch::latest
ubuntu::18-04
ubuntu::20-04
ubuntu::21-10
fedora::34
fedora::35

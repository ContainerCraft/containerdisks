#!/usr/bin/env bash
# Requires Kind & Docker

set -ex

FLAVOR=${FLAVOR:-$1}

[[ -z ${FLAVOR} ]] && {
	echo "\$FLAVOR must be passed in"
	exit 1
}

# TODO: validate flavor exists

export FLAVOR

KUBEVIRT_LATEST="v0.47.1"

# Install virtctl cli
virtctl version --client || {
	VIRTCTL_RELEASE=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases/latest | awk -F '["v,]' '/tag_name/{print $5}')
	sudo curl --output /usr/local/bin/virtctl \
		-L https://github.com/kubevirt/kubevirt/releases/download/v"${VIRTCTL_RELEASE}"/virtctl-v"${VIRTCTL_RELEASE}"-$(uname -s | awk '{print tolower($0)}')-amd64
	sudo chmod +x /usr/local/bin/virtctl
	virtctl version --client
}

# Check for || Create Kind Cluster
kind get clusters | grep kmi-test || kind create cluster --config .github/workflows/kind/config.yml
kubectl cluster-info

kubectl get storageclass standard
kubectl get nodes -oyaml | grep 'test:' && echo "detected node label 'kmi=test'"

# Check for || Create ssh keys & credentials secret
ls "$HOME"/.ssh/id_rsa || ssh-keygen -t rsa -N "" -f "$HOME"/.ssh/id_rsa
kubectl create secret generic kargo-sshpubkey-kc2user \
	--from-file=key1="$HOME"/.ssh/id_rsa.pub \
	--dry-run=client -oyaml |
	kubectl apply -f -

# Deploy Kubevirt
until kubectl create namespace kubevirt --dry-run=client -oyaml | kubectl apply -f -; do sleep 1; done
until kubectl apply -n kubevirt -f https://github.com/kubevirt/kubevirt/releases/download/"${KUBEVIRT_LATEST}"/kubevirt-operator.yaml; do sleep 1; done
until kubectl apply -n kubevirt -f https://github.com/kubevirt/kubevirt/releases/download/"${KUBEVIRT_LATEST}"/kubevirt-cr.yaml; do sleep 1; done
until kubectl create configmap kubevirt-config -n kubevirt --from-literal debug.useEmulation=true --dry-run=client -oyaml | kubectl apply -f -; do sleep 1; done

# Wait for kubevirt ready
set +e
until kubectl wait --for condition=ready pod -n kubevirt --timeout=100s -l kubevirt.io=virt-operator; do sleep 1; done
until kubectl wait --for condition=ready pod -n kubevirt --timeout=100s -l kubevirt.io=virt-api; do sleep 1; done
until kubectl wait --for condition=ready pod -n kubevirt --timeout=100s -l kubevirt.io=virt-controller; do sleep 1; done
until kubectl wait --for condition=ready pod -n kubevirt --timeout=100s -l kubevirt.io=virt-handler; do sleep 1; done

# Deploy Test VM
until bash .github/workflows/kind/testvm.sh; do sleep 1; done
# until virtctl console testvm 2>&1 | tee -a /tmp/console.log; do sleep 1; done
until kubectl wait --for=condition=ready pod -l test=kmi --timeout=240s; do sleep 1; done
set -e

guest_test_boot() {
	set +xe

	local ready=1
	local count=1
	echo ">>>"

	# Wait for vm to boot
	while [[ $ready != 0 ]] && [[ $count -lt 60 ]]; do
		echo ">>> Waiting for guest VM to boot ... Attempt #$count ..."
		virtctl guestosinfo testvm 2>&1
		ready=$(echo $?)
		((count += 1))
		sleep 7
	done

	if [[ $ready == 0 ]]; then
		echo ">>>"
		echo ">>> Kubevirt VM Booted Successfully! ... Continuing Test"
		echo ">>>"
	elif [[ $ready != 0 ]] || [[ $count -gt 60 ]]; then
		echo ">>>"
		echo ">>> Failed to detect guest boot"
		echo ">>>"
		exit 1
	else
		echo
	fi

	set -xe
}

guest_test_ssh() {
	set +xe

	local ready=1
	local count=1
	echo ">>>"

	# Wait for vm ssh ready
	while [[ $ready != 0 ]] && [[ $count -le 60 ]]; do
		echo ">>> Testing guest VM for SSH ... Attempt #$count ..."
		ready=$(
			ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no -p30950 kc2user@127.0.0.1 whoami 2>&1 1>/dev/null
			echo $?
		)
		((count += 1))
		sleep 5
	done

	if [[ $ready == 0 ]]; then
		echo ">>>"
		echo ">>> Kubevirt VM Passed SSH Validation! ... Continuing Test"
		echo ">>>"
	elif [[ $ready != 0 ]] || [[ $count -gt 60 ]]; then
		echo ">>>"
		echo ">>> Failed ssh to Guest VM"
		echo ">>>"
		exit 1
	fi

	set -xe
}

guest_test_boot
guest_test_ssh

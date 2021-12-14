#!/usr/bin/env bats

setup_file() {

	load common

	log "Setting up..."

	FLAVOR=${FLAVOR:-$1}
	[[ -z ${FLAVOR} ]] && {
		log "\$FLAVOR must be passed in"
		exit 1
	}

	export FLAVOR

	# Install virtctl cli
	virtctl version --client || {
		VIRTCTL_RELEASE=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases/latest | awk -F '["v,]' '/tag_name/{print $5}')
		sudo curl --output /usr/local/bin/virtctl \
			-L https://github.com/kubevirt/kubevirt/releases/download/v"${VIRTCTL_RELEASE}"/virtctl-v"${VIRTCTL_RELEASE}"-$(uname -s | awk '{print tolower($0)}')-amd64
		sudo chmod +x /usr/local/bin/virtctl
		virtctl version --client
	}

	# Only run these steps if not on github actions
	if [[ -z "${GITHUB_ACTIONS}" ]]; then
		kind delete cluster --name kmi-test || :
		log "Creating cluster..."
		kind create cluster --config .github/workflows/kind/config.yml
	fi

	kubectl cluster-info

	ls "$HOME"/.ssh/id_rsa || ssh-keygen -t rsa -N "" -f "$HOME"/.ssh/id_rsa
	kubectl create secret generic kargo-sshpubkey-kc2user \
		--from-file=key1="$HOME"/.ssh/id_rsa.pub --dry-run=client -oyaml | kubectl apply -f -

	# Deploy Kubevirt
	kubectl create namespace kubevirt --dry-run=client -oyaml | kubectl apply -f -

	KUBEVIRT_LATEST="v0.47.1"
	log "Installing KubeVirt ${KUBEVIRT_LATEST}"

	kubectl apply -n kubevirt \
		-f https://github.com/kubevirt/kubevirt/releases/download/"${KUBEVIRT_LATEST}"/kubevirt-operator.yaml

	kubectl apply -n kubevirt \
		-f https://github.com/kubevirt/kubevirt/releases/download/"${KUBEVIRT_LATEST}"/kubevirt-cr.yaml

	kubectl create configmap kubevirt-config -n kubevirt \
		--from-literal debug.useEmulation=true --dry-run=client -oyaml | kubectl apply -f -

	log "Waiting for KubeVirt to be ready"

	# TODO: We can get stuck in an infinite loop here very easily
	# Wait for kubevirt ready
	until kubectl wait --for condition=ready pod -n kubevirt --timeout=100s -l kubevirt.io=virt-operator; do sleep 1; done
	until kubectl wait --for condition=ready pod -n kubevirt --timeout=100s -l kubevirt.io=virt-api; do sleep 1; done
	until kubectl wait --for condition=ready pod -n kubevirt --timeout=100s -l kubevirt.io=virt-controller; do sleep 1; done
	until kubectl wait --for condition=ready pod -n kubevirt --timeout=100s -l kubevirt.io=virt-handler; do sleep 1; done

	log "Deploying test VM (${FLAVOR})"
	# Deploy Test VM
	kubectl delete vm testvm || echo
	bash ./kmi/${FLAVOR}/testvm.yaml.sh
	# until virtctl console testvm 2>&1 >> console.txt; do sleep 1; done
}

teardown_file() {
	log "Tearing down..."
	log "Gathering logs..."
	kubectl get events -A --sort-by=.metadata.creationTimestamp > events.txt
	kubectl describe vmi/testvm > pod.txt

	# TODO: gather cloud-init logs

	# TODO: add flag to disable teardown
	# if not running in GHA CI, teardown
	if [[ -z "${GITHUB_ACTIONS}" ]]; then
		log "Destroying cluster..."
		kind delete cluster --name kmi-test
	fi
}

setup() {
	SKIP=$(jq -r "."${FLAVOR%%-*}".\""${FLAVOR#*-}"\".skip // [] | join(\"|\")" index.json)
	if [[ ! -z ${SKIP} ]] && [[ "${BATS_TEST_NAME}" =~ ($SKIP) ]]; then
		skip "Test is disabled"
	fi
}

@test "VM pods become ready" {
	run tests/wait-for-ready.sh
	[ $status = 0 ]
}

@test "QEMU guest agent starts on boot" {
	run tests/qemu-guest-agent.sh
	[ $status = 0 ]
}

@test "guest ssh connects successfully" {
	run tests/guest-ssh.sh
	[ $status = 0 ]
}

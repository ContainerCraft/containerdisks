#!/usr/bin/env bats

setup_file() {

	load common
	log "Setting up..."

	if [[ -z ${FLAVOR} ]]; then
		log "\$FLAVOR must be passed in" && exit 1
	fi

	export FLAVOR

	# Install virtctl cli
	virtctl version --client || {
		VIRTCTL_RELEASE=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases/latest | awk -F '["v,]' '/tag_name/{print $5}')
		sudo curl --output /usr/local/bin/virtctl \
			-L https://github.com/kubevirt/kubevirt/releases/download/v"${VIRTCTL_RELEASE}"/virtctl-v"${VIRTCTL_RELEASE}"-"$(uname -s | awk '{print tolower($0)}')"-amd64
		sudo chmod +x /usr/local/bin/virtctl
		virtctl version --client
	}

	# Only run these steps if not on github actions
	if [[ -z "${GITHUB_ACTIONS}" ]]; then
		kind delete cluster --name kmi-test || :
		log "Creating cluster..."
		kind create cluster --config .github/workflows/kind/config.yml
	fi

	kubectl cluster-info || (log "Failed to get cluster info" && exit 1)

	ls "$HOME"/.ssh/id_rsa || ssh-keygen -t rsa -N "" -f "$HOME"/.ssh/id_rsa
	kubectl create secret generic kargo-sshpubkey-kc2user \
		--from-file=key1="$HOME"/.ssh/id_rsa.pub --dry-run=client -oyaml | kubectl apply -f -

	# Deploy Kubevirt
	kubectl create namespace kubevirt --dry-run=client -oyaml | kubectl apply -f -

	KUBEVIRT_VERSION="v0.50.0"
	log "Installing KubeVirt ${KUBEVIRT_VERSION}"

	kubectl apply -n kubevirt \
		-f https://github.com/kubevirt/kubevirt/releases/download/"${KUBEVIRT_VERSION}"/kubevirt-operator.yaml

	kubectl apply -n kubevirt \
		-f https://github.com/kubevirt/kubevirt/releases/download/"${KUBEVIRT_VERSION}"/kubevirt-cr.yaml

	kubectl patch -n kubevirt \
		kubevirt kubevirt --type=merge \
		--patch '{"spec":{"configuration":{"developerConfiguration":{"useEmulation":true}}}}'

	log "Waiting for KubeVirt to be ready"

	# TODO: We can get stuck in an infinite loop here very easily
	# Wait for kubevirt ready
	until kubectl wait --for condition=ready pod -n kubevirt --timeout=100s -l kubevirt.io=virt-operator; do sleep 1; done
	until kubectl wait --for condition=ready pod -n kubevirt --timeout=100s -l kubevirt.io=virt-api; do sleep 1; done
	until kubectl wait --for condition=ready pod -n kubevirt --timeout=100s -l kubevirt.io=virt-controller; do sleep 1; done
	until kubectl wait --for condition=ready pod -n kubevirt --timeout=100s -l kubevirt.io=virt-handler; do sleep 1; done

	log "Deploying test VM (${FLAVOR})"
	kubectl delete vm testvm || :
	bash images/"${FLAVOR}"/testvm.yaml.sh
	# until virtctl console testvm 2>&1 >> console.txt; do sleep 1; done
}

teardown_file() {
	log "Tearing down..."

	kubectl get events -A --sort-by=.metadata.creationTimestamp > events.txt
	kubectl describe vmi/testvm > pod.txt
	kubectl get kubevirt -n kubevirt kubevirt -o yaml > kubevirt.yaml
	kubectl get daemonsets -n kubevirt virt-handler -o yaml > virt-handler-ds.yaml
	kubectl get nodes -o yaml > nodes.yaml
	for pod in $(kubectl get pod -n kubevirt -o name | grep virt-operator); do
		kubectl logs "${pod}" -n kubevirt > "${pod/\//-}-logs.txt"
	done

	# TODO: gather cloud-init logs

	# TODO: add flag to disable teardown
	kubectl delete vm testvm || :

	# if not running in GHA CI, teardown
	if [[ -z "${GITHUB_ACTIONS}" ]]; then
		log "Destroying cluster..."
		kind delete cluster --name kmi-test
	fi
}

setup() {
	# skip all remaining tests if there is a failure
	[[ ! -f "${BATS_PARENT_TMPNAME}".skip ]] || skip "skipping remaining tests"

	load common
	log "Running test '${BATS_TEST_DESCRIPTION}'..."
	source images/"${FLAVOR}"/env.sh
	if [[ -n ${SKIP} ]] && [[ "${BATS_TEST_NAME}" =~ ($SKIP) ]]; then
		skip "Test is disabled"
	fi
}

teardown() {
	# force skip all remaining tests if a test fails
	[[ -n "${BATS_TEST_COMPLETED}" ]] || touch "${BATS_PARENT_TMPNAME}".skip
}

@test "vm pods become ready" {
	run retry 5 kubectl wait --for=condition=ready pod -l test=kmi --timeout=240s
	[ $status -eq 0 ]
}

@test "qemu-guest-agent starts on boot" {
	run retry 120 virtctl guestosinfo testvm 2>&1
	[ $status -eq 0 ]
}

@test "guest ssh connects successfully" {
	run retry 10 ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no -p30950 kc2user@127.0.0.1 whoami
	[ $status -eq 0 ]
}

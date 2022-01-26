#!/usr/bin/env bats

load common

setup_file() {
	log "Setting up..."

	if [[ -z "${FLAVOR}" ]]; then
		log "\$FLAVOR must be passed in" && exit 1
	fi

	export FLAVOR

	KUBEVIRT_VERSION="v0.50.0"
	KUBEVIRT_URL=https://github.com/kubevirt/kubevirt/releases/download/"${KUBEVIRT_VERSION}"
	# Install virtctl cli
	virtctl version --client || {
		sudo curl --output /usr/local/bin/virtctl -L "${KUBEVIRT_URL}"/virtctl-"${KUBEVIRT_VERSION}"-linux-amd64
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

	ls "${HOME}"/.ssh/id_rsa || ssh-keygen -t rsa -N "" -f "${HOME}"/.ssh/id_rsa
	kubectl create secret generic kargo-sshpubkey-kc2user \
		--from-file=key1="${HOME}"/.ssh/id_rsa.pub --dry-run=client -oyaml | kubectl apply -f -

	# Deploy Kubevirt
	kubectl create namespace kubevirt --dry-run=client -oyaml | kubectl apply -f -

	log "Installing KubeVirt ${KUBEVIRT_VERSION}"
	kubectl apply -n kubevirt -f "${KUBEVIRT_URL}"/kubevirt-operator.yaml
	kubectl apply -n kubevirt -f "${KUBEVIRT_URL}"/kubevirt-cr.yaml

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

	kubectl apply -f tests/ssh-service.yaml
	kubectl apply -f tests/vm-presets.yaml

	log "Deploying test VM (${FLAVOR})"
	kubectl delete vmi testvm || :

	if [[ -f "images/${FLAVOR}/testvmi.yaml" ]]; then
		kubectl apply -f images/"${FLAVOR}"/testvmi.yaml
	else
		IMAGE=${FLAVOR/-/:} envsubst < tests/vmi.yaml | kubectl apply -f -
	fi
}

teardown_file() {
	log "Tearing down..."

	kubectl get events -A --sort-by=.metadata.creationTimestamp > events.txt
	kubectl get kubevirt -n kubevirt kubevirt -o yaml > kubevirt.yaml
	kubectl get daemonsets -n kubevirt virt-handler -o yaml > virt-handler-ds.yaml
	kubectl get nodes -o yaml > nodes.yaml
	kubectl describe vmi/testvm > pod.txt
	for pod in $(kubectl get pod -n kubevirt -o name | grep virt-operator); do
		kubectl logs "${pod}" -n kubevirt > "${pod/\//-}-logs.txt"
	done

	# TODO: gather cloud-init logs

	# TODO: add flag to disable teardown
	kubectl delete vmi testvm || :

	# if not running in GHA CI, teardown
	if [[ -z "${GITHUB_ACTIONS}" ]]; then
		log "Destroying cluster..."
		kind delete cluster --name kmi-test
	fi
}

setup() {
	# skip all remaining tests if there is a failure
	[[ ! -f "${BATS_PARENT_TMPNAME}".skip ]] || skip "skipping remaining tests"

	log "Running test '${BATS_TEST_DESCRIPTION}'..."
	source images/"${FLAVOR}"/env.sh
	if [[ -n ${SKIP} ]] && [[ "${BATS_TEST_DESCRIPTION}" =~ ($SKIP) ]]; then
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

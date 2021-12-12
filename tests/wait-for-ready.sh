#!/usr/bin/env bash

DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"
source "${DIR}/common.bash"

retry=5
ready=1
count=1

# Wait for vm to boot
while [[ $ready -ne 0 ]] && [[ $count -lt $retry ]]; do
	log "Waiting for VM pods to become ready ... Attempt #$count ..."
	kubectl wait --for=condition=ready pod -l test=kmi --timeout=240s
	ready=$(echo $?)
	((count += 1))
	sleep 1
done

if [[ $ready -eq 0 ]]; then
	log "VM pods are ready!"
elif [[ $ready -ne 0 ]] || [[ $count -gt $retry ]]; then
	log "VM pods failed to become ready"
	exit 1
fi

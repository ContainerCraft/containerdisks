#!/usr/bin/env bash

DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"
source "${DIR}/common.bash"

retry=90
ready=1
count=1

# Wait for vm ssh ready
while [[ $ready -ne 0 ]] && [[ $count -le $retry ]]; do
	log "Testing guest VM for SSH ... Attempt #$count ..."
	ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no -p30950 kc2user@127.0.0.1 whoami
	ready=$(echo $?)
	((count += 1))
	sleep 5
done

if [[ $ready -eq 0 ]]; then
	log "Kubevirt VM Passed SSH Validation!"
elif [[ $ready -ne 0 ]] || [[ $count -gt $retry ]]; then
	log "Failed ssh to Guest VM"
	exit 1
fi

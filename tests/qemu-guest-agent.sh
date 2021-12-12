#!/usr/bin/env bash

DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"
source "${DIR}/common.bash"

retry=120
ready=1
count=1

# Wait for vm to boot
while [[ $ready -ne 0 ]] && [[ $count -lt $retry ]]; do
	log "Waiting to connect to guest agent ... Attempt #$count ..."
	virtctl guestosinfo testvm 2>&1
	ready=$(echo $?)
	((count += 1))
	sleep 7
done

if [[ $ready -eq 0 ]]; then
	log "Connected to guest agent successfully!"
elif [[ $ready -ne 0 ]] || [[ $count -gt $retry ]]; then
	log "Failed to detect guest boot"
	exit 1
fi

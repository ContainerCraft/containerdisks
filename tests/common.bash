log() {
	echo "$(date +'%T') $1" >&3
}

retry() {
	local until=$1; shift;
	local cmd="$*"
	local ready=1
	local count=1

	while [[ $ready -ne 0 ]] && [[ $count -lt $until ]]; do
		$cmd 2>&1
		ready=$(echo $?)
		((count += 1))
		sleep 5
	done

	if [[ $ready -eq 0 ]]; then
		log "Succeeded after $count attempts!"
	elif [[ $ready -ne 0 ]] || [[ $count -gt $until ]]; then
		log "Failed after $count attempts!"
		exit 1
	fi
}

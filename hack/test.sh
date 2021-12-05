#!/bin/bash -ex
# Requires Kind & Docker

export FLAVOR=ubuntu
export VERSION="18.04"
KUBEVIRT_LATEST=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases/latest | jq -r .tag_name)

# Install virtctl cli
install_virtctl () {
export VIRTCTL_RELEASE=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases/latest | awk -F '["v,]' '/tag_name/{print $5}')
sudo curl --output /usr/local/bin/virtctl -L https://github.com/kubevirt/kubevirt/releases/download/v${VIRTCTL_RELEASE}/virtctl-v${VIRTCTL_RELEASE}-$(uname -s | awk '{print tolower($0)}')-amd64
sudo chmod +x /usr/local/bin/virtctl
virtctl version --client
}
virtctl version --client || install_virtctl

# Check for || Create Kind Cluster
kind get clusters | grep kmi-test || kind create cluster --config .github/workflows/kind/config.yml
kubectl cluster-info

kubectl get storageclass standard
kubectl get nodes -oyaml | grep 'test:' && echo "detected node label 'kmi=test'"

# Check for || Create ssh keys & credentials secret
ls $HOME/.ssh/id_rsa || ssh-keygen -t rsa -N "" -f $HOME/.ssh/id_rsa
kubectl create secret generic kargo-sshpubkey-kc2user --from-file=key1=$HOME/.ssh/id_rsa.pub --dry-run=client -oyaml | kubectl apply -f -

# Deploy Kubevirt
until kubectl create namespace kubevirt --dry-run=client -oyaml | kubectl apply -f - ; do sleep 1 ; done
until kubectl apply -n kubevirt -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_LATEST}/kubevirt-operator.yaml ; do sleep 1 ; done
until kubectl apply -n kubevirt -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_LATEST}/kubevirt-cr.yaml ; do sleep 1 ; done
until kubectl create configmap kubevirt-config -n kubevirt --from-literal debug.useEmulation=true --dry-run=client -oyaml | kubectl apply -f - ; do sleep 1 ; done

# Wait for kubevirt ready
set +o errexit
until kubectl wait --for condition=ready pod -n kubevirt --timeout=100s -l kubevirt.io=virt-operator   ; do sleep 1 ; done
until kubectl wait --for condition=ready pod -n kubevirt --timeout=100s -l kubevirt.io=virt-api        ; do sleep 1 ; done
until kubectl wait --for condition=ready pod -n kubevirt --timeout=100s -l kubevirt.io=virt-controller ; do sleep 1 ; done
until kubectl wait --for condition=ready pod -n kubevirt --timeout=100s -l kubevirt.io=virt-handler    ; do sleep 1 ; done

# Deploy Test VM
until source .github/workflows/kind/testvm.sh ; do sleep 1 ; done
until kubectl wait --for=condition=ready pod -l test=kmi --timeout=240s ; do sleep 1 ; done
set -e

guest_test_boot () {
  export ready=1
  export count=1
  echo ">>>"

  # Wait for vm to boot
  while [[ $ready != 0 ]] \
    &&  [[ $count -le 60 ]] \
  ;do
    set +o errexit
    echo ">>> Waiting for guest VM to boot ... $ready"
    let "count=count+1"
    ready=$(virtctl guestosinfo testvm 2>&1 1>/dev/null ; echo $?)
    virtctl guestosinfo testvm 2>&1
    echo $count
    sleep 7
    set -e
  done

  if [[ $ready == 0 ]] ; then
    echo ">>>"
    echo ">>> Kubevirt VM Booted Successfully! ... Continuing Test"
    echo ">>>"
  elif [[ $ready != 0 ]] && [[ $count -gt 120 ]]; then
    echo ">>>"
    echo ">>> Failed to detect guest boot"
    echo ">>>"
    exit 1
  else
    echo
  fi
}

guest_test_ssh () {
  export ready=1
  export count=1
  echo ">>>"

  # Wait for vm ssh ready
  while [[ $ready != 0 ]] \
    &&  [[ $count -le 60 ]] \
  ;do
    set +o errexit
    echo ">>> Testing guest VM for SSH ... $ready"
    let "count=count+1"
    ready=$(ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no -p30950 kc2user@127.0.0.1 whoami 2>&1 1>/dev/null;echo $?)
    echo $count
    sleep 5
    set -e
  done

  if [[ $ready == 0 ]] ; then
    echo ">>>"
    echo ">>> Kubevirt VM Passed SSH Validation! ... Continuing Test"
    echo ">>>"
  elif [[ $ready != 0 ]] && [[ $count -gt 120 ]]; then
    echo ">>>"
    echo ">>> Failed ssh to Guest VM"
    echo ">>>"
    exit 1
  fi
}

guest_test_boot
# guest_test_ssh

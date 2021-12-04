#!/bin/bash -x
# Requires Kind & Docker

export FLAVOR=ubuntu
export VERSION="18.04"
KUBEVIRT_LATEST=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases/latest | jq -r .tag_name)

#kind create cluster --config .github/workflows/kind/config.yml || echo 0
kubectl cluster-info
kubectl get storageclass standard
kubectl get nodes -oyaml | grep 'test:' && echo "detected node label 'kmi=test'"
ls $HOME/.ssh/id_rsa || ssh-keygen -t rsa -N "" -f $HOME/.ssh/id_rsa
kubectl create secret generic kargo-sshpubkey-kc2user --from-file=key1=$HOME/.ssh/id_rsa.pub --dry-run=client -oyaml | kubectl apply -f -

kubectl create namespace kubevirt --dry-run=client -oyaml | kubectl apply -f -
kubectl apply -n kubevirt -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_LATEST}/kubevirt-operator.yaml \
  || sleep 3 && kubectl apply -n kubevirt -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_LATEST}/kubevirt-operator.yaml

kubectl apply -n kubevirt -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_LATEST}/kubevirt-cr.yaml
kubectl create configmap kubevirt-config -n kubevirt --from-literal debug.useEmulation=true --dry-run=client -oyaml | kubectl apply -f -
kubectl get pods -A

sleep 20
kubectl wait --for condition=ready pod -n kubevirt --timeout=100s -l kubevirt.io=virt-operator
kubectl wait --for condition=ready pod -n kubevirt --timeout=100s -l kubevirt.io=virt-api
kubectl wait --for condition=ready pod -n kubevirt --timeout=100s -l kubevirt.io=virt-controller
kubectl wait --for condition=ready pod -n kubevirt --timeout=100s -l kubevirt.io=virt-handler

# Deploy Test VM
source .github/workflows/kind/testvm.sh \
  || sleep 2 && source .github/workflows/kind/testvm.sh
kubectl wait --for=condition=ready pod -l test=kmi --timeout=240s

guest_test_boot () {
  export ready=1
  export count=1
  echo ">>>"

  # Wait for vm to boot
  while [[ $ready != 0 ]] \
    &&  [[ $count -le 60 ]] \
  ;do
    echo ">>> Waiting for guest VM to boot ... $ready"
    let "count=count+1"
    ready=$(virtctl guestosinfo testvm 2>&1 1>/dev/null ; echo $?)
    virtctl guestosinfo testvm 2>&1
    echo $count
    sleep 5
  done

  if [[ $ready == 0 ]] ; then
    echo ">>>"
    echo ">>> Kubevirt VM Booted Successfully! ... Continuing Test"
    echo ">>>"
  elif [[ $ready != 0 ]] && [[ $count -gt 60 ]]; then
    echo ">>>"
    echo ">>> Failed to detect guest boot"
    echo ">>>"
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
    echo ">>> Testing guest VM for SSH ... $ready"
    let "count=count+1"
    ready=$(ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no -p30950 kc2user@127.0.0.1 whoami 2>&1 1>/dev/null;echo $?)
    echo $count
    sleep 5
  done

  if [[ $ready == 0 ]] ; then
    echo ">>>"
    echo ">>> Kubevirt VM Passed SSH Validation! ... Continuing Test"
    echo ">>>"
  elif [[ $ready != 0 ]] && [[ $count -gt 60 ]]; then
    echo ">>>"
    echo ">>> Failed ssh to Guest VM"
    echo ">>>"
  fi
}

sleep 15
guest_test_boot
sleep 5
guest_test_ssh

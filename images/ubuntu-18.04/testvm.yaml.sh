cat <<EOF | kubectl apply -f -
---
apiVersion: kubevirt.io/v1alpha3
kind: VirtualMachine
metadata:
  name: testvm
  labels:
    test: kmi
spec:
  running: true
  template:
    metadata:
      labels:
        test: kmi
        kubevirt.io/flavor: default-features
    spec:
      nodeSelector:
        test: "kmi"
      domain:
        devices:
          disks:
            - name: containerdisk
              bootOrder: 1
              disk:
                bus: virtio
            - name: cloudinitdisk
              disk:
                bus: virtio
      hostname: testvm
      terminationGracePeriodSeconds: 0
      accessCredentials:
      - sshPublicKey:
          source:
            secret:
              secretName: kargo-sshpubkey-kc2user
          propagationMethod:
            qemuGuestAgent:
              users:
              - "kc2user"
      volumes:
        - name: containerdisk
          containerDisk:
            image: docker.io/containercraft/ubuntu:18.04-dev
            imagePullPolicy: Always
        - name: cloudinitdisk
          cloudInitNoCloud:
            networkData: |
              version: 2
              ethernets:
                enp1s0:
                  dhcp4: true
                  dhcp6: false
            userData: |
              #cloud-config
              ssh_pwauth: true
              disable_root: true
              chpasswd:
                list: |
                   kc2user:kc2user
                expire: False
              users:
                - name: kc2user
                  shell: /bin/bash
                  lock_passwd: false
                  sudo: ['ALL=(ALL) NOPASSWD:ALL']
                  groups: sudo,wheel
              growpart:
                mode: auto
                devices: ['/']
                ignore_growroot_disabled: true
              package_upgrade: false
              runcmd:
                - "setenforce 0"
EOF

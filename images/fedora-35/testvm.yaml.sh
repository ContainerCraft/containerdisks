cat <<EOF | kubectl apply -f -
---
apiVersion: kubevirt.io/v1
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
      volumes:
        - name: containerdisk
          containerDisk:
            image: docker.io/containercraft/fedora:35-dev
            imagePullPolicy: Always
        - name: cloudinitdisk
          cloudInitNoCloud:
            userData: |
              #cloud-config
              chpasswd:
                expire: False
                list: |
                   kc2user:kc2user
              users:
                - name: kc2user
                  shell: /bin/bash
                  lock_passwd: false
                  groups: sudo,wheel
                  sudo: ['ALL=(ALL) NOPASSWD:ALL']
                  ssh-authorized-keys:
                    - $(cat ~/.ssh/id_rsa.pub)
              runcmd:
                - "setenforce 0"
EOF

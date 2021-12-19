cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: ssh
spec:
  ports:
  - nodePort: 30950
    port: 30950
    protocol: TCP
    targetPort: 22
  selector:
    test: kmi
  type: NodePort
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
    spec:
      nodeSelector:
        test: "kmi"
      domain:
        devices:
          autoattachPodInterface: true
          autoattachSerialConsole: true
          autoattachGraphicsDevice: true
          networkInterfaceMultiqueue: false
          disks:
            - name: containerdisk
              bootOrder: 1
              disk:
                bus: virtio
            - name: cloudinitdisk
              disk:
                bus: virtio
        cpu:
          cores: 1
          threads: 1
          sockets: 1
          model: host-model
        resources:
          limits:
            memory: 4G
          requests:
            memory: 4G
      hostname: testvm
      terminationGracePeriodSeconds: 0
      volumes:
        - name: containerdisk
          containerDisk:
            image: docker.io/containercraft/${FLAVOR/-/:}-dev
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
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
        resources:
          limits:
            memory: 4G
          requests:
            memory: 4G
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
            image: docker.io/containercraft/${FLAVOR/-/:}-dev
            imagePullPolicy: Always
        - name: cloudinitdisk
          cloudInitNoCloud:
            networkData: |
              version: 2
              ethernets:
                eth0:
                  match:
                    mac_address: "$(sudo cat /sys/class/net/$(ip route show default | awk '/default/ {print $5}' | uniq)/address)"
                    dhcp4: true
            userData: |
              #cloud-config
              chpasswd:
                list: |
                   kc2user:kc2user
              users:
                - default
                - name: kc2user
                  ssh-authorized-keys:
                    - $(cat ~/.ssh/id_rsa.pub)
EOF

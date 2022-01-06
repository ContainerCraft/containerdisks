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
            memory: 3G
          requests:
            memory: 3G
      hostname: testvm
      terminationGracePeriodSeconds: 0
      volumes:
        - name: containerdisk
          containerDisk:
            image: docker.io/containercraft/${FLAVOR/-/:}-dev
            imagePullPolicy: Always
        - name: cloudinitdisk
          cloudInitConfigDrive:
            userData: |-
              {
                "ignition": {
                  "version": "3.3.0"
                },
                "passwd": {
                  "users": [
                    {
                      "groups": [
                        "adm",
                        "sudo",
                        "wheel",
                        "docker",
                        "systemd-journal"
                      ],
                      "name": "kc2user",
                      "passwordHash": "$y$j9T$g4gmvVc2wOkbIgwHmmwB9.$Vb/kJJ6P/6Fr9/r.c0l7XhFvElEyMkUtQnFKG/8icE6",
                      "sshAuthorizedKeys": [
                        "$(cat ~/.ssh/id_rsa.pub)"
                      ]
                    }
                  ]
                },
                "storage": {
                  "files": [
                    {
                      "path": "/etc/ssh/sshd_config.d/20-enable-passwords.conf",
                      "contents": {
                        "source": "data:,PasswordAuthentication%20yes%0A"
                      },
                      "mode": 420
                    }
                  ]
                }
              }
EOF
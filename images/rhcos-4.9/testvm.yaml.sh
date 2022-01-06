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
                  "version": "3.2.0"
                },
                "passwd": {
                  "users": [
                    {
                      "groups": [
                        "adm",
                        "sudo",
                        "wheel",
                        "systemd-journal"
                      ],
                      "name": "kc2user",
                      "passwordHash": "$6$PNObhlqtbaVu81X9$NDUNjKfoCYIsq.fUvoDMYr62ijGUWiNgUpY.2zCl72JCxbg1plohB2pVHH1H7NUcj24S9xjLBUVt4/rbAkagq/",
                      "sshAuthorizedKeys": [
                        "$(cat ~/.ssh/id_rsa.pub)"
                      ]
                    }
                  ]
                }
              }
EOF
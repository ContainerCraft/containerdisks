# https://docs.docker.com/engine/reference/commandline/buildx_bake
# docker buildx create --driver docker-container --name builder --use
# FLAG=$(git rev-parse --short HEAD) docker buildx bake -f bake.hcl --builder builder --progress tty --load

variable "FLAG" {
  default = "dev"
}

group "default" {
  targets = ["ubuntu", "arch"]
}

group "ubuntu" {
  targets = ["ubuntu-18.04", "ubuntu-20.04", "ubuntu-21.10"]
}

target "ubuntu-defaults" {
  dockerfile = "Containerfile"
  platforms = ["linux/arm64", "linux/amd64"]
  args = {
    FLAVOR = "ubuntu"
    PKG_LIST = "screenfetch,python3,tmux,git,vim,net-tools,cloud-init,cloud-initramfs-growroot,qemu-guest-agent"
    OPERATIONS = "user-account,logfiles,customize,bash-history,net-hostname,net-hwaddr,machine-id,dhcp-server-state,dhcp-client-state,yum-uuid,udev-persistent-net,tmp-files,smolt-uuid,rpm-db,package-manager-cache"
  }
}

target "ubuntu-18.04" {
  inherits = ["ubuntu-defaults"]
  tags = [
    "docker.io/containercraft/ubuntu:18.04-${FLAG}",
    "docker.io/containercraft/ubuntu:bionic-${FLAG}"
  ]
  args = {
    VERSION = "18.04"
  }
}

target "ubuntu-20.04" {
  inherits = ["ubuntu-defaults"]
  tags = [
    "docker.io/containercraft/ubuntu:20.04-${FLAG}",
    "docker.io/containercraft/ubuntu:focal-${FLAG}"
  ]
  args = {
    VERSION = "20.04"
  }
}

target "ubuntu-21.10" {
  inherits = ["ubuntu-defaults"]
  tags = [
    "docker.io/containercraft/ubuntu:21.10-${FLAG}",
    "docker.io/containercraft/ubuntu:impish-${FLAG}"
  ]
  args = {
    VERSION = "21.10"
  }
}

target "arch" {
  dockerfile = "Containerfile"
  platforms = ["linux/amd64"]
  tags = [
    "docker.io/containercraft/arch:latest-${FLAG}"
  ]
  args = {
    FLAVOR = "arch"
    PKG_LIST = "screenfetch,python3,tmux,git,vim,net-tools,qemu-guest-agent,libguestfs"
    OPERATIONS = "logfiles,customize,bash-history,net-hostname,net-hwaddr,machine-id,dhcp-server-state,dhcp-client-state,tmp-files,smolt-uuid,package-manager-cache"
    VERSION = "latest"
  }
}

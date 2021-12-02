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
  targets = ["ubuntu-18.04"]
}

group "fedora" {
  targets = ["fedora-35"]
}

target "ubuntu-18.04" {
  dockerfile = "Containerfile"
  platforms = ["linux/arm64", "linux/amd64"]
  tags = [
    "docker.io/containercraft/ubuntu:18.04-${FLAG}",
    "docker.io/containercraft/ubuntu:bionic-${FLAG}"
  ]
  args = {
    FLAVOR = "ubuntu"
    VERSION = "18.04"
  }
}

target "fedora-35" {
  dockerfile = "Containerfile"
  platforms = ["linux/arm64", "linux/amd64"]
  tags = [
    "docker.io/containercraft/fedora:35-${FLAG}"
  ]
  args = {
    FLAVOR = "fedora"
    VERSION = "35"
  }
}

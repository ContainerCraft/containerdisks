# https://docs.docker.com/engine/reference/commandline/buildx_bake
# docker buildx create --driver docker-container --name builder --use
# FLAG=$(git rev-parse --short HEAD) docker buildx bake -f bake.hcl --builder builder --progress tty --load

variable "FLAG" {
  default = "dev"
}

variable "REPO" {
  default = ""
}

group "default" {
  targets = [
    "ubuntu",
    "fedora",
    "arch",
    "debian",
    "opensuse",
    "centos",
  ]
}

target "defaults" {
  dockerfile = "Containerfile"
  platforms = ["linux/arm64", "linux/amd64"]
  labels = {
    license = "GPLv3"
    distribution-scope = "public"
    description = "ContainerCraft.io Maintained Public Reference KMI",
    "io.k8s.description" = "ContainerCraft.io Maintained Public Reference KMI"
    "org.opencontainers.image.source" = "https://github.com/ContainerCraft/kmi/"
  }
}

group "ubuntu" {
  targets = ["ubuntu-18.04", "ubuntu-20.04", "ubuntu-21.10"]
}

group "fedora" {
  targets = ["fedora-34", "fedora-35"]
}

group "debian" {
  targets = ["debian-10", "debian-11"]
}

group "opensuse" {
  targets = ["opensuse-leap-15", "opensuse-tumbleweed"]
}

group "centos" {
  targets = ["centos-8", "centos-9"]
}

function "tag" {
  params = [image, tag]
  result = equal("", REPO) ? "docker.io/containercraft/${image}:${tag}-${FLAG}" : "${REPO}/${image}:${tag}-${FLAG}"
}

target "ubuntu-18.04" {
  inherits = ["defaults"]
  tags = [
    tag("ubuntu", "18.04"),
    # tag("ubuntu", "bionic"),
  ]
  args = {
    FLAVOR = "ubuntu-18.04"
  }
}

target "ubuntu-20.04" {
  inherits = ["defaults"]
  tags = [
    tag("ubuntu", "20.04"),
    # tag("ubuntu", "focal"),
  ]
  args = {
    FLAVOR = "ubuntu-20.04"
  }
}

target "ubuntu-21.10" {
  inherits = ["defaults"]
  tags = [
    tag("ubuntu", "21.10"),
    # tag("ubuntu", "impish"),
  ]
  args = {
    FLAVOR = "ubuntu-21.10"
  }
}

target "fedora-34" {
  inherits = ["defaults"]
  tags = [
    tag("fedora", "34")
  ]
  args = {
    FLAVOR = "fedora-34"
  }
}

target "fedora-35" {
  inherits = ["defaults"]
  tags = [
    tag("fedora", "35")
  ]
  args = {
    FLAVOR = "fedora-35"
  }
}

target "arch-latest" {
  inherits = ["defaults"]
  tags = [
    tag("arch", "latest")
  ]
  args = {
    FLAVOR = "arch-latest"
  }
}

target "debian-10" {
  inherits = ["defaults"]
  tags = [
    tag("debian", "10")
  ]
  args = {
    FLAVOR = "debian-10"
  }
}

target "debian-11" {
  inherits = ["defaults"]
  tags = [
    tag("debian", "11")
  ]
  args = {
    FLAVOR = "debian-11"
  }
}

target "opensuse-leap-15" {
  inherits = ["defaults"]
  platforms = ["linux/amd64"]
  tags = [
    tag("opensuse", "leap-15")
  ]
  args = {
    FLAVOR = "opensuse-leap-15"
  }
}

target "opensuse-tumbleweed" {
  inherits = ["defaults"]
  platforms = ["linux/amd64"]
  tags = [
    tag("opensuse", "tumbleweed")
  ]
  args = {
    FLAVOR = "opensuse-tumbleweed"
  }
}

target "centos-8" {
  inherits = ["defaults"]
  tags = [
    tag("centos", "8")
  ]
  args = {
    FLAVOR = "centos-8"
  }
}

target "centos-9" {
  inherits = ["defaults"]
  tags = [
    tag("centos", "9")
  ]
  args = {
    FLAVOR = "centos-9"
  }
}

target "rhcos-4.9" {
  inherits = ["defaults"]
  tags = [
    tag("rhcos", "4.9")
  ]
  args = {
    FLAVOR = "rhcos-4.9"
  }
}

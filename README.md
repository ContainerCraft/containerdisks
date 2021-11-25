# Kubevirt Machine Images
This repo facilitates kubevirt machine image build and publishing pipelines.
    
Pipelines are run weekly at minimum to package each distribution and version
with the latest updates. Images can be used via tag by digest in your VirtualMachine definitions.
This is recommended for production use.
### Image Criteria:
####    Planned
Planned images represent distributions we hope to, or are actively working to publish and support.
Community contributions are always welcome. Always feel free to start here if you want to add a new
image to the kmi library!
####    Preview
Preview images are published without any functionality testing. These images are either under active
development, or published for community testing to gauge overall interest for maintenance priority.
####    Proposed
Proposed images are expected to be reasonably stable. These images are candidates for stable status
and will be upgraded to stable after consistent and sustained reliability is observed and any major
planned enhancements are finalized.
####    Stable
Stable images have have achieved consistentcy and reliability under scrutiny for a sustained timeframe.
These images have also automated maintenance for all required compliance including:
  - Metadata
    - Source of image
    - Repository commit digest included
    - Date image was pulled from upstream
    - Validate shasum hashes during build
    - URL to upstream distribution documentation
    - URL to upstream distribution download source
    - Original ULA & Distribution license included
    - [Cosign signature](https://github.com/sigstore/cosign)
  - entrypoint.sh will print any or all required metadata on command
  - Image will be within public registry size limits
  - Image will be qcow2 format and sparsify optimized
  - Where applicable, default packages will include:
    - git
    - vim
    - tmux
    - net-tools
    - screenfetch
    - qemu-guest-agent
  - Additional packages and sources will be subject to scrutiny before graduation as a proposed stable candidate
  - On boot, qemu-guest-agent will provision ssh keys for accessing the guest from kubernets secret
  - Image is published in the approved from scratch ubi micro container
  - Image will boot on kubevirt using standardized kmi baseline test definitions
  - SELinux / Apparmor / Firewall is in state of compliance with published distro best practices
  - cloud-init will configure guest and users via supported cloud-config syntax*
  - Basic storage, networking, and OS functionality behaves as expected
  - Ready for PR to kubevirt/containerdisks upstream catalog**    
    
*cloud-init requirement may be waived on case by case basis    
**upstream requirement may be waived on case by case basis
    
------
> Distribution Release Chart
    
| Flavor           | Stable | Proposed | Preview | Planned  | | x86_64 | arm64 |
|:-----------------|:------:|:--------:|:-------:|:--------:|-|:------:|:-----:|
| [AlmaLinux OS]   |        |          |    x    |          | |    X   |   X   |
| [Alpine Linux]   |        |          |    x    |          | |    X   |   X   |
| [Amazon Linux]   |        |          |    x    |          | |    X   |       |
| [Arch Linux]     |        |          |    x    |          | |    X   |   X   |
| [CentOS]         |        |          |    X    |          | |    X   |   X   |
| [Fedora]         |        |          |    X    |          | |    X   |   X   |
| [Fedora CoreOS]  |        |          |    X    |          | |    X   |       |
| [Neutrino]       |        |          |         |    X     | |    X   |       |
| [NixOS]          |        |          |         |    X     | |    X   |       |
| [OpenBSD]        |        |          |         |    X     | |    X   |       |
| [OpenWRT]        |        |          |         |    X     | |    X   |   X   |
| [OPNsense]       |        |          |         |    X     | |    X   |       |
| [openSUSE]       |        |          |         |    X     | |    X   |       |
| [PFSense]        |        |          |         |    X     | |    X   |       |
| [Red Hat CoreOS] |        |          |         |    X     | |    X   |       |
| [Rocky Linux]    |        |          |         |    X     | |    X   |       |
| [Ubuntu]         |        |          |    X    |          | |    X   |   X   |
| [VyOS]           |        |          |    X    |          | |    X   |       |
    
[AlmaLinux OS]:https://almalinux.org
[Alpine Linux]:https://www.alpinelinux.org
[Amazon Linux]:https://aws.amazon.com/amazon-linux-2
[Arch Linux]:https://archlinux.org
[CentOS]:https://www.centos.org
[Fedora]:https://getfedora.org
[Fedora CoreOS]:https://docs.fedoraproject.org/en-US/fedora-coreos
[Neutrino]:https://github.com/ContainerCraft/neutrino
[NixOS]:https://nixos.org
[OpenBSD]:https://www.openbsd.org
[openSUSE]:http://www.opensuse.org
[OpenWRT]:https://openwrt.org
[OPNsense]:https://opnsense.org
[PFSense]:https://www.pfsense.org
[Red Hat CoreOS]:https://cloud.redhat.com/learn/coreos
[Rocky Linux]:https://rockylinux.org
[Ubuntu]:https://ubuntu.com
[VyOS]:https://vyos.io
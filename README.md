# Vagrant config for SAP NW752 SP01 dev edition

## How to install

- install **virtual box**
- install **vagrant**
- vagrant may require Powershell 3 on Win7. If this is an issue check [this](https://docs.microsoft.com/en-us/skypeforbusiness/set-up-your-computer-for-windows-powershell/download-and-install-windows-powershell-3-0).
- download this repository (as zip or `git clone`)
- put uncompressed distribution files into `distrib` subfolder of the cloned dir
- open shell in cloned directory (where `Vagrantfile` is)
- run `vagrant up`
- wait for installation to finish ... (took ~1-1.5 hours on my laptop)

## How to use

- whenever you want to start NW
    - cd to the Vagrantfile directory
    - start vm with `vagrant up`
    - run `vagrant ssh -c startsap.sh`
- to stop instance
    - cd to the Vagrantfile directory
    - run `vagrant ssh -c stopsap.sh`
    - run `vagrant halt`
- to go inside linux
    - cd to the Vagrantfile directory
    - run `vagrant ssh`
- completely remove virtual machine destroying all data
    - cd to the Vagrantfile directory
    - in the Vagrantfile directory ... or after `vagrant global-config`
    - run `vagrant destroy`

Additional comments:

- you may start vm from any directory but then you need to address it by id or name. Run `vagrant global-config` to check the name. It should be `sapnw`. So the command to vm would look like `vagrant up sapnw` or `vagrant ssh sapnw -c startsap.sh`
- `startsap.sh` and `stopsap.sh` are shortcuts that are placed to `~/.local/bin` during installation. They contain command like `sudo -i -u npladm startsap`. Can be used for other short scripts.

## Infos

### What is vagrant

A tool to setup virtual environments conveniently. No need to go through boring installation process which is a plus. Basic virtual machine is created within seconds (for popular flavors that exist in vagrant cloud repository).

### Why not docker?

1) Ideologically docker is supposed to be stateless. Databases should be in volumes, not inside docker layer.
2) Besides, docker storage layer is slower than volumes

Well, probably this can be solved. /sybase directory can be mounted to volume. Also logs and transports should be considered. Well, I don't have enough basis skills for this :) Maybe someday.

### Why Ubuntu

1) Ubuntu is very popular linux flavor. The community is huge and there are a lot of materials on how to solve this or that issue
2) Bare ubuntu server is just ~1 GB in size
3) and yes, I know debian-like system beter than other flavors ;) might be the main reason.

### Memory

Currently machine is setup to consume 6GB. Though in my experiance 4GB is usually enough (ungrounded opinion). One option to decrease memory usage is to activate swap. To do this:
- uncomment `vb.memory = "4096"` in `Vagrantfile` (and comment the one with 6GB)
- uncomment `config.vm.provision "shell", path: "scripts/add_swap.sh"` - this will activate swap during installation. Or just run it after install via ssh `/vagrant/scripts/add_swap.sh`

### Regards and references

- got some script ideas (expect) from https://github.com/tobiashofmann/sap-nw-abap-docker
- concept on how to create additional VB drives in VM folder from https://gist.github.com/leifg/4713995
- cool guide on swap file in ubuntu: https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-16-04

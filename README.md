# Vagrant config for SAP NW752 SP01 dev edition

**DRAFT, USE WITH CAUTION**

TODO:
- check hosts for strange records after install - prevents normal DB startup
- autoinstall license ???
- finalize docs

## How to install

- install **virtual box**
- install **vagrant**
- download this repository (as zip or `git clone`)
- put uncompressed distribution files into `distrib` subfolder of the cloned dir
- open shell in cloned directory (where `Vagrantfile` is)
- run `vagrant up`
- wait for installation to finish ...

## How to use

- whenever you want to start NW
    - in the Vagrantfile directory ... or after `vagrant global-config`
    - start vm with `vagrant up`
    - run `vagrant ssh sapnw -c 'sudo -i -u npladm startsap'`
- to stop instance
    - in the Vagrantfile directory ... or after `vagrant global-config`
    - run `vagrant ssh sapnw -c 'sudo -i -u npladm stopsap'`
    - run `vagrant halt sapnw`
- to go inside linux
    - in the Vagrantfile directory ... or after `vagrant global-config`
    - run `vagrant ssh sapnw`
- completely remove virtual machine destroying all data
    - in the Vagrantfile directory ... or after `vagrant global-config`
    - run `vagrant destroy sapnw`

## Infos

### What is vagrant

Tool to setup virtual environment conveniently. No need to go through boring installation process which is a plus. Basic virtual machine is created within seconds (for popular flavors that exist in vagrant cloud repository).

### Why not docker?

1) Ideologically docker is supposed to be stateless. Databases should be in volumes, not inside docker layer.
2) besides, docker storage layer is slower than volumes

Well, probably this can be solved. /sybase directory can be mounted to volume. Also logs and transports should be considered. Probably licenses also ? Well, I don't have enough basis skill for this :) Maybe someday.

### Why Ubuntu

1) Ubuntu is very popular linux flavor. The community is huge and there are a lot of materials on how to solve this or that issue
2) bare ubuntu server is just ~1 GB in size
3) and yes, I know debian-like system beter than other flavors ;) might be the main reason.

### Memory

Currently machine is setup to consume 6GB. Though in my experiance 4 is usually enough (ungrounded opinion). One option to decrease memory usage is to activate swap. To do this:
- uncomment `vb.memory = "4096"` in `Vagrantfile` (and comment the one with 6GB)
- uncomment `config.vm.provision "shell", path: "scripts/add_swap.sh"`

### Regards

- got some script ideas (expect) from https://github.com/tobiashofmann/sap-nw-abap-docker
- concept on how to create additional VB drives in VM folder from https://gist.github.com/leifg/4713995
- coll guide on swap file in ubuntu: https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-16-04

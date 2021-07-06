![Version](https://img.shields.io/github/v/tag/sbcgua/sap-nw-abap-vagrant.svg)

# Vagrant config for SAP NW752 SP01/SP04 dev edition

## [PINNED] 2020-03 SYBASE LICENCE update

The sybase DB license included in the original distrib expired on March 2021. The new license can be obtained as described here: https://blogs.sap.com/2018/08/30/as-abap-7.5x-ase-license-available/

In order to include this file into a new installation:
1. Place the `SYBASE_ASE_TestDrive.lic` file into distrib folder, near `install.sh` script.
2. Edit `Vagrantfile`, uncomment `config.vm.provision "shell", path: "scripts/provision/patch_install_script.sh"` line near the end of the file.
3. This will adjust the `install.sh` script so that it find and copies the new licence after uncompressing the files and before start of the SAP installation.

## What is it ?

This repo contains a Vagrant script and set of deployment scripts which installs SAP NW752 SP01 dev edition in Ubuntu in Virtual Box environment with **minimal** manual steps required. The target is that you copy the script, download distribs, run Vagrant which will do allmost of steps from the offical guide and some more, and then you have ready system which just needs the post install license steps. In addition to the official installation guide the script does:

- configures NW to autostart on virtual machine startup
- can *optionally* install github and gitlab SSL certificates to use with abapGit
- can *optionally* install latest abapGit

For a quick start [watch this video](https://www.youtube.com/watch?v=-BeEF1U-cqQ)

Confirmed to work with NW752 SP01 and **the newer SP04**.

## How to install

- install **virtual box**
- install **vagrant**. Note: vagrant may require Powershell 3 on Window 7. If this is an issue check [this](https://docs.microsoft.com/en-us/skypeforbusiness/set-up-your-computer-for-windows-powershell/download-and-install-windows-powershell-3-0).
- download this repository (as zip or `git clone`)
- put uncompressed distribution files into `distrib` subfolder of the cloned dir
- open shell in cloned directory (where `Vagrantfile` is)
- run `vagrant up`
- wait for installation to finish ... (took ~1-1.5 hours on my laptop)
- you can connect to the system and follow the post-install steps from the official guide (in particular SAP licence installation). The system will be at **127.0.0.1, 00, NPL**
- *optionally*, run `vagrant ssh -c "sudo /vagrant/scripts/install_addons.sh"` to install SSL certificates mentioned above and latest [abapGit](https://github.com/larshp/abapGit). This can only be done **AFTER** licence installation.

## How to use

Starting from v1.1 of this repo the scripts install sapnw as a `systemd` service and enables it by default. So the netveawer should automatically start on boot (note that it will take a minute or two after the machine is up) and you should be able to connect. On the system halt the service will attempt to gracefully stop NW (with 5 min timeout). If you want to disable the service for whatever reason run `vagrant ssh -c "sudo systemctl disable sapnw"`, then start/stop sap manually (see below).

### Start/stop virtual machine

- all the below assumes you started the console in the `Vagrantfile` directory
- whenever you want to start NW
    - start vm with `vagrant up`
- to stop instance
    - run `vagrant halt`
- to go inside linux
    - run `vagrant ssh`
- completely remove virtual machine destroying all data
    - run `vagrant destroy`

Alternatively you can run VM directly from virtual box, Vagrant did it's job by now and now it is just a convenient option.

### Useful commands for `systemd` service control

- the following commands can be issued either with `vagrant ssh -c "<command>"` or when logged in the system with `vagrant ssh`
- check service status
    - `sudo systemctl status sapnw`
- starting/stopping
    - `sudo systemctl start sapnw` - manually start the service
    - `sudo systemctl stop sapnw` - manually stop the service
    - `sudo systemctl enable sapnw` - enable service autostart
    - `sudo systemctl disable sapnw` - disable service autostart
    - `sudo systemctl daemon-reload` - reload service script in case you changed it manually (`/etc/systemd/system/sapnw.service`)
- see the journal (start/stop output)
    - `sudo journalctl -u sapnw -b`
    - `sudo journalctl -u sapnw -f` - output last message and follow new ones (useful after manual `sudo systemctl start sapnw`)
    - `sudo cat /var/log/syslog | grep sapnw` - same but from system log (may have more info)
    - `sudo cat /var/log/syslog | grep SAPNPL` - to see sap instance messages
- useful links about systemd services [digitalocean systemd guide](https://www.digitalocean.com/community/tutorials/how-to-use-systemctl-to-manage-systemd-services-and-units), [systemd wiki](https://wiki.archlinux.org/index.php/Systemd), [freedesktop systemd docs](https://www.freedesktop.org/software/systemd/man/systemd.service.html)


### Manual mode (if the service is disabled)

- assuming you started the console in the `Vagrantfile` directory and started the vm ...
- `vagrant ssh -c startsap.sh` - start sap system
- `vagrant ssh -c stopsap.sh` - stop sap system

### Changing VM Name

~~specify `--vm-name` parameter to set virtual machine name...~~ - this was deprecated in v1.3.1. Unfortunately, parsing command line args in Vagrant file conflicts with it's native args (see more in [this issue](https://github.com/sbcgua/sap-nw-abap-vagrant/issues/6)). Instead a new approach was implemented via environment variables (see below).

The default name for VM is defined at the beginning of the Vagrant file in `argMachineName` variable. It is used in the code after to define the virtual machine name. You can override it by setting `VAGRANT_SAPNW_VM_NAME` environment variable for the session (or, optionally, redefine it directly in the file).

The way depends on your shell:
- cmd - `set VAGRANT_SAPNW_VM_NAME=my_new_sapnw`
- powershell - `$env:VAGRANT_SAPNW_VM_NAME="my_new_sapnw"` (mind the double-quotes !)
- bash - `export VAGRANT_SAPNW_VM_NAME=my_new_sapnw` or specifying the var in front of the command e.g. `VAGRANT_SAPNW_VM_NAME=my_new_sapnw vagrant ssh -c "ls -AFl"`

Don't forget to set the variable, especially before the sensitive commands like `up` and `destroy`. If you work with several instances a lot you might want to create dedicated script/batch files.

Example (cmd):
```
set VAGRANT_SAPNW_VM_NAME=my_new_sapnw
vagrant up
vagrant ssh -c "sudo /vagrant/scripts/install_addons.sh"
```

### Additional comments

- you may start the vm from any directory but then you need to address it by id or name. Run `vagrant global-status` to check the name. It should be `sapnw`. So the command to vm would look like `vagrant up sapnw` or `vagrant ssh sapnw -c <command>`
- `startsap.sh` and `stopsap.sh` are shortcuts that are placed to `/usr/local/bin` during installation. They contain command like `sudo -i -u npladm startsap`

## Infos

### What is vagrant

A tool to setup virtual environments conveniently. No need to go through boring installation process which is a plus. Basic virtual machine is created within seconds (for popular flavors that exist in vagrant cloud repository).

### Why not docker? (my opinion, no offends :)

1) Imho docker is supposed to be stateless. Databases should be in volumes, not inside docker layer.
2) Besides, docker storage layer is slower than volumes (AFAIK)

P.S.: Probably this can be solved. `/sybase` directory can be mounted to volume. Also logs and transports should be considered. Well, I don't have enough basis skills for this :) Maybe someday.  
P.P.S.: Docker has a lot of potential in terms of composability. E.g. compose several pods with NW dev edition, HANA express for sidecar, configured SMTP server and make them interact. Feel free to reuse the scripts from the repo, they should be very portable to docker, in fact they work inside Ubuntu so might be zero changes needed.

### Why Ubuntu

1) Ubuntu is very popular linux flavor. The community is huge and there are a lot of materials on how to solve this or that issue
2) Bare ubuntu server is just ~1 GB in size
3) and yes, I know debian-like system better than other flavors ;) might be the main reason.

### Memory

Currently machine is setup to consume 6GB. Though in my experiance 4GB is usually enough (ungrounded opinion). One option to decrease memory usage is to activate swap. To do this:
- uncomment `vb.memory = "4096"` in `Vagrantfile` (and comment the one with 6GB)
- uncomment `config.vm.provision "shell", path: "scripts/add_swap.sh"` - this will activate swap during installation. Or just run it after install via ssh `/vagrant/scripts/add_swap.sh`

### SSL certificates

SSL certificates installation can be triggered by `/vagrant/scripts/install_addons.sh` or separate `/vagrant/scripts/addons/install_ssl_certificates.sh` scripts. It install the files from `certificates` directory. The repositiry contains certificates of github and gitlab. However, you can add more (in *.cer format) before running the script above. The script will install all the certificates that are in the folder. In order to initiate certificate script again later (if you don't want to install certificates manually via `STRUST`), login to ssh and run `/vagrant/scripts/addons/install_ssl_certificates.sh`.

### Publication

- [Installing NetWeaver AS ABAP 7.52 SP 01 Developer Edition with Vagrant and Ubuntu](https://blogs.sap.com/2018/09/22/installing-netweaver-as-abap-7.52-sp-01-developer-edition-with-vagrant)
- [How to easily install SAP NetWeaver developer edition 7.52 and abapGit with Vagrant in 10 man-minutes](https://blogs.sap.com/2019/04/30/how-to-easily-install-sap-netweaver-developer-edition-7.52-and-abapgit-with-vagrant-in-10-man-minutes/)
- [Video with installation process](https://www.youtube.com/watch?v=-BeEF1U-cqQ)

### Regards and references

- [AS ABAP 752 SP01, developer edition, official announce](https://blogs.sap.com/2018/09/13/as-abap-752-sp01-developer-edition-to-download/)
- [AS ABAP 7.52 SP01, developer edition: Concise installation guide](https://blogs.sap.com/2018/09/13/as-abap-7.52-sp01-developer-edition-concise-installation-guide/)
- got some script ideas (expect) from https://github.com/tobiashofmann/sap-nw-abap-docker
- https://github.com/wechris/SAPNW75SPS02 as an inspiration
- concept on how to create additional VB drives in VM folder from https://gist.github.com/leifg/4713995
- cool guide on swap file in ubuntu: https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-16-04
- @filak-sap and https://github.com/filak-sap/sap-nw-abap-docker for ideas and inspiration
- https://github.com/SAP/node-rfc - nodejs lib to call SAP RFCs, used for SSL certificate installation
- @marcellourbani for his https://github.com/marcellourbani/abap-adt-api (cool!)
- [AS ABAP 752 SP04, developer edition: NOW AVAILABLE](https://blogs.sap.com/2019/07/01/as-abap-752-sp04-developer-edition-to-download)
- [AS ABAP 7.52 SP04, Developer Edition: Concise Installation Guide](https://blogs.sap.com/2019/10/01/as-abap-7.52-sp04-developer-edition-concise-installation-guide/)

### TODO

- download github/lab certificates directly from internet ?
- migrate to Ubuntu 18.04 LTS (Bionic Beaver)
- improve abapdeploy.js
- early detect presence of distrib

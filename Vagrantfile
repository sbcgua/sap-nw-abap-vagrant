# -*- mode: ruby -*-
# vi: set ft=ruby :

# Create additional disk in VM directory
class VagrantPlugins::ProviderVirtualBox::Action::SetName
  alias_method :original_call, :call
  def call(env)
    machine = env[:machine]
    driver  = machine.provider.driver
    uuid    = driver.instance_eval { @uuid }
    ui      = env[:ui]

    # Find out folder of VM
    vm_folder = ""
    vm_info   = driver.execute("showvminfo", uuid, "--machinereadable")
    lines     = vm_info.split("\n")
    lines.each do |line|
      if line.start_with?("CfgFile")
        vm_folder = line.split("=")[1].gsub('"','')
        vm_folder = File.dirname(File.expand_path(vm_folder))
        ui.info "VM Folder is: #{vm_folder}"
        break
      end
    end

    disk_size = 60 * 1024  # 1GB
    disk_file = File.join(vm_folder, "sybase.vdi")
    ui.info "VM additional disk is: #{disk_file}"

    ui.info "Adding disk to VM ..."
    if File.exist?(disk_file)
      ui.info "  disk already exists"
    else
      ui.info "  creating new disk"
      driver.execute(
        'createhd', 
        '--filename', disk_file, 
        '--format',   'VDI', 
        '--size',     "#{disk_size}",
        '--variant', 'Standard'  # dynamic disk
      )
      ui.info "  attaching disk to VM"
      driver.execute(
        'storageattach', uuid,
        '--storagectl',  'SCSI',
        '--port',   '2',
        '--device', '0', 
        '--type',   'hdd',
        '--medium', disk_file
      )
    end

    original_call(env)
  end
end

# Vagrant config
Vagrant.configure("2") do |config|
  config.vm.box      = "ubuntu/xenial64"
  config.vm.hostname = "vhcalnplci"
  config.vm.define "sapnw"
  
  # Check for updates only on `vagrant box outdated`
  config.vm.box_check_update = false

  # stopsap may take time
  config.vm.graceful_halt_timeout = 600

  # Network
  config.vm.network "forwarded_port", guest: 22,    guest_ip: "10.0.2.15", host_ip: "127.0.0.1", host: 2222,  id: "ssh", auto_correct: true
  config.vm.network "forwarded_port", guest: 8000,  guest_ip: "10.0.2.15", host_ip: "127.0.0.1", host: 8000,  id: "http"
  config.vm.network "forwarded_port", guest: 44300, guest_ip: "10.0.2.15", host_ip: "127.0.0.1", host: 44300, id: "https"
  config.vm.network "forwarded_port", guest: 3300,  guest_ip: "10.0.2.15", host_ip: "127.0.0.1", host: 3300,  id: "rfc"
  config.vm.network "forwarded_port", guest: 3200,  guest_ip: "10.0.2.15", host_ip: "127.0.0.1", host: 3200,  id: "sapgui"

  # Virtualbox settings
  config.vm.provider "virtualbox" do |vb|
    vb.name = "Sap-nw752"
    vb.memory = "6144" # 6 GB
    # vb.memory = "4096" # 4 GB + enable add_swap.sh below !!!
  end

  # Provision scripts
  config.vm.provision "shell", path: "scripts/add_disk.sh"
  # config.vm.provision "shell", path: "scripts/add_swap.sh"
  config.vm.provision "shell", path: "scripts/pre_install.sh"
  config.vm.provision "shell", path: "scripts/install_nw.sh"
  config.vm.provision "shell", path: "scripts/startup.sh"
  config.vm.provision "shell", path: "scripts/post_install.sh"
end

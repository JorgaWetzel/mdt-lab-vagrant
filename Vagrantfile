$domain = "mylab.com"
$domain_ip_address = "192.168.56.2"
$mdt_ip_address = "192.168.56.3"
$ESXIP = "192.168.5.97"
$ESXUser = "root"
$ESXPW = "P@ssw0rd"
$ESXRAMMDT = "8192"
$ESXCPUMDT = "2"
$ESXNET = "VM Network"
$ESXSTORE = "Storage"
$BaseboxServer = "JorgaWetzel/windows_2019DE"
$BaseboxServerVersion = "11.10.2021"


Vagrant.configure("2") do |config|
    
    config.vm.define "dc" do |config|
        config.vm.box = "JorgaWetzel/windows_2019DE"
        config.vm.hostname = "dc"

        # use the plaintext WinRM transport and force it to use basic authentication.
        # NB this is needed because the default negotiate transport stops working
        #    after the domain controller is installed.
        #    see https://groups.google.com/forum/#!topic/vagrant-up/sZantuCM0q4
        config.winrm.transport = :plaintext
        config.winrm.basic_auth_only = true

        config.vm.provider :virtualbox do |v, override|
            v.linked_clone = true
            v.cpus = 4
            v.memory = 4096
            v.customize ["modifyvm", :id, "--clipboard-mode", "bidirectional"]
            v.customize ["storageattach", :id,
                            "--storagectl", "IDE Controller",
                            "--device", "0",
                            "--port", "1",
                            "--type", "dvddrive",
                            "--medium", "emptydrive"]
        end

		config.vm.network "private_network", ip: $domain_ip_address, libvirt__forward_mode: "route", libvirt__dhcp_enabled: false
        #config.vm.network "forwarded_port", guest: 3389, host: 3389,
        #   auto_correct: true
        #config.vm.provision "shell", path: "provision/Language/set-language-german.ps1"   
        config.vm.provision "shell", path: "provision/ps.ps1",  args: ["domain-controller.ps1", $domain]
        config.vm.provision "shell", reboot: true
        config.vm.provision "shell", path: "provision/ps.ps1", args: "domain-controller-configure.ps1"
        config.vm.provision "shell", inline: "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))", name: "Install Chocolatey"
        config.vm.provision "shell", path: "provision/ps.ps1", args: "provision-base.ps1"
        config.vm.provision "shell", reboot: true
        config.vm.provision "shell", path: "provision/ps.ps1", args: "summary.ps1"
    end

    config.vm.define "mdt" do |config|  
        config.vm.provider :libvirt do |lv, config|
            lv.memory = 4096
            # replace the default synced_folder with something that works in the base box.
            # NB for some reason, this does not work when placed in the base box Vagrantfile.
            config.vm.synced_folder '.', '/vagrant', type: 'smb', smb_username: ENV['USER'], smb_password: ENV['VAGRANT_SMB_PASSWORD']
        end
        config.vm.provider :virtualbox do |v, override|
			v.linked_clone = true
			v.cpus = 4
            v.memory = 4096
			v.customize ["modifyvm", :id, "--clipboard-mode", "bidirectional"]
			#v.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", "1", "--device", "0", "--type", "dvddrive", "--medium", "C:\\\E2B\\_ISO\\WINDOWS\\SVR2019\\Windows Server 2019 1909 DE.ISO"]
			v.customize ["storageattach", :id, "--storagectl", "IDE Controller", "--port", "1", "--device", "0", "--type", "dvddrive", "--medium", "C:\\E2B\\_ISO\\WINDOWS\\WIN10\\Windows10AIO.ISO"]	
			v.customize ["storageattach", :id, "--storagectl", "IDE Controller", "--port", "0", "--device", "1", "--type", "dvddrive", "--medium", "C:\\E2B\\_ISO\\WINDOWS\\WIN11\\Windows11AIO.ISO"]	
        end

        #  Provider (esxi) settings
        config.vm.provider :vmware_esxi do |v,esxi|
            v.esxi_hostname = $ESXIP
            v.esxi_username = $ESXUser
            v.esxi_password = $ESXPW
            v.esxi_virtual_network = ['$ESXNET']
            v.guest_memsize = $ESXRAMMDT
            v.guest_numvcpus = $ESXCPUMDT
            v.guest_disk_type = 'thick' # 'thin', 'thick', or 'eagerzeroedthick'

        end
        
        config.vm.box = $BaseboxServer
        #config.vm.box_version = $BaseboxServerVersion
        config.vm.hostname = "mdt01"
        config.winrm.transport = :plaintext
        config.winrm.basic_auth_only = true

        config.vm.network "private_network", ip: $mdt_ip_address, libvirt__forward_mode: "route", libvirt__dhcp_enabled: false
        config.vm.network "forwarded_port", guest: 3389, host: 3399,
            auto_correct: true
        #config.vm.provision "windows-sysprep"
        config.vm.provision "shell", path: "provision/ps.ps1", args: "provision-base.ps1"
        config.vm.provision "shell", path: "provision/Language/set-language-german.ps1"
        config.vm.provision "shell", path: "provision/add-to-domain.ps1", args: [$domain, $domain_ip_address]
        config.vm.provision "shell", reboot: true
        config.vm.provision "shell", inline: "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))", name: "Install Chocolatey"
        config.vm.provision "shell", path: "provision/copy-mount.ps1"
        config.vm.provision "shell", path: "provision/ChocoOneICT.ps1"
        config.vm.provision "shell", path: "provision/install-afce.ps1"
        config.vm.provision "shell", inline: "C:\\Source\\Install.ps1"
        config.vm.provision "shell", path: "provision/install-hotfix.ps1"
        config.vm.provision "shell", path: "provision/install-dhcp.ps1"
        config.vm.provision "shell", path: "provision/install-wds.ps1"
		config.vm.provision "shell", inline: "Add-DhcpServerInDC"
        config.vm.provision "shell", reboot: true
        config.vm.provision "shell", path: "provision/ps.ps1", args: "summary.ps1"
    end

              
end

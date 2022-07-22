Install-WindowsFeature DHCP -IncludeManagementTools
netsh dhcp add securitygroups
Restart-Service dhcpserver
start-sleep -Seconds 3

#Todo Doublehop scenerio which causes this to fail
Add-DhcpServerInDC

Set-ItemProperty -Path "registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager\Roles\12" -Name ConfigurationState -Value 2

#[string]$userName = "mylab.com\Administrator"
#[string]$userPassword = "P@ssw0rd"
#[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force

#[pscredential]$credOject = New-Object System.Management.Automation.PSCredential ($userName, #$secStringPassword)

#Set-DhcpServerDnsCredential -Credential $credOject -ComputerName "mdt01.mylab.com"

Add-DhcpServerv4Scope -name "main" -StartRange "192.168.56.101" -EndRange "192.168.56.200" -SubnetMask "255.255.255.0" -State Active

Set-DhcpServerv4OptionValue -ScopeId "192.168.56.0" -DnsServer "192.168.56.2" -DnsDomain "mylab.com"
Set-DhcpServerv4OptionValue -ScopeId "192.168.56.0" -OptionId 003 -Value "192.168.56.3"
# Set-DhcpServerv4OptionValue -ScopeId "192.168.56.0" -OptionId 066 -Value "192.168.56.3"
# Set-DhcpServerv4OptionValue -ScopeId "192.168.56.0" -OptionId 067 -Value "boot\x86\wdsnbp.com" # für UEFI x64
# Set-DhcpServerv4OptionValue -ScopeId "192.168.56.0" -OptionId 067 -Value "boot\x86\wdsnbp.com" # für x86
# Set-DhcpServerv4OptionValue -ScopeId "192.168.56.0" -OptionId 067 -Value "boot\x64\wdsnbp.com" #für x64

copy-item "C:\Windows\System32\RemInst\boot\x64\wdsmgfw.efi" "C:\remInstall\Boot\x64\wdsmgfw.efi"
Add-DhcpServerInDC
#https://community.spiceworks.com/topic/2150005-pxe-booting-uefi-dell-latitude-7404?page=1#entry-7853547
#https://rakhesh.com/powershell/adding-dhcp-scope-options-via-powershell/


#Configure Windows Server 2019 as a NAT Router
#https://msftwebcast.com/2020/02/configure-windows-server-2019-as-a-nat-router.html
Write-Output -InputObject ":: Installing RRAS"
Install-WindowsFeature -Name RemoteAccess,Routing,RSAT-RemoteAccess-Mgmt 
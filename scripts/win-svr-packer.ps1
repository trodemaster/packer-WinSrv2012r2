# windows server cleanup

# Power settings to MAX

#powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
#powercfg -change -monitor-timeout-ac never

# Disable Hybernation
powercfg -hibernate OFF

# configure screen saver

#Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Control Panel\Desktop\" -Name ScreenSaveTimeOut -Value 0
#Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Control Panel\Desktop\" -Name ScreenSaveActive -Value 0
Set-ItemProperty -Path "registry::HKEY_USERS\.DEFAULT\Control Panel\Desktop" -Name ScreenSaveActive -Value 0

# enforce password history 2 & Max password age 90
net accounts /uniquepw:10 /maxpwage:90 /minpwlen:8

# change administrator user pass next login
net user administrator /logonpasswordchg:yes

# change administrator user pass next login
# this gets reset by sysprep/guest customization. need to set it again in the guest customization script. 
net user packer /logonpasswordchg:no

# enable administrator account
net user administrator /active:yes

#Enable RDC in firewall rules in case firewall is turned back on
Set-NetFirewallRule -DisplayGroup "Remote Desktop" -Enabled True

# Disable firewall
netsh advfirewall set allprofiles state off

## Optimize IPv6 settings
# disable privacy IPv6 addresses
netsh interface ipv6 set privacy state=disabled store=active
netsh interface ipv6 set privacy state=disabled store=persistent
# enable EUI-64 addressing
netsh interface ipv6 set global randomizeidentifiers=disabled store=active
netsh interface ipv6 set global randomizeidentifiers=disabled store=persistent


#  Enable Remote Desktop
(Get-WmiObject Win32_TerminalServiceSetting -Namespace root\cimv2\TerminalServices).SetAllowTsConnections(1,1) | Out-Null
(Get-WmiObject -Class "Win32_TSGeneralSetting" -Namespace root\cimv2\TerminalServices -Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(0) | Out-Null

# Clear windows autologon
Remove-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultDomainName
Remove-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName
Remove-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon

# Clear WSUS settings
#Remove-Item -Path "HKLM:\software\policies\Microsoft\Windows\WindowsUpdate" -recurse

# Enable remote command policy
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name LocalAccountTokenFilterPolicy -Value 1 -Type DWord

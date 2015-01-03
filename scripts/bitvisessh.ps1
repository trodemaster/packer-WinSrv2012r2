$host.ui.RawUI.WindowTitle = "bitvisessh.ps1"

$ProgressPreference = "SilentlyContinue"


# download ssh server from local http server or bitvise website
If (test-connection -quiet 1.1.1.1) {
write-host "Downloading http://1.1.1.1/BvSshServer-Inst.exe"
Invoke-WebRequest -Uri http://1.1.1.1/BvSshServer-Inst.exe -OutFile 'C:\windows\temp\BvSshServer-Inst.exe'
} else {
write-host "Downloading http://dl.bitvise.com/BvSshServer-Inst.exe"
Invoke-WebRequest http://dl.bitvise.com/BvSshServer-Inst.exe -OutFile 'C:\windows\temp\BvSshServer-Inst.exe'
}


# Install Bitvise SSH server
start-process -FilePath 'C:\windows\temp\BvSshServer-Inst.exe' -ArgumentList '-defaultSite -acceptEULA' -wait -verb RunAs

# Configure Bitvise SSH server
start-process -FilePath 'C:\Program Files\Bitvise SSH Server\BssCfg.exe' -ArgumentList 'settings importtext A:\bitvisessh.cfg' -wait -verb RunAs

# Start Bitvise SSH server
Set-Service -Name BvSshServer -StartupType Automatic -Status Running 

# Disable firewall
netsh advfirewall set allprofiles state off
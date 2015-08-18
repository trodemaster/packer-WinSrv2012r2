# install vmware tools
write-host "starting vmware tools install"
#install vmware cert
start-process -FilePath 'C:/Windows/Temp/certmgr.exe' -ArgumentList '-add C:/Windows/Temp/vmware.cer -c -s -r localMachine TrustedPublisher' -wait
write-host "Installed VMware cert..."

Write-Host "Installing VMWare Tools..."
#stop-service winrm
#start-sleep -s 20
#Run vmware tools installer
#$p = start-process -FilePath 'C:/Windows/Temp/setup64.exe' -ArgumentList '/S /v "/qn /l*v ""C:\windows\temp\vmwtoolsinstall.log"" ADDLOCAL=ALL REMOVE=Hgfs REBOOT=R"' -PassThru -wait
start-process -FilePath 'C:/Windows/Temp/setup64.exe' -ArgumentList '/S /v "/qn /l*v ""C:\windows\temp\vmwtoolsinstall.log"" ADDLOCAL=ALL REMOVE=Hgfs"'

exit 0

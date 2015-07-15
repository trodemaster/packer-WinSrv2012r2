#install vmware cert
start-process -FilePath 'C:/Windows/Temp/certmgr.exe' -ArgumentList '-add C:/Windows/Temp/vmware.cer -c -s -r localMachine TrustedPublisher' -wait -verb RunAs
write-host "Installed VMware cert..."


Write-Host "Installing VMWare Tools..."
#Run vmware tools installer
$p = start-process -FilePath 'C:/Windows/Temp/setup64.exe' -ArgumentList '/S /v "/qn /l*v ""C:\windows\temp\vmwtoolsinstall.log"" ADDLOCAL=ALL REMOVE=Hgfs REBOOT=R"' -PassThru

#Wait for tools installer to finish
write-host "Waiting for VMware tools to install"
wait-process -name setup64
write-host "Done Waiting for VMware tools to install"

if ($p.ExitCode -eq 0) {
  Write-Host "Done."
} elseif ($p.ExitCode -eq 3010) {
  Write-Host "Done, but a reboot is necessary."
} else {
  Write-Host "VMWare Tools install failed: ExitCode=$($p.ExitCode), Log=C:\windows\temp\vmwtoolsinstall.log"
}

write-host "Installed VMware tools..."

exit 0


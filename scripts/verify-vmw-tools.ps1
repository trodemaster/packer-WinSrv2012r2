if (Test-Path -Path "C:\Program Files\VMware\VMware Tools\VMwareToolboxCmd.exe")
  {
   start-process -FilePath 'C:\Program Files\VMware\VMware Tools\VMwareToolboxCmd.exe' -ArgumentList '-v' -wait
  }
else
  {
   write-host "VMware tools not installed!!"
   exit 1
  }
exit 0  
#Capture pass paramater
param (
    [string]$group = "all",
    [string]$server = "1.1.1.1"
 )

# group must be configured on wsus server
write-host "Group $group"

# server is the IP of your local wsus server
write-host "Server $server"


# Set the wsus IP if you can reach the wsus server

If (test-connection -quiet $server) {
$wsusserver="http://" + $server + ":8530"
} elseif (test-connection -quiet 1.1.1.1) {
$wsusserver="http://1.1.1.1:8530"
} else {
write-host "Unable to contact the wsus server. Using microsoft.com"
exit 0
}

write-host "WSUS server contacted " $wsusserver

# set windows updates to pull from local wsus server
stop-service wuauserv
New-Item -Path "HKLM:Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\software\policies\Microsoft\Windows\WindowsUpdate" -Name WUServer -Value $wsusserver -Type String -force
Set-ItemProperty -Path "HKLM:\software\policies\Microsoft\Windows\WindowsUpdate" -Name WUStatusServer -Value $wsusserver -Type String -force
Set-ItemProperty -Path "HKLM:\software\policies\Microsoft\Windows\WindowsUpdate\AU" -Name UseWUServer -Value "1" -Type DWORD -force
Set-ItemProperty -Path "HKLM:\software\policies\Microsoft\Windows\WindowsUpdate" -Name TargetGroupEnabled -Value "1" -Type DWORD -force
Set-ItemProperty -Path "HKLM:\software\policies\Microsoft\Windows\WindowsUpdate" -Name TargetGroup -Value $group -Type String -force


start-service wuauserv
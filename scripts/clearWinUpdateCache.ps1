## clean windows update cach files on 2012 r2 
## sourced http://gallery.technet.microsoft.com/scriptcenter/Clean-up-your-C-Drive-bc7bb3ed
                     
## Stops the windows update service.  
Get-Service -Name wuauserv | Stop-Service -Force -Verbose -ErrorAction SilentlyContinue 
## Windows Update Service has been stopped successfully! 
 
## Delete the contents of windows software distribution. 
Get-ChildItem "C:\Windows\SoftwareDistribution\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | remove-item -force -recurse -ErrorAction SilentlyContinue 
 
## Starts the Windows Update Service 
Get-Service -Name wuauserv | Start-Service -Verbose 

# use dism to cleanup windows sxs. This only works on 2012r2 and 8.1 and above. 
dism /online /cleanup-image /startcomponentcleanup /resetbase

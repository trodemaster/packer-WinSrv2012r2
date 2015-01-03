#Powershell version of install vmware tools via task scheduler
$host.ui.RawUI.WindowTitle = "tools-win.ps1"

#check if scheduled task called installvmwtools exists install VMware tools
if (get-scheduledtask -taskname installvmwtools -ErrorAction SilentlyContinue) {
	Write-Host Starting VMware Tools Installation
	#install vmware cert
	start-process -FilePath 'C:/Windows/Temp/certmgr.exe' -ArgumentList '-add C:/Windows/Temp/vmware.cer -c -s -r localMachine TrustedPublisher' -wait -verb RunAs

	#Run vmware tools installer
	start-process -FilePath 'C:/Windows/Temp/setup64.exe' -ArgumentList '/S /v "/qn /l*v ""C:\windows\temp\vmwtoolsinstall.log"" ADDLOCAL=ALL REMOVE=Hgfs"' -verb RunAs

	#remove scheduled task
	unregister-scheduledtask -taskname installvmwtools -Confirm:$false
    	
	#Wait for tools installer to finish
	wait-process -name setup64
	
	write-host VMware tools Install Done!!
    New-Item C:\Windows\Temp\tools_install_done -type file

	} else {

	#if scheduled task called installvmwtools does not exist create a scheduled task in the near future to re-run this script
	Write-host Creating scheduled task to start tools-win.ps1 with proper elevation
	
	#Calculate time stamp short time in the future..
	$triggertime = Get-Date
	$triggertime = $triggertime.AddSeconds(5)

	#Create Action..
	$toolsaction = New-ScheduledTaskAction -ID toolsaction -Execute C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -Argument '-File C:\windows\temp\tools-win.ps1'

	#Create start time..
	$trigger = New-ScheduledTaskTrigger -At $triggertime -Once 

	#Create principal for the task to run
	$Principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\administrators" -RunLevel Highest

	#Create scheduled task
	Register-ScheduledTask -taskname installvmwtools -trigger $trigger -Action $toolsaction -Principal $Principal
	
	# wait for installer to finish
    while (-Not(test-path C:\windows\temp\tools_install_done))  {
    sleep -s 5
    } 
}



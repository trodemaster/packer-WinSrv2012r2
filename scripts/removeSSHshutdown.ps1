#Powershell version of install vmware tools via task scheduler
$host.ui.RawUI.WindowTitle = "removeSSHshutdown.ps1"

#check if scheduled task called cleanupssh exists install VMware tools
if (get-scheduledtask -taskname cleanupssh -ErrorAction SilentlyContinue) {
	
	# remove bitvise ssh server
	copy-item 'C:\Program Files\Bitvise SSH Server\uninst.exe' C:\Windows\temp\
	start-process -FilePath 'C:\windows\temp\uninst.exe' -ArgumentList '"Bitvise SSH Server" -unat' -wait -verb RunAs
	Remove-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Bitvise" -recurse
	get-childitem -Recurse "C:\Program Files\Bitvise SSH Server" | remove-item -Recurse -Force -ErrorAction SilentlyContinue
	remove-item "C:\Program Files\Bitvise SSH Server" -Recurse -Force -ErrorAction SilentlyContinue

	#Clean up the windows temp directory
	get-childitem -Recurse "C:\Windows\Temp" | remove-item -Recurse -Force -ErrorAction SilentlyContinue 
	write-host "Finished cleaning C:\Windows\Temp"

	#Start System halt
	start-process -FilePath 'shutdown' -ArgumentList '/s /t 15 /f /d p:4:1 /c "Packer Shutdown"' -verb RunAs
	
	# Remove Scheduled task
	unregister-scheduledtask -taskname cleanupssh -Confirm:$false
	
	} else {

	#if scheduled task called cleanupssh does not exist create a scheduled task in the near future to re-run this script
	Write-host Creating scheduled task to start removeSSHshutdown.ps1 with proper elevation
	
	#Calculate time stamp short time in the future..
	$triggertime = Get-Date
	$triggertime = $triggertime.AddSeconds(5)

	#Create Action..
	$scriptaction = New-ScheduledTaskAction -ID scriptaction -Execute C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -Argument '-File C:\windows\temp\removeSSHshutdown.ps1'

	#Create start time..
	$trigger = New-ScheduledTaskTrigger -At $triggertime -Once 

	#Create principal for the task to run
	$Principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\administrators" -RunLevel Highest

	#Create scheduled task
	Register-ScheduledTask -taskname cleanupssh -trigger $trigger -Action $scriptaction -Principal $Principal
}




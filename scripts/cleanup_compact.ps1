#Powershell version of install cleanup_compact via task scheduler
$host.ui.RawUI.WindowTitle = "cleanup_compact.ps1"

# unzip function
function punzip( $zipfile, $outdir ) {
  If(-not(Test-Path -path $zipfile)){return "zipfile " + $zipfile + " not found!"}
  If(-not(Test-Path -path $outdir)){return "output dir " + $outdir + " not found!"}
  $shell = new-object -com shell.application
  $zip = $shell.NameSpace($zipfile)
  foreach($item in $zip.items())
    {
      $shell.Namespace($outdir).copyhere($item)
    }
}


#check if scheduled task called cleanup_compact exists then install cleanup_compact
if (get-scheduledtask -taskname cleanup_compact -ErrorAction SilentlyContinue) {
  Write-Host Starting cleanup_compact Installation
  #New-Item C:\Windows\Temp\cleanup_task_exists -type file
  
  # extract ultradefrag archive
  write-host extracting ultradefrag archive
  punzip ("C:\windows\temp\ultradefrag-portable-6.0.4.bin.amd64.zip") ("C:\Windows\temp")

  # extract sdelete archive
  write-host extracting sdelete archive
  punzip ("C:\windows\temp\sdelete.zip") ("C:\Windows\temp")

  # Stops the windows update service.  
  Get-Service -Name wuauserv | Stop-Service -Force -Verbose -ErrorAction SilentlyContinue 
 
  # Delete the contents of windows software distribution.
  write-host Delete the contents of windows software distribution 
  Get-ChildItem "C:\Windows\SoftwareDistribution\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | remove-item -force -recurse -ErrorAction SilentlyContinue 
 
  # Starts the Windows Update Service 
  Get-Service -Name wuauserv | Start-Service -Verbose 

  # use dism to cleanup windows sxs. This only works on 2012r2 and 8.1 and above.
  write-host "Cleaning windows SXS" 
  dism /online /cleanup-image /startcomponentcleanup /resetbase

  # Defragment the virtual disk blocks
  write-host "Defragmenting the C: disk" 
  start-process -FilePath 'C:\Windows\Temp\ultradefrag-portable-6.0.4.amd64\udefrag.exe' -ArgumentList '--optimize --repeat C:' -wait
  
  # Zero dirty blocks
  write-host "Writing zeros to all dirty blocks" 
  New-Item -Path "HKCU:\Software\Sysinternals\SDelete" -force -ErrorAction SilentlyContinue
  Set-ItemProperty -Path "HKCU:\Software\Sysinternals\SDelete" -Name EulaAccepted -Value "1" -Type DWORD -force
  start-process -FilePath 'C:\Windows\Temp\sdelete.exe' -ArgumentList '-q -z C:' -wait

  #remove scheduled task
  unregister-scheduledtask -taskname cleanup_compact -Confirm:$false
  
  #create marker file so original script knows this task is done
  New-Item C:\Windows\Temp\cleanup_compact_done -type file
  
   } else {

  #if scheduled task called cleanup_compact does not exist create a scheduled task in the near future to re-run this script
  Write-host Creating scheduled task to start cleanup_compact.ps1 with proper elevation
  #New-Item C:\Windows\Temp\cleanup_task_doesnt_exist -type file
  
  #Calculate time stamp short time in the future..
  $triggertime = Get-Date
  $triggertime = $triggertime.AddSeconds(5)

  #Create Action..
  $cleanup_compactaction = New-ScheduledTaskAction -ID cleanup_compactaction -Execute C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -Argument '-File C:\windows\temp\cleanup_compact.ps1'

  #Create start time..
  $trigger = New-ScheduledTaskTrigger -At $triggertime -Once 

  #Create principal for the task to run
  $Principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\administrators" -RunLevel Highest

  #Create scheduled task
  Register-ScheduledTask -taskname cleanup_compact -trigger $trigger -Action $cleanup_compactaction -Principal $Principal
  
  # wait for installer to finish
  while (-Not(test-path C:\windows\temp\cleanup_compact_done))  {
    sleep -s 5
  } 
}




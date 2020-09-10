
Invoke-WebRequest -Uri https://github.com/mickem/nscp/releases/download/0.5.2.35/NSCP-0.5.2.35-x64.msi -OutFile 'c:\nscp.msi'

Start-Process c:\nscp.msi -Wait

Write-Host "Install nsclient from nsclient.org first"
$password = Read-Host -Prompt 'Input your password'
$monitoring_ip = Read-Host -Prompt 'Input your monitoring ip'

Invoke-WebRequest -Uri https://raw.githubusercontent.com/cloudcentral/monitoring-plugins/master/etc/nsclient.ini -OutFile 'c:\Program Files\NSClient++\nsclient.ini'

powershell -Command "(gc 'c:\Program Files\NSClient++\nsclient.ini') -replace '_PASSWORD_', '$password' | Out-File -encoding ASCII 'c:\Program Files\NSClient++\nsclient.ini'"
powershell -Command "(gc 'c:\Program Files\NSClient++\nsclient.ini') -replace '_MONITORING_IP_', '$monitoring_ip' | Out-File -encoding ASCII 'c:\Program Files\NSClient++\nsclient.ini'"

Invoke-WebRequest -Uri https://raw.githubusercontent.com/cloudcentral/monitoring-plugins/master/plugins/check_time.ps1 -OutFile 'c:\Program Files\NSClient++\scripts\check_time.ps1'
Invoke-WebRequest -Uri https://raw.githubusercontent.com/cloudcentral/monitoring-plugins/master/plugins/check_ad.vbs -OutFile 'c:\Program Files\NSClient++\scripts\check_ad.vbs'


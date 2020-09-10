Write-Host "Install nsclient from nsclient.org first"
$password = Read-Host -Prompt 'Input your password'
$monitoring_ip = Read-Host -Prompt 'Input your monitoring ip'

Invoke-WebRequest -Uri https://raw.githubusercontent.com/cloudcentral/monitoring-plugins/master/etc/nsclient.ini -OutFile c:\Program Files\NSClient++\nsclient.ini

powershell -Command "(gc test) -replace '_PASSWORD_', '$password' | Out-File -encoding ASCII test"
powershell -Command "(gc test) -replace '_MONITORING_IP_', '$monitoring_ip' | Out-File -encoding ASCII test"

Invoke-WebRequest -Uri https://raw.githubusercontent.com/cloudcentral/monitoring-plugins/master/plugins/check_time.ps1 -OutFile c:\Program Files\NSClient++\scripts\check_time.ps1
Invoke-WebRequest -Uri https://raw.githubusercontent.com/cloudcentral/monitoring-plugins/master/plugins/check_ad.vbs -OutFile c:\Program Files\NSClient++\scripts\check_ad.vbs


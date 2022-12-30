# Security Protocol
[Net.ServicePointManager]::SecurityProtocol = 'Tls12'

# Create base folder
if (!(Test-Path "C:\Temp")) {
        New-Item -itemType Directory -Path C:\ -Name Temp
        }
        
# Install Chocolatey
Invoke-WebRequest "https://raw.githubusercontent.com/T13KDEV/Scripts/devel/powershell/packages.config" -OutFile "C:\Temp\packages.config"
Invoke-WebRequest "https://chocolatey.org/install.ps1" -UseBasicParsing | Invoke-Expression

# Install Choco Applications
& C:\ProgramData\chocolatey\choco.exe install --confirm c:\Temp\packages.config

Start-Sleep -Seconds 30

& dism /online /Export-DefaultAppAssociations:%TMP%\AppAssoc.xml  
& dism /online /Import-DefaultAppAssociations:%TMP%\AppAssoc.xml

# Prepare User Desktop
if (Test-Path 'C:\Users\Public\Desktop\Command Prompt.lnk') { Remove-Item 'C:\Users\Public\Desktop\Command Prompt.lnk' -Force }
if (Test-Path 'C:\Users\Public\Desktop\Disk Management.lnk') { Remove-Item 'C:\Users\Public\Desktop\Disk Management.lnk' -Force }
if (Test-Path 'C:\Users\Public\Desktop\Google Chrome.lnk') { Remove-Item 'C:\Users\Public\Desktop\Google Chrome.lnk' -Force }
if (Test-Path 'C:\Users\Public\Desktop\Internet Explorer.lnk') { Remove-Item 'C:\Users\Public\Desktop\Internet Explorer.lnk' -Force }
if (Test-Path 'C:\Users\Public\Desktop\Microsoft Edge.lnk') { Remove-Item 'C:\Users\Public\Desktop\Microsoft Edge.lnk' -Force }

Invoke-WebRequest "https://datablob.oss.eu-west-0.prod-cloud-ocb.orange-business.com/Abmelden.ico" -Outfile "C:\Temp\Abmelden.ico"
Invoke-WebRequest "https://datablob.oss.eu-west-0.prod-cloud-ocb.orange-business.com/Abmelden.cmd" -Outfile "C:\Temp\Abmelden.cmd"
Invoke-WebRequest "https://datablob.oss.eu-west-0.prod-cloud-ocb.orange-business.com/Abmelden.lnk" -Outfile "C:\Temp\Abmelden.lnk"
Invoke-WebRequest "https://datablob.oss.eu-west-0.prod-cloud-ocb.orange-business.com/LayoutModification.xml" -Outfile "C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml"

Copy-Item -Path "C:\Temp\Abmelden.lnk" -Destination "C:\Users\Public\Desktop"
Remove-Item -Path "C:\Temp\Abmelden.lnk" -Force

Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\Shell\Bags\1\Desktop" -Name "FFlags" -Value 1075839525
stop-process -name explorer -force

# Join Machine to Domain and restart
Start-Sleep -s 30
$password = "xxxxx" | ConvertTo-SecureString -asPlainText -Force
$username = "licdemo\xxxx"
$credential = New-Object System.Management.Automation.PSCredential($username,$password)
Add-Computer -DomainName "licdemo.local" -OUPath "OU=NewJoined,OU=Computer,OU=Tier2,OU=LICDEMO,DC=licdemo,DC=local" -Credential $credential -Restart


# Security Protocol
[Net.ServicePointManager]::SecurityProtocol = 'Tls12'

# Create base folder
if (!(Test-Path "C:\Install")) {
    New-Item -itemType Directory -Path C:\ -Name Install
    }

# Install Evergreen and applications
# Invoke-WebRequest "https://raw.githubusercontent.com/Deyda/Evergreen-Script/main/Evergreen.ps1" -OutFile "C:\Install\Evergreen.ps1" 
# Invoke-WebRequest "https://raw.githubusercontent.com/T13KDEV/Scripts/devel/config/LastSetting.txt" -OutFile "C:\Install\LastSetting.txt"
# Powershell.exe -NoProfile -ExecutionPolicy Bypass -Command C:\Install\Evergreen.ps1 -file C:\Install\LastSetting.txt

# Start-Sleep -Seconds 30

# Install Chocolatey
Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression

# Install Choco Applications
& C:\ProgramData\chocolatey\choco.exe install powershell-core -y
& C:\ProgramData\chocolatey\choco.exe install googlechrome -y
& C:\ProgramData\chocolatey\choco.exe install irfanview -y
& C:\ProgramData\chocolatey\choco.exe install irfanview-shellextension -y
& C:\ProgramData\chocolatey\choco.exe install irfanviewplugins -y
& C:\ProgramData\chocolatey\choco.exe install notepadplusplus.install -y
& C:\ProgramData\chocolatey\choco.exe install 7zip.install -y
& C:\ProgramData\chocolatey\choco.exe install microsoft-edge -y
& C:\ProgramData\chocolatey\choco.exe install freeoffice -y

Start-Sleep -Seconds 30

& dism /online /Export-DefaultAppAssociations:%TMP%\AppAssoc.xml  
& dism /online /Import-DefaultAppAssociations:%TMP%\AppAssoc.xml

# Join Machine to Domain and restart
Start-Sleep -s 30
$password = "tkmdLpu4d9WOg0ygXq17" | ConvertTo-SecureString -asPlainText -Force
$username = "licdemo\domjoin"
$credential = New-Object System.Management.Automation.PSCredential($username,$password)
Add-Computer -DomainName "licdemo.local" -OUPath "OU=NewJoined,OU=Computer,OU=Tier2,OU=LICDEMO,DC=licdemo,DC=local" -Credential $credential -Restart

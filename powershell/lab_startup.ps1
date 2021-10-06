# Security Protocol
[Net.ServicePointManager]::SecurityProtocol = 'Tls12'

# Create base folder
if (!(Test-Path "C:\Install")) {
    New-Item -itemType Directory -Path C:\ -Name Install
    }

# Install Evergreen and applications
Invoke-WebRequest "https://raw.githubusercontent.com/Deyda/Evergreen-Script/main/Evergreen.ps1" -OutFile "C:\Install\Evergreen.ps1" 
Invoke-WebRequest "https://raw.githubusercontent.com/T13KDEV/Scripts/devel/config/LastSetting.txt" -OutFile "C:\Install\LastSetting.txt"
# powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = 'Tls12'; iex ((New-Object System.Net.Webclient).DownloadString('https://github.com/ansible/ansible/raw/devel/examples/scripts/ConfigureRemotingForAnsible.ps1'))"
Powershell.exe -NoProfile -ExecutionPolicy Bypass -Command C:\Install\Evergreen.ps1 -file C:\Install\LastSetting.txt

# Join Machine to Domain and restart
Start-Sleep -s 30
$password = "tkmdLpu4d9WOg0ygXq17" | ConvertTo-SecureString -asPlainText -Force
$username = "training\domjoin"
$credential = New-Object System.Management.Automation.PSCredential($username,$password)
Add-Computer -DomainName "training.local" -OUPath "OU=Students,OU=Training,DC=training,DC=local" -Credential $credential -Restart

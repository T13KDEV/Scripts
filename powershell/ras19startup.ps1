# Security Protocol
[Net.ServicePointManager]::SecurityProtocol = 'Tls12'

# Create base folder
if (!(Test-Path "C:\Install")) {
    New-Item -itemType Directory -Path C:\ -Name Install
    }

# Install Chocolatey
Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression

Start-Sleep -Seconds 30

# Join Machine to Domain and restart
Start-Sleep -s 30
$password = "tkmdLpu4d9WOg0ygXq17" | ConvertTo-SecureString -asPlainText -Force
$username = "licdemo\domjoin"
$credential = New-Object System.Management.Automation.PSCredential($username,$password)
Add-Computer -DomainName "licdemo.local" -OUPath "OU=NewJoined,OU=Computers,OU=Tier1,OU=LICDEMO,DC=licdemo,DC=local" -Credential $credential -Restart

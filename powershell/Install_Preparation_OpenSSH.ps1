Import-Module -Name 'NetSecurity'

# Setup windows update service to manual
$wuauserv = Get-WmiObject Win32_Service -Filter "Name = 'wuauserv'"
$wuauserv_starttype = $wuauserv.StartMode
Set-Service wuauserv -StartupType Manual

# Install OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Install OpenSSH Client
# Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

# Set service start type
Set-Service -Name ssh-agent -StartupType 'Automatic'
Set-Service -Name sshd -StartupType 'Automatic'

# Start services
Start-Service ssh-agent
Start-Service sshd

# Setup windows update service to original
Set-Service wuauserv -StartupType $wuauserv_starttype

# Configure Powershell as default ssh shell
New-ItemProperty -Path "HKLM:\Software\OpenSSH" -Name "DefaultShell" -Value "$Env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force

# Restart the service
Restart-Service sshd

# Configure SSH public key
# $content = @"
# ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjF4UVBeGRntZMv/f9kI/DtYdWbxhfEmPT0D+Ep9iNfBRNdmCqRWHkS3+y7++66OGzAX4VU73BgOu99NiEYxrchgxbZwQu76p5HUEB1nrU+HFdH1cjHVsM7zkyYcyoEHYvhIn2sBVffB++jTvg+X9/fNtFF/mb2WrIR/4selstDWumHTn9k4Xf5z9hNA2c4fGWYD8jocVONdS/+Gj2I9gBhm3MJJ9Fy1zNP5EwhbjKXV8PwQxSXn1Vpvdc+YPfwZr9rmGXevKjX5ZPlhDS3iQU3NwhG61yql1gEVpkKZKSiCjeuh37Bp/VlG5nZzzyHZ+H6xvHimnCpiDOiaFIYsTZ root@ansible.ad.myctx.net
# "@ 
$content @"MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAtaQHi5wscaNFzCd8r3gEIxaLLPTNbf+ktnoFUAgGXjrB8nOuM6/Hv0F8sF58nVjO0BKN8peaQVEaaAY6LNP6l9dyh4TNowKgaIWe+RG4cSZxNEL5YoRTHiF5JziTW8BcNPOhCYlZJygPD7nETEzgmMHuutmPNrPMYkyN2EmofBETdcUs2Ov6gwY0k04DZddHYuywRTAIclO6wwf55zojsGN7cGGKjkfbjKtAdR25KMtV6FG5XZ/agHpXqNYbH1qGME9X43wsKzpsjisHHmuo9Lv8TYKJQy/C59PgGldlZE9qNXb3gVnwrWVZQc7DEwX6uoQjqqQj6a7kpojAczeK1dNMvcS6Itjl5wr9KoMXxi4kqDd04r1wbpQyUn/EuIqOA+AG4O9l750DAu8hhrE7gditt/LujvCpPl88lGwmUJASMbxB6OfoDxhUx9wOHkELKznSU1kZ00RJyVuLbbBqh2W9/KfGWyAes5UnkWZOt4vGmZ4VpjxbgTSNqOofK+GWw6MHniZghbQJlQjjTyULQ1mM1PUT7hogR8e3LYkunlsM2WZTQnoav2emXULcAtlLINN/aJRMVIFEAoemWcMrpgzorc2xH5RLaGnuXJwnuMpNQSDJ8t1KBxSEgVpB3jzoIB5RKlL5zfz7xHcxT5fmUh2OL/d8P9tvOXl1WfDYwHECAwEAAQ==@"

# Write public key to file
$content | Set-Content -Path "$Env:ProgramData\ssh\administrators_authorized_keys"

# Set acl on administrators_authorized_keys
$admins = ([System.Security.Principal.SecurityIdentifier]'S-1-5-32-544').Translate( [System.Security.Principal.NTAccount]).Value
$acl = Get-Acl $Env:ProgramData\ssh\administrators_authorized_keys
$acl.SetAccessRuleProtection($true, $false)
$administratorsRule = New-Object system.security.accesscontrol.filesystemaccessrule($admins,"FullControl","Allow")
$systemRule = New-Object system.security.accesscontrol.filesystemaccessrule("SYSTEM","FullControl","Allow")
$acl.SetAccessRule($administratorsRule)
$acl.SetAccessRule($systemRule)
$acl | Set-Acl

# Open Windows Firewall for SSH traffic inbound
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22


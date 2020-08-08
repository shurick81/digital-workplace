Start-Transcript C:\vm-initiate.ps1.log

Set-ExecutionPolicy Bypass -Force;
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install -y git --version 2.24.1.2
choco install -y nodejs --version=10.16.3
choco install -y vscode --version=1.47.3
choco install -y azure-cli --version=2.10.0
choco install -y packer --version=1.6.1
choco install -y vagrant --version=2.2.9
choco install -y terraform --version=0.12.28
choco install -y googlechrome

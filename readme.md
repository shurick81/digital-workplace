Prerequisites:

1. Docker
2. Environment variables:

* ARM_CLIENT_ID
* ARM_CLIENT_SECRET
* ARM_SUBSCRIPTION_ID
* ARM_TENANT_ID
* VM_ADMIN_PASSWORD

Verify prerequisites in Windows

```PowerShell
docker run --rm mcr.microsoft.com/azure-cli:2.9.1 /bin/bash -c "az login --service-principal -u $env:ARM_CLIENT_ID -p $env:ARM_CLIENT_SECRET --tenant $env:ARM_TENANT_ID; az account list"
```

Clone the project

Windows
```Powershell
git clone https://github.com/shurick81/digital-workplace c:\projects\digital-workplace
```

Deploying Windows development VM

Using Windows:

```PowerShell
cd c:\projects\digital-workplace\src\windows\dev
Remove-Item .terraform.tfstate.lock.info -Recurse
Remove-Item terraform.tfstate
Remove-Item terraform.tfstate.backup
Sleep 5;
docker run --rm -v ${PWD}:/workplace -w /workplace hashicorp/terraform:light init
docker run --rm -v ${PWD}:/workplace -w /workplace `
    -e TF_VAR_ARM_CLIENT_ID=$env:ARM_CLIENT_ID `
    -e TF_VAR_ARM_CLIENT_SECRET=$env:ARM_CLIENT_SECRET `
    -e TF_VAR_ARM_SUBSCRIPTION_ID=$env:ARM_SUBSCRIPTION_ID `
    -e TF_VAR_ARM_TENANT_ID=$env:ARM_TENANT_ID `
    -e TF_VAR_VM_ADMIN_PASSWORD=$env:VM_ADMIN_PASSWORD `
    hashicorp/terraform:light `
    apply -auto-approve
```

Destroying Windows development VM

Using Windows:

```PowerShell
docker run --rm mcr.microsoft.com/azure-cli:2.9.1 /bin/bash -c "az login --service-principal -u $env:ARM_CLIENT_ID -p $env:ARM_CLIENT_SECRET --tenant $env:ARM_TENANT_ID; `
    az group delete -g workplace-00 --subscription $env:ARM_SUBSCRIPTION_ID -y"
```

Deploying Linux development VM

Using Windows:

```PowerShell
cd c:\projects\digital-workplace\src\linux\dev
Remove-Item .terraform.tfstate.lock.info -Recurse
Remove-Item terraform.tfstate
Remove-Item terraform.tfstate.backup
Sleep 5;
docker run --rm -v ${PWD}/..:/workplace -w /workplace/dev hashicorp/terraform:light init
docker run --rm -v ${PWD}/..:/workplace -w /workplace/dev `
    -e TF_VAR_ARM_CLIENT_ID=$env:ARM_CLIENT_ID `
    -e TF_VAR_ARM_CLIENT_SECRET=$env:ARM_CLIENT_SECRET `
    -e TF_VAR_ARM_SUBSCRIPTION_ID=$env:ARM_SUBSCRIPTION_ID `
    -e TF_VAR_ARM_TENANT_ID=$env:ARM_TENANT_ID `
    -e TF_VAR_VM_ADMIN_PASSWORD=$env:VM_ADMIN_PASSWORD `
    hashicorp/terraform:light `
    apply -auto-approve
```

Connect:
```PowerShell
ssh-keygen -R ipworkplace-01-vm-dev.westeurope.cloudapp.azure.com
ssh aleks@ipworkplace-01-vm-dev.westeurope.cloudapp.azure.com
```

Destroying Windows development VM

Using Windows:

```PowerShell
docker run --rm mcr.microsoft.com/azure-cli:2.9.1 /bin/bash -c "az login --service-principal -u $env:ARM_CLIENT_ID -p $env:ARM_CLIENT_SECRET --tenant $env:ARM_TENANT_ID; `
    az group delete -g workplace-01 --subscription $env:ARM_SUBSCRIPTION_ID -y"
```

```PowerShell
docker run --rm -v ${PWD}/..:/workplace -w /workplace/dev `
    -e TF_VAR_ARM_CLIENT_ID=$env:ARM_CLIENT_ID `
    -e TF_VAR_ARM_CLIENT_SECRET=$env:ARM_CLIENT_SECRET `
    -e TF_VAR_ARM_SUBSCRIPTION_ID=$env:ARM_SUBSCRIPTION_ID `
    -e TF_VAR_ARM_TENANT_ID=$env:ARM_TENANT_ID `
    -e TF_VAR_VM_ADMIN_PASSWORD=$env:VM_ADMIN_PASSWORD `
    hashicorp/terraform:light `
    destroy -target azurerm_virtual_machine.main -auto-approve
```


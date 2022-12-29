# Introduction

This GitHub repository implement the [Valet Key Pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/valet-key) to retrieve picture from the Azure Storage.

The SAS Token is returned using an Azure Function.

# Architecture


![architecture](https://raw.githubusercontent.com/hugogirard/valetKeyPattern/refactoring/diagram/architecture.drawio.png)

In this example the Azure Function doesn't use a private endpoint and this is for simplicity purpose.  In **production** all traffic should pass in the Application Gateway with a WAF.

The function will return you a SAS token, you will need to construct the URL to retrieve the picture.

The URL will have this format.

```
https://<FQDN>/pictures/<imagename>?<sas token>
```

1. The user requests a SAS token for a specific picture
2. One the user retrieve the SAS token it can get the picture 

# Prerequisites

First step is to Fork this repository.

Next, you will need to have a public domain name and a wildcard certificate. 

If you already own a public domain but you don't have a wild certificate here some step to create one using [Azure DNS Public Zone](https://docs.microsoft.com/en-us/azure/dns/dns-getstarted-portal).

## Generating SSL certificate with Azure DNS Public Zone (optional)

Here the tool you need to installe on your machine.

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

- [Powershell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.1)

- Install the official [Powershell](https://github.com/rmbolger/Posh-ACME) **Let's Encrypt client**

Here the [list](https://letsencrypt.org/docs/client-options/) of all supported clients if you want to implement your own logic for the **Let's Encrypt Certificate**.


## Create Azure DNS Public Zone

This demo is using Azure Public DNS Zone, you will need to have a domain that you own from any register.  Once it is done, you need to configure your DNS in your domain register with Azure DNS Public Zone entry.

It all explain [here](https://docs.microsoft.com/en-us/azure/dns/dns-getstarted-portal).


## Run the Powershell script

Be sure you already configured your **Azure Public DNS Zone**.

First create a service principal running the following command.

```Bash
$ az ad sp create-for-rbac --name <ServicePrincipalName> --sdk-auth --role contributor --scope '/subscriptions/{subscriptionId}'
```

Take note of the output you will need it to create Github Secrets.

Now go to the folder scripts, there you have a powershell called **letsEncrypt.ps1**.

This script will connect to your Azure Subscription passed in parameters and create a **TXT** challenge in your **Azure DNS Public Zone**.  

First run this command in a PowerShell terminal

```bash
$ Set-PAServer LE_PROD
```

Now with the information retrieved when you created the **service principal** you can create your certificate.

Be sure your **Service Principal** have access to modify your Azure Public DNS Zone.  If you want to use least privilege refers to this [doc](https://github.com/rmbolger/Posh-ACME/blob/main/Posh-ACME/Plugins/Azure-Readme.md#create-a-custom-role).

*Be sure the username, password and certificate password are in double quotes**

```Bash
$ .\letsEncrypt.ps1 -certNames *.contoso.com -acmeContact john@contoso.com -aZSubscriptionId <subId> -aZTenantId <tenantId> -aZAppUsername "<sp_clientId>" -aZAppPassword "<sp_password>" -pfxPassword "<pfxPassword>"
```

When the command is finished, a new folder called **pa** will be created inside the scripts folder.

If you browse in it inside the last child folder of **acme-v02.api.letsencrypt.org** you will see those files. The important file is called cert.pfx.

# Create the Azure Resources

# Create the Azure Resources

## Get the base64 encoded value of your certificate

You will need to create GitHub secrets to configure this repository.  Two of them are related to your certificate and needed when communicating with the Application Gateway.

You will need to find the base64 value of your certificate and save it in a GitHub Secret.  To do so run the following command and get the value from the text file generated.

```
$fileContentBytes = get-content 'cert.pfx' -Encoding Byte
[System.Convert]::ToBase64String($fileContentBytes) | Out-File 'pfx-bytes.txt'
```

## Create GitHub Secrets

You will need to create some [GitHub repository secrets](https://docs.github.com/en/codespaces/managing-codespaces-for-your-organization/managing-encrypted-secrets-for-your-repository-and-organization-for-codespaces#adding-secrets-for-a-repository) first.  Here the list of secrets you will need to create.

| Secret Name | Value | Link
|-------------|-------|------|
| AZURE_CREDENTIALS | The service principal credentials needed in the Github Action | [GitHub Action](https://github.com/marketplace/actions/azure-login)
| AZURE_SUBSCRIPTION | The subscription ID where the resources will be created |
| CERTIFICATE_DATA | The base64 value of your pfx certificate file |
| CERTIFICATE_PASSWORD | The password of your pfx file |
| PA_TOKEN | Needed to create GitHub repository secret within the GitHub action |  [Github Action](https://github.com/gliech/create-github-secret-action) |
| STORAGE_CUSTOM_DOMAIN | The custom domain associated to the Public IP of the Application Gateway to retrieve the storage blob.
| RESOURCE_GROUP_NAME | The name of the resource group where all resources will be created |
| LOCATION | The location where all the resources will be created

## Run Create Azure Resources GitHub Action

Now you can go to the Actions tab and Run the **Create Azure Resources** [GitHub Actions](https://docs.github.com/en/actions).
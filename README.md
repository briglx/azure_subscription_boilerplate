# Azure Subscription Boilerplate

Example project to setup a new azure subscription for development. This project demonstrates several technologies:

* Infrastructure as Code
* Infrastructure Automation
* Management and Landing Zone organization

# Getting Started

Prerequisites:
- Azure Subscription
- GitHub Account
- Azure CLI

Copy the example.env and replace the values
Clone the project

Setup GitHub Secrets

AZURE_CREDENTIALS

Install Azure CLI

```bash
# Check if installed
az --version

sudo apt-get update
sudo apt-get install ca-certificates curl apt-transport-https lsb-release gnupg
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

AZ_REPO=$(lsb_release -cs) 
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |  sudo tee /etc/apt/sources.list.d/azure-cli.list

sudo apt-get update
sudo apt-get install azure-cli

az --version
```
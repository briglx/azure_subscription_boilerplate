# Azure Subscription Boilerplate

Example project to demonstrate:

* Infrastructure as Code
* Infrastructure Automation
* Management and Landing Zone organization

## Architecture Diagram

![Network Overview](docs/networkoverview.svg "Network Overview")

## Components

### Solution

- [Azure Blob Storage](https://azure.microsoft.com/en-us/products/storage/blobs/) - Target storage account where monitoring applications saves new files.

### DevOps

- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) - Provisioning, managing and deploying the application to Azure.
- [GitHub Actions](https://github.com/features/actions) - The CI/CD pipelines.
- [Azure Developer CLI](https://learn.microsoft.com/azure/developer/azure-developer-cli/overview) - The CI/CD pipelines.

### Developer tools

- [Visual Studio Code](https://code.visualstudio.com/) - The local IDE experience.
- [Git Client](https://git-scm.com/download/win)
- [GitHub Codespaces](https://github.com/features/codespaces) - The cloud IDE experience.
- (Optional) [Docker](https://docs.docker.com/desktop/install/windows-install/) - Run the application in a container.

# Prerequisites

- Azure Subscription
- Azure CLI
- GitHub Account

## Install Azure CLI

```bash
# Check if installed
az --version

# Install azure cli
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

az login --tenant $AZURE_TENANT_ID
```

# Quick Start

Get started creating a new subscription.

* Fork or Clone this project and configure .env settings
* Create System Identities
* Configure GitHub
* Run GitHub Actions

## Clone Project

```bash
# clone project
git clone https://github.com/briglx/azure_subscription_boilerplate.git

# Navigate to Project
cd azure_subscription_boilerplate

# Open Project
code .
```

Configure the environment variables. Copy example.env to .env and update the values

```bash
# Set Secrets in .env
AZURE_TENANT_ID=ReplaceWithYourTenantId
AZURE_TENANT_NAME=ReplaceWithYourTenantName
AZURE_SUBSCRIPTION_ID=ReplaceWithYourSubscriptionId
GITHUB_ORG=ReplaceWithYourGitHubOrgOrUserName
GITHUB_REPO=RepalceWithYourRepoName

cp example.env .env
sed -i "s/<tenant_id>/$AZURE_TENANT_ID/" .env
sed -i "s/<tenant_name>/$AZURE_TENANT_NAME/" .env
sed -i "s/<subscription_id>/$AZURE_SUBSCRIPTION_ID/" .env
sed -i "s/<github_org>/$GITHUB_ORG/" .env
sed -i "s/<github_repo>/$GITHUB_REPO/" .env
```
## Create System Identities

The solution use system identities to deploy cloud resources. The following table lists the system identities and their purpose.

| System Identities           | Authentication                                             | Authorization                                                                                                                                                                  | Purpose                                                        |
| --------------------------- | ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------- |
| `env.CICD_CLIENT_NAME`      | OpenId Connect (OIDC) based Federated Identity Credentials | Subscription Contributor access<br>Microsoft Graph API admin consent Permissions: <ul><li>Directory.ReadWrite.All</li><li>User.Invite.All</li><li>User.ReadWrite.All</li></ul> | Deploy cloud resources: <ul><li>connectivity resources</li><li>Common resources</li></ul>  |

```bash
# Login to cloud cli. Only required once per install.
az login --tenant $AZURE_TENANT_ID

# Load environment variables
source ./script/common.sh
load_env .env

# Create Azure CICD system identity
./script/create_cicd_sh.sh
# Adds CICD_CLIENT_ID=$created_clientid to .env
```

## Configure GitHub

Create GitHub secrets for storing Azure configuration.

Open your GitHub repository and go to Settings. Select Secrets and then New Secret. Create secrets with values from `.env` for:

- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `CICD_CLIENT_ID`

## Provision Resources

The project uses scripts and GitHub Actions to provision resources. Each Github Action calls a specific script. The following table lists the workflows and their purpose.
| Workflow | Description |
| -------- | ----------- |
| platform_connectivity | Provision and manage connectivity resources. |
| platform_common | Provision and manage common resources. |

* Run platform_connectivity workflow to create vnets, subnets, and peering. This is equivalent to calling the following:

    ```bash
    ./script/devops.sh provision_connectivity --jumpbox
    ```
* Run platform_common workflow to create common resources. This is equivalent to calling the following:

    ```bash
    ./script/devops.sh provision_common
    ```

# Development

You'll need to set up a development environment if you want to develop a new feature or fix issues.

## Setup your dev environment

```bash
# Create and activate a python virtual environment
# virtualenv \path\to\.venv -p path\to\specific_version_python.exe
python3 -m venv .venv
source .venv/bin/activate
# deactivate
pip install -r requirements_dev.txt

# Configure linting and formatting tools
sudo apt-get update
sudo apt-get install -y shellcheck jq
pre-commit install

# login to azure cli
az login --tenant $TENANT_ID
```

## Style Guidelines

This project follows [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)

We use [ShellCheck](https://www.shellcheck.net/) to check shell scripts.

## Testing

Ideally, all code is checked to verify the following:

- All code passes the checks from the linting tools

To run the linters, run the following commands:

```bash
# Use pre-commit scripts to run all linting
pre-commit run --all-files

# Run a specific linter via pre-commit
pre-commit run --all-files shellcheck
```

# Architecture Decisions

For Infrastructure as code, we use `azure cli` to provision resources. Here are the different levels of parameters:

| Parameters | Description | Domain |
| ----- | ----------- |---------|
| UI - GitHub Action Manual Trigger | Generally very simple variables that would change for each deployment. | Human Computer Interaction |
| GitHub Action | Parameters common between deployment steps | GitActions and Deployment |
| `devops.sh` script | Single point to control all iac automation. Call specific iac deployment. | Deployment |
| `./iac/<specific>_deployment.sh` script | Defines a collection of resources to deploy together. Similar to a Master Arm template used to orchestrate a deployment. Uses `azure cli`. | Deploymnet and CLI |
| `./script/common.sh` script | Modular functions to deploy resources using `azure cli`. | Deployment and CLI |

Use `azure cli` in the `./iac/<specific>_deployment.sh` script where feasible. Fall back to `./script/common.sh` script if additional logic is required.

# References

- Use Gitub Actions to connect to Azure https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-portal%2Cwindows
- OpenID Connect Auth for GitHub https://github.com/Azure/login#configure-a-service-principal-with-a-federated-credential-to-use-oidc-based-authentication
- CAF Migration Landing Zone - https://github.com/microsoft/CloudAdoptionFramework/tree/master/ready/migration-landing-zone-governance
- Azure Security Benchmark https://learn.microsoft.com/en-us/azure/governance/blueprints/samples/azure-security-benchmark-foundation/
- Transfer Subscription https://learn.microsoft.com/en-us/azure/role-based-access-control/transfer-subscription

Bash

- Good Bash Examples https://linuxize.com/tags/bash/
- Google Bash Standard https://google.github.io/styleguide/shellguide.html
- Shell Script Linting https://www.shellcheck.net/

#!/bin/bash
#######################################################
# Connectivity RG Script
# Params
# --rg_region Resource Region. Default westus2
#######################################################
echo starting script

# Stop on errors
set -e

# Global
rg_region=${rg_region:-westus2}

# Parse params
while [ $# -gt 0 ]; do
  if [[ $1 == *"--"* ]]; then
 param="${1/--/}"
 declare $param="$2"
  fi
 shift
done

#######################################################
# Variables RG
#######################################################
rg_name=${rg_name:-rg_connectivity}_$rg_region

vnet_core_name=vnet-core-$rg_region
vnet_core_cidr='10.0.0.0/16'
vnet_core_subnet_bastion_name=AzureBastionSubnet
vnet_core_subnet_bastion_cidr='10.0.255.64/27'
vnet_core_subnet_bastion_ip_bastion_name=core_bastion_ip
vnet_core_subnet_bastion_bastion_core_name=core_bastion
vnet_core_subnet_management_name=snet-management
vnet_core_subnet_management_cidr='10.0.1.0/24'

vnet_dev_name=vnet-dev-$rg_region
vnet_dev_cidr='10.1.0.0/16'
vnet_dev_subnet_confluence_name=snet-confluence
vnet_dev_subnet_confluence_cidr='10.1.0.'

# connectivity resource group
echo creating $rg_name in $rg_region
az group create --name $rg_name --location $rg_region

# Network watcher
az network watcher configure --resource-group $rg_name --locations $rg_region

# create core vnet 
echo creating $vnet_core_name vnet in $rg_name
az network vnet create --resource-group $rg_name --name $vnet_core_name --address-prefixes $vnet_core_cidr
# core bastion subnet
az network vnet subnet create --resource-group $rg_name --name $vnet_core_subnet_bastion_name --vnet-name $vnet_core_name --address-prefixes $vnet_core_subnet_bastion_cidr
az network public-ip create --resource-group $rg_name --name $vnet_core_subnet_bastion_ip_bastion_name --sku Standard --location $rg_region
az network bastion create --resource-group $rg_name --name $vnet_core_subnet_bastion_bastion_core_name --public-ip-address $vnet_core_subnet_bastion_ip_bastion_name  --vnet-name $vnet_core_name --location $rg_region
# management subnet
az network vnet subnet create --resource-group $rg_name --name $vnet_core_subnet_management_name --vnet-name $vnet_core_name --address-prefixes $vnet_core_subnet_management_cidr

# create dev vnet 
echo creating $vnet_dev_name vnet in $rg_name
az network vnet create --resource-group $rg_name --name $vnet_dev_name --address-prefixes $vnet_dev_cidr
# confluence subnet
az network vnet subnet create --resource-group $rg_name --name $vnet_dev_subnet_confluence_name --vnet-name $vnet_dev_name --address-prefixes $vnet_dev_subnet_confluence_cidr

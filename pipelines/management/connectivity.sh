#!/bin/bash
#######################################################
# Connectivity RG Script
# Params
# --rg_region Resource Region. Default westus3
#######################################################
echo starting script

# Stop on errors
set -e

# Global
prefix=''
rg_region=${rg_region:-westus3}

# Parse params
while [ $# -gt 0 ]; do
  if [[ $1 == *"--"* ]]; then
 param="${1/--/}"
 declare $param="$2"
  fi
 shift
done

# Add Dev prefix
if [ $target_env == "dev" ]; then
  prefix="DEV_"
fi

#######################################################
# Variables RG
#######################################################
rg_name=$prefix${rg_name:-rg_connectivity}$rg_region

vnet_core_name=vnet-hub-core-$rg_region
vnet_core_cidr='10.0.0.0/16'
vnet_core_subnet_bastion_name=AzureBastionSubnet
vnet_core_subnet_bastion_cidr='10.0.255.64/27'
vnet_core_subnet_bastion_ip_bastion_name=core_bastion_ip
vnet_core_subnet_bastion_bastion_core_name=core_bastion
vnet_core_subnet_jump_box_name=snet-jumpbox
vnet_core_subnet_jump_box_cidr='10.0.0.0/29'
vnet_core_subnet_firewall_name=snet-firewall
vnet_core_subnet_firewall_cidr='10.0.0.8/29'
vnet_core_subnet_management_name=snet-management
vnet_core_subnet_management_cidr='10.0.0.64/26'

vnet_dev_name=vnet-dev-$rg_region
vnet_dev_cidr='10.1.0.0/16'
vnet_dev_subnet_confluence_name=snet-confluence
vnet_dev_subnet_confluence_cidr='10.1.0.0/27'

# connectivity resource group
echo creating $rg_name in $rg_region
az group create --name $rg_name --location $rg_region

# Network watcher
echo creating network watcher in $rg_name
az network watcher configure --resource-group $rg_name --locations $rg_region --enabled

# create core vnet 
echo creating $vnet_core_name vnet in $rg_name
az network vnet create --resource-group $rg_name --name $vnet_core_name --address-prefixes $vnet_core_cidr
# core bastion subnet
echo creating subnet $vnet_core_subnet_bastion_name
az network vnet subnet create --resource-group $rg_name --name $vnet_core_subnet_bastion_name --vnet-name $vnet_core_name --address-prefixes $vnet_core_subnet_bastion_cidr
az network public-ip create --resource-group $rg_name --name $vnet_core_subnet_bastion_ip_bastion_name --sku Standard --location $rg_region --zone 1 2 3
az network bastion create --resource-group $rg_name --name $vnet_core_subnet_bastion_bastion_core_name --public-ip-address $vnet_core_subnet_bastion_ip_bastion_name  --vnet-name $vnet_core_name --location $rg_region
# jumpbox subnet
echo creating subnet $vnet_core_subnet_jump_box_name
az network vnet subnet create --resource-group $rg_name --name $vnet_core_subnet_jump_box_name --vnet-name $vnet_core_name --address-prefixes $vnet_core_subnet_jump_box_cidr
# management subnet
echo creating subnet $vnet_core_subnet_management_name
az network vnet subnet create --resource-group $rg_name --name $vnet_core_subnet_management_name --vnet-name $vnet_core_name --address-prefixes $vnet_core_subnet_management_cidr

# create dev vnet 
echo creating $vnet_dev_name vnet in $rg_name
az network vnet create --resource-group $rg_name --name $vnet_dev_name --address-prefixes $vnet_dev_cidr
# confluence subnet
echo creating subnet $vnet_dev_subnet_confluence_name
az network vnet subnet create --resource-group $rg_name --name $vnet_dev_subnet_confluence_name --vnet-name $vnet_dev_name --address-prefixes $vnet_dev_subnet_confluence_cidr

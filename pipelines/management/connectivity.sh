#!/bin/bash
#######################################################
# Connectivity RG Sctip
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

rg_name=${rg_name:-rg_connectivity}_$rg_region

#######################################################
# Connectivity RG
#######################################################

# create resource group
echo creating $rg_name in $rg_region
az group create --name $rg_name --location $rg_region

# create domain vnet
vnet_name=vnet-domain-$rg_region
echo creating $vnet_name vnet in $rg_name
vnet_prefix='10.0.0.0/16'
az network vnet create --resource-group $rg_name --name $vnet_name --address-prefixes $vnet_prefix

# domain bastion subnet
subnet_name=AzureBastionSubnet
subnet_prefix='10.0.255.64/27'
ip_name=domain_bastion_ip
bastion_name=domain_bastion
az network vnet subnet create --resource-group $rg_name --name $subnet_name --vnet-name $vnet_name --address-prefixes $subnet_prefix
az network public-ip create --resource-group $rg_name --name $ip_name --sku Standard --location $rg_region
az network bastion create --resource-group $rg_name --name $bastion_name --public-ip-address $ip_name  --vnet-name $vnet_name --location $rg_region

# azure ad domain services subnet
subnet_name=snet-add-ds
subnet_prefix='10.0.255.0/27'
az network vnet subnet create --resource-group $rg_name --name $subnet_name --vnet-name $vnet_name --address-prefixes $subnet_prefix

# create development vnet 
vnet_name=vnet-dev-$rg_region
echo creating $vnet_name vnet in $rg_name
vnet_prefix='10.1.0.0/16'
az network vnet create --resource-group $rg_name --name $vnet_name --address-prefixes $vnet_prefix

# dev bastion subnet
subnet_name=AzureBastionSubnet
subnet_prefix='10.1.255.64/27'
ip_name=dev_bastion_ip
bastion_name=dev_bastion
az network vnet subnet create --resource-group $rg_name --name $subnet_name --vnet-name $vnet_name --address-prefixes $subnet_prefix
az network public-ip create --resource-group $rg_name --name $ip_name --sku Standard --location $rg_region
az network bastion create --resource-group $rg_name --name $bastion_name --public-ip-address $ip_name  --vnet-name $vnet_name --location $rg_region

# dev subnet
subnet_name=snet-dev
subnet_prefix='10.1.1.0/24'
az network vnet subnet create --resource-group $rg_name --name $subnet_name --vnet-name $vnet_name --address-prefixes $subnet_prefix







# # Create NSG for subnets
# echo creating nsg for subnets
# nsg_name=dev-nsg
# az network nsg create --name $nsg_name --resource-group $rg_name
# az network vnet subnet update -g $rg_name -n $subnet_name --vnet-name $vnet_name --network-security-group $nsg_name

# function create_vnet() {
#      local rg_name=${1}
#      local vnet_name=${2}
#      local vnet_prefix=${3}

#      echo creating $vnet_name vnet in $rg_name
#      # vnet_name=vnet-dev-$rg_region
#      # vnet_prefix='10.1.0.0/16'
#      az network vnet create -g $rg_name -n $vnet_name --address-prefixes $vnet_prefix



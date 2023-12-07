# shellcheck shell=bash
# Functions to provision connectivity infrastructure
create_core_vnet(){
  local name="$1"
  local rg_name="$2"
  # local $location="$3"

  # vnet_core_name=vnet-hub-core-$rg_region
  vnet_core_cidr='10.0.0.0/16'
  # vnet_core_subnet_bastion_name=AzureBastionSubnet
  # vnet_core_subnet_bastion_cidr='10.0.255.64/27'
  # vnet_core_subnet_bastion_ip_bastion_name=core_bastion_ip
  # vnet_core_subnet_bastion_bastion_core_name=core_bastion
  # vnet_core_subnet_jump_box_name=snet-jumpbox
  # vnet_core_subnet_jump_box_cidr='10.0.0.0/29'
  # # vnet_core_subnet_firewall_name=snet-firewall
  # # vnet_core_subnet_firewall_cidr='10.0.0.8/29'
  # vnet_core_subnet_management_name=snet-management
  # vnet_core_subnet_management_cidr='10.0.0.64/26'

  create_vnet "$name" "$rg_name" "$vnet_core_cidr"

  # # create vnet
  # echo creating "$vnet_core_name" vnet in "$rg_name"
  # az network vnet create --resource-group "$rg_name" --name "$vnet_core_name" --address-prefixes "$vnet_core_cidr"

  # # core bastion subnet
  # echo "creating subnet $vnet_core_subnet_bastion_name"
  # az network vnet subnet create --resource-group "$rg_name" --name "$vnet_core_subnet_bastion_name" --vnet-name "$vnet_core_name" --address-prefixes "$vnet_core_subnet_bastion_cidr"
  # az network public-ip create --resource-group "$rg_name" --name "$vnet_core_subnet_bastion_ip_bastion_name" --sku Standard --location "$rg_region" --zone 1 2 3
  # az network bastion create --resource-group "$rg_name" --name "$vnet_core_subnet_bastion_bastion_core_name" --public-ip-address "$vnet_core_subnet_bastion_ip_bastion_name"  --vnet-name "$vnet_core_name" --location "$rg_region"
  # # jumpbox subnet
  # echo "creating subnet $vnet_core_subnet_jump_box_name"
  # az network vnet subnet create --resource-group "$rg_name" --name "$vnet_core_subnet_jump_box_name" --vnet-name "$vnet_core_name" --address-prefixes "$vnet_core_subnet_jump_box_cidr"
  # # management subnet
  # echo "creating subnet $vnet_core_subnet_management_name"
  # az network vnet subnet create --resource-group "$rg_name" --name "$vnet_core_subnet_management_name" --vnet-name "$vnet_core_name" --address-prefixes "$vnet_core_subnet_management_cidr"
}

# # Global
# PROJ_ROOT_PATH=$(cd "$(dirname "$0")"/..; pwd)
# echo "Project root: $PROJ_ROOT_PATH"
# SCRIPT_DIRECTORY="${PROJ_ROOT_PATH}/script"

# # shellcheck source=common.sh
# source "${SCRIPT_DIRECTORY}/common.sh"

#######################################################
# Variables RG
#######################################################

provision_connectivity(){
  # Default values
  app_name="core"
  location="westus3"
  # environment="prod"

  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --parameters)
          shift
          # Assume it's key-value pairs passed directly
          while [ -n "$1" ] && [ "${1:0:1}" != "-" ]; do
              key="${1%%=*}"
              value="${1#*=}"
              local "$key=$value"
              shift
          done
          ;;
      *)
          echo "Unknown option: $1"
          exit 1
          ;;
    esac
  done

  # variables
  rg_name="rg_${app_name}_${location}"
  vnet_core_name="vnet-${app_name}-${location}"

  # connectivity resources
  create_resource_group "$rg_name" "$location"
  create_core_vnet "$vnet_core_name" "$rg_name"

}

# provision_connectivity --parameters location=westus3

# # connectivity resource group
# echo "creating $rg_name in $rg_region"
# az group create --name "$rg_name" --location "$rg_region"

# # Network watcher
# echo "creating network watcher in $rg_name"
# az network watcher configure --resource-group "$rg_name" --locations "$rg_region" --enabled

# # create core vnet
# echo creating "$vnet_core_name" vnet in "$rg_name"
# az network vnet create --resource-group "$rg_name" --name "$vnet_core_name" --address-prefixes "$vnet_core_cidr"
# # core bastion subnet
# echo "creating subnet $vnet_core_subnet_bastion_name"
# az network vnet subnet create --resource-group "$rg_name" --name "$vnet_core_subnet_bastion_name" --vnet-name "$vnet_core_name" --address-prefixes "$vnet_core_subnet_bastion_cidr"
# az network public-ip create --resource-group "$rg_name" --name "$vnet_core_subnet_bastion_ip_bastion_name" --sku Standard --location "$rg_region" --zone 1 2 3
# az network bastion create --resource-group "$rg_name" --name "$vnet_core_subnet_bastion_bastion_core_name" --public-ip-address "$vnet_core_subnet_bastion_ip_bastion_name"  --vnet-name "$vnet_core_name" --location "$rg_region"
# # jumpbox subnet
# echo "creating subnet $vnet_core_subnet_jump_box_name"
# az network vnet subnet create --resource-group "$rg_name" --name "$vnet_core_subnet_jump_box_name" --vnet-name "$vnet_core_name" --address-prefixes "$vnet_core_subnet_jump_box_cidr"
# # management subnet
# echo "creating subnet $vnet_core_subnet_management_name"
# az network vnet subnet create --resource-group "$rg_name" --name "$vnet_core_subnet_management_name" --vnet-name "$vnet_core_name" --address-prefixes "$vnet_core_subnet_management_cidr"

# # create dev vnet
# echo "creating $vnet_dev_name vnet in $rg_name"
# az network vnet create --resource-group "$rg_name" --name "$vnet_dev_name" --address-prefixes "$vnet_dev_cidr"
# # confluence subnet
# echo "creating subnet $vnet_dev_subnet_confluence_name"
# az network vnet subnet create --resource-group "$rg_name" --name "$vnet_dev_subnet_confluence_name" --vnet-name "$vnet_dev_name" --address-prefixes "$vnet_dev_subnet_confluence_cidr"

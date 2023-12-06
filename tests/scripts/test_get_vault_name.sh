#!/bin/bash

PROJ_ROOT_PATH=$(cd "$(dirname "$0")"/../../ || exit; pwd)
TARGET_SCRIPT="$PROJ_ROOT_PATH/pipelines/management/get_vault_name.sh"

# Test No Args
echo "Test ./script No Args"
$TARGET_SCRIPT
echo

# Test -e arg
echo "Test ./script -e dev "
$TARGET_SCRIPT -e dev
echo

# Test -e missing arg
echo "Test ./script -e missing arg "
$TARGET_SCRIPT -e
echo

# Test -r arg
echo "Test ./script -r arg "
$TARGET_SCRIPT -r eastus
echo

# Test invalid arg
echo "Test ./script -x invalid arg "
$TARGET_SCRIPT -x
echo


# Test valid -e -r arg
echo "Test valid ./script -e dev -r eastus"
$TARGET_SCRIPT -e dev -r eastus
echo

# Test valid -e -r arg
echo "Test valid ./script -e prod -r eastus"
$TARGET_SCRIPT -e prod -r eastus
echo

# Test dev option -d
echo "Test dev option ./script -d"
$TARGET_SCRIPT -d
echo

# Test valid dev -e -r
echo "Test dev option ./script -e dev -r westus3"
$TARGET_SCRIPT -e dev -r westus3
echo

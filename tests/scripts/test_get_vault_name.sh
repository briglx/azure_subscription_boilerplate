#!/bin/bash

EXEC_DIR="$(pwd)"
PATH_TO_PROJECT="../../"
PROJ_PATH="$(cd $PATH_TO_PROJECT;pwd)"
TEST_DIR="$PROJ_PATH/tests"

TARGET_SCRIPT="$PROJ_PATH/pipelines/management/get_vault_name.sh"

# Test No Args
echo "Test ./script No Args"
echo "$($TARGET_SCRIPT)"
echo

# Test -e arg 
echo "Test ./script -e dev "
echo "$($TARGET_SCRIPT -e dev)"
echo

# Test -e missing arg 
echo "Test ./script -e missing arg "
echo "$($TARGET_SCRIPT -e)"
echo

# Test -r arg 
echo "Test ./script -r arg "
echo "$($TARGET_SCRIPT -r eastus)"
echo

# Test invalid arg 
echo "Test ./script -x invalid arg "
echo "$($TARGET_SCRIPT -x)"
echo


# Test valid -e -r arg 
echo "Test valid ./script -e dev -r eastus"
echo "$($TARGET_SCRIPT -e dev -r eastus)"
echo

# Test valid -e -r arg 
echo "Test valid ./script -e prod -r eastus"
echo "$($TARGET_SCRIPT -e prod -r eastus)"
echo

# Test dev option -d 
echo "Test dev option ./script -d"
echo "$($TARGET_SCRIPT -d)"
echo

# Test valid dev -e -r 
echo "Test dev option ./script -e dev -r westus3"
echo "$($TARGET_SCRIPT -e dev -r westus3)"
echo
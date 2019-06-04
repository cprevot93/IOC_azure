#!/bin/bash
set -euxo pipefail

# Function app and storage account names must be unique.
location=westeurope
groupName=cprevot-test-${location}
storageName=${groupName}-storageaccount-${RANDOM}
functionAppName=${groupName}-${RANDOM}

# Create a resource resourceGroupName
az group create \
  --name "${groupName}" \
  --location "${location}"

# Create an azure storage account
az storage account create \
  --name "${storageName}" \
  --location "${location}" \
  --resource-group "${groupName}" \
  --sku Standard_LRS

# Create an App Service plan
az appservice plan create \
  --name myappserviceplan \
  --resource-group "${groupName}" \
  --location ${location}

# Create a Function App
az functionapp create \
  --name ${functionAppName} \
  --storage-account ${storageName} \
  --plan myappserviceplan \
  --resource-group ${groupName}
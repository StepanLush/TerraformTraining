#!/bin/bash

az group create --name state-rg --location 'West Europe'

az storage account create \
  --resource-group state-rg \
  --name ur6urur \
  --sku Standard_LRS \
  --encryption-services blob


  az storage container create \
  --name stagecontainer \
  --account-name ur6urur
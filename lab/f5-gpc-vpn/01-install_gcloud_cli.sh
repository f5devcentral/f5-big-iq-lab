#!/bin/bash
# Uncomment set command below for code debuging bash
#set -x

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color


if [ ! -f /snap/bin/gcloud ]; then
  echo -e "\n${GREEN}Installation Google Cloud CLI${NC}"
  sudo snap install google-cloud-sdk  --classic
fi

# To authorize without a web browser and non-interactively, create a service account with the appropriate scopes using the Google Cloud Platform Console 
# and use gcloud auth activate-service-account with the corresponding JSON key file.
gcloud auth activate-service-account --key-file=google-cred.json

gcloud config list

gcloud projects create example-foo-bar-1 --name="Happy project" --labels=type=happy

echo -e "\n${GREEN}Set Cloud Name to ${BLUE} $AZURE_CLOUD ${NC}"
az cloud set --name $AZURE_CLOUD

echo -e "\n${GREEN}Login${NC}"
if [[ $USE_TOKEN == 1 ]]; then
  az login
else
  az login --service-principal -u $CLIENT_ID --password $SERVICE_PRINCIPAL_SECRET --tenant $TENANT_ID
  az account set --subscription $SUBSCRIPTION_ID
  az role assignment list --assignee $CLIENT_ID --output table
fi

#az account show
echo -e "\n${GREEN}Account list${NC}"
az account list --all --output table

#echo -e "\n${GREEN}Account Location${NC}"
#az account list-locations --output table

exit 0

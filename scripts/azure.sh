#!/bin/bash
set -euxo pipefail

# create a resource group to hold everything in this demo
resourceGroup="wordpressappservice"
location="westeurope"
# we need a unique name for the servwer
mysqlServerName="mysql-xyz123"
adminUser="wpadmin"
adminPassword="P@ssw0rd123"
# create an app service plan to host our web app
planName="wordpressappservice"
appName="wordpress-1247"

verbose=0
output_file=""

create_app() {
  az group create --location "${location}" --name "${resourceGroup}"
  az appservice plan create -n "${planName}" \
    --resource-group "${resourceGroup}" \
    --location "${location}" \
    --is-linux --sku S1

  az mysql server create --resource-group "${resourceGroup}" \
    --name "${mysqlServerName}" \
    --admin-user "${adminUser}" --admin-password "${adminPassword}" \
    --location "${location}" --ssl-enforcement Disabled \
    --version 5.7 --sku-name B_Gen5_1

  # open the firewall (use 0.0.0.0 to allow all Azure traffic for now)
  az mysql server firewall-rule create --resource-group "${resourceGroup}" \
    --server "${mysqlServerName}" --name AllowAppService \
    --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0

  az webapp create --name "${appName}" --resource-group "${resourceGroup}" \
    --plan "${planName}" -i "wordpress"


  # get hold of the wordpress DB host name
  wordpressDbHost=$(az mysql server show --resource-group "${resourceGroup}" \
    --name "${mysqlServerName}" --query "fullyQualifiedDomainName" -o tsv)

  # configure web app settings (container environment # variables)
  az webapp config appsettings set --name "${appName}" --resource-group "${resourceGroup}" \
    --settings WORDPRESS_DB_HOST="${wordpressDbHost}" \
    WORDPRESS_DB_USER="${adminUser}"@"${mysqlServerName}" \
    WORDPRESS_DB_PASSWORD="${adminPassword}"

  site=$(az webapp show --name "${appName}" --resource-group "${resourceGroup}" \
    --query "defaultHostName" -o tsv)

  Start-Process https://"${site}"
}

cleanup() {
  echo "Deleting resource group: ${resourceGroup}..."
  az group delete --name "${resourceGroup}" --yes
  echo "Done"
}

usage() {
  echo "usage: $(basename ${0})"
}

while getopts "h?vcsf:" opt; do
  case "${opt}" in
    h|\?)
      usage
      exit 0
      ;;
    v)  verbose=1
      ;;
    f)  output_file=${OPTARG}
      ;;
    c)  cleanup
      ;;
    s)  create_app
      ;;
  esac
done
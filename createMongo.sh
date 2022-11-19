resourceGroup="rg-<yourname>-az-usw3-sbx-001"                 # Please update to your resouce group  eg. rg-paitoon-az-usw3-sbx-001
vnetName="vnet-<yourname>-az-usw3-sbx-001"                    # Please update to your vnet eg. vnet-paitoon-az-usw3-sbx-001
subnetName="snet-<yourname>PrivateEndpoint-az-usw3-sbx-001"   # Please update to subnet (PriateEndpoint) eg. snet-paitoonPrivateEndpoint-az-usw3-sbx-001

account="mongo-${LOGNAME}-az-usw3-sbx-001"
privateEndpointName="pe-${LOGNAME}Mongo-az-usw3-sbx-001"
privateConnectionName="pcon-${LOGNAME}Mongo-az-usw3-sbx-001"

location="West US 3"
databaseDev="dev-tutorial"
databaseProd="tutorial"
serverVersion="4.2"
cosmosDbSubResourceType="MongoDB"

# set subscription
az account set --subscription sub-POC-CDC-az-sb

echo "1. Creating $account"
az cosmosdb create --name $account \
    --resource-group $resourceGroup \
    --kind MongoDB \
    --server-version $serverVersion \
    --default-consistency-level Eventual \
    --enable-automatic-failover false \
    --locations regionName="$location" \
    --enable-automatic-failover false \
    --backup-redundancy Local \
    --backup-policy-type Periodic \
    --enable-public-network false

# create dev database
echo "2. Creating dev database $databaseDev" 
az cosmosdb mongodb database create --account-name $account --resource-group $resourceGroup --name $databaseDev

# create prod database 
echo "3. Creating prod database $databaseProd" 
az cosmosdb mongodb database create --account-name $account --resource-group $resourceGroup --name $databaseProd

# create private endpoint
echo "4. Creating Private Endpoint" 
az network private-endpoint create \
    --name $privateEndpointName \
    --resource-group $resourceGroup \
    --vnet-name $vnetName  \
    --subnet $subnetName \
    --private-connection-resource-id "/subscriptions/85f39032-bdd3-4533-9f29-ecc20894ad02/resourceGroups/$resourceGroup/providers/Microsoft.DocumentDB/databaseAccounts/$account" \
    --group-id $cosmosDbSubResourceType \
    --connection-name $privateConnectionName

# create dns configuration
echo "5. Creating DNS configuration" 
az network private-endpoint dns-zone-group create \
   --resource-group $resourceGroup \
   --endpoint-name $privateEndpointName \
   --name privatelink_mongo_cosmos_azure_com \
   --private-dns-zone "/subscriptions/85f39032-bdd3-4533-9f29-ecc20894ad02/resourceGroups/rg-azure101hub-az-usw3-sbx-001/providers/Microsoft.Network/privateDnsZones/privatelink.mongo.cosmos.azure.com" \
   --zone-name default

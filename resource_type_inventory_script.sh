#!/bin/bash
# written by Kyle Butler WW Prisma Cloud Channel Solutions Architect

# REQUIREMENTS:
#   jq needs to be installed: 
#   debian/ubuntu: sudo apt install jq
#   rhel/fedora: sudo yum install jq
#   macos: sudo brew install jq


# Recommendations for hardening are: store variables in a secret manager of choice or export the access_keys/secret_key as env variables in a separate script. 
# Decision here is to use environment variables to simplify the workflow and mitigate risk of including credentials in the script.

# Access key should be created in the Prisma Cloud Enterprise Edition Console under: Settings > Accesskeys
# Example of a better way: APIURL=$(vault kv get -format=json <secret/path> | jq -r '.<resources>')


# INSTRUCTIONS:
# install requirement jq
# export the environment variables in shell with the below commands sans the '#'
# COMMANDS:
#   export ACCESSKEY="<ACCESS_KEY_FROM_CONSOLE_HERE>"
#   export SECRETKEY="<SECRET_KEY_FROM_CONSOLE_HERE>"
#   export APIURL="<PRISMA_API_URL_HERE"
#   bash ./resource_type_inventory_script.sh

# No edits needed below this line

##########################
### SCRIPT BEGINS HERE ###
##########################

ACCESSKEY=$ACCESSKEY

SECRETKEY=$SECRETKEY

APIURL=$APIURL


REQUESTBODYSINGLE="
{
 'username':'${ACCESSKEY}', 
 'password':'${SECRETKEY}'
}"

REQUESTBODY="${REQUESTBODYSINGLE//\'/\"}"


AUTHTOKEN=$(curl -s --request POST \
                       --url "${APIURL}/login" \
                       --header 'Accept: application/json; charset=UTF-8' \
                       --header 'Content-Type: application/json; charset=UTF-8' \
                       --data "${REQUESTBODY}" | jq -r '.token')

REPORTDATE=$(date  +%m_%d_%y)
RESPONSEDATA=$(curl --request GET \
     --url "${APIURL}/v2/inventory?timeType=relative&timeAmount=12&timeUnit=month&groupBy=resource.type&scan.status=all" \
     --header "x-redlock-auth: ${AUTHTOKEN}")
     
RESPONSEJSON=$(printf %s ${RESPONSEDATA} | jq '[.groupedAggregates[]]' | jq 'group_by(.cloudTypeName)[] | {(.[0].cloudTypeName): [.[] | {resourceTypeName: .resourceTypeName, totalResources: .totalResources}]}' )
                                                             
echo -e "aws" >> pcee_asset_inventory_${REPORTDATE}.csv 2>/dev/null                                                            
printf %s "${RESPONSEJSON}" | jq -r '.aws' | jq -r 'map({resourceTypeName,totalResources}) | (first | keys_unsorted) as $keys | map([to_entries[] | .value]) as $rows | $keys,$rows[] | @csv' >> pcee_asset_inventory_${REPORTDATE}.csv 2>/dev/null

echo -e "\nazure \n" >> pcee_asset_inventory_${REPORTDATE}.csv 2>/dev/null                                                            
printf %s "${RESPONSEJSON}" | jq -r '.azure' | jq -r 'map({resourceTypeName,totalResources}) | (first | keys_unsorted) as $keys | map([to_entries[] | .value]) as $rows | $keys,$rows[] | @csv' >> pcee_asset_inventory_${REPORTDATE}.csv 2>/dev/null

echo -e "\naws\n" >> pcee_asset_inventory_${REPORTDATE}.csv 2>/dev/null                                                            
printf %s "${RESPONSEJSON}" | jq -r '.gcp' | jq -r 'map({resourceTypeName,totalResources}) | (first | keys_unsorted) as $keys | map([to_entries[] | .value]) as $rows | $keys,$rows[] | @csv' >> pcee_asset_inventory_${REPORTDATE}.csv 2>/dev/null

#!/bin/bash

if [[ "$#" -ne 5 ]]; then
    echo "Must include args for CLIENT_ID, USERNAME, INSTANCE_URL, and SFDX_ALIAS"
    exit 1
fi

CLIENT_ID=$1
USERNAME=$2
INSTANCE_URL=$3
SFDX_ALIAS=$4
SERVER_KEY=$5

echo "${SERVER_KEY}" > server.key

sfdx force:auth:jwt:grant --clientid ${CLIENT_ID} -f ./server.key --username ${USERNAME} --instanceurl ${INSTANCE_URL} --setalias ${SFDX_ALIAS} --setdefaultusername
if [[ "$?" -ne 0 ]]; then
    echo "Authorize Org failed"
    exit 1
fi

ORG_DETAILS=$(echo "$(sfdx force:org:display --json)")
ACCESS_TOKEN=$(echo ${ORG_DETAILS} | jq -r .result.accessToken)
INSTANCE_URL=$(echo ${ORG_DETAILS} | jq -r .result.instanceUrl)
if [[ $? -ne 0 ]]; then
    echo "Failed to get accessToken"
    exit 1
fi
echo "::set-output name=accesstoken::${ACCESS_TOKEN}"
echo "::set-output name=instanceurl::${INSTANCE_URL}"
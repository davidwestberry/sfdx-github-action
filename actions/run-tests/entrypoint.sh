#!/bin/bash

if [[ "$#" -ne 2 ]]; then
    echo "Must include args for access token and instance Url"
    exit 1
fi

ACCESS_TOKEN=$1
INSTANCE_URL=$2

echo "ACCESS_TOKEN=${ACCESS_TOKEN}"
echo "INSTANCE_URL=${INSTANCE_URL}"

sfdx force:config:set --global instanceUrl=${INSTANCE_URL}

RESULT=$(sfdx force:apex:test:run -c --testlevel RunLocalTests --json -r human -w 15 -u ${ACCESS_TOKEN})

OUTCOME=$(echo ${RESULT} | jq -r .result.summary.outcome)

if [[ ${OUTCOME} -eq "Failed" ]]; then
    echo "Test failures were reported"
    FAILURES=$(echo ${OUTCOME} | jq -r '[.result.tests[] | select(.Outcome == "CompileFail" or .Outcome == "Fail") | {"test": .FullName, "stackTrace": .StackTrace, "message": .Message}]')
    for FAIL in ${FAILURES}; do
        echo "${FAIL} | jq -r '.test' \t\t\t\t ${FAIL} | jq -r '.message'"
    done
    exit 1
fi
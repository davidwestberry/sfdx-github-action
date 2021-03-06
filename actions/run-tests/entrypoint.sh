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

RESULT=$(sfdx force:apex:test:run -c --testlevel RunLocalTests --json -r json -w 15 -u ${ACCESS_TOKEN})

OUTCOME=$(echo ${RESULT} | jq -r '.result.summary.outcome')
echo "OUTCOME=${OUTCOME}"

if [[ "${OUTCOME}" == "Failed" ]]; then
    echo "Test failures were reported"
    #echo "${RESULT}"
    echo "${RESULT}" | jq -r '.result.summary'
    FAILURES=$(echo "${RESULT}" | jq -r '[.result.tests[] | select(.Outcome == "CompileFail" or .Outcome == "Fail") | {"test": .FullName, "stackTrace": .StackTrace, "message": .Message}]')
    echo ${FAILURES} | jq -r '.[] | [.test, .message] | @csv' | awk -v FS="," 'BEGIN{print "Test\t\t\tMessage";print"============================"}{printf "%s\t\t\t%s%s",$1,$2,ORS}'
    exit 1
else
    echo "Tests Passed"
    echo "${RESULT}" | jq -r '.result.summary'
    exit 0
fi

#!/bin/bash
# Uncomment set command below for code debugging bash
#set -x

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

env="udf"
user="f5student"
bigiq="10.1.1.4"
bigiq_user="admin"
bigiq_password="purple123"

echo -e "\n------ Export Transactions (Request/Response) to CSV file ------\n"

# Usage
echo -e "Usage: ${RED} $0 <virtual> <from> <to> <duration>${NC}\n"
echo -e "Example: $0 /conference/site41waf/serviceMain -1m now 30\n"

if [[ -z $1 ]]; then
    virtual="/conference/site41waf/serviceMain"
else
    virtual=$1
fi

# If no from/to/duration not specified, set default values
if [[ -z $2 ]]; then
    from="-1m"
    to="now"
    duration="30" # in SECONDS
else
    from="$2"
    to="$3"
    duration="$4" # in SECONDS
fi

echo -e "Environement:${RED} $env ${NC}"

# BIG-IQ must be configured for basic auth, in the console run `set-basic-auth on`

body="{
    \"kind\": \"ap:query:stats:byTime\",
    \"source\": \"bigip\",
    \"module\": \"http\",
    \"timeRange\": {
      \"from\": \"$from\",
        \"to\": \"$to\"
    },
    \"timeGranularity\": {
        \"duration\": $duration,
        \"unit\": \"SECONDS\"
    },
    \"aggregations\": {
        \"transactions\$avg-count-per-sec\": {
            \"metricSet\": \"transactions\",
            \"metric\": \"avg-count-per-sec\"
        },
        \"transaction-request-size\$avg-value-per-sec\": {
            \"metricSet\": \"transaction-request-size\",
            \"metric\": \"avg-value-per-sec\"
        },
        \"transaction-response-size\$avg-value-per-sec\": {
            \"metricSet\": \"transaction-response-size\",
            \"metric\": \"avg-value-per-sec\"
        }
    },
    \"dimensionFilter\": {
        \"type\": \"and\",
        \"args\": [
            {
                \"type\": \"eq\",
                \"dimension\": \"virtual\",
                \"value\": \"$virtual\"
            }
        ]
    }
}"

cd /home/$user/f5-demo-bigiq-analytics-export-restapi
# Get the analytics data in JSON
curl --silent --output input.json -k \
    -H "Accept: application/json" \
    -H "Content-Type:application/json" \
    -X POST --data "$body" "https://$bigiq_user:$bigiq_password@$bigiq/mgmt/ap/query/v1/tenants/default/products/local-traffic/metric-query"


# Send the Json over to splunk HTTP Event Collector
# https://answers.splunk.com/answers/311286/parsing-json-fields-from-log-files-and-create-dash.html
if [ -s input.json ]; then
    # wrap BIG-IQ JSON into Splunk format
    sed -i '1i{"event":' input.json
    echo '}' >> input.json
    cat input.json | jq . > input2.json
    token=$(cat /home/$user/splunk-token)
    # using token created in splunk in the update_git.sh, send the data to collector
    curl --silent -k \
        -H "Authorization: Splunk $token" \
        -H "Content-Type: application/json" \
        -X POST \
        -d "$(cat input2.json)" https://localhost:8088/services/collector
else
    echo -e "\n${RED}Something went wrong, input.json file empty.${NC}\n"
fi
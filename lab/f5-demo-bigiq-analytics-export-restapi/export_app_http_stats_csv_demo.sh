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
if [[ -z $1 ]]; then
    echo -e "Usage: ${RED} $0 <virtual> <from> <to> <duration> <udf/sjc/sjc2>${NC}\n"
    echo -e "Example: $0 /conference/site41waf/serviceMain -P1H now 30\n"
    exit 1;
fi

virtual=$1

# If no from/to/duration not specified, set default values
if [[ -z $2 ]]; then
    from="-P1H"
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

# Get the analytics data in JSON
curl --silent --output tmp.json -k \
    -H "Accept: application/json" \
    -H "Content-Type:application/json" \
    -X POST --data "$body" "https://$bigiq_user:$bigiq_password@$bigiq/mgmt/ap/query/v1/tenants/default/products/local-traffic/metric-query"

cat tmp.json | jq .result > input.json
rm tmp.json

# Install json2csv tool
if [ ! -d "json2csv" ]; then
    git clone https://github.com/evidens/json2csv.git
    sudo pip install -r json2csv/requirements.txt
fi

# Install csv tool
if [ ! -f "/usr/bin/csvtool" ]; then
    sudo apt-get install csvtool
fi

# Convert JSON to CSV (if file not empty)
if [ -s input.json ]; then
    cd json2csv
    python json2csv.py ../input.json ../outline.json -o ../output.csv > /dev/null 2>&1
    cd ..
    echo
    # Display CSV
    csvtool readable output.csv
else
    echo -e "\n${RED}Something went wrong, input.json file empty.${NC}\n"
fi
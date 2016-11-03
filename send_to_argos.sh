#!/bin/sh
# Script to send alerts from Splunk to Argos API
#=========================================
# created by tchristenson, 9/9/16
# last modified 9/12/16
#=========================================
## NonProd Endpoint
# Internal (within IHP): opsalerts-qal.api.intuit.net
# External (AWS): opsalerts-qal.api.intuit.com
endpoint_server="opsalerts-qal.api.intuit.com"

## Prod Endpoint
# Internal (within IHP): opsalerts.api.intuit.net
# External (AWS): opsalerts.api.intuit.com
# endpoint_server="opsalerts.api.intuit.com"

## Authentication Key
key="CHANGEME"

# Internal Vars
epoch_date=`date +%s`
splunk_server=`uname -n`

# Setting the payload
# Variables available:  See http://docs.splunk.com/Documentation/Splunk/6.4.3/Alert/Configuringscriptedalerts
#==============================================
# Arg   Value
# 0     Script name
# 1     Number of events returned
# 2     Search terms
# 3     Fully qualified query string
# 4     Name of report
# 5     Trigger reason. For example, "The number of events was greater than 1."
# 6     Browser URL to view the report.
# 7     Not used for historical reasons.
# 8     File in which the results for the search are stored.Contains raw results in gzip file format.
#==============================================
# Optional Field examples:
#    "application_name": "Mint Bills",

searchTerms=`printf %s "$2" | sed 's/\"//g'`
searchQuery=`printf %s "$3" | sed 's/\"//g'`

alertJson=`cat <<EOF
{
    "source": "$splunk_server",
    "alarm_title": "$4",
    "creation_time": "$epoch_date",
    "criticality": "CRITICAL",
    "alert_description": "$5",
    "source_event_id": "$searchQuery",
    "event_type": "splunk",
    "intermediary_source": "$splunk_server",
    "custom": {
        "splunk": {
                "script_name": "$0",
                "event_count": "$1",
                "search_terms": "$searchTerms",
                "search_string": "$searchQuery",
                "report_name": "$4",
                "trigger_reason": "$5",
                "search_url": "$6",
                "file_url": "$8"
            }
     }
}
EOF
`
# For diag purposes only. Comment out for production
#echo $alertJson > "$SPLUNK_HOME/bin/scripts/argos_alert.txt"

# Use curl to send event to Argos Alert API
curl -X POST --header 'Content-Type: application/json' -H "Authorization: Intuit_APIKey intuit_apikey=$key" --header 'Accept: application/json' -d "$alertJson"  https://${endpoint_server}/v1/addAlerts -i -x http://qypprdproxy01.ie.intuit.net:80
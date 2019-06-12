#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

if [ "$#" -ne 7 ]; then
  usage
  exit 1
fi

tenant=""
client_id=""
secret=""
sub_id=""
groupName=""
location=""
tag="quarantine"
functionapp_url=""

usage() {
  echo "Usage: ${0} <url> <tenant> <client_id> <secret> <subcription_id> <resourceGroup> <location>" 1>&2
}

json=\\"{ \\\"tenant\\\": ${tenant},\
  \\\"client_id\\\": ${client_id},\
  \\\"secret\\\": ${secret},\
  \\\"subscription_id\\\": ${sub_id},\
  \\\"group_name\\\": ${groupName},\
  \\\"location\\\": ${location},\
  \\\"tag\\\": ${tag},\
  \\\"ip\\\": \\\"%%log.srcip%%\\\"\
}"

config="config system automation-trigger\n\
    edit \"Addquarantine\"\n\
    next\n\
  end\n\
  config system automation-action\n\
    edit \"Addquarantine_azure\"\n\
    set action-type webhook\n\
    set delay 1\n\
    set protocol https\n\
    set uri \"${functionapp_url}\"\n\
    set http-body \"${json}\"\n\
    set port 443\n\
    set headers \"Content-Type:application/json\"\n\
    next\n\
  end\n\
  config system automation-stitch\n\
    edit \"Addquarantine\"\n\
    set trigger \"Addquarantine\"\n\
    set action \"Addquarantine_azure\"\n\
  end"

echo "${config}"

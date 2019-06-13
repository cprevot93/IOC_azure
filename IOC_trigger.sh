#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# if [ "$#" -ne 7 ]; then
#   usage
#   exit 1
# fi

tenant="942b80cd-1b14-42a1-8dcf-4b21dece61ba"
client_id="134d90cf-4395-4998-a4b4-b037af9f78e3"
secret="85aJ.=./0hV1N.5uP=1XxiuP1nMo6H/v"
sub_id="cf72478e-c3b0-4072-8f60-41d037c1d9e9"
groupName="cprevot-DemoSDN"
location="francecentral"
tag="quarantine"
url="cprevot-demosdn.azurewebsites.net/api/IOC_resource_tagging"

usage() {
  echo "Usage: ${0} <url> <tenant> <client_id> <secret> <subcription_id> <resourceGroup> <location>" 1>&2
}

json="{ \\\"tenant\\\": \\\"${tenant}\\\",\
  \\\"client_id\\\": \\\"${client_id}\\\",\
  \\\"secret\\\": \\\"${secret}\\\",\
  \\\"subscription_id\\\": \\\"${sub_id}\\\",\
  \\\"group_name\\\": \\\"${groupName}\\\",\
  \\\"location\\\": \\\"${location}\\\",\
  \\\"tag\\\": \\\"${tag}\\\",\
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
    set uri \"${url}\"\n\
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

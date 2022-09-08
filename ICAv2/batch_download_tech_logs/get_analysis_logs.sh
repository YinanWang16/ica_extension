#!/usr/bin/env bash

set -auo pipefail

function help() {
  cat <<-EOF
  Download ICAv2 analysis logs by providing analysis id.
  Prerequisites:
    icav2   v2.3+
    jq      v1.6
  Usage:
    $0 [analysis id]
EOF
  exit
}

if [ $# -eq 0 ]; then
  help
fi

while true; do
  case "$1" in
    -h | --help             ) help ;;
    -*                      ) echo "$1 is not a valid flag"; exit;;
    *                       ) analysis_id="$1"; break;;
  esac
done

## =============== settings ================ ##
if [ -f ~/.icav2/.session.ica.yaml ]; then
  project_id=`sed -n 's/^project-id: //p' ~/.icav2/.session.ica.yaml`
  JWT=`sed -n 's/^access-token: //p' ~/.icav2/.session.ica.yaml`
else
  echo "Please login ICA with 'icav2 config'"; exit
fi
if [ -z $project_id ]; then
  echo "Please enter a project"; exit
fi
if [ -z $JWT ]; then
  echo "Invalid configuration. Please login ICA with 'icav2 config'"; exit
fi
## ======================================== ##

## =============== get step json =============== ##
TEPJSON=$(mktemp /tmp/steps_XXXX.json)
curl -s -X 'GET' \
  'https://ica.illumina.com/ica/rest/api/projects/'$project_id'/analyses/'$analysis_id'/steps' \
  -H 'accept: application/vnd.illumina.v3+json' \
  -H 'Authorization: Bearer '$JWT'' > $TEPJSON
status=`cat /tmp/steps_Ub4D.json|jq '.status'`
if [ $status == null ]; then
  echo "Couldn't find logs for analysis $analysis_id."
  exit
fi
## =============== download file =============== ##
while read -r file_id file_path; do
  dir_name=$(dirname $file_path)
  # create directory
  mkdir -p ${PWD}$dir_name
  # download file
  icav2 projectdata download $file_id ${PWD}$file_path
done < <(jq -r -j '.items[].logs[]|.id," ",.details.path,"\n"' $TEPJSON)
echo "Analysis logs are saved in \"analysis/\"."; exit 0
## ============================================= ##
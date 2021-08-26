#!/usr/bin/env bash

function help() {
  cat <<-EOF
  $0 [options]
  -h | --help             This help screen.
  -i | --workflow-run-id  REQUIRED. Provide the workflow run id.
  -c | --clear            Optional. Clear intermediate json files.
EOF
  exit
}
clear_intermediates="false"
while true; do
  case "$1" in
    -h | --help             ) help ;;
    -i | --workflow-run-id  ) wfr_id="$2"   ; shift 2 ;;
    -c | --clear            ) clear_intermediates="true"    ; shift   ;;
    -- ) shift; break ;;
    *  ) break ;;
  esac
done

if [ ! $wfr_id ]; then
  help
  exit
fi

function time_diff() {
  secondsUsed=$(( $(date -d "$1" +%s) - $(date -d "$2" +%s) ))
  printf '%02dh:%02dm:%02ds\n' $((secondsUsed/3600)) $((secondsUsed%3600/60)) $((secondsUsed%60))
}

wfr_json=${wfr_id}.get.json
if [ ! -f $wfr_json ]; then
  ica workflows runs get -o json $wfr_id >$wfr_json
fi

# get workflow history json file
wfr_hist_json=${wfr_id}.history.json
if [ ! -f $wfr_hist_json ]; then
  ica workflows runs history -o json $wfr_id >$wfr_hist_json
fi

# get task id list
task_id_list=(`jq -r '.items[].eventDetails.additionalDetails[0]|select(.EventType != null)|select(.EventType|test("LaunchTask")).Output.TaskRunId' $wfr_hist_json`)

echo -e "TASK ID,TASK NAME,STATUS,CREATED,MODIFIED,NODE TIME,ACTUAL ANALYSIS TIME,RESOURCE SIZE, RESOURCE TIER, RESOURCE TYPE"

for trn in ${task_id_list[@]}; do
  # download task json
  echo -n "$trn,"
  trn_json=${trn}.get.json
  if [ ! -f $trn_json ]; then
    ica tasks runs get -o json $trn >$trn_json
  fi
  description=`jq -r '.description' $trn_json| tr -d '\n'`
  sta=`jq -r '.status' $trn_json`
  # calculate task node time
  timeCreated=`jq -r '.timeCreated' $trn_json`
  timeModified=`jq -r '.timeModified' $trn_json`
  timeUsed=`time_diff $timeModified $timeCreated`
  # calculate task actual run time
  timeStarted=`jq -r '.logs[0].startTime' $trn_json`
  timeStopped=`jq -r '.logs[0].endTime' $trn_json`
  actualTimeUsed=`time_diff $timeStopped $timeStarted`

  # resources
  resources=(`jq -r '.execution.environment.resources|.size,.tier,.type' $trn_json`)
  printf '%s ' $description
  printf ',%s,%s,%s,%s,%s,%s,%s,%s\n' $sta $timeCreated $timeModified $timeUsed $actualTimeUsed ${resources[@]}
  if $clear_intermediates; then
    rm $trn_json
  fi
done

# calculate workflow node time (run time + queue time)
timeCreated=`jq -r '.timeCreated' $wfr_json`
timeModified=`jq -r '.timeModified' $wfr_json`
timeUsed=`time_diff $timeModified $timeCreated`

# calculate workflow actual run time
timeStarted=`jq -r '.timeStarted' $wfr_json`
timeStopped=`jq -r '.timeStopped' $wfr_json`
actualTimeUsed=`time_diff $timeStopped $timeStarted`

if $clear_intermediates; then
  rm $wfr_json
fi

echo -e "$wfr_id,Total Workflow  Run Time,Succeed,${timeCreated},${timeModified},${timeUsed},${actualTimeUsed}\n"


# ica_extension
## workflow_run_time_stats.sh
This script is to summarize tasks run time in a workflow run.
* Prerequisites
    1. [ica](https://sapac.support.illumina.com/downloads/illumina-connected-analytics-cli-v1-0.html) command line tool
    2. JSON parser [jq](https://stedolan.github.io/jq/)
* Usage
```bash
  ./workflow_run_time_stats.sh [options]
  -h | --help             This help screen.
  -i | --workflow-run-id  REQUIRED. Provide the workflow run id.
  -c | --clear            Optional. Clear intermediate json files.
```
* Example command
```bash
./workflow_run_time_stats.sh -i wfr.c4dc6d4a97dd4b3d9e8bbe514f803f29 -c
```
* Example output (comma separated table)
    <details>
      <summary>Click to expand!</summary>
      
        TASK NAME,STATUS,CREATED,MODIFIED,NODE TIME,ACTUAL ANALYSIS TIME
        Dragen TSO500 RUO Configuration Task ,Completed,2021-02-24T09:25:19.617Z,2021-02-24T09:35:06.404Z,00h:09m:47s,00h:04m:48s
        Dragen TSO500 RUO Analysis Task ,Completed,2021-02-24T09:36:07.610Z,2021-02-24T12:21:14.556Z,02h:45m:07s,02h:37m:53s
        Dragen TSO500 RUO Gather Task ,Completed,2021-02-24T12:21:44.198Z,2021-02-24T12:37:15.942Z,00h:15m:31s,00h:07m:50s
        Total Workflow  Run Time,Succeed,2021-02-24T09:25:10.058Z,2021-02-24T12:38:17.165Z,03h:13m:07s,03h:12m:58s
    </details>
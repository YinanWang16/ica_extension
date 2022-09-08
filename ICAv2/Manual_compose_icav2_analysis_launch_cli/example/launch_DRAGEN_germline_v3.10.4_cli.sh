#!/usr/bin/env bash
set -auo pipefail

## ================= Settings ================ ##
# pipeline info (replace with your own setting)
pipeline_id="61f71142-10b7-472e-af54-26c589fbfcd6"
pipeline_code="DRAGEN Germline Whole Genome 3-10-4-v2"
ref_id="fil.48a0f63157c54624ea2908d9ba754d71" # hg38_altaware_graph_based.v8.tar
output_dir_id=""  # Please create an output directory and put its id here.
# ------------ functions -------------- #
NOW=$(date --rfc-3339='seconds')
## ============================================ #

## ============== Get sample list ============= #
sample_list=($(cat sample_list.txt))
## ============================================ #
for sample in ${sample_list[@]}; do
  # ------------- make log dir
  log_dir=Logs_analysis_${sample}
  log="$log_dir/run.log"
  CMD="mkdir -p $log_dir"
  eval ${CMD}
  echo "$NOW  INFO  - Start processing ${sample}" >$log
  echo "$NOW  INFO  - COMMAND: ${CMD}" | tee -a $log
  
  # ------------- get fastq list and fastq_list.csv of the sample
  echo "$NOW  INFO  - Get fastq list of ${sample}" | tee -a $log
  fastq_list_json=$log_dir/fastq_list.json
  CMD="icav2 projectdata list --data-type FILE \
  --match-mode FUZZY --file-name ${sample} -o json >$fastq_list_json"
  echo "$NOW  INFO  - COMMAND: ${CMD}" | tee -a $log
  eval ${CMD} 2>>$log
  # data id list of fastq files
  fastq_id_list=(`jq -r '.items[]|select(.details.name| match("fastq.gz")).id' $fastq_list_json`)
  echo "$NOW  INFO  - Data IDs of FASTQ files: ${fastq_id_list[@]}" | tee -a $log
  # data id of fastq_list.csv
  fastq_list_csv_id=(`jq -r '.items[]|select(.details.name| match("fastq_list.csv")).id' $fastq_list_json`)
  echo "$NOW  INFO  - Data IDs of fastq_list.csv: $fastq_list_csv_id" | tee -a $log

  # ------------ submit analysis
  run_name="${sample}_${pipeline_code}"   # change according to your needs
  echo "$NOW  INFO - Submit an analysis" | tee -a $log
  fastq_id_list=$(printf "\\\"%s\\\"," ${fastq_id_list[@]} | sed 's/,$//')
  CMD="icav2 projectpipelines start nextflow ${pipeline_id} \
  --user-reference \"${run_name}\" \
  --input \"fastqs\":${fastq_id_list} \
  --input \"ref_tar\":\"${ref_id}\" \
  --input \"fastq_list\":\"${fastq_list_csv_id}\" \
  --parameters \"enable_dragen_reports\":\"true\" \
  --parameters \"additional_args\":\"--repeat-genotype-specs /opt/edico/repeat-specs/experimental/smn-catalog.hg38.json\" \
  --parameters \"enable_map_align\":\"true\" \
  --parameters \"enable_map_align_output\":\"true\" \
  --parameters \"output_format\":\"BAM\" \
  --parameters \"enable_variant_caller\":\"true\" \
  --parameters \"vc_emit_ref_confidence\":\"GVCF\" \
  --parameters \"enable_cnv\":\"true\" \
  --parameters \"cnv_segmentation_mode\":\"SLM\" \
  --parameters \"enable_sv\":\"true\" \
  --parameters \"repeat_genotype_enable\":\"true\" \
  --parameters \"enable_smn\":\"true\" \
  --parameters \"enable_hla\":\"true\" \
  --parameters \"enable_cyp2d6\":\"true\" \
  --output-parent-folder ${output_dir_id} \
  --storage-size SMALL \
  -o json"
  echo "${NOW}  INFO - COMMAND: ${CMD}" | tee -a ${log}
  eval ${CMD} &>$log_dir/projectanalyses.json
  analysis_id=`jq -r '.id' $log_dir/projectanalyses.json`
  if [[ -z "$analysis_id" ]]; then
    echo -e "\nError: Failed to launch the analysis" | tee -a $log
  else
    echo -e "\n${NOW}  INFO - Launching \"$pipeline_code\" for ${sample}: Succeeded"| tee -a $log
  fi
done


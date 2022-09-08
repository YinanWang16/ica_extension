# How to compose an ICAv2 CLI to submit DRAGEN analysis in batch
## Step 1: Settle down DRAGEN desired parameter set
1. Browse available options in out-of-box DRAGEN pipelines, `Start New Analysis` page.
2. For some of out-of-box DRAGEN pipelines, addition parameters and flags can be passed in via the `Additional DRAGEN args` slot,
following `--flag setting` format, please refer to [DRAGEN online User Guide](https://support-docs.illumina.com/SW/DRAGEN_v40/Content/SW/FrontPages/DRAGEN.htm) for available options.

## Step 2: Submit a test analysis in GUI and get the "analysis id"
After settled down with the parameter setting, submit a test run in GUI with all the desired parameters. 
Retrieve the "analysis id" from UI or use `icav2` CLI. The first column "ID" is the analysis id.
```bash
icav2 projectanalyses list
ID                                      REFERENCE                                                                                                                       CODE                                            STATUS 
fb55ec10-06cf-4d64-8e23-4fd951ea57f8    roka-metagenome-test1-dragen_metagenomics_krona-pipeline-demo-37c80407-e936-451b-b616-725c8aa4cbeb                              dragen_metagenomics_krona-pipeline-demo FAILED
650d0ca6-04c0-40af-942c-9387cb2783a2    yw_dragen_metagenomics_krona-pipeline-run2-yw_dragen_metagenomics_krona-pipeline-e6e235d4-4e12-403e-ac7f-bcb144b571d1           yw_dragen_metagenomics_krona-pipeline   SUCCEEDED
c28fcb68-3300-4d3a-8840-5ea1bd1a2653    yw_dragen_metagenomics_krona-pipeline_cli_run1-yw_dragen_metagenomics_krona-pipeline-aaa88e6c-f539-4d42-a8d4-2cb7d3d3f4cb       yw_dragen_metagenomics_krona-pipeline   SUCCEEDED
73256fe0-2eb5-4b80-8ebc-e4dbcfc90623    yw_dragen_metagenomics_krona_pipeline_v2-run1-yw_dragen_metagenomics_krona_pipeline_v2-c6e86e8c-5dca-4914-9842-3b38b2c3b80e     dragen_metagenomics_krona_pipeline_v2   FAILED
169c9603-dea8-4d9d-833b-912abb6d83c8    yw_dragen_metagenomics_krona_pipeline_v2-run2-yw_dragen_metagenomics_krona_pipeline_v2-5474c25f-3289-4ded-b502-8653d75b80a7     dragen_metagenomics_krona_pipeline_v2   SUCCEEDED
No of items :  5
```
## Step 2: Get input codes via icav2 CLI


## step 3: Get parameter codes via ICAv2 Swagger page

## Compose the analysis submitting CLI

## Example: use `for` loop to launch analyses in batch
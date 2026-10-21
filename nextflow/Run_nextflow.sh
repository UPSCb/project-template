#!/bin/bash
#SBATCH -A account
#SBATCH -c 1
#SBATCH -t 7-00:00:00
#SBATCH -J nextflow_run
#SBATCH -o nextflow.out
#SBATCH -e nextflow.err

ml Nextflow/26.04.6


nextflow run nf-core/rnaseq -r 3.26.0  \
-profile singularity,upscb -c nextflow/nextflow.config \
-params-file nextflow/nf-params.json \
-with-trace -with-report report_$(date "+%Y_%m_%d_%H_%M").html \
-resume

#!/bin/bash

###########################
# 0: Blanca Setup
###########################

#SBATCH --job-name=CPDinfo03_pval
#SBATCH --array=1-22               #JOB ARRAY
#SBATCH --ntasks=4                 #NUMBER OF REQUESTED CORES
#SBATCH --qos=preemptable          #QOS
#SBATCH --time=6:00:00             #WALL TIME
#SBATCH --mem=60gb                 #SPECIFY MEMORY IN GB
#SBATCH --output=/rc_scratch/paro1093/magma/pVal_analysis/slurm/slurm-CPDinfo03_pval_logCPD_ver2_chr%a.mgm.out

##################################
# 0: Summit Setup (inactive)
##################################

##SBATCH --job-name=run_info03_pval       #JOBNAME
##SBATCH --time=3:00:00                   #WALL TIME
##SBATCH --partition=ssky-preemptable     #PARTITION/ACCOUNT
##SBATCH --mem=10gb                       #MEMORY, IN GB
##SBATCH --ntasks=4                       #NUMBER OF CORES/PROCESSES
##SBATCH --nodes=1        #NODES: Keep all tasks of one array (job) in same node
##SBATCH --output=/scratch/summit/paro1093/magma/pVal_analysis/slurm/slurm-run_info03_pval.mgm.out

#0: Set up:
#------------
#get Job ID:
echo "Slurm Job ID:" ${SLURM_ARRAY_JOB_ID}

#get task number:
taskNum="${SLURM_ARRAY_TASK_ID}"
echo "Analyzing chr:" $taskNum

#get start time:
start_time=`date +%s`
echo "Start time:" `date +%c`
  #print start time in Day-Month-Yr Time in 24 hr format

#change working directory:
cd /rc_scratch/paro1093/magma/pVal_analysis

#clean environment & load software:
ml purge
export PATH=/pl/active/KellerLab/opt/bin:$PATH

####################################
# 1: Prep Plink Files
####################################
#Gene ixn using p-vals from GxGWAS previously done (with info >= 0.3, per GSCAN standards):
#make a single .bim file:
#cat /rc_scratch/supa7655/greml_ukb/bed/chr*.bim >> /rc_scratch/paro1093/magma/pVal_analysis/temp.bim
  #NOTE: these files are the UKB data from Substrata with info 0.3 used in the info03_dosages gxGWAS analysis ran earlier.
#make single .bed file:
#cat /rc_scratch/supa7655/greml_ukb/bed/chr*.bed >> /rc_scratch/paro1093/magma/pVal_analysis/temp.bed

#make single .fam file:
#cat /rc_scratch/supa7655/greml_ukb/bed/chr1.fam > /rc_scratch/paro1093/magma/pVal_analysis/temp.fam

#plink2 --memory --threads 14 --merge-list /pl/active/IBG/promero/magma/pval_analysis/merge03dos.txt --make-bed --out full03dos.qc

#NOTE: edit paths depending on if you're working on summit/blanca and raw cpd/logCpd

####################################
# 2: SNP-wise MEAN Pval Analysis
####################################

echo "Starting snp-wise MEAN p-val analysis of gxGWAS with info >=0.3"

#1: raw CPD:
#----------------------------------------------
  # magma1.08 \
  #   --bfile /rc_scratch/supa7655/greml_ukb/bed/chr${taskNum} \
  #   --gene-annot /pl/active/IBG/promero/magma/gene_annot/info03_25kbWindow_ver2.genes.annot \
  #   --pval /pl/active/IBG/promero/magma/pval_analysis/master_cpd_info03_pval.txt use=RSID, Pval ncol=2 \
  #   --gene-model snp-wise=mean \
  #   --out /rc_scratch/paro1093/magma/pVal_analysis/mean_info03_CPD_25kb_pvals_ver2.chr${taskNum}.results

#2: log CPD:
#----------------------------------------------
magma1.08 \
  --bfile /rc_scratch/supa7655/greml_ukb/bed/chr${taskNum} \
  --gene-annot /pl/active/IBG/promero/magma/gene_annot/info03_25kbWindow_ver2.genes.annot \
  --pval /pl/active/IBG/promero/magma/pval_analysis/master_logCPD_info03_pval.txt use=RSID, Pval ncol=2 \
  --gene-model snp-wise=mean \
  --out /rc_scratch/paro1093/magma/pVal_analysis/mean_logCPD_info03_CPD_25kb_pvals_ver2.chr${taskNum}.results

####################################
# 2: SNP-wise TOP Pval Analysis
####################################
echo "Starting snp-wise TOP p-val analysis of gxGWAS with info >=0.3"

#1: raw CPD:
#----------------------------------------------
# magma1.08 \
#   --bfile /rc_scratch/supa7655/greml_ukb/bed/chr${taskNum} \
#   --gene-annot /pl/active/IBG/promero/magma/gene_annot/info03_25kbWindow_ver2.genes.annot \
#   --pval /pl/active/IBG/promero/magma/pval_analysis/master_cpd_info03_pval.txt use=RSID, Pval ncol=2 \
#   --gene-model snp-wise=top \
#   --out /rc_scratch/paro1093/magma/pVal_analysis/top_info03_CPD_25kb_pvals_ver2.chr${taskNum}.results

#2: log CPD:
#----------------------------------------------
magma1.08 \
  --bfile /rc_scratch/supa7655/greml_ukb/bed/chr${taskNum} \
  --gene-annot /pl/active/IBG/promero/magma/gene_annot/info03_25kbWindow_ver2.genes.annot \
  --pval /pl/active/IBG/promero/magma/pval_analysis/master_logCPD_info03_pval.txt use=RSID, Pval ncol=2 \
  --gene-model snp-wise=top \
  --out /rc_scratch/paro1093/magma/pVal_analysis/top_logCPD_info03_CPD_25kb_pvals_ver2.chr${taskNum}.results

##################
# 3: Run down
##################

echo "Process complete"
echo "Total runtime: $((($(date +%s)-$start_time)/60)) minutes"

##################
# Notes
##################

#Dec/29/2020: added a '2' to slurm & output file to test if removing the big data tag will get rid of the following note in the results log file: Filtering phenotype/covariate missing values... 503 individuals remaining #Update: emailed Christiaan and he says it's a software error that that msg displayed, analysis is correct.

#/scratch/summit/paro1093/magma/pVal_analysis/info03_cpd_25kb_pvals.results

#for running logCPD with TOP model:
# echo "Starting swnp-wise TOP p-val analysis of gxGWAS with info >=0.3"
#
#   magma1.08 \
#     --bfile /pl/active/IBG/promero/magma/snp_loc/g1000_eur/g1000_eur \
#     --gene-annot /pl/active/IBG/promero/magma/gene_annot/info03_25kbWindow.genes.annot \
#     --pval /pl/active/IBG/promero/magma/pval_analysis/master_logCPD_info03_pval.txt use=RSID, Pval ncol=2 \
#     --gene-model snp-wise=top \
#     --out /rc_scratch/paro1093/magma/pVal_analysis/top_info03_logCPD_25kb_pvals.results

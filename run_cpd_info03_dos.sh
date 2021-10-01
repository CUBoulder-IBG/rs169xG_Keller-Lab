#!/bin/bash

######################
# 0: Setup with Blanca
######################

#SBATCH --time 10:00:00
  # Walltime: max time before quitting job
#SBATCH --qos=preemptable
  # Quality of Service: limits characteristics of job
## SBATCH --part=blanca-nso
  # Partition: What queue/resources to use
## SBATCH --constraint=avx|avx2
#SBATCH --mem=35gb
  # Total amount of memory to allocate
#SBATCH --ntasks 10
  # Number of CPUs, always request in multiples of 2
#SBATCH --nodes=1
  # Keep all tasks of one array (job) in same node
#SBATCH --array 20
  # Number of jobs
#SBATCH --output=/rc_scratch/paro1093/rs169xCPD/results_03dosCPD/chr.${cc}.03doscpd.out

############################################
# 0: Setup with Summit's Skylake Preemptable (inactive)
############################################
##SBATCH --job-name=03info_gxGwas
##SBATCH --partition=ssky-preemptable
##SBATCH --time 24:00:00
##SBATCH --mem=35gb
##SBATCH --ntasks 10
##SBATCH --nodes=1
##SBATCH --array 20
##SBATCH --output=/scratch/summit/paro1093/rs169xCPD/results_03dosCPD/chr.${cc}.03doscpd.out

#0.1: Job Specs
#--------------
#get start time:
echo "Starting Job. Your Slurm Job ID is:" ${SLURM_ARRAY_JOB_ID}
start_time=`date +%s`
echo "Start time:" `date +%c`
  #print start time in Day-Month-Yr Time in 24 hr format

cc=${SLURM_ARRAY_TASK_ID}
jid=${SLURM_JOB_ID}

echo Working on chromosome number "$cc"

#0.2: Load Software
#-----------------
export PATH=/pl/active/KellerLab/opt/bin:$PATH
ml purge
ml load intel mkl

#0.3: Change Working Directory (Currently: Summit)
#--------------------------------------------------
#Summit: cd /scratch/summit/paro1093/rs169xCPD/results_03dosCPD

#Blanca:
cd /rc_scratch/paro1093/rs169xCPD/results_03dosCPD

######################
# 1: Run info 0.3 gxGWAS
######################
plink2 --memory 35840 --geno 0.05 --hwe 0.00000001 --maf 0.01 \
       --threads 10  \
       --bgen /rc_scratch/supa7655/greml_ukb/bgen/chr${cc}.bgen ref-first \
       --sample /rc_scratch/supa7655/greml_ukb/bgen/chr${cc}.sample \
       --keep /pl/active/IBG/luke/test/cpd_rel05.grm.id \
       --pheno /pl/active/IBG/luke/test/pheno_cpd.txt \
       --pheno-col-nums 6\
       --covar /pl/active/IBG/promero/rs169xCPD/covariates_CPD/covariates_CPDmBig_interactions.txt \
       --covar-variance-standardize \
       --linear interaction --vif 200 \
       --parameters 1-439 \
       --out /rc_scratch/paro1093/rs169xCPD/results_03dosCPD/chr.${cc}.03doscpd.result


##############
# 2: Rundown
##############
echo "Process complete"
echo "Total runtime: $((($(date +%s)-$start_time)/60)) minutes"
#NOTE: Use command sacct --starttime=YYYY-MM-DD --jobs=your_job-id --format=User,JobName,JobId,MaxRSS to check how much memory this took.


##############
# 3: Notes
##############
#COVAR TODO: Error: Cannot proceed with --glm regression on phenotype 'PHENO1', since
# covariate correlation matrix could not be inverted (VIF_INFINITE). You may want
# to remove redundant covariates and try again.
  #DONE: May/29/20: the --parameter flag should only access mBig and the normal covariates, no ixns. Otherwise, you;ll get three-way ixns.

#BGEN TODO: find out what the reference allele is. Luke says he doesnt remember but used "qctool_v2.0 to pull out the snps & individuals from the original UK Biobank raw data and output to bgen format. So it should be consistent between the two, or however QCtool handles it".
  #Per convention, it probably is the first: use ref-first
  #DONE: first allele is ref/major one, confirmed using dbSNP on some of the alleles on a chr.

#PHENO NOTE: --pheno-col-nums 5 is to only look at LOG CPD as our phenotype.
  #Warning: --mpheno flag deprecated.  Use --pheno-col-nums instead.  (Note that --pheno-col-nums does not add 2 to the column number(s).

#COVAR NOTE: use --covar-variance-standardize \ specifying pheno did NOT resolve issue of covariate scales varying too widely.

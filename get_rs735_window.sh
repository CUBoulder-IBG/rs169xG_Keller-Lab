#!/bin/bash
#RUN: sbatch /pl/active/IBG/promero/rs169xCPD/pcna_hit/get_rs735_window.sh
######################
# 0: Setup with Blanca
######################
#SBATCH --job-name=rs735window
#SBATCH --time 3:00:00
#SBATCH --qos=preemptable
#SBATCH --mem=15gb
#SBATCH --ntasks 4
#SBATCH --output=/rc_scratch/paro1093/rs169xCPD/rs735window.out

#0.1: Job Specs
#--------------
echo "Starting Job. Your Slurm Job ID is:" ${SLURM_ARRAY_JOB_ID}
start_time=`date +%s` #get start time:
echo "Start time:" `date +%c` #print start time in Day-Month-Yr Time in 24 hr format

#0.2: Load Software
#-----------------
export PATH=/pl/active/KellerLab/opt/bin:$PATH
ml purge

#0.3: Change Working Directory (Currently: SSD)
#--------------------------------------------------
#cd to local SSD for faster I/O and computing:
cd $SLURM_SCRATCH

##################################################################
# 1: Get all snps within 250kb on either side of rs16969968
##################################################################
#note: --snp specifies a single variant to load by name. If it's combined with --window, all variants with physical position no more than half the specified kb distance (decimal permitted) from the named variant are loaded as well.
plink2 --memory ${SLURM_MEM_PER_NODE} \
       --threads ${SLURM_NTASKS} \
       --pfile /rc_scratch/paro1093/plink_bgen_03dos/pgen/03dosHRC20 \
       --snp rs73586411 \
       --window 500 \
       --make-pgen \
       --out ./rs735window

##############
# 2: Rundown
##############
mv ./* /rc_scratch/paro1093/rs169xCPD/ #move stuff out of local scratch
echo "Process complete"
echo "Total runtime: $((($(date +%s)-$start_time)/60)) minutes"

#!/bin/bash
#RUN JOB: sbatch /pl/active/IBG/promero/rs169xCPD/pcna_hit/LD/calc_LD_pcnaGene.sh
######################
# 0: Setup with Blanca
######################
#SBATCH --job-name=calc_LD_pcnaGene  #JOBNAME
#SBATCH --time 2:00:00               # Walltime
#SBATCH --qos=preemptable            # Quality of Service
#SBATCH --ntasks 4                   # Number of CPUs
#SBATCH --output=/rc_scratch/paro1093/rs169xCPD/calc_LD_pcnaGene.out

#0.1: Job Specs
#--------------
#get start time:
echo "Starting Job. Your Slurm Job ID is:" ${SLURM_JOB_ID}
start_time=`date +%s`
echo "Start time:" `date +%c` #print start time in Day-Month-Yr Time in 24 hr format
echo "Requesting" ${SLURM_NTASKS} "num of CPUs"
echo "Requesting" ${SLURM_MEM_PER_CPU} "memory/CPU"

parentDir="/rc_scratch/paro1093/rs169xCPD" #get data's location

#0.2: Load Software
#-----------------
ml purge #clean envrionment
export PATH=/pl/active/KellerLab/opt/bin:$PATH #where plink software lives

#0.3: Change Working Directory (Currently: Blanca)
#--------------------------------------------------
cd $SLURM_SCRATCH #faster I/O here
############################################
# 1: Extract PCNA gene SNPs in .bed format:
############################################
cd /rc_scratch/paro1093/rs169xCPD

cut -f3 /pl/active/IBG/promero/rs169xCPD/pcna_hit/PCNAsnps4.results  > /rc_scratch/paro1093/rs169xCPD/PCNAsnps.rsids #get list of 61 SNPs in our PCNA gene with no header or quotation marks around each rsid, one SNP per line

plink2 \
  --bfile /pl/active/IBG/UKBiobank/GENO/QCed/imputed/white/ukb_imputed_QC/chrom/plink_bed/chr.${chr}.qc \
  --extract /rc_scratch/paro1093/rs169xCPD/PCNAsnps.rsids \
  --make-bed --out snpsPCNAgene

############################################
# 2: Run Plink to get LD for our gene window:
############################################
plink1.9 --bfile "$parentDir/snpsPCNAgene" \
       --r2 \
       --ld-window-r2 0 \
       --out r2_pcnaGene

#now move final output off of SSD to /rc_scratch:
mv ./* /rc_scratch/paro1093/rs169xCPD/
##############
# 3: Rundown
##############
echo "Process complete"
echo "Total runtime: $((($(date +%s)-$start_time)/60)) minutes"
##############
# 4: Notes
##############
#there should be 61 SNPs in the PCNA gene region used in MAGMA (PCNA gene + 25kb window)
#out of these 61, 13 were nominally significant (see nomSigSnps txt file sent via email).
#added the --ld-window-r2 flag as Plink by default excludes r2 < 0.2 and we want all of them. 

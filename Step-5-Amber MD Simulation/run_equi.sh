#!/bin/bash
#SBATCH --job-name=3KOH_equi
#SBATCH --output=3KOH_equi.gpus
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=4G
#SBATCH --gpus=1
#SBATCH --time=48:00:00

# Load Modules
module purge
module load python/3.12
module load gcc/14.1
module load spack/release
source /apps/src/ambertools/24/amber24/amber.sh
module load cuda/12.4.1-pw6cogp

# Amber input files and output name
INP=parm_equi.in
TOP=3KOH_solv.prmtop
CRD=3KOH_heat.rst
OUT=3KOH_equi

# Launch pmemd.cuda 
pmemd.cuda                                  -O     -i   $INP   -p   $TOP   -c   $CRD   -r   $OUT.rst \
                                                   -o   $OUT.out   -e   $OUT.ene   -v   $OUT.vel   -inf $OUT.nfo   -x   $OUT.mdcrd \
                                                   -ref $CRD





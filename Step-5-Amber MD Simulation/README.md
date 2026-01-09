## Amber MD Simulation Procedure

Copy `prmtop` and `inpcrd` files from `tleap` into the MD Simulation directory.

**Step-1: Energy Minumization**

Since we aim to generate a TS-like active site for the P450 enzyme, we decided to use NMR style gemoetric constraints at the active site to maintain the TS-like geometry of the O---H---C interaction.

The constrained minimization input (`parm_min.in`).

    Minimize
     &cntrl
      imin=1,       ! run minimization
      ntx=1,        ! read coords only
      irest=0,      ! not a restart
      maxcyc=30000, ! total steps
      ncyc=30000,   ! steepest descent then CG: Here 30000 make usre it uses Steepest descent throughout to eliminate LINMIN error
      ntpr=100,     ! print energies
      ntwx=100,     ! print trajectory output
      ntb=1,        ! constant volume periodic conditions
      cut=12.0,     ! nonboned cutoff (Å) (ignored if ntb=0)
      ioutfm=1,     ! Write netcdf file
      nmropt=1     ! turn on nmr style restraints
    /
    &wt type='END' /   ! End of weight changes
     &rst iat=7847,7858, r1=1.10, r2=1.20, r3=1.20, r4=1.30, rk2=1000.0, rk3=1000.0, /
     &rst iat=7848,7858, r1=1.20, r2=1.30, r3=1.30, r4=1.40, rk2=1000.0, rk3=1000.0, /
     &rst iat=0 /       ! End of restraints

Corresponding submission script (`run_min.sh`). 

    #!/bin/bash
    #SBATCH --job-name=3KOH_min
    #SBATCH --output=3KOH_min.gpus
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
    INP=parm_min.in
    TOP=3KOH_solv.prmtop
    CRD=3KOH_solv.inpcrd
    OUT=3KOH_min
    
    # Launch pmemd.cuda 
    pmemd.cuda                                  -O     -i   $INP   -p   $TOP   -c   $CRD   -r   $OUT.rst \
                                                       -o   $OUT.out   -e   $OUT.ene   -v   $OUT.vel   -inf $OUT.nfo   -x   $OUT.nc \
                                                       -ref $CRD






**Step-2: Heat the system**

**Step-3: Equilibration**

**Step-4: MD Simulation**

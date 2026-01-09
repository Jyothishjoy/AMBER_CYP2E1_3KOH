## Amber MD Simulation Procedure

Copy `prmtop` and `inpcrd` files from `tleap` into the MD Simulation directory.

**Step-1: Energy Minumization**

Since we aim to generate a TS-like active site for the P450 enzyme, we decided to use NMR-style geometric restraints at the active site to maintain the TS-like geometry of the O---H---C interaction.

The restrained minimization input (`parm_min.in`).

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
                                                       -o   $OUT.out   -e   $OUT.ene   -v   $OUT.vel   -inf $OUT.nfo   -x   $OUT.mdcrd \
                                                       -ref $CRD


Tip: Since this is an energy minimization process, AMBER does not produce a `netcdf` file with `mdcrd` extension. Use `cpptraj` to check the last structure of the minimization using the following script (`cpptraj_struc.in`).

        parm 3KOH_solv.prmtop
        trajin 3KOH_min.rst
        autoimage
        strip :WAT,:Cl\-
        trajout 3KOH_min.pdb
        run

`source /apps/src/ambertools/24/amber24/amber.sh` (only one time to activate the AmberTools)

Type `cpptraj cpptraj_struc.in` to generate `3KOH_min.pdb` and visualize using PyMol to check if the restraints are okay.



**Step-2: Heating the system**

`prmtop`, `inpcrd`,  and `{name}_min.rst` files are required for this step.

Input file (`parm_heat.in`):

        heating_with_restraints.in (200 ps, 1 fs timestep)
        &cntrl
          imin=0,        ! Molecular Dynamics
          ntx=1,         ! Read coordinates, no velocities
          irest=0,       ! New simulation
          ntb=1,         ! Constant volume (NVT)
          cut=10.0,      ! 10 Angstrom cutoff
          ntc=2, ntf=2,  ! SHAKE on H-bonds
          tempi=10.0,    ! Start temp
          temp0=300.0,   ! Target temp
          ntt=3,         ! Langevin thermostat
          gamma_ln=1.0,  ! Collision frequency
          nstlim=200000, ! 200 ps
          dt=0.001,      ! 1 fs timestep
          ntpr=1000, ntwx=1000, ntwr=5000,   ! print every 1 ps, write trajectory every 1 ps, write restart every 5 ps
          ig=-1,         ! Random seed
          nmropt=1,      ! Enable NMR restraints/weight changes
        &end
        
        ! Temperature Ramp
        &wt type='TEMP0', istep1=0, istep2=200000, value1=10.0, value2=300.0 /
        &wt type='END' /
        
        ! Distance Restraints
        &rst iat=7847,7858, r1=1.10, r2=1.20, r3=1.20, r4=1.30, rk2=1000.0, rk3=1000.0, /i
        &rst iat=7848,7858, r1=1.20, r2=1.30, r3=1.30, r4=1.40, rk2=1000.0, rk3=1000.0, /
        /

Here, we read only the coordinates, no velocities, because the  previous step was just an energy minimization

Submission script (`run_heat.sh`):

        #!/bin/bash
        #SBATCH --job-name=3KOH_heat
        #SBATCH --output=3KOH_heat.gpus
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
        INP=parm_heat.in
        TOP=3KOH_solv.prmtop
        CRD=3KOH_min.rst
        OUT=3KOH_heat
        
        # Launch pmemd.cuda 
        pmemd.cuda                                  -O     -i   $INP   -p   $TOP   -c   $CRD   -r   $OUT.rst \
                                                           -o   $OUT.out   -e   $OUT.ene   -v   $OUT.vel   -inf $OUT.nfo   -x   $OUT.mdcrd \
                                                           -ref $CRD






**Step-3: Equilibration**

`prmtop`, `inpcrd`,  and `{name}_heat.rst` files are required for this step.

Input file (`parm_equi.in`):

        NPT equilibration with distance restraints
        &cntrl
          imin=0,           ! Run Molecular Dynamics (no minimization)
          ntx=5,            ! Read coordinates AND velocities (restart mode)
          irest=1,          ! Continue from a previous MD run (restart)
          
          ntb=2,            ! Periodic boundaries with constant Pressure
          ntp=1,            ! Isotropic pressure scaling
          pres0=1.0,        ! Target pressure in bar (1.0 bar = ~1 atm)
          taup=2.0,         ! Pressure relaxation time (in ps)
          
          ntt=3,            ! Langevin thermostat
          temp0=300.0,      ! Target temperature
          tempi=300.0,      ! Initial temperature (ignored if irest=1)
          gamma_ln=1.0,     ! Collision frequency for Langevin thermostat
          ig=-1,            ! Random seed for thermostat (ensures unique velocities)
        
          nstlim=300000,    ! Number of steps (300,000 * 1fs = 300 ps)
          dt=0.001,         ! Timestep in ps (1 fs)
          
          cut=10.0,         ! Non-bonded cutoff in Angstroms
          ntc=2,            ! Enable SHAKE to constrain bonds involving Hydrogen
          ntf=2,            ! Bond interactions involving H are omitted from force calc
          ntr=0,            ! No positional (Cartesian) restraints
          
          ntpr=1000,        ! Print energies to mdout every 1,000 steps
          ntwx=1000,        ! Write coordinates to trajectory every 1,000 steps
          ntwr=5000,        ! Write restart file every 5,000 steps
          
          nmropt=1,         ! Enable NMR-style restraints and weight changes
        &end
        
        &wt 
          type='DUMPFREQ', istep1=100, ! Write restraint data to external file every 100 steps
        &end
        
        &wt 
          type='END',       ! End of the weight change/DUMPFREQ block
        &end
        
        &rst iat=7847,7858, r1=1.10, r2=1.20, r3=1.20, r4=1.30, rk2=1000.0, rk3=1000.0, /
        &rst iat=7848,7858, r1=1.20, r2=1.30, r3=1.30, r4=1.40, rk2=1000.0, rk3=1000.0, /
        /

Submission script (`run_equi.sh`):

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





**Step-4: MD Simulation**

`prmtop`, `inpcrd`,  and `{name}_equi.rst` files are required for this step.

Input file (`parm_md.in`):

        Production MD (100 ns, 2 fs timestep)
        &cntrl
          imin=0,           ! Run Molecular Dynamics (no minimization)
          ntx=5,            ! Read coordinates AND velocities from restart file
          irest=1,          ! Continue from previous MD (restarts velocities)
          
          ntb=2,            ! Periodic boundaries at Constant Pressure
          ntp=1,            ! Isotropic pressure scaling (box scales equally in X,Y,Z)
          pres0=1.0,        ! Target pressure of 1.0 bar
          taup=2.0,         ! Pressure relaxation time (in ps)
          
          ntt=3,            ! Langevin thermostat
          temp0=300.0,      ! Target temperature
          gamma_ln=1.0,     ! Collision frequency (ps^-1)
          ig=-1,            ! Random seed for thermostat (ensures unique run)
        
          nstlim=50000000,  ! Number of steps (50M steps * 0.002 ps = 100,000 ps)
          dt=0.002,         ! Timestep in ps (2 fs). Possible because SHAKE is on.
          
          cut=10.0,         ! Non-bonded cutoff distance in Angstroms
          ntc=2,            ! SHAKE enabled: constrains all bonds involving Hydrogen
          ntf=2,            ! Bond interactions involving H are omitted from force calculation
          ntr=0,            ! No positional restraints (using distance restraints instead)
          
          ntpr=1000,        ! Print energies to mdout every 2 ps (1,000 * 0.002)
          ntwx=5000,        ! Write trajectory (nc) every 10 ps (5,000 * 0.002)
          ntwr=50000,       ! Write restart (rst7) every 100 ps (backup in case of crash)
          
          nmropt=1,         ! Flag to enable &wt and &rst sections
        &end
        
        &wt 
          type='DUMPFREQ', istep1=100, ! Record restraint distances every 100 steps
        &end
        
        &wt 
          type='END', 
        &end
        
        &rst iat=7847,7858, r1=1.10, r2=1.20, r3=1.20, r4=1.30, rk2=1000.0, rk3=1000.0, /
        &rst iat=7848,7858, r1=1.20, r2=1.30, r3=1.30, r4=1.40, rk2=1000.0, rk3=1000.0, /
        /

Submission script (`run_md.sh`):

        #!/bin/bash
        #SBATCH --job-name=3KOH_md
        #SBATCH --output=3KOH_md.gpus
        #SBATCH --nodes=1
        #SBATCH --ntasks-per-node=1
        #SBATCH --mem=4G
        #SBATCH --gpus=h200:1
        #SBATCH --time=48:00:00
        
        # Load Modules
        module purge
        module load python/3.12
        module load gcc/14.1
        module load spack/release
        source /apps/src/ambertools/24/amber24/amber.sh
        module load cuda/12.4.1-pw6cogp
        
        # Amber input files and output name
        INP=parm_md.in
        TOP=3KOH_solv.prmtop
        CRD=3KOH_equi.rst
        OUT=3KOH_md
        
        # Launch pmemd.cuda 
        pmemd.cuda                                  -O     -i   $INP   -p   $TOP   -c   $CRD   -r   $OUT.rst \
                                                           -o   $OUT.out   -e   $OUT.ene   -v   $OUT.vel   -inf $OUT.nfo   -x   $OUT.mdcrd \
                                                           -ref $CRD



**Trajectory Analysis**

At the end of a successful MD simulation, convert the last frame into a pdb file for visual inspection, use the following input (cpptraj_str.in) with `cpptraj`.

    parm 3KOH_solv.prmtop
    trajin 3KOH_md.rst
    autoimage
    strip :WAT,:Cl\-
    trajout 3KOH_md.pdb
    run

RMSD of the protein backbone, the HEM, and SUB acn be examined using the `rmsd_analysis.in` input file with `cpptraj`.

    parm 3KOH_solv.prmtop
    trajin 3KOH_md.mdcrd
    
    # Center and wrap
    autoimage
    
    # Set reference
    reference 3KOH_md.mdcrd [1]
    
    # Calculate RMSDs
    # Syntax: rms <name> <mask_to_fit> [out <filename>] [ref <reference>]
    rms Protein_BB :1-476@CA,C,N out rmsd_final.dat
    rms Heme_Group :HEM out rmsd_final.dat
    rms Substrate :SUB out rmsd_final.dat
    
    run

To visualize the final trajectory (`traj_extract.in`).

    parm 3KOH_solv.prmtop
    trajin 3KOH_md.mdcrd              # reads the binary mdcrd (auto-detects format)
    autoimage
    center :1-9999 mass                # adjust residue range as needed
    rms first :1-9999@CA,C,N,O         # pick an appropriate mask for RMS
    strip :WAT,:Cl\-
    trajout md_traj.pdb pdb           # PDB with all frames (movie)



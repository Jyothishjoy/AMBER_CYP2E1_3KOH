After the production MD run from Step 5 using the literature parameters for the HEME part, clustering using KMeans is performed on the "3KOH_md.mdcrd" file using the cpptraj package.

Used the following input file for the run.

    parm 3KOH_solv.prmtop
    trajin 3KOH_md.mdcrd
    
    # (optional but recommended) strip solvent/ions to speed up
    strip :WAT,Na+,Cl-
    
    # (optional) align all frames to the first frame based on HEM+SUB heavy atoms
    rms first :HEM,SUB&!@H= nofit out rms_align.dat
    
    # Perform k-means clustering on HEM + SUB heavy atoms
    cluster c1 \
      kmeans clusters 10 randompoint maxit 500 \
      rms :HEM,SUB&!@H= \
      sieve 10 random \
      out clustertime.dat \
      summary summary.dat \
      info info.dat \
      cpopvtime cpopvtime.agr normframe \
      repout rep repfmt pdb \
      singlerepout singlerep.nc singlerepfmt netcdf \
      avgout avg avgfmt pdb
    
    run

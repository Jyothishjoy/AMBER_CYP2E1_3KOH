After the production MD run from Step 5 using the literature parameters for the HEME part, clustering using KMeans is performed on the "3KOH_md.mdcrd" file using the cpptraj package.

Used the following "cpptraj_clustering.in" file for the run.

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

In the FSL, `source /apps/src/ambertools/24/amber24/amber.sh` to activate the AmberTools.

then run `cpptraj cpptraj_clustering.in`

This will generate 10 cluster files and their representative snapshots. We used the snapshot with the maximum population of frames by checking the `info.dat` file. 

Based on the information from `info.dat` file, 'rep.c1.pdb' file will be used for further cluster modelling.

From the 'rep.c1.pdb', 10A-diameter sphere around the active site is extracted using PyMol using the following commands.

        select active_site, br. all within 10 of (resi 478 and resn SUB and name H2)
        create theozyme, active_site
        delete 1LW5
        delete active_site
        save theozyme_10A.pdb

Sequence in the theozyme_10A.pdb is the following,

        ARG79(+chrg)-LEU82-PHE85-ILE93-ILE94-PHE95-ARG105(+chrg)-PHE186-LEU189-ASP274(-chrg)-LEU275-PHE277-ALA278-GLY279-THR280
        -GLU281(-chrg)-THR282-THR283-THR285-THR286-LEU342-VAL343-ASN346-LEU347-PRO348-HIE349-LEU372-PRO408-PHE409-SER410
        -ARG414(+chrg)-VAL415-CYP416-ALA417-GLY418-GLU419(-chrg)-PHE420-GLY421-HEM477-SUB478

I deleted `LEU 189` and `LEU 372` because they are not required for reactivity. Saved the structure as 'theozyme_10A.pdb'. 
Opened `theozyme_10A.pdb` in GaussView and changed −CO and −NH on the enzyme backbone to H. Saved the structure as `theozyme_10A_fixed.pdb`. 
This structure has 3 cationic (`ARG79`, `ARG105`, and `ARG414`) and 3 anionic residues (`ASP274`, `GLU218` and `GLU419`). Hence, the overall charge of the complex is -2, coming from the two carboxylates of the HEME.

Since the anionic residues have carboxylate functionality and is not stabilized by other H-bonds, I decided to protonate these residues.
In GaussView, protonated the carboxylate functionalities of `ASP274`, `GLU218` and `GLU419`. Saved the protonated structure as `theozyme_10A_fixed_protonated_ASP274-GLU281-GLU419.pdb`
Now the overall charge of the system is +1 (-2 from `HEME` and +3 from `ARG79`, `ARG105`, and `ARG414`).


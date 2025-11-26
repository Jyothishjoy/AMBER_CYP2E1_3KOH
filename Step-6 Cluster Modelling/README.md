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

Saving the final structure from GaussView as `pdb` file is useful, as it retains the newly added cap hydrogens as `HETATM`, and hence they can be easily visualized in GaussView. 

Since the model is reasonably large, G16 maynot be the ideal choice for full QM optimization. I will be using QM/xTB method implemented in Orca-6.1 for the geometry optimization.

Step-I: Fix CA, CB, and HB atoms and run modredundant optimization to relax added cap H atoms.
CA refers to the C atom that directly connects to the newly added cap HA. CB refers to the C atom that connects to the CA atom. HB refers to the H atoms already attached to the CA, which are not the newly added cap HA atoms. 
To generate the input file, I froze CA, CB, and HB atoms using GV. Then I saved this GV input file and copied the atom symbol and freeze/no-freeze identities (-1/0) using Notepad++ into an Excel sheet. Added a new column for atom numbers starting from 0. Then sort the Excel sheet in ascending order for the freeze/no-freeze column. Now, I have the Excel sheet with all ORCA atom numbers for the frozen coordinates. Then I prepared an ORCA input file using this information.

Atom numbers in the QM region can be identified by selecting all the residues in ChemCraft and `View > Hide Certain Atoms > Hide Selected Atoms`. 
Then the remaining atoms will be in the QM layer. I decided to use the basic porphyrine (all C-H) and an SH connected to the Fe as the simplest model for the P450 model, and everything else is moved to the xTB layer. In this way, I can keep the QM layer neutral-doublet. The overall charge is +1, and multiplicity is doublet. Careful about the placement of charge/multiplicity in the input file (two locations).
https://www.faccts.de/docs/orca/6.1/manual/contents/multiscalesimulations/qmmm-molecules.html#system-charges-and-multiplicities


        !QM/XTB B3LYP/G D4 DEF2-SVP OPT
        
        %QMMM 
        QMATOMS {459 521 526 529:533 538:542 545:548 551:560 575:578 591:609} END 
        Charge_Total  1         # charge of the full system. 
        Mult_Total    2         # multiplicity of the full system.
        AutoFF_QM2_Method QM2
        END
        
        %maxcore 12000
        
        %pal nprocs 12 end
        
        %geom
            Constraints 
                { C 0:1 C }
                { C 8 C }
                { C 20:21 C }
        	    { C 24 C }
                { C 35:36 C }
                { C 43 C }
                { C 51 C }
                { C 58 C }
                { C 88 C } 
                { C 97 C }
        		{ C 105:106 C }
        		{ C 113 C }
        		{ C 125:126 C }
        		{ C 133 C }
        		{ C 141 C }
        		{ C 145 C }
        		{ C 147:148 C }
        		{ C 152 C }
        		{ C 158 C }
        		{ C 168 C }
        		{ C 178 C }
        		{ C 223 C }
        		{ C 225 C }
        		{ C 247 C }
        		{ C 252 C }
        		{ C 258 C }
        		{ C 264 C }
        		{ C 271 C }
        		{ C 276 C }
        		{ C 282 C }
        		{ C 289 C }
        		{ C 300 C }
        		{ C 305 C }
        		{ C 313 C }
        		{ C 320 C }
        		{ C 359 C }
        		{ C 367 C }
        		{ C 373 C }
        		{ C 374 C }
        		{ C 379 C }
        		{ C 408 C }
        		{ C 412 C }
        		{ C 416 C }
        		{ C 426 C }
        		{ C 482 C }
        		{ C 485 C }
        		{ C 487 C }
        		{ C 489 C }
        		{ C 494 C }
        		{ C 504 C }
        		{ C 512:513 C }
        		{ C 515:516 C }
            end
          end
          
          
        * XYZ 0 2   # charge and mult. of the high level region
         C          45.44000000   32.87500000   19.15600000 
         C          46.53000000   33.25100000   20.11200000 
         C          46.75000000   32.36400000   21.34300000 
         C          47.37900000   30.99800000   21.21600000 
         N          48.74300000   31.16000000   20.52100000 
         C          49.17600000   30.65600000   19.33600000 
         N          48.38200000   29.98700000   18.57400000 
         N          50.31900000   30.88000000   18.84100000 
         H          45.36500000   31.80900000   19.10200000 
         H          47.42700000   33.11400000   19.50900000 
         H          46.45900000   34.30300000   20.38800000 
         H          47.45100000   32.91900000   21.96700000 
         H          45.87100000   32.37500000   21.98800000 
         H          47.58700000   30.54000000   22.18300000 
         ..............

Step-II: Run optimization by fixing the CA and cap HA atoms only. After this calculation, the model will be ready for further use. 
In the second step, fix only the CA and newly added cap HA atoms. Reoptimize the structure and perform a frequency calculation to ensure the system is at a minimum. This step can also use the `theozyme_10A_fixed_protonated_ASP274-GLU281-GLU419.pdb` file. The cap HA atoms and their immediately connected CA atoms can be easily visualized in GV (because HA are saved as HETATM), and freeze the desired ones using 'Tools > Atom Groups > Gaussian fragments.' It is also noted that some CA have two cap HA atoms. We need to freeze only one of those HA atoms to reduce optimization difficulties and minimize the number of constraints in our calculation.

Step-III: Optimize the reactant and product complex and run an NEB-TS calculation to identify the TS structure.
https://www.faccts.de/docs/orca/6.1/manual/contents/multiscalesimulations/qmmm-molecules.html#subtractive-qm-qm2-method-oniom2



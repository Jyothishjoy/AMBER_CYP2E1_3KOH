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

Based on the information from `info.dat`, and `summary.dat` files, and by visually examining the structure of the active site, `rep.c1.pdb` file will be used for further cluster modelling.

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

**Step-I:**
Fix CA, CB, and HB atoms and run modredundant optimization to relax added cap H atoms.
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

**Step-II:**
Run optimization by fixing the CA and cap HA atoms only. After this calculation, the model will be ready for further use. 
In the second step, fix only the CA and newly added cap HA atoms. Reoptimize the structure and perform a frequency calculation to ensure the system is at a minimum. This step can also use the `theozyme_10A_fixed_protonated_ASP274-GLU281-GLU419.pdb` file. The cap HA atoms and their immediately connected CA atoms can be easily visualized in GV (because HA are saved as HETATM), and freeze the desired ones using 'Tools > Atom Groups > Gaussian fragments.' It is also noted that some CA have two cap HA atoms. We need to freeze only one of those HA atoms to reduce optimization difficulties and minimize the number of constraints in our calculation.

**Step-III: Optimize the reactant and product complex and run an NEB-TS calculation to identify the TS structure.**
https://www.faccts.de/docs/orca/6.1/manual/contents/multiscalesimulations/qmmm-molecules.html#subtractive-qm-qm2-method-oniom2

**Step-IV: OPTTS of the TS structure using Compound Job.***

Here, I am using a 3 strp compund job to reoptimize the TS. First job freezes the cubane and the Fe=O. Next job only freezes the key Fe-O, O-H, and C-H distances. The third job releases all the constraints and reoptimizes the TS. The TS calculation uses a hybrid Hessian for the active part of the TS and a model Hessian for the rest.

        * XYZfile 0 2 QMXTB_ORCA_NEB_NEB-CI_converged.xyz  # charge and mult. of the high level region # XYZ file from NEB-TS optimization but altered Fe-O, O-H and C-H distance for the gas phase TS structure
        
        %maxcore 12000
        %pal nprocs 24 end
        
        
        %compound
        # Step 1: constrained optimization by freezing the cubane and Fe=O
        New_Step
        ! QM/XTB B3LYP/G D4 DEF2-SVP OPT 
        
        %QMMM 
        QMATOMS {459 521 526 529:533 538:542 545:548 551:560 575:578 591:609} END 
        
        ActiveAtoms { 1:19 21:34 36:50 52:87 89:104 106:124 126:140 142:146 148:151 153:167 169:224 226:246 248:257 259:270 272:281 283:299 301:312 314:358 360:372 374:407 409:415 417:481 483:486 488:493 495:512 514:609 611 615 617 624 632 } END
        
        Charge_Total  1         # charge of the full system. 
        Mult_Total    2         # multiplicity of the full system.
        
        AutoFF_QM2_Method QM2   # Toplogy for automatic identificatiion of boundary
        END
        
        %geom 
            Constraints
        	      { C 560 C }
                { C 542 C }
                { C 601 C } 
                { C 591 C }
                { C 600 C }
                { C 602 C }
                { C 592 C }
                { C 593 C }
                { C 603 C }
                { C 599 C }
                { C 609 C }
                { C 594 C }
                { C 604 C }
                { C 598 C } 
                { C 608 C }
                { C 596 C }
                { C 506 C }
                { C 597 C }
                { C 607 C }
                { C 595 C }
                { C 605 C }
            end
        end
        Step_End
        
        # Step 2: constrained optimization by freezing Fe-O, O-H and C-H bonds
        New_Step
        ! QM/XTB B3LYP/G D4 DEF2-SVP OPT 
        
        %QMMM 
        QMATOMS {459 521 526 529:533 538:542 545:548 551:560 575:578 591:609} END 
        
        ActiveAtoms { 1:19 21:34 36:50 52:87 89:104 106:124 126:140 142:146 148:151 153:167 169:224 226:246 248:257 259:270 272:281 283:299 301:312 314:358 360:372 374:407 409:415 417:481 483:486 488:493 495:512 514:609 611 615 617 624 632 } END
        
        Charge_Total  1         # charge of the full system. 
        Mult_Total    2         # multiplicity of the full system.
        
        AutoFF_QM2_Method QM2   # Toplogy for automatic identificatiion of boundary
        END
        
        %geom 
            Constraints
        	      { B 560 542 C }
                { B 542 601 C }
                { B 591 601 C }
            end
        end
        Step_End
        
        # Step 3: full TS optimization
        New_Step
        ! QM/XTB B3LYP/G D4 DEF2-SVP OPTTS  NumFreq
        
        %QMMM 
        QMATOMS {459 521 526 529:533 538:542 545:548 551:560 575:578 591:609} END 
        
        ActiveAtoms { 1:19 21:34 36:50 52:87 89:104 106:124 126:140 142:146 148:151 153:167 169:224 226:246 248:257 259:270 272:281 283:299 301:312 314:358 360:372 374:407 409:415 417:481 483:486 488:493 495:512 514:609 611 615 617 624 632 } END
        
        Charge_Total  1         # charge of the full system. 
        Mult_Total    2         # multiplicity of the full system.
        
        AutoFF_QM2_Method QM2   # Toplogy for automatic identificatiion of boundary
        END
        
        %Geom
        	Calc_Hess True
        	Hybrid_Hess {542 560 591 592 600 601 602 } end
        	MaxIter 500
        end
        
        Step_End
        
        End


**Step-V: Partial Hessian Vibrational Analysis.**

https://www.faccts.de/docs/orca/6.1/manual/contents/multiscalesimulations/qmmm-general.html?q=PHVA&n=1#frequency-calculation

        !QM/XTB B3LYP/G D4 DEF2-SVP NumFreq
        
        %maxcore 12000
        %pal nprocs 24 end
        
        %QMMM 
        QMATOMS {459 521 526 529:533 538:542 545:548 551:560 575:578 591:609} END 
        
        ActiveAtoms { 1:19 21:34 36:50 52:87 89:104 106:124 126:140 142:146 148:151 153:167 169:224 226:246 248:257 259:270 272:281 283:299 301:312 314:358 360:372 374:407 409:415 417:481 483:486 488:493 495:512 514:609 611 615 617 624 632 } END
        
        Charge_Total  1         # charge of the full system. 
        Mult_Total    2         # multiplicity of the full system.
        
        AutoFF_QM2_Method QM2   # Toplogy for automatic identificatiion of boundary
        
        END
        
        * XYZ 0 2   # charge and mult. of the high level region # XYZ file from Step-V-NEB/OPTTS-C_H-1_33/OPTTS-HybHess/ optimization
        C    45.440001000000     32.874998000000     19.156001000000
        C    46.594733000000     33.314638000000     20.047896000000
        C    46.755789000000     32.452053000000     21.298681000000
        C    47.369294000000     31.083354000000     20.989905000000
        N    48.732211000000     31.225729000000     20.523667000000
        C    49.250854000000     30.792342000000     19.370484000000
        N    48.539049000000     30.169169000000     18.439300000000
        N    50.538145000000     31.011699000000     19.119514000000
        H    45.386271000000     31.791192000000     19.106993000000
        H    47.526142000000     33.258577000000     19.480411000000
        H    46.439250000000     34.354281000000     20.347550000000
        H    47.415853000000     32.963176000000     22.001946000000
        H    45.785755000000     32.306044000000     21.774401000000
        H    47.378973000000     30.489879000000     21.909802000000
        H    46.772837000000     30.548938000000     20.253607000000
        H    49.332591000000     31.763054000000     21.141457000000
        H    49.052264000000     29.816720000000     17.632908000000
        H    47.607567000000     29.801492000000     18.586010000000
        H    50.892670000000     30.644367000000     18.223217000000
        H    51.125624000000     31.568243000000     19.726781000000
        ..............
        ..............


**Step VI:**
During the TS optimization we found that the TS looks very earlier compared to the PCM-TS optimized for just the FePor-methcubane complex. This prompted us to neutralize the system and recalculate the TS.
We deprotonated H435 (Orca counting) of ARG414 to generate the neutral doublet system. Every atom count after 435 is now shifted to one unit down.

        * XYZfile 0 2 QMXTB_ORCA_NEB_NEB-CI_converged_neutral.xyz  # charge and mult. of the high level region # XYZ file from NEB-TS optimization but altered Fe-O, O-H and C-H distance for the gas phase TS structure
        
        %maxcore 12000
        %pal nprocs 24 end
        
        
        %compound
        # Step 1: constrained optimization by freezing the cubane and Fe=O
        New_Step
        ! QM/XTB B3LYP/G D4 DEF2-SVP OPT 
        
        %QMMM 
        QMATOMS { 458 520 525 528:532 537:541 544:547 550:559 574:577 590:608 } END 
        
        ActiveAtoms { 1:19 21:34 36:50 52:87 89:104 106:124 126:140 142:146 148:151 153:167 169:224 226:246 248:257 259:270 272:281 283:299 301:312 314:358 360:372 374:407 409:415 417:480 482:485 487:492 494:511 513:608 610 614 616 623 631 } END
        
        Charge_Total  0         
        Mult_Total    2         
        
        AutoFF_QM2_Method QM2   
        END
        
        %geom 
            Constraints
                { C 559 C }
                { C 541 C }
                { C 600 C }
                { C 590 C }
                { C 599 C }
                { C 601 C }
                { C 591 C }
                { C 592 C }
                { C 602 C }
                { C 598 C }
                { C 608 C }
                { C 593 C }
                { C 603 C }
                { C 597 C }
                { C 607 C }
                { C 595 C }
                { C 505 C }
                { C 596 C }
                { C 606 C }
                { C 594 C }
                { C 604 C }
            end
        end
        Step_End
        
        # Step 2: constrained optimization by freezing Fe-O, O-H and C-H bonds
        New_Step
        ! QM/XTB B3LYP/G D4 DEF2-SVP OPT 
        
        %QMMM 
        QMATOMS { 458 520 525 528:532 537:541 544:547 550:559 574:577 590:608 } END 
        
        ActiveAtoms { 1:19 21:34 36:50 52:87 89:104 106:124 126:140 142:146 148:151 153:167 169:224 226:246 248:257 259:270 272:281 283:299 301:312 314:358 360:372 374:407 409:415 417:480 482:485 487:492 494:511 513:608 610 614 616 623 631 } END
        
        Charge_Total  0         # charge of the full system. 
        Mult_Total    2         # multiplicity of the full system.
        
        AutoFF_QM2_Method QM2   # Toplogy for automatic identificatiion of boundary
        END
        
        %geom 
            Constraints
        	    { B 559 541 C }
                { B 541 600 C }
                { B 590 600 C }
            end
        end
        Step_End
        
        # Step 3: full TS optimization
        New_Step
        ! QM/XTB B3LYP/G D4 DEF2-SVP OPTTS  NumFreq
        
        %QMMM 
        QMATOMS { 458 520 525 528:532 537:541 544:547 550:559 574:577 590:608 } END 
        
        ActiveAtoms { 1:19 21:34 36:50 52:87 89:104 106:124 126:140 142:146 148:151 153:167 169:224 226:246 248:257 259:270 272:281 283:299 301:312 314:358 360:372 374:407 409:415 417:480 482:485 487:492 494:511 513:608 610 614 616 623 631 } END
        
        Charge_Total  0         # charge of the full system. 
        Mult_Total    2         # multiplicity of the full system.
        
        AutoFF_QM2_Method QM2   # Toplogy for automatic identificatiion of boundary
        END
        
        %Geom
        	Calc_Hess True
        	Hybrid_Hess {541 559 590 592 599 600 601 } end
        	MaxIter 500
        end
        
        Step_End
        
        End


**Step-VII:**
The neutral system did not introduce any changes to the TS structure. However, this structural change appears to be an ORCA artifact, particularly with the def2SVP basis set. We re-optimized the TS using only the QM region with `UB3LYP/def2SVP CPCM(DCM)` and `UB3LYP/6-31G*/LANL2DZ CPCM(DCM)` in ORCA-6.1.1. While these calculations resulted in an early TS, the spin distribution was incorrect.

We then reoptimized the same TS in Gaussian-16 using `UB3LYP/def2SVP CPCM(DCM)` and `UB3LYP/6-31G*/LANL2DZ CPCM(DCM)` levels of theory. This demonstrated that only `UB3LYP-D3(BJ)/6-31G*/LANL2DZ CPCM(DCM)` could correctly determine the spin densities and the later TS structure. Additionally, ORCA only has RHF-->UHF wavefunction stability analysis implemented, and therefore, it cannot correct for internal instabilities.

Thus, the observation that `UB3LYP/6-31G*/LANL2DZ` level of theory is needed for this problem, and the lack of a solution for internal instability prompted us to use Gaussian-16 to move forward. 
We then decided to use Gaussian's external tools option to incorporate xTB to carry out `QM/xTB` type ONIOM calculations. This was done using Tian Lu's `gau_xtb` package. A detailed instruction on its installation and usage can be found in my GitHub post (**Gaussian-xTB**)

**Step-VIII:**
We took the fully optimized TS coordinates from the ORCA QM/xTB calculation and prepared a Gaussian QM/xTB file using the ONIOM procedure. 
Link atoms were added using GaussView and manually checked to ensure consistency with the ORCA link atoms.

Tip: To generate proper link atoms in GaussView:
a) Open the structure in GV and connect all atoms in the high level using bonds, then remove any bonds between high and low levels.
b) Tools --> Select layers. Select All --> Apply as Middle layer.
c) Select a High layer atom --> Expand Selection --> Apply. This will select all high-layer atoms.
d) Now, add all the bonds between High and Medium layers that were deleted in the previous step. This will ensure that GV assigns the correct Link atoms when the file is saved.
e) Always double-check the Link atoms.


        %chk=theozyme_from_ORCA_QMxTB_OPTTS_GauxTB_ModRed.chk
        %mem=96GB
        %nprocs=24
        # opt=(ModRed,maxcycles=500,nomicro) Freq oniom(ub3lyp/genecp:external='gau_xtb') scf=(maxcycles=500,xqc)
        
        TS optimization using QM/xTB OPTTS structure from NEB-TS in ORCA-6.1.1 
        
        1 2 0 2 0 2
         C              -1   45.440001000     32.874998000     19.156001000 M
         C               0   46.593951000     33.313693000     20.049484000 M
         C               0   46.755802000     32.448268000     21.298259000 M
         C               0   47.372698000     31.081820000     20.986425000 M
         N               0   48.734911000     31.228758000     20.519515000 M
         C               0   49.254700000     30.795931000     19.366438000 M
         N               0   48.544645000     30.169984000     18.435892000 M
         N               0   50.541095000     31.019385000     19.114739000 M
         H               0   45.386126000     31.791247000     19.105969000 M
         H               0   47.525515000     33.260267000     19.482051000 M
         H               0   46.436711000     34.352359000     20.351745000 M
         .....................................................................
         .....................................................................
        
        B 561 543 F
        B 543 602 F
        B 602 592 F
        
        -C -H -N -O -S 0
        6-31G(d)
        ******
        -Fe 0
        LANL2DZ
        ******
        
        -Fe 0
        LANL2DZ



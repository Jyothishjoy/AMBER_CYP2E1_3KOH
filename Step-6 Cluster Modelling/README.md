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

Step-IV: OPTTS of the TS structure using Compound Job.

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


Step-V: Partial Hessian Vibrational Analysis.

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


Step VI: During the TS optimization we found that the TS looks very earlier compared to the PCM-TS optimized for just the FePor-methcubane complex. This prompted us to neutralize the system and recalculate the TS.
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


Step-VII
The neutral system did not make any changes to the TS structure. As it turned out, this structural change is an ORCA thing, especially with def2SVP basis set. 
We took the QM region only and reoptimized the TS in `UB3LYP/def2SVP CPCM(DCM)` and `UB3LYP/6-31G*/LANL2DZ CPCM(DCM)` levels of theory in ORCA-6.1.1. 
Both of these calculations resulted in an early TS, but their spin distribution was wrong.

We then reoptimized the same TS in Gaussian-16 using `UB3LYP/def2SVP CPCM(DCM)` and `UB3LYP/6-31G*/LANL2DZ CPCM(DCM)` levels of theory. 
This showed that `UB3LYP-D3(BJ)/6-31G*/LANL2DZ CPCM(DCM)` can only get the spin densities correct and the later TS structure.
Also, ORCA has only RHF-->UHF wavefunction stability analysis implemented. Hence, it cannot correct for internal instabilities. 

Thus, the observation that `UB3LYP/6-31G*/LANL2DZ` level of theory is needed for this problem, and the lack of a solution for internal instability prompted us to use gaussian-16 to move forward.

We then decided to use Gaussian's external tools option to incorporate xTB to carryout `QM/xTB` type ONIOM calculations. This was done using Tian Lu's `gau_xtb` package. 
A detailed instruction on it's installation and usage can be found in my GitHub post (**Gaussian-xTB**)

Step-VIII
We took the fully optimized TS coordinates from the ORCA QM/xTB calculation, and prepared a Gaussian QM/xTB file using the ONIOM procedure. 

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
         H               0   47.413911000     32.959040000     22.003652000 M
         H               0   45.785673000     32.298745000     21.772692000 M
         H               0   47.384682000     30.486427000     21.905117000 M
         H               0   46.776960000     30.547548000     20.249430000 M
         H               0   49.334303000     31.766988000     21.137348000 M
         H               0   49.059579000     29.817924000     17.629979000 M
         H               0   47.614040000     29.800551000     18.582636000 M
         H               0   50.897218000     30.648727000     18.220339000 M
         H               0   51.128306000     31.575586000     19.722577000 M
         C              -1   44.814000000     27.123000000     25.806000000 M
         C               0   46.292301000     27.003362000     25.450842000 M
         C               0   46.532410000     26.772424000     23.952555000 M
         C               0   46.390001000     28.076324000     23.169091000 M
         C               0   47.917440000     26.174397000     23.710991000 M
         H               0   44.309421000     26.173705000     25.638456000 M
         H               0   46.818547000     27.908618000     25.763994000 M
         H               0   46.715532000     26.167071000     26.011826000 M
         H               0   45.783271000     26.058413000     23.592804000 M
         H               0   46.522657000     27.909145000     22.102144000 M
         H               0   45.410061000     28.521201000     23.320912000 M
         H               0   47.146824000     28.786970000     23.499397000 M
         H               0   48.691583000     26.838027000     24.093741000 M
         H               0   48.015638000     25.209401000     24.203185000 M
         H               0   48.087991000     26.031808000     22.645957000 M
         C              -1   47.174001000     28.907000000     30.974000000 M
         C               0   48.026815000     29.021691000     29.707742000 M
         C               0   49.335339000     28.297870000     29.846840000 M
         C               0   50.387535000     28.872972000     30.548582000 M
         C               0   49.518222000     27.041121000     29.286044000 M
         C               0   51.598046000     28.216108000     30.674520000 M
         C               0   50.727532000     26.379171000     29.411800000 M
         C               0   51.773311000     26.966715000     30.102963000 M
         H               0   47.679812000     29.361945000     31.821556000 M
         H               0   47.471007000     28.608326000     28.863348000 M
         H               0   48.217635000     30.077832000     29.499205000 M
         H               0   50.258619000     29.850066000     30.992008000 M
         H               0   48.707673000     26.579372000     28.739861000 M
         H               0   52.407957000     28.682764000     31.216102000 M
         H               0   50.854338000     25.402335000     28.967511000 M
         H               0   52.718063000     26.451020000     30.199404000 M
         C              -1   53.755000000     36.319999000     24.203000000 M
         C               0   52.761620000     35.311957000     23.633697000 M
         O               0   52.118838000     35.529921000     22.625759000 M
         C               0   55.220892000     35.987699000     23.859230000 M
         C               0   55.335391000     35.557877000     22.390690000 M
         C               0   55.817377000     34.943392000     24.800972000 M
         C               0   56.762271000     35.617297000     21.858425000 M
         H               0   53.503000000     37.276899000     23.741609000 M
         H               0   55.789923000     36.915173000     23.990837000 M
         H               0   54.943304000     34.544239000     22.277730000 M
         H               0   54.701065000     36.209488000     21.786348000 M
         H               0   55.603721000     35.194136000     25.838654000 M
         H               0   55.421061000     33.954126000     24.585636000 M
         H               0   56.896600000     34.901266000     24.681338000 M
         H               0   56.784024000     35.336904000     20.808039000 M
         H               0   57.161544000     36.624464000     21.953546000 M
         H               0   57.415162000     34.937487000     22.399233000 M
         N               0   52.617994000     34.148622000     24.318286000 M
         C               0   51.926799000     33.018741000     23.713942000 M
         C               0   50.405105000     33.198011000     23.729189000 M
         O               0   49.708789000     32.973046000     22.753233000 M
         C               0   52.226125000     31.681677000     24.425979000 M
         C               0   53.726525000     31.382656000     24.525440000 M
         C               0   51.517677000     30.552679000     23.677726000 M
         C               0   54.032873000     30.291790000     25.546612000 M
         H               0   53.134426000     33.999878000     25.170171000 M
         H               0   52.225350000     32.954805000     22.658701000 M
         H               0   51.821600000     31.737532000     25.444495000 M
         H               0   54.099191000     31.076244000     23.548026000 M
         H               0   54.267619000     32.285163000     24.817190000 M
         H               0   50.440581000     30.689992000     23.689300000 M
         H               0   51.851961000     30.526242000     22.643545000 M
         H               0   51.736348000     29.597454000     24.144602000 M
         H               0   53.572890000     30.518806000     26.506630000 M
         H               0   53.656598000     29.329429000     25.213977000 M
         H               0   55.106890000     30.197520000     25.685187000 M
         N               0   49.886633000     33.544046000     24.916050000 M
         C              -1   48.468000000     33.456000000     25.208000000 M
         C               0   48.244274000     32.923860000     26.626060000 M
         C               0   49.067110000     31.685105000     26.861585000 M
         C               0   48.763699000     30.498036000     26.207166000 M
         C               0   50.175766000     31.720200000     27.697614000 M
         C               0   49.560106000     29.379680000     26.374793000 M
         C               0   50.971920000     30.601120000     27.872583000 M
         C               0   50.670272000     29.430230000     27.199759000 M
         H               0   50.504021000     33.751502000     25.684774000 M
         H               0   48.038739000     32.777301000     24.466469000 M
         H               0   48.515877000     33.693519000     27.351676000 M
         H               0   47.182449000     32.704619000     26.748410000 M
         H               0   47.893315000     30.452597000     25.568005000 M
         H               0   50.407671000     32.632997000     28.232368000 M
         H               0   49.312463000     28.461206000     25.864403000 M
         H               0   51.818658000     30.638115000     28.541109000 M
         H               0   51.289565000     28.557421000     27.333754000 M
         C              -1   56.695000000     39.723000000     20.581000000 M
         C               0   55.634137000     38.922060000     19.835315000 M
         C               0   56.213250000     38.152017000     18.651087000 M
         C               0   55.173400000     37.240813000     17.993741000 M
         N               0   55.718367000     36.676072000     16.776354000 M
         C               0   55.761314000     35.392498000     16.393974000 M
         N               0   55.178415000     34.415242000     17.046928000 M
         N               0   56.414866000     35.096763000     15.262127000 M
         H               0   57.543211000     39.087123000     20.827030000 M
         H               0   55.181486000     38.209621000     20.527462000 M
         H               0   54.845101000     39.590557000     19.486453000 M
         H               0   56.586946000     38.864791000     17.911551000 M
         H               0   57.057403000     37.547080000     18.987876000 M
         H               0   54.885137000     36.433333000     18.666673000 M
         H               0   54.275597000     37.822095000     17.752904000 M
         H               0   56.199885000     37.337004000     16.184902000 M
         H               0   54.462479000     34.481933000     17.800191000 M
         H               0   55.262417000     33.493592000     16.622710000 M
         H               0   57.076281000     35.734227000     14.856209000 M
         H               0   56.498371000     34.096680000     15.057395000 M
         C              -1   54.031999000     19.089002000     28.064000000 M
         C               0   55.360706000     19.336013000     27.356018000 M
         C               0   55.298124000     19.222926000     25.855188000 M
         C               0   56.249358000     18.478034000     25.169968000 M
         C               0   54.326041000     19.892353000     25.120652000 M
         C               0   56.227198000     18.405586000     23.788410000 M
         C               0   54.301553000     19.819765000     23.738942000 M
         C               0   55.255504000     19.074442000     23.065661000 M
         H               0   53.247581000     19.732344000     27.672899000 M
         H               0   55.705283000     20.345806000     27.609151000 M
         H               0   56.101649000     18.628453000     27.732790000 M
         H               0   57.019540000     17.946896000     25.709596000 M
         H               0   53.570881000     20.475118000     25.631615000 M
         H               0   56.976078000     17.820288000     23.280387000 M
         H               0   53.531140000     20.343317000     23.190535000 M
         H               0   55.228375000     18.987468000     21.991013000 M
         C              -1   56.340000000     31.605000000     29.107000000 M
         C               0   57.533781000     31.148631000     28.290924000 M
         O               0   57.601851000     30.048181000     27.766848000 M
         C               0   55.454360000     32.558282000     28.310049000 M
         C               0   54.091169000     32.660497000     28.950491000 M
         O               0   53.573239000     31.827717000     29.638431000 M
         O              -1   53.493000000     33.814000000     28.634000000 M
         H               0   55.747280000     30.727983000     29.374099000 M
         H               0   55.882148000     33.557263000     28.223070000 M
         H               0   55.306307000     32.162093000     27.301697000 M
         N               0   58.503852000     32.062131000     28.161483000 M
         C              -1   59.703000000     31.790000000     27.396000000 M
         C               0   60.566380000     33.034890000     27.255413000 M
         C               0   59.930499000     34.141619000     26.401871000 M
         C               0   60.735567000     35.430573000     26.554194000 M
         C               0   59.860868000     33.743367000     24.928989000 M
         H               0   58.464687000     32.929847000     28.671125000 M
         H               0   59.396739000     31.416823000     26.413455000 M
         H               0   60.780829000     33.426367000     28.253007000 M
         H               0   61.517852000     32.745806000     26.807339000 M
         H               0   58.909999000     34.326041000     26.760243000 M
         H               0   61.754871000     35.280384000     26.207407000 M
         H               0   60.290545000     36.231242000     25.968584000 M
         H               0   60.771477000     35.748104000     27.593894000 M
         H               0   60.850535000     33.489897000     24.557301000 M
         H               0   59.205649000     32.889428000     24.777582000 M
         H               0   59.480835000     34.571192000     24.334508000 M
         C              -1   59.187000000     26.782000000     29.705000000 M
         C               0   59.009816000     26.403007000     28.252968000 M
         O               0   59.537110000     25.418203000     27.748693000 M
         C               0   57.830875000     26.624474000     30.432616000 M
         C               0   57.017845000     25.503892000     29.839022000 M
         C               0   55.848335000     25.775595000     29.140367000 M
         C               0   57.448014000     24.186315000     29.934828000 M
         C               0   55.127967000     24.756402000     28.542366000 M
         C               0   56.731939000     23.166427000     29.334240000 M
         C               0   55.572424000     23.449089000     28.632204000 M
         H               0   59.936402000     26.117841000     30.133824000 M
         H               0   58.016916000     26.434948000     31.491458000 M
         H               0   57.265268000     27.554963000     30.352770000 M
         H               0   55.496158000     26.795680000     29.064371000 M
         H               0   58.351225000     23.958662000     30.481352000 M
         H               0   54.218373000     24.983609000     28.004752000 M
         H               0   57.079470000     22.147239000     29.416711000 M
         H               0   55.014104000     22.654670000     28.160400000 M
         N               0   58.182725000     27.192641000     27.550166000 M
         C               0   57.767403000     26.817476000     26.215395000 M
         C               0   58.966085000     26.722421000     25.274490000 M
         O               0   58.988527000     25.918067000     24.357539000 M
         C               0   56.760935000     27.820580000     25.670721000 M
         H               0   57.816856000     28.057432000     27.925705000 M
         H               0   57.322043000     25.813536000     26.248854000 M
         H               0   55.854507000     27.795072000     26.269716000 M
         H               0   57.182384000     28.821336000     25.715163000 M
         H               0   56.512700000     27.578406000     24.641115000 M
         N               0   59.946142000     27.602712000     25.515127000 M
         C               0   61.194747000     27.609546000     24.797180000 M
         C               0   62.311568000     26.766249000     25.430971000 M
         O               0   63.474837000     27.081655000     25.289036000 M
         H               0   59.871232000     28.186575000     26.334934000 M
         H               0   61.021384000     27.208582000     23.793143000 M
         H               0   61.557242000     28.634534000     24.703826000 M
         N               0   61.895112000     25.668934000     26.084788000 M
         C               0   62.832406000     24.798117000     26.759979000 M
         C               0   62.518592000     23.332296000     26.448281000 M
         O               0   63.270751000     22.655199000     25.771644000 M
         C               0   62.860201000     25.108564000     28.275332000 M
         C               0   63.975026000     24.321344000     28.957967000 M
         O               0   62.984563000     26.498129000     28.474594000 M
         H               0   60.919208000     25.553558000     26.328440000 M
         H               0   63.818403000     25.018508000     26.330834000 M
         H               0   61.890713000     24.856767000     28.718560000 M
         H               0   63.786806000     26.797436000     28.026984000 M
         H               0   64.938635000     24.581649000     28.524541000 M
         H               0   63.996978000     24.552855000     30.019779000 M
         H               0   63.814892000     23.254693000     28.829810000 M
         N               0   61.360032000     22.860885000     26.947409000 M
         C               0   60.945202000     21.483209000     26.718712000 M
         C               0   60.722412000     21.189061000     25.228040000 M
         O               0   60.660417000     20.045334000     24.809347000 M
         C               0   59.712360000     21.179541000     27.583574000 M
         C               0   59.166259000     19.751970000     27.483377000 M
         C               0   60.106158000     18.663734000     27.954296000 M
         O               0   61.273566000     18.804201000     28.202952000 M
         O              -1   59.471000000     17.492000000     28.084000000 M
         H               0   60.708928000     23.485985000     27.403204000 M
         H               0   61.760927000     20.815043000     27.025249000 M
         H               0   59.990082000     21.378869000     28.621559000 M
         H               0   58.913143000     21.871407000     27.302180000 M
         H               0   58.253228000     19.672516000     28.075216000 M
         H               0   58.899067000     19.509324000     26.453546000 M
         N               0   60.604585000     22.258071000     24.435124000 M
         C               0   60.616713000     22.184161000     22.996482000 M
         C               0   61.747149000     21.307015000     22.453818000 M
         O               0   61.552523000     20.508945000     21.548710000 M
         C               0   60.806277000     23.635138000     22.417446000 M
         C               0   59.569211000     24.078454000     21.656459000 M
         O               0   61.140414000     24.540828000     23.438796000 M
         H               0   60.772536000     23.197812000     24.782067000 M
         H               0   59.676956000     21.752454000     22.636409000 M
         H               0   61.671797000     23.620811000     21.742667000 M
         H               0   60.327441000     25.029058000     23.681393000 M
         H               0   59.650329000     25.122928000     21.363882000 M
         H               0   59.440571000     23.489024000     20.755838000 M
         H               0   58.686460000     23.975643000     22.280514000 M
         N               0   62.952780000     21.580526000     22.957814000 M
         C              -1   64.171000000     21.078000000     22.372000000 M
         C               0   65.127827000     22.232994000     22.019099000 M
         C               0   65.773399000     22.821209000     23.266688000 M
         O               0   66.165969000     21.782244000     21.177304000 M
         H               0   63.043622000     22.135781000     23.800433000 M
         H               0   63.887276000     20.534778000     21.465366000 M
         H               0   64.542759000     23.014349000     21.502014000 M
         H               0   65.789552000     21.379722000     20.387327000 M
         H               0   66.426198000     22.076444000     23.713353000 M
         H               0   66.371284000     23.686919000     22.997085000 M
         H               0   65.019465000     23.114814000     23.990428000 M
         C              -1   61.515000000     16.705000000     23.971000000 M
         C               0   62.245811000     16.307430000     22.713129000 M
         O               0   62.734727000     15.206631000     22.544917000 M
         C               0   60.007301000     16.895463000     23.712755000 M
         C               0   59.321356000     15.549561000     23.510850000 M
         O               0   59.395539000     17.551227000     24.800543000 M
         H               0   61.645445000     15.904107000     24.702724000 M
         H               0   59.875670000     17.506201000     22.804351000 M
         H               0   59.825134000     18.417523000     24.873561000 M
         H               0   59.354387000     14.982954000     24.437758000 M
         H               0   58.280908000     15.692667000     23.231315000 M
         H               0   59.830486000     14.988423000     22.732708000 M
         N               0   62.303621000     17.269371000     21.769541000 M
         C              -1   62.827000000     16.935000000     20.467000000 M
         C               0   63.006556000     18.171443000     19.573520000 M
         C               0   63.635481000     17.761697000     18.243709000 M
         O               0   61.780981000     18.809923000     19.293658000 M
         H               0   61.846470000     18.159590000     21.898824000 M
         H               0   62.157411000     16.224509000     19.967191000 M
         H               0   63.683418000     18.871711000     20.089000000 M
         H               0   61.532345000     19.366656000     20.047571000 M
         H               0   64.603641000     17.298046000     18.406729000 M
         H               0   62.981857000     17.058194000     17.735910000 M
         H               0   63.756495000     18.636192000     17.609641000 M
         C              -1   56.500000000     18.432000000     18.027000000 M
         C               0   55.121130000     18.525562000     18.746237000 M
         O               0   54.906860000     17.946979000     19.792511000 M
         C               0   57.347651000     19.662704000     18.337142000 M
         C               0   57.496508000     19.949699000     19.832303000 M
         C               0   58.245351000     18.828948000     20.546070000 M
         C               0   58.222482000     21.276307000     20.028835000 M
         H               0   56.984363000     17.520773000     18.363837000 M
         H               0   58.342320000     19.522038000     17.906168000 M
         H               0   56.883005000     20.533239000     17.862686000 M
         H               0   56.496731000     20.039859000     20.270245000 M
         H               0   59.183743000     18.619142000     20.037062000 M
         H               0   58.464992000     19.124468000     21.569293000 M
         H               0   57.642701000     17.925569000     20.574672000 M
         H               0   58.206443000     21.541933000     21.081481000 M
         H               0   59.258093000     21.193474000     19.704925000 M
         H               0   57.743663000     22.080099000     19.469982000 M
         N               0   54.168926000     19.292001000     18.145016000 M
         C              -1   52.809000000     19.551000000     18.661000000 M
         C               0   52.735001000     20.843992000     19.481280000 M
         C               0   53.149172000     22.058549000     18.650663000 M
         C               0   51.321492000     21.019169000     20.028759000 M
         H               0   54.420982000     19.789386000     17.305815000 M
         H               0   52.537383000     18.699005000     19.286482000 M
         H               0   53.429849000     20.745569000     20.323100000 M
         H               0   52.551768000     22.121252000     17.742515000 M
         H               0   52.999715000     22.974266000     19.219059000 M
         H               0   54.199982000     21.999306000     18.372174000 M
         H               0   50.614458000     21.188899000     19.220471000 M
         H               0   51.005488000     20.130034000     20.565727000 M
         H               0   51.273820000     21.866812000     20.708621000 M
         C              -1   49.213000000     22.824000000     16.993000000 M
         C               0   48.594750000     23.661963000     18.108802000 M
         O               0   47.688611000     23.243989000     18.812140000 M
         C               0   49.047273000     23.472001000     15.608086000 M
         C               0   50.115451000     24.511487000     15.272367000 M
         N               0   50.164894000     24.877283000     13.983518000 M
         O               0   50.884514000     24.976637000     16.098434000 M
         H               0   50.280597000     22.721163000     17.205082000 M
         H               0   49.079773000     22.697100000     14.838917000 M
         H               0   48.072294000     23.963264000     15.540792000 M
         H               0   49.502205000     24.532269000     13.311897000 M
         H               0   50.812343000     25.601852000     13.681245000 M
         N               0   49.144917000     24.877004000     18.262053000 M
         C               0   48.626153000     25.852896000     19.198706000 M
         C               0   47.450730000     26.585011000     18.528653000 M
         O               0   47.641325000     27.365284000     17.608030000 M
         C               0   49.668588000     26.906483000     19.570799000 M
         C               0   51.024551000     26.368612000     20.044282000 M
         C               0   51.784448000     27.510177000     20.723106000 M
         C               0   50.894526000     25.188605000     21.000994000 M
         H               0   49.871421000     25.170617000     17.614200000 M
         H               0   48.284081000     25.311288000     20.082709000 M
         H               0   49.824375000     27.542465000     18.696613000 M
         H               0   49.230500000     27.526861000     20.358381000 M
         H               0   51.591462000     26.031507000     19.171977000 M
         H               0   51.308103000     27.765791000     21.668784000 M
         H               0   52.814995000     27.224494000     20.919780000 M
         H               0   51.781050000     28.401415000     20.099168000 M
         H               0   50.405190000     24.347074000     20.519814000 M
         H               0   51.881985000     24.862738000     21.317414000 M
         H               0   50.322210000     25.472802000     21.881819000 M
         N               0   46.220332000     26.332582000     18.992240000 M
         C               0   45.073098000     26.905917000     18.309904000 M
         C               0   45.203367000     28.400540000     18.020298000 M
         O               0   45.713772000     29.196626000     18.797763000 M
         C               0   43.917835000     26.638783000     19.277991000 M
         C               0   44.301478000     25.288749000     19.876042000 M
         C               0   45.818109000     25.395675000     20.032161000 M
         H               0   44.920800000     26.374570000     17.360813000 M
         H               0   43.910881000     27.410137000     20.050394000 M
         H               0   42.953128000     26.629788000     18.776172000 M
         H               0   43.805044000     25.091350000     20.823592000 M
         H               0   44.053378000     24.488594000     19.178919000 M
         H               0   46.076654000     25.800757000     21.016438000 M
         H               0   46.306916000     24.428989000     19.889212000 M
         N               0   44.534583000     28.748799000     16.915363000 M
         C              -1   44.407000000     30.098000000     16.412000000 M
         C               0   44.968758000     30.195209000     14.984400000 M
         C               0   46.255801000     29.449017000     14.876667000 M
         C               0   47.545637000     29.900424000     14.944470000 M
         N               0   46.258787000     28.090144000     14.736368000 M
         C               0   47.521991000     27.747098000     14.717873000 M
         N               0   48.342114000     28.803069000     14.832388000 M
         H               0   44.358273000     28.035551000     16.221246000 M
         H               0   44.941492000     30.761240000     17.092035000 M
         H               0   44.252172000     29.750365000     14.291181000 M
         H               0   45.108935000     31.243443000     14.719146000 M
         H               0   47.945924000     30.888431000     15.048758000 M
         H               0   47.875068000     26.740201000     14.619436000 M
         H               0   49.373625000     28.801360000     14.838304000 M
         N              -1   57.979000000     22.602001000     10.708002000 M
         C               0   57.677521000     22.278515000     12.107472000 M
         C               0   57.200464000     23.498310000     12.885207000 M
         O               0   56.673804000     23.411626000     13.978965000 M
         C               0   58.995125000     21.759414000     12.728265000 M
         C               0   59.773792000     21.250385000     11.519914000 M
         C               0   59.386901000     22.278336000     10.457761000 M
         H               0   56.899083000     21.511547000     12.188014000 M
         H               0   59.534594000     22.587496000     13.191658000 M
         H               0   58.811284000     20.992384000     13.474933000 M
         H               0   60.845353000     21.215488000     11.698723000 M
         H               0   59.429641000     20.255531000     11.232603000 M
         H               0   59.979113000     23.186918000     10.598811000 M
         H               0   59.528815000     21.926150000      9.436875000 M
         N               0   57.420962000     24.672626000     12.261549000 M
         C               0   57.432381000     25.936852000     12.958459000 M
         C               0   56.222627000     26.831628000     12.673633000 M
         O               0   56.161803000     27.964960000     13.131370000 M
         C               0   58.722865000     26.704336000     12.628805000 M
         C               0   59.935457000     25.935982000     13.074153000 M
         C               0   60.268664000     25.854744000     14.420550000 M
         C               0   60.733722000     25.284461000     12.142898000 M
         C               0   61.383881000     25.142492000     14.824361000 M
         C               0   61.839014000     24.554978000     12.546998000 M
         C               0   62.165145000     24.482174000     13.890370000 M
         H               0   57.884380000     24.600364000     11.363317000 M
         H               0   57.403855000     25.712756000     14.035262000 M
         H               0   58.756535000     26.878393000     11.549892000 M
         H               0   58.673907000     27.672044000     13.129109000 M
         H               0   59.670717000     26.363895000     15.161491000 M
         H               0   60.503667000     25.369964000     11.089372000 M
         H               0   61.643766000     25.110176000     15.870732000 M
         H               0   62.449750000     24.052466000     11.811256000 M
         H               0   63.031675000     23.922654000     14.208334000 M
         N               0   55.271068000     26.310727000     11.894112000 M
         C              -1   54.018000000     27.003000000     11.655000000 M
         C               0   53.319065000     27.372316000     12.980352000 M
         O               0   51.939736000     27.112597000     12.918974000 M
         H               0   55.356329000     25.341970000     11.626365000 M
         H               0   53.359474000     26.342219000     11.092014000 M
         H               0   53.772381000     26.779380000     13.787937000 M
         H               0   53.494849000     28.430405000     13.198736000 M
         H               0   51.523116000     27.709451000     13.591044000 M
         C              -1   52.248000000     33.889000000     14.204000000 M
         C               0   53.318692000     32.826214000     14.470009000 M
         O               0   53.472507000     32.325896000     15.566960000 M
         C               0   50.852103000     33.340542000     14.532683000 M
         C               0   50.639489000     33.205737000     16.042632000 M
         C               0   50.346964000     34.548448000     16.725332000 M
         N               0   50.723784000     34.481757000     18.118171000 M
         C               0   50.034275000     34.834581000     19.190833000 M
         N               0   48.910874000     35.579155000     19.103395000 M
         N               0   50.474074000     34.451788000     20.370828000 M
         H               0   52.470833000     34.717805000     14.882459000 M
         H               0   50.093435000     33.998773000     14.102493000 M
         H               0   50.739279000     32.356666000     14.075535000 M
         H               0   49.825385000     32.509566000     16.241174000 M
         H               0   51.543378000     32.773093000     16.470673000 M
         H               0   50.916634000     35.349685000     16.239964000 M
         H               0   49.284865000     34.786433000     16.627255000 M
         H               0   51.705800000     34.206008000     18.308122000 M
         H               0   48.332122000     35.682379000     19.917478000 M
         H               0   48.504304000     35.792526000     18.211175000 M
         H               0   51.324048000     33.851659000     20.443508000 M
         H               0   50.092608000     34.794276000     21.234507000 M
         N               0   54.101916000     32.527153000     13.411827000 M
         C               0   55.154133000     31.519706000     13.378097000 M
         C               0   55.912860000     31.420488000     14.699874000 M
         O               0   56.176145000     32.400792000     15.393004000 M
         C               0   56.134465000     31.859918000     12.228446000 M
         C               0   56.788784000     33.227040000     12.417983000 M
         C               0   57.219002000     30.795446000     12.087678000 M
         H               0   53.863516000     32.912623000     12.510806000 M
         H               0   54.710919000     30.535212000     13.172608000 M
         H               0   55.535145000     31.876789000     11.308743000 M
         H               0   56.051234000     34.000802000     12.619428000 M
         H               0   57.497229000     33.181887000     13.241235000 M
         H               0   57.335644000     33.496892000     11.517932000 M
         H               0   57.911599000     30.853598000     12.924304000 M
         H               0   56.790064000     29.798284000     12.055597000 M
         H               0   57.779227000     30.963475000     11.171167000 M
         N               0   56.314044000     30.191657000     15.015649000 M
         C               0   57.193672000     29.937365000     16.143853000 M
         C               0   58.232098000     31.062233000     16.260931000 M
         O               0   58.801962000     31.528762000     15.294577000 M
         C               0   57.940783000     28.627810000     15.912822000 M H 460
         S               0   59.221717000     28.277064000     17.208252000 H
         H               0   56.148252000     29.412760000     14.386124000 M
         H               0   56.601200000     29.879345000     17.065392000 M
         H               0   57.246014000     27.791210000     15.863606000 M
         H               0   58.487478000     28.706553000     14.970743000 M
         N               0   58.466680000     31.436370000     17.531101000 M
         C               0   59.382261000     32.489228000     17.894457000 M
         C               0   60.734668000     31.991584000     18.451758000 M
         O               0   61.454379000     32.736339000     19.090446000 M
         C               0   58.716934000     33.445867000     18.878964000 M
         H               0   58.052816000     30.905550000     18.283588000 M
         H               0   59.624785000     33.016513000     16.962515000 M
         H               0   59.455424000     34.158954000     19.234121000 M
         H               0   57.893760000     33.971874000     18.400575000 M
         H               0   58.333747000     32.884795000     19.728145000 M
         N               0   61.058794000     30.742276000     18.099063000 M
         C               0   62.333741000     30.138993000     18.417046000 M
         C               0   62.747468000     29.106429000     17.367605000 M
         O               0   63.319498000     28.076448000     17.660009000 M
         H               0   60.351629000     30.115557000     17.714149000 M
         H               0   63.082900000     30.935981000     18.466754000 M
         H               0   62.311384000     29.637153000     19.387788000 M
         N               0   62.442655000     29.468406000     16.112529000 M
         C              -1   62.711000000     28.657000000     14.940000000 M
         C               0   61.873916000     29.194823000     13.787453000 M
         C               0   62.088430000     28.441446000     12.475951000 M
         C               0   62.923692000     29.218293000     11.489954000 M
         O               0   63.587308000     30.189713000     11.722170000 M
         O              -1   62.821000000     28.689000000     10.263000000 M
         H               0   61.961436000     30.341357000     15.962730000 M
         H               0   62.444781000     27.620916000     15.170591000 M
         H               0   60.824971000     29.142243000     14.080770000 M
         H               0   62.129535000     30.245023000     13.628406000 M
         H               0   62.589294000     27.487613000     12.652363000 M
         H               0   61.143522000     28.216412000     11.982561000 M
         C              -1   48.494000000     17.957000000     22.174000000 M
         C               0   49.959324000     17.808148000     21.651096000 M
         O               0   50.145114000     17.661291000     20.457674000 M
         C               0   48.332753000     18.703370000     23.500970000 M
         C               0   48.951454000     20.074517000     23.475126000 M
         C               0   48.464594000     21.044760000     22.606762000 M
         C               0   50.005045000     20.405706000     24.317411000 M
         C               0   49.012993000     22.313061000     22.582954000 M
         C               0   50.558126000     21.673835000     24.294289000 M
         C               0   50.061240000     22.632611000     23.429717000 M
         H               0   47.953103000     18.459906000     21.374057000 M
         H               0   47.261406000     18.802099000     23.700950000 M
         H               0   48.759866000     18.116027000     24.317785000 M
         H               0   47.645241000     20.810151000     21.944359000 M
         H               0   50.392843000     19.673034000     25.012514000 M
         H               0   48.617981000     23.049003000     21.898933000 M
         H               0   51.378022000     21.916768000     24.955030000 M
         H               0   50.488390000     23.624295000     23.420708000 M
         N               0   50.995347000     17.843006000     22.528006000 M
         C              -1   52.403001000     17.525000000     22.176000000 M
         H               0   50.797278000     17.925392000     23.510196000 M
         H               0   52.777055000     18.214997000     21.427216000 M
         H               0   53.005068000     17.575507000     23.073423000 M
         C               0   52.986233000     27.665140000     17.137354000 M H 546
         C               0   61.549372000     22.775282000     17.672400000 M H 553
         C               0   62.441439000     29.273802000     22.143007000 M H 554
         C               0   54.828310000     31.303293000     20.677596000 M H 555
         N               0   56.544859000     26.872165000     18.075386000 H
         C               0   52.966405000     28.924668000     16.257462000 M
         C               0   62.275839000     22.443843000     18.730170000 M
         C               0   62.370574000     30.599303000     22.130383000 M
         C               0   54.734500000     32.346528000     19.564181000 M
         N               0   59.010172000     25.449669000     18.206556000 H
         C               0   51.498733000     29.218839000     15.905105000 M
         C               0   53.422172000     33.124261000     19.627792000 M
         N               0   57.525572000     28.834989000     19.838172000 H
         C               0   55.274561000     28.812865000     18.880075000 H
         C               0   57.059965000     24.757836000     16.913762000 H
         C               0   61.284011000     25.526595000     19.105268000 H
         C               0   59.469084000     29.474944000     21.201209000 H
         C               0   54.191892000     24.892910000     15.937459000 M H 552
         C               0   58.860786000     22.317528000     16.144818000 M H 547
         C               0   63.595382000     26.654758000     20.766865000 M H 548
         C               0   57.622433000     31.671277000     22.288975000 M H 549
         C               0   55.413894000     27.663978000     18.122058000 H
         C               0   58.357567000     24.589971000     17.367893000 H
         C               0   61.170275000     26.703261000     19.824976000 H
         C               0   58.159735000     29.617661000     20.772361000 H
         O               0   57.831457000     26.235065000     20.432443000 H
         O               0   51.072318000     28.808468000     14.802858000 M
         O               0   53.301234000     34.131210000     18.883936000 M
         C               0   54.359431000     27.088580000     17.314064000 H
         C               0   59.214363000     23.478229000     17.011070000 H
         C               0   62.223919000     27.230231000     20.659834000 H
         C               0   57.268985000     30.655013000     21.243315000 H
         O               0   50.800287000     29.813126000     16.747962000 M
         O               0   52.520506000     32.722077000     20.389740000 M
         C               0   54.866229000     25.925445000     16.783509000 H
         C               0   60.399789000     23.671331000     17.678364000 H
         C               0   61.721795000     28.370269000     21.250186000 H
         C               0   56.079802000     30.486746000     20.574156000 H
         C               0   56.226956000     25.807432000     17.257401000 H
         C               0   60.261861000     24.928750000     18.397321000 H
         C               0   60.351497000     28.501745000     20.775305000 H
         C               0   56.256343000     29.339116000     19.709124000 H
         N               0   60.049871000     27.489803000     19.899170000 H
         Fe              0   58.236820000     27.118470000     19.053457000 H
         H               0   52.343133000     26.907011000     16.681292000 M
         H               0   52.563190000     27.917467000     18.111539000 M
         H               0   61.764471000     22.319929000     16.711418000 M
         H               0   63.118003000     28.780416000     22.833195000 M
         H               0   53.949522000     30.654326000     20.634759000 M
         H               0   54.807429000     31.822348000     21.639274000 M
         H               0   53.535982000     28.751626000     15.345448000 M
         H               0   53.391677000     29.785907000     16.775033000 M
         H               0   62.050699000     22.810920000     19.716549000 M
         H               0   63.089493000     21.744383000     18.650016000 M
         H               0   61.784054000     31.150525000     21.414191000 M
         H               0   62.958251000     31.189988000     22.813432000 M
         H               0   54.774351000     31.869361000     18.580909000 M
         H               0   55.569539000     33.048403000     19.621084000 M
         H               0   54.315610000     29.314383000     18.844591000 H
         H               0   56.671866000     24.024794000     16.215178000 H
         H               0   62.244855000     25.029343000     19.112331000 H
         H               0   59.834903000     30.177178000     21.939600000 H
         H               0   53.173483000     25.189482000     15.698168000 M
         H               0   54.751243000     24.714482000     15.018238000 M
         H               0   54.148293000     23.949531000     16.483764000 M
         H               0   58.547649000     21.477985000     16.764578000 M
         H               0   58.057513000     22.563465000     15.456021000 M
         H               0   59.739168000     22.002238000     15.583305000 M
         H               0   63.550895000     25.594101000     21.012587000 M
         H               0   64.103625000     26.775137000     19.807552000 M
         H               0   64.167573000     27.166719000     21.536953000 M
         H               0   57.738481000     31.181730000     23.257952000 M
         H               0   58.561310000     32.169898000     22.046395000 M
         H               0   56.839576000     32.422697000     22.369751000 M
         C               0   55.381795000     26.066301000     21.064405000 H
         C               0   55.229677000     25.049070000     22.114474000 H
         C               0   55.084982000     23.499214000     21.930627000 H
         C               0   53.857847000     23.479251000     22.906969000 H
         C               0   53.979446000     25.023352000     23.131629000 H
         C               0   54.957169000     24.788551000     24.325742000 H
         C               0   56.183802000     24.815235000     23.349694000 H
         C               0   54.826044000     23.239825000     24.119503000 H
         C               0   56.048897000     23.264924000     23.142804000 H
         H               0   55.292578000     27.101364000     21.409366000 H
         H               0   56.566493000     26.060008000     20.676868000 H
         H               0   54.803096000     25.889218000     20.153899000 H
         H               0   55.134107000     22.978425000     20.973522000 H
         H               0   52.923044000     22.945728000     22.725838000 H
         H               0   53.162861000     25.747486000     23.105270000 H
         H               0   54.900514000     25.300240000     25.288435000 H
         H               0   57.121953000     25.350378000     23.507600000 H
         H               0   54.675536000     22.503078000     24.907919000 H
         H               0   56.868642000     22.546189000     23.159842000 H
         H              -1   57.070351000     40.582546000     20.028537000 M
         H               0   56.279063000     40.101740000     21.512789000 M
         H              -1   54.207346000     27.901194000     11.062240000 M
         H              -1   43.337220000     30.349872000     16.400880000 M
         H              -1   44.474956000     33.250583000     19.495011000 M
         H               0   45.586448000     33.250494000     18.144066000 M
         H              -1   44.316267000     27.875766000     25.201198000 M
         H               0   44.694688000     27.390193000     26.853401000 M
         H              -1   47.998203000     34.438593000     25.080123000 M
         H              -1   53.616621000     36.422950000     25.279594000 M
         H              -1   56.695620000     32.075053000     30.026235000 M
         H              -1   59.531017000     27.814505000     29.823992000 M
         H              -1   60.264079000     30.980409000     27.878675000 M
         H              -1   46.225261000     29.409810000     30.814362000 M
         H               0   46.982298000     27.862664000     31.208141000 M
         H              -1   52.303236000     34.285912000     13.192800000 M
         H              -1   63.786286000     28.692845000     14.726798000 M
         H              -1   63.798297000     16.448627000     20.612948000 M
         H              -1   64.665071000     20.379033000     23.056909000 M
         H              -1   61.933863000     17.615036000     24.405028000 M
         H              -1   52.398015000     16.516741000     21.765396000 M
         H              -1   53.702537000     18.054043000     27.967886000 M
         H               0   54.137072000     19.300470000     29.127559000 M
         H              -1   52.124536000     19.578316000     17.812758000 M
         H              -1   48.088651000     16.946328000     22.272287000 M
         H              -1   56.305534000     18.384262000     16.950310000 M
         H              -1   48.761085000     21.834808000     17.023866000 M
         H              -1   57.393070000     22.035058000     10.109411000 M
         H              -1   63.366459000     29.188625000      9.624495000 M
         H              -1   52.622241000     33.886715000     29.069707000 M
         H              -1   60.097582000     16.772972000     28.282278000 M
        
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



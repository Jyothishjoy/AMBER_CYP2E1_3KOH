# Use MCPB.py to Prepare Force Field Parameters (for metalloenzyme)

1.	Open “3koh_combined.pdb” from Step 2 and “sub.pdb” from Step 3 using Pymol to double check any clashes between crystal waters and substrate, because waters were not included in docking calculation. If there is any overlap between substrate and waters, oxygen atom can be moved using “Editing” mode of Pymol. First, click on the bottom right area, then left click on the oxygen atom we want to move, hold “CTRL + SHIFT”, left click and drag oxygen atom to the area we want.

2.	Extract HEM and waters.
   
       save HEM.pdb, resname HEM
  	    save water.pdb, resname HOH
  	    remove resname HEM
  	    remove resname HOH
  	    save 3koh_enzyme.pdb, 3koh_combined

3.	Use H++ server to determine protonation state of enzyme: upload “3koh_enzyme.pdb” using the “Process File”. The default value can be used, then “PROCESS”. Download the top and crd file (“3koh_enzyme.top”, “3koh_enzyme.crd”) and convert to pdb file.

4.	Make **convert.inp** file for parameter editor.

        parm 3koh_enzyme.top
        loadCoordinates 3koh_enzyme.crd
        outpdb 3koh_Hpp.pdb

5. Run **parmed** tool in AmberTools to generate the "3koh_Hpp.pdb" file

        parmed -i convert.inp

6. Open “3koh_Hpp.pdb” and “HEM.pdb” to double-check the protonation state. Because H++ does not consider the metal ion while adding hydrogen atoms. Hence, the hystidine sulfur has a proton, which is not meaningful.

7. The Hydrogen of CYS416 (atom no: 6802) was removed as the S is directly bound to the Fe.

8. Also fixed the HID-349 hydrogen position. The hydrogen of the HID-349 residue that directly interacting with COO- group of the HEME unit was not correctly positioned. This is because the H++ served saw only the enzyme backbone. I used GaussView to fix this using the following procedure.

         Manually delete the wrong-positioned HID-349 proton from 3KOH_enzyme_Hpp. Open this file in GaussView and follow https://gaussian.com/tip2/.

         After identifying the residue, I manually added the proton at the correct N atom, and saved it as 3KOH_enzyme_Hpp_fix.pdb file. 

10. Configure HEME parameters:

         Open the Heme.pdb extracted from Step 2 using GaussView. Accept "add Hydrogen" prompt. Double-check the hydrogens, as GaussView occasionally adds additional hydrogens (e.g., an H atom is added to an O atom).
   
         Optimize the position of added hydrogens via DFT using in the following Gaussian input.

      
         %nprocshared=12
         %mem=24GB
         #p b3lyp/genecp nosymm opt=readopt
         . . .
         noatoms atoms=44-74

         (Guassian genecp format here – [SDD-6-31G*])


         noatoms atoms=44-74 will optimize the positions of all hydrogens by keeping everything else frozen.



11. Open the log file in GaussView after optimizing the H positions. Save FE, HEM, and O as three separate pdb files. Use metalpdb2mol2.py to convert FE.pdb to FE.mol2. Use antechamber to convert to HEM_ligand.pdb and O.pdb to HEM_ligand.mol2 and O.mol2.
  

         




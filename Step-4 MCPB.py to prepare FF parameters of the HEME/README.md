# Use MCPB.py to Prepare Force Field Parameters (for metalloenzyme)

1.	Open “3koh_combined.pdb” from Step 2 and “sub.pdb” from Step 3 using Pymol to double check any clashes between crystal waters and substrate, because waters were not included in docking calculation. If there is any overlap between substrate and waters, oxygen atom can be moved using “Editing” mode of Pymol. First, click on the bottom right area, then left click on the oxygen atom we want to move, hold “CTRL + SHIFT”, left click and drag oxygen atom to the area we want.

2.	Extract HEM and waters.
   
        save HEM.pdb, resname HEM
  	    save water.pdb, resname HOH
  	    remove resname HEM
  	    remove resname HOH
  	    save 3koh_enzyme.pdb, 3koh_combined

4.	Use H++ server to determine protonation state of enzyme: upload “3koh_enzyme.pdb” using the “Process File”. The default value can be used, then “PROCESS”. Download the top and crd file (“3koh_enzyme.top”, “3koh_enzyme.crd”) and convert to pdb file.

5.	Make **convert.inp** file for parameter editor.

        parm 3koh_enzyme.top
        loadCoordinates 3koh_enzyme.crd
        outpdb 3koh_Hpp.pdb

6. Run **parmed** tool in AmberTools to generate the "3koh_Hpp.pdb" file

        parmed -i convert.inp

7. Open “3koh_Hpp.pdb” and “HEM.pdb” to double-check the protonation state. Because H++ does not consider the metal ion while adding hydrogen atoms. Hence, the hystidine sulfur has a proton, which is not meaningful. 



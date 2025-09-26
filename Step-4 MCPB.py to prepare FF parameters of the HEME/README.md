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

6. Open “3koh_Hpp.pdb” and “HEM.pdb” to double-check the protonation state. Because H++ does not consider the metal ion while adding hydrogen atoms. The CYS416 sulfur has a proton, which is not meaningful. Also, HID349 has a hydrogen on the wrong nitrogen. We know this because hydrogen on the other N makes a proper H-bond with the COO- of the HEM. This is because the H++ server saw only the enzyme backbone. 

7. To remove H on CYS416, in the PyMol GUI activate 3-Button mode to editing (option on the bottom right). Use the left mouse button to select the H on CYS416. Now, from the Build menu option, select "Remove(pk1)" 

8. Also fixed the HID349 hydrogen position. First, remove HID349/HD1 using the steps mentioned above. But, had some difficulty adding H on the other N.

10. So, I opened the pdb file in Notepad++ and manually deleted the wrong-positioned CYS416 and HID349 protons from 3KOH_enzyme_Hpp.pdb using Notepad++. Then opened this file in GaussView and followed https://gaussian.com/tip2/. After identifying the residue, I manually added the proton at the correct N atom, and saved it as 3KOH_enzyme_Hpp_fix.pdb file. Alternatively, from GaussView we can copy the new H coordinates and paste it into the original pdb file as well.

11. Configure HEME parameters:

         Open the Heme.pdb extracted from Step 2 using GaussView. Accept "add Hydrogen" prompt. Double-check the hydrogens, as GaussView occasionally adds additional hydrogens (e.g., an H atom is added to an O atom).
   
         Optimize the position of added hydrogens via DFT using in the following Gaussian input.

      
         %nprocshared=12
         %mem=24GB
         #p b3lyp/genecp nosymm opt=readopt
         . . .
         noatoms atoms=45-74

         (Guassian genecp format here – [SDD-6-31G*])


         noatoms atoms=45-74 will optimize the positions of all hydrogens by keeping everything else frozen.



12. Open the log file in GaussView after optimizing the H positions. Save FE, HEM, and O as three separate pdb files.

14. Use metalpdb2mol2.py (script attached here) to convert FE.pdb to FE.mol2 and O.pdb to O.mol2. Use antechamber to convert HEM_ligand.pdb to HEM_ligand.mol2.

          python3 metalpdb2mol2.py -i FE.pdb -o FE.mol2 -c 2
          python3 metalpdb2mol2.py -i O.pdb -o OX.mol2 -c -2
          antechamber -fi pdb -fo mol2 -i HEM.pdb -o HEM.mol2 -rn HEM -at gaff -pf y -c bcc -nc -4

Here we use metalpdb2mol2.py script to convert O.pdb simply because abtechamber expects to have more than one atom.
Antechamber uses AM1 with -4 total charge to calculate the bcc charge distribution in the HEM ligand species (porphyrine). Finally, write the results into HEM.mol2 using bcc charges and amber/gaff atom types.

15. Now, open HEM.mol2 file and compare its contents with FE.mol2 and OX.mol2. It seems like some items are missing from the FE.mol2 and OX.mol2 files. Ideally mol2 file should look like the following,

            atom_id  atom_name  x  y  z  atom_type  residue_id  residue_name  charge

So, manually fix the FE.mol2 and OX.mol2 files accordingly. It then looks like,

            1 FE         -2.9090    5.6440    7.3760 FE        0 FE        2.000000

            1 O          -3.5350    5.6860   9.0850  O         1 OX       -2.000000

16. Copy sub.pdb, sub.mol2 and sub.frcmod from Step 3 to the current directory.

17. Combine "3KOH_amber.pdb", "FE.pdb", "O.pdb", "HEM.pdb", "sub.pdb", and "water.pdb" 
            cat  3KOH_amber.pdb FE.pdb O.pdb HEM.pdb sub.pdb water.pdb > 3KOH_composite.pdb

Open the 3KOH_composite.pdb file and remove all unnecessary comment sections (from Gaussian). Feel free to rearrange their order as well. 
Always make sure that the  atom numbering for the HEM and substrate exactly matches their atom numbering in the mol2 files.  
Fix any 	discrepancies using notepad++ (Windows) or notepadqq (Linux) to copy the atom numbering 	vertically. Alternatively, if you are processing bulk files it is possible to employ the Linux “sed” 	command when editing files. Ensure proper atom types (GAFF2).

18. 
            


  

         




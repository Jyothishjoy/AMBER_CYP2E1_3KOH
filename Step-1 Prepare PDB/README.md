## Step 1. Prepare PDB file.
1.	Download the “3KOH.pdb” from Protein Data Bank (https://www.rcsb.org/). Open "3koh.pdb" in a text editor. Read the "REMARK" section for useful information, such as the original reference, "RESOLUTION", "MISSING RESIDUES", and "MISSING ATOM".
2.	Open Pymol:

	        fetch 3koh
  	
3.	In Pymol, enable "Display → Sequence", then “Display → Sequence Mode → Residue Names”, we will see there are several missing (grey) residues. There are several residues missing in both  terminals of enzymes. You can also see some unnecessary molecules.
4.	Remove chain B, unnecessary molecules, and save pdb file:
    
    	remove chain B
    	remove resname OIO
    	save 3koh_chainA.pdb

5.	Save HEME and crystal water as separate pdb files:
	
		save HEM.pdb, resname HEM
		save water.pdb, resname HOH

6.	Add missing residues by using ModLoop (https://modbase.compbio.ucsf.edu/modloop/):
	a.	Open “3koh_chainA.pdb” in text editor (Notepad++).
	b.	Remove line with “ANISOU” information:
		i.	Go to the search menu, “Ctrl + F”, and open the “Mark” tab.
		ii.	Check “Bookmark line”.
		iii.	Enter “ANISOU” in Find what: box, then click “Mark All”.
		iv.	Menu “Search → Bookmark → Remove Bookmarked lines”.
	c.	Add those lines in line 2. Note: The coordinates here are arbitrary.

		ATOM      1  N   MET A  22     -32.912  -5.119  -3.220  1.00 50.32      A    N
		ATOM      1  N   ALA A  23     -32.912  -5.119  -3.220  1.00 50.32      A    N
		ATOM      1  N   LYS A  24     -32.912  -5.119  -3.220  1.00 50.32      A    N
		ATOM      1  N   LYS A  25     -32.912  -5.119  -3.220  1.00 50.32      A    N
		ATOM      1  N   THR A  26     -32.912  -5.119  -3.220  1.00 50.32      A    N
		ATOM      1  N   SER A  27     -32.912  -5.119  -3.220  1.00 50.32      A    N
		ATOM      1  N   SER A  28     -32.912  -5.119  -3.220  1.00 50.32      A    N
		ATOM      1  N   LYS A  29     -32.912  -5.119  -3.220  1.00 50.32      A    N
		ATOM      1  N   GLY A  30     -32.912  -5.119  -3.220  1.00 50.32      A    N
		ATOM      1  N   LYS A  31     -32.912  -5.119  -3.220  1.00 50.32      A    N 

	d.	Add those lines after line contain formation of last residues (now is line 3787):

		ATOM   3777  OG  HIS A 494      29.574  -0.850  15.832  1.00 51.99      A    O 
		ATOM   3777  OG  HIS A 495      29.574  -0.850  15.832  1.00 51.99      A    O
		ATOM   3777  OG  HIS A 496      29.574  -0.850  15.832  1.00 51.99      A    O
		ATOM   3777  OG  HIS A 497      29.574  -0.850  15.832  1.00 51.99      A    O  

	e.	Rename file to “3koh_missing_residues.pdb” by “File → Save As”.
	f.	Open ModLoop using Web Browser:
		i.	In “Modeller license key”, enter “MODELIRANJE”.
		ii.	In “Upload coordinate file”, choose “3koh_missing_residues.pdb”.
		iii.	In “Enter loop segments”, provide following information, then “Process”.

		0:A:9:A:
		494:A:497:A:
  	
		iv.	Save pdb file from ModLoop as “3koh_add_residues.pdb”.
		Note: Pymol can also add residues (https://www.youtube.com/watch?v=JWqIBKQUgn8).

8. Add oxygen to the Fe-heme unit.
 
	i. Open HEM.pdb in GaussView and add oxygen above the Fe in the correct orientation. Check with the original pdb file to decide which direction "O" should go.

	ii. Save this file as a "HEM_oxo.pdb" file.

	iii. Opening "HEM_oxo.pdb" in PyMol shows no bond between Fe and O.

	iv. To solve this connectivity issue, simply copy the coordinate position of the oxo and paste it into the original HEM.pdb file. Add corresponding connectivity information at the bottom of the HEM.pdb file.

	v. Now, save as "HEM_oxo.pdb".

11. Open “3koh_add_residues.pdb” and "HEM_oxo.pdb" in PyMol and combine all the files;

		create 3koh_combined, 3koh_add_residues + HEM_oxo
		delete 3koh_add_residues + HEM_oxo
		save 3koh_combined.pdb

12. For some reason after combining everything, I found the oxygen still missing from the combined pdb file.

13. So, I opened the combined pdb file and manually added oxygen coordinates, and connectivity.


		




How to convert HEME.pdb to HEME_oxo.pdb

1. Open HEME in GaussView and add an oxygen above the Fe in the correct orientation. Check with the pdb file to decide where the O should go.
2. Save the file as a pdb file.
3. If we re-open this file in PyMol, its not going to show FE and O atoms.
4. The trick is just to copy the coordinate position of the O atom from this pdb file and manually insert it in the original HEME.pdb file.
5. Don't forget to add the connectivity at the bottom of the pdb file.
6. Save as HEME_oxo.pdb.
7. Now add this into the pdb file obtained from ModLoop calculation.
8. For some reason after combining everything, I found the oxygen still missing from the combined pdb file. 
9. So, I opened the combined pdb file and manually added oxygen coordinates.
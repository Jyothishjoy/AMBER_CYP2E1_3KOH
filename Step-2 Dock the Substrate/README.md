# Dock the Substrate

**Read Autodock Tutorial.pdf (https://pmc.ncbi.nlm.nih.gov/articles/PMC4669947/)**

1. Download
   
> Autodock4 (https://autodock.scripps.edu/download-autodock4/)
> Autodock Tools (https://ccsb.scripps.edu/mgltools/downloads/)
  
2. Prepare substrate:
   
`Optimize substrate using DFT. Save as pdb file using Gaussview (“sub.pdb”)`

3. A useful tip for preparing the enzyme:
 
   `a. In AutoDockTools menu bar, “File → Read Molecule”, choose “3koh_combined.pdb”.`
   
   `b. Delete water molecules: “Select → Select From String → type ‘HOH*’ in Residues → Add →       Dismiss”, then “Edit → Delete → Delete Selected Atoms → Continue”.`
     
   `c. Add hydrogen: “Edit → Hydrogens → Add → Polar Only → OK”.`

4. Follow the steps exactly as described in the **Autodock Tutorial.pdf**

5. Don't forget to copy **autogrid4.exe** and **autodock4.exe** into the current working directory. This will make their execution much easier through WSL2 (Ubuntu).

6. Through WSL2, navigate to the location of the files and executables.

7. Run autogrid and autodock as described in the paper.
   
   `./autogrid4.exe -p a.gpf -l a.glg &`
   
   `./autodock4.exe -p a.dpf -l a.dlg &`
    
8. Everything should work fine.

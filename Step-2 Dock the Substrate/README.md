### Read *Autodock Tutorial.pdf*

1. Download
   
       Autodock4 (https://autodock.scripps.edu/download-autodock4/)
       Autodock Tools (https://ccsb.scripps.edu/mgltools/downloads/)
  
2. Prepare substrate:
   
       a. Optimize substrate using DFT. Save as pdb file using Gaussview (“sub.pdb”).

3. A useful tip for preparing the enzyme:
 
      a. In AutoDockTools menu bar, “File → Read Molecule”, choose “3koh_combined.pdb”.

      b. Delete water molecules: “Select → Select From String → type ‘HOH*’ in Residues → Add →       Dismiss”, then “Edit → Delete → Delete Selected Atoms → Continue”.
  
      c. Add hydrogen: “Edit → Hydrogens → Add → Polar Only → OK”.

4. Follow the steps exactly as described in the Autodock Tutorial.pdf


# Useful YouTube Videos for PyMol

1. https://www.youtube.com/watch?v=mBlMI82JRfI&t=308s


# Useful Pymol Tricks

**To manually edit the active site by translating or lengthening the docked substrate, do the following.**

1. Open the enzyme and the substrate in the PyMol viewer. In my case, `3KOH_combined.pdb` and `sub.pdb` from the `Step-2-Dock the Substrate` folder.

2. To get the active site into focus, type `show sticks, byres all within 8 of sub`. This will make all residues 8A around `sub` into sticks.

3. Now, do `hide > cartoon` under the main enzyme display (3KOH_combines in this case). This will show only the active site we are interested in. 
   
4. Change `3-button-viewing` to `3-button-editing`.
   
5. Use `SHIFT+Left Mouse Button` for rotation. Use `Cntrl+Middle Mouse Button` for translation of the whole structure or elongating a bond.

6. To check if the atoms after translation are clashing with any atoms of the amino acid residues, do the following.
  
7. Activate `3-button-viewing` and select the relevant aminoacids aroung the substrate.  Type `h_add` in the command line to add hydrogens to the selected residues.

8. Manually check for clashes.

9. Also, we can check the cavity of the active site to determine the correct orientation of the substrate.

10. To do that, `Setting > Surface > Cavity Detection Radius > 3 Solvent Radii`. `Setting > Surface > Cavities and Pockets Only`

11. Type,
    
      show surface
      set transparency, 0.3, polymer

13. This will show the cavity area, and you can now align the substrate along the free cavity direction.

14. Once satisfied with the new orientation, save the new substarte as `save sub_new.pdb, resname SUB`
    

**Once we have successfully run a `tleap` job, it becomes much easier to make modifications only to the substrate position (e.g., Relaxation of the enzyme with a TS-like structure of the active site).**

### Step 1: Modify the substrate position in the docked enzyme-substrate complex using the following procedure.

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


### Step-2: Follow the same procedure described in `Step-2 Dock the Substrate` and generate `sub.mol2` and `sub.frcmod` files.

In this step, the newly created `sub.mol2` file needed to be edited. This file did not identify a bond between C1 and H11. We need to add it manually. 

To do that, open `sub.mol2` in a text editor, and change (a) the number of bonds from 22 to 23, (b) change gaff atom type `c2` to `c3`, (c) change `ha` and `DU` to `hc`. 
Also, add a new bond in the `@<TRIPOS>BOND` section as `4     1    11 1`. Overall the `sub.mol2` should look like the following.

      @<TRIPOS>MOLECULE
      SUB
         19    23     1     0     0
      SMALL
      resp
      
      
      @<TRIPOS>ATOM
            1 C1          -4.8800     3.7510     9.8690 c3         1 SUB      -0.513664
            2 C2          -5.0790     4.0320    11.3240 cy         1 SUB       0.359478
            3 C3          -5.7370     5.3280    11.9270 cy         1 SUB      -0.116852
            4 C4          -4.5940     5.4130    12.9990 cy         1 SUB      -0.053470
            5 C5          -3.9390     4.1150    12.4070 cy         1 SUB      -0.116852
            6 C6          -4.7950     3.2350    13.3840 cy         1 SUB      -0.053470
            7 C7          -5.9390     3.1490    12.3140 cy         1 SUB      -0.116852
            8 C8          -5.4490     4.5330    13.9790 cy         1 SUB       0.005530
            9 C9          -6.5920     4.4480    12.9050 cy         1 SUB      -0.053470
           10 H1          -5.8120     3.7800     9.2950 hc         1 SUB       0.137735
           11 H2          -4.0970     4.6950     9.3200 hc         1 SUB       0.060946
           12 H3          -4.3650     2.8030     9.6820 hc         1 SUB       0.137735
           13 H4          -6.1130     6.1650    11.3340 hc         1 SUB       0.052771
           14 H5          -4.0540     6.3210    13.2750 hc         1 SUB       0.045499
           15 H6          -2.8750     3.9800    12.1980 hc         1 SUB       0.052771
           16 H7          -4.4170     2.3940    13.9690 hc         1 SUB       0.045499
           17 H8          -6.4770     2.2410    12.0330 hc         1 SUB       0.052771
           18 H9          -5.5970     4.7340    15.0420 hc         1 SUB       0.028397
           19 H10         -7.6560     4.5820    13.1050 hc         1 SUB       0.045499
      @<TRIPOS>BOND
           1     1     2 1   
           2     1    10 1   
           3     1    12 1 
           4     1    11 1	 
           5     2     3 1   
           6     2     5 1   
           7     2     7 1   
           8     3     4 1   
           9     3     9 1   
          10     3    13 1   
          11     4     5 1   
          12     4     8 1   
          13     4    14 1   
          14     5     6 1   
          15     5    15 1   
          16     6     7 1   
          17     6     8 1   
          18     6    16 1   
          19     7     9 1   
          20     7    17 1   
          21     8     9 1   
          22     8    18 1   
          23     9    19 1     	
      @<TRIPOS>SUBSTRUCTURE
           1 SUB         1 TEMP              0 ****  ****    0 ROOT


### Step 3: Make a new folder inside `Step-4 MCPB.py` and copy the following files.

      3KOH_mcpbpy.pdb, 3KOH_tleap.in, CPDI.frcmod, CS1.mol2, HEM.mol2, and tleap.sh

Now copy the newly created `sub.frcmod`, `sub.mol2`, from Step-2 above into this directory.

Open `3KOH_mcpbpy.pdb` and change the coordinates of the `SUB` resid with the coordinates in the structurally modified `sub.mol2` file.

### Step 4: Run `tleap.sh`

In this step, run `source tleap.sh`. This will generate the `parmtop` and `inpcrd` files for the modified system. This can then be used directly for the MD run.


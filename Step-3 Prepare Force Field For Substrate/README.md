# Prepare Force Field For Substrate 

1.	Open “sub_dock.pdbqt” from Step-2 with Gaussview and add hydrogen atom. Double-check if there is any hydrogen that was misassigned. Save as “sub.com”, then remove any residues information (e.g., “(PDBName=C,ResName=,ResNum=0)”).

        %Chk=sub.chk
        #P B3LYP/6-31G(d) Opt Nosymm 5d
        ...
        --Link1--
        %Chk=sub.chk
        #p b3lyp/6-31g(d) 5d Nosymm SCF=Tight Pop=MK IOp(6/33=2,6/41=10,6/42=17) geom=allcheck guess=read

2.	Generate parameter for the substrate using RESP charge method.
   This assumes that AmberTools is locally installed. I used WSL2 for AmberTools. https://ambermd.org/InstWindows.php

        antechamber -fi gout -fo mol2 -c resp -i sub.out -o sub.mol2 -rn SUB -at gaff2 -pf y
        antechamber -fi gout -fo pdb -c resp -i sub.out -o sub.pdb -rn SUB -at gaff2 -pf y
        parmchk2 -i sub.mol2 -o sub.frcmod -f mol2

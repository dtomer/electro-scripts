#!/usr/bin/python

import openbabel as ob
import pybel
import sys, glob, os
import numpy as np

lis = sys.argv
lis.pop(0)
print lis,
for x in sorted(lis):
    seed = x.strip(".log")
    for mol in pybel.readfile("g09", x):
        f = open("Li/" + seed  + "_Li.com", "w")
        f.write("%chk=" + seed + """_Li.chk
%Mem=9600Mb
%NProcShared=8
#P  B3LYP/6-31+G(d,p)
    gfinput iop(6/7=3) pop=full NoSym
    opt=(cartesian) freq Int=(Grid=UltraFine)
    symm=follow pop=hirshfeld
    SCRF(SMD,Solvent=generic,Read) out=wfn

""" + seed + """ with Li

0 2
""")

        f.close()
        ring = mol.sssr[0]
        ratom = np.array
        print mol.molwt, mol.charge
        yy = np.array([0.0, 0.0, 0.0])
        for at in sorted(ring._path):
            print   at-1, mol.atoms[at-1].coords,"x", mol.atoms[at-1].atomicnum, "x"
            for i in (0,2):
                yy[i] +=  np.array(mol.atoms[at-1].coords[i])
        print "\n", mol.spin, mol.title, mol.charge, "coccobao"
        yy /= len(ring._path)
        print x, list(sorted(ring._path))
        Li = mol.OBMol.NewAtom()
        Li.SetAtomicNum(3)
        pvec1 = np.array(mol.atoms[ring._path[0]].coords) - np.array(mol.atoms[ring._path[1]].coords)
        pvec2 = np.array(mol.atoms[ring._path[1]].coords) - np.array(mol.atoms[ring._path[2]].coords)
        orth = np.cross(pvec1, pvec2)
        orth /=  np.linalg.norm(orth)
        zz = yy + 2.0*orth
        Li.SetVector(zz[0], zz[1], zz[2])

    mol.write("gjf", "Li/" + seed +".xyz", overwrite = True)
    os.system("sed '1,5d' Li/" + seed + ".xyz >> Li/" + seed  + "_Li.com" )
    os.system("cp " + seed + ".chk Li/" + seed + "_Li.chk")
    with open("Li/" + seed  + "_Li.com", "a") as f:
        f.write("""EpsInf=2.014
HBondAcidity=0.0
HBondBasicity=0.379
SurfaceTensionAtInterface=59.59
Eps=89.78
CarbonAromaticity=0.0
ElectronegativeHalogenicity=0.0

""" +  seed + ".wfn\n\n")

    os.chdir("Li")
    os.system("topbs.pl " + seed  + "_Li.com")
    os.chdir("../")



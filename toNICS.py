#!/usr/bin/python

import openbabel as ob
import pybel
import sys, glob, os
import numpy as np


lis = sys.argv
lis.pop(0)
print lis
for x in sorted(lis):
    print x
    ErrorFlag = 0
    with open(x, "r") as f:
        for line in f:
            if "GINC" in line:
                summary = ""
                while not ('\\@' in summary):
                    summary += line.strip()
                    line = f.next()
            if "Error termination" in line: ErrorFlag = 1

    AllInfo = summary.split("\\\\")
    GeomInfo= AllInfo[3].split("\\")
    ChargeSpin= GeomInfo.pop(0)

    coords = [];
    type = []
    for atom in GeomInfo:
        temp = atom.split(",")
        type.append(temp.pop(0))
        coords.append(np.array([float(temp[0]), float(temp[1]), float(temp[2])]))


    seed = x.strip(".log")
    for mol in pybel.readfile("g09", x):
        f = open("NICS/" + seed  + ".NICS.com", "w")
        f.write("""%Mem=9600Mb
%NProcShared=8
#P  B3LYP/6-31+G(d,p) NMR Int=(Grid=UltraFine) pop=hirshfeld gfinput iop(6/7=3) pop=full NoSym

NICS calculation

""")
        numrings = len(mol.sssr)
        for r in xrange(0, numrings):
            ratom = np.array
            print mol.molwt, mol.charge
            yy = np.array([0.0, 0.0, 0.0])
            for at in sorted(mol.sssr[r]._path):
                print   at-1, mol.atoms[at-1].coords,"x", mol.atoms[at-1].atomicnum, "x"
                yy +=  coords[at-1]
            yy /= len(mol.sssr[r]._path)
            pvec1 = coords[mol.sssr[r]._path[0]-1] - coords[mol.sssr[r]._path[1]-1]
            pvec2 = coords[mol.sssr[r]._path[1]-1] - coords[mol.sssr[r]._path[2]-1]
            orth = np.cross(pvec1, pvec2)
            orth /=  np.linalg.norm(orth)
            zz = yy+orth
            coords.append(yy)
            coords.append(zz)
            type.append("Bq")
            type.append("Bq")
    g = open("NICS/" + seed  + ".NICS.xyz", "w")
    g.write("{0}\n\n".format(len(type)))
    for i in range(0,len(type)):
        g.write("{0} {1[0]:.10f}  {1[1]:.10f}  {1[2]:.10f}\n".format(type[i], coords[i]))
    g.close
    f.write("{0} {1} \n".format(mol.charge, mol.spin))
    for i in range(0,len(type)):
        f.write("{0} {1[0]:.10f}  {1[1]:.10f}  {1[2]:.10f}\n".format(type[i], coords[i]))
    f.write("\n")
    os.chdir("NICS")
    os.system("topbs.pl " + seed  + ".NICS.com")
    os.chdir("../")


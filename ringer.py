#!/usr/bin/python

import pybel, openbabel, glob, sys, os

lis = sys.argv
lis.pop(0)

f = open("aromaticity", "w")
f.write('%-30s %-9s %-9s %-9s %-9s %-9s %-9s   ring path\n' % ("system",  "HOMA",  "avg", "std", "FLU",  "avg", "std"))
f.close()


for x in sorted(lis):
    for mol in pybel.readfile("g09", x):
     for ring in  mol.sssr:
        homaring = "HOMA-onlyvalues "
        fluring = "FLU-onlyvalues "
        homaring+=  x
        fluring +=  x

#        for ring in mol.sssr:
        for atom in list(ring._path):
                homaring += " " + str(atom)
                fluring  += " " + str(atom)
        print homaring +  " " + str(ring._path[0])
        os.system(homaring +  " " + str(ring._path[0]) )
        os.system(fluring +  " " + str(ring._path[0]) )
     f = open("aromaticity", "a")
     f.write("\n")
     f.close()


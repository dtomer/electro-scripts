#!/usr/bin/python

import openbabel as ob
import numpy as np, sys, os

summary = open("summary", "w")
os.system("module load gaussian/09_C01")
lis = sys.argv
lis.pop(0)

for molname in sorted(lis):
    mol = ob.OBMol()
    chk = molname.replace(".log", ".chk")
    fchk = molname.replace(".log", ".fchk")
    mwin =  molname.replace(".log", ".mwin")
    mwout=  molname.replace(".log", ".mwout")
    os.system("formchk " + chk + " " + fchk)
    print chk, fchk
    xx = ob.OBConversion()
    xx.SetInFormat("g09")
    xx.SetOutFormat("com")
    xx.ReadFile(mol, molname)
    seed = molname.strip(".log")
    print molname,
    with open(molname, 'r') as inF:
        for line in inF:
                if 'alpha electron' in line:
                    alphel = line.split()[0]
                    betael = line.split()[3]
                    lumo = str(int(alphel)+1)
    print alphel, betael

    patterns= {
    "-H-"   :   "[H]",
    "-F-"   :   "F",
    "-Cl-"  :   "Cl",
    "-Br-"  :   "Br",
    "-NO2-" :   "N(=O)=O",
    "-NH2-" :   "[NH2]",
    "-OH-"  :   "O",
    "-Ac-"  :   "C(=O)[CH3]",
    "-Me-"  :   "[CH3]",
    "-MeOH-":   "CO",
    "-CN-"  :   "C#N",
    "-NCH32-":  "N([CH3])[CH3]",
    "-CF3-" :   "C(F)(F)F",
    "-COF-" :   "C(=O)F",
    "-COCl-":   "C(=O)Cl",
    "-CHO-" :   "[CH]=O",
    "-OCH3-":   "O[CH3]",
#    "-NF2-" :   "N(F)F",
    "-COOMe-":  "C(=O)O[CH3]",
    "-N3-":     "(N=[N]=[N])",
    "-ONO2-":   "(ON(=O)=O)",
    "-SO3-":    "(S([O])([O])[O])",
    "-TBu-":    "(C(C)(C)C)",
    "-SO2F-":   "(S(=O)(=O)F)",
    "-POF2-":   "(P(=O)(F)F)",
    "-BOH3-":   "([B-](O)(O)O)",
    "-SO2CN-":  "(S(=O)(=O)C#N)",
    "-SO2CF3-": "(S(=O)(=O)C(F)(F)F)",
    "-OCN-":    "(OC#N)",
    "-SCN-":    "(SC#N)"
    }


    for key in patterns.keys():
        if key in molname: pattern = "C"+patterns[key]
    obpat = ob.OBSmartsPattern()
    obpat.Init(pattern)
    obpat.Match(mol)
    # avoid getting lots of <openbabel.vectorvInt; proxy ... > etc.
    matches = [m for m in obpat.GetUMapList()]
    print matches
    seeds = []
    for i in matches:
        z = mol.DeleteBond(mol.GetBond(mol.GetAtom(i[0]),mol.GetAtom(i[1])))
    frags = mol.Separate()

    print "There are ",len(frags), "fragments", mol.GetTotalCharge(), mol.GetTotalSpinMultiplicity()

    # Grep the quinone moieties
#    pattern = "C=O";
#    obpat = ob.OBSmartsPattern()
#    obpat.Init(pattern)
#    obpat.Match(frags[0])
#    matches = [m for m in obpat.GetUMapList()]
#    print "cao", matches
#    quins = []
#    for i in matches:
#        quins.append(str(i[1]))
#        z = mol.DeleteBond(mol.GetBond(mol.GetAtom(i[0]),mol.GetAtom(i[1])))
#    frags = mol.Separate()

    fraglist = []
    MW = open( mwin, 'w')
    MW.write(fchk + "\n")
    MW.write("8 \n9\n")

    for frag in frags:
        print frag.NumAtoms(), len(frags)
        atinfr = []
        for atom in ob.OBMolAtomIter(frag):
            atinfr.append(str(atom.GetId()+1))
        MW.write("-9\n" + ",".join(atinfr) + "\n")
        MW.write(alphel + "\n" + lumo + "\n")
        fraglist.append(atinfr)
    print fraglist
    MW.close()
    print "Multiwfn < " + mwin + " > " + mwout
    os.system("Multiwfn < " + mwin + " > " + mwout)
    what = [molname]
    with open(mwout, 'r') as MWF:
        for line in MWF:
            if 'Fragment' in line:
                what.append(line.split()[-1].replace("%",""))
    summary.write("  ".join(what[0::2]) + "\n")

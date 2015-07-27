#!/usr/bin/env python
# encoding: utf-8
"""
Murcko.py

Created by Florian Nigsch on 2008-04-22.
Copyright (c) 2008 nigsch.com. All rights reserved.
"""

import sys, md5
import os, pybel
import openbabel as ob
from collections import deque
from operator import itemgetter

def GetFusedRingsMatrix(mol):
    numrings = len(mol.sssr)
    fused = [[0 for y in range(0, numrings)] for x in range(0, numrings)]
    for r1 in range(0, numrings):
        ring = mol.sssr[r1]
        print "-"*50
        print "Ring of size: %d" % ring.PathSize()
        print "Atoms in ring:", sorted(ring._path)
        for r2 in range(r1+1, numrings):
            intsec = set(ring._path).intersection(set(mol.sssr[r2]._path))
            print "Intersection ring %d with ring %d: %d" % (r1, r2, len(intsec)), intsec
            if len(intsec):
                fused[r1][r2] = 1
                fused[r2][r1] = 1
    return fused

def FuseRing(ringid, fusmat, totalrings):
    visited = [False] * totalrings

    queue = deque([ringid])
    while queue:
        print queue
        print visited
        next = queue.popleft()
        visited[next] = True
        for pos, i in enumerate(fusmat[next]):
            if i and not visited[pos]:
                queue.append(pos)
    return visited

def GetFusedRings(FusedRingsMatrix, totalrings):
    RingSys = []
    attributed = []
    for r in range(0, totalrings):
        ringset = []
        if r not in attributed:
            for pos, bit in enumerate(FuseRing(r, FusedRingsMatrix, totalrings)):
                if bit:
                    ringset.append(pos)
                    attributed.append(pos)
        if len(ringset):
            RingSys.append(ringset)
    return RingSys

def GetExocyclicDoubleBonds(mol):
    smarts = pybel.Smarts("[*!R]=[R]")
    return smarts.findall(mol)

def GetAtomsInRingSystems(mol, FusedRings, inclexo=True):
    res = []
    for ringsys in FusedRings:
        path = []
        for ring in ringsys:
            path += list(mol.sssr[ring]._path)
        res.append(set(path))
    # Handle exocyclic double bonds
    if inclexo:
        ExocyclicDoubleBonds = GetExocyclicDoubleBonds(mol)
        for at_ring, at_exo in ExocyclicDoubleBonds:
            # Which one of the two is in a ring?
            if mol.atoms[at_exo].OBAtom.IsInRing():
                tmp = at_ring
                at_ring = at_exo
                at_exo = tmp
            for num, atomset in enumerate(res):
                if at_ring in atomset:
                    #print at_ring, mol.atoms[at_ring].OBAtom.GetType(), "in ringsys", num
                    #print at_exo, mol.atoms[at_exo].OBAtom.GetType(), "is exocyclic db"
                    atomset.add(at_exo)
	return res

def WriteFragmentsToFile(out, smiles, RingSystems):
	fraglist = []
	for num, rs in enumerate(RingSystems):
		fragment = pybel.readstring("smi", smiles)
		numatoms = len(fragment.atoms)
		#print "Atoms in new fragment at start:", len(fragment.atoms)
		toremove = list(set(range(1, numatoms+1)).difference(rs))
		#print sorted(toremove, reverse=True)
		for idx in sorted(toremove, reverse=True):
			#print "ID to remove %d. Index of atom %d: %d. Type: %s" % (idx, idx, fragment.atoms[idx-1].index, fragment.atoms[idx-1].OBAtom.GetType())
			fragment.OBMol.DeleteAtom(fragment.atoms[idx-1].OBAtom)
		out.write(fragment)
		fraglist.append(fragment.write("can").split()[0])
	return fraglist

# This is for charged aromatic nitrogens without an H attached:
# --> Such nitrogens have no charge.
ClearSmarts_NarinRing = pybel.Smarts("[n+R]")
# Nitrogens with three bonds but a charge: do not exist.
ClearSmarts_NchargedinRing = pybel.Smarts("[Nv3+R]")
# Nitrogens in a ring with exactly two valences: they are missing a hydrogen
# --> Can possibly be done with OBMol.AddHydrogens(): NO, just tried. So do
#     it manually!
# Not implemented, but apparently under some circumstances N radicals can be found
# in the identified fragments.
#ClearSmarts_Nv2unchargedinRing = pybel.Smarts("[Nv2R]")

def GetCanonicalFragments(smiles, RingSystems):
	fraglist = []
	for num, rs in enumerate(RingSystems):
		fragment = pybel.readstring("smi", smiles)
		numatoms = len(fragment.atoms)
		#print "Atoms in new fragment at start:", len(fragment.atoms)
		toremove = list(set(range(1, numatoms+1)).difference(rs))
		#print sorted(toremove, reverse=True)
		for idx in sorted(toremove, reverse=True):
			#print "ID to remove %d. Index of atom %d: %d. Type: %s" % (idx, idx, fragment.atoms[idx-1].index, fragment.atoms[idx-1].OBAtom.GetType())
			fragment.OBMol.DeleteAtom(fragment.atoms[idx-1].OBAtom)
		# Add hydrogens at this point
		fragment.OBMol.AddHydrogens()
		###################
		# CLEAR STRUCTURE #
		###################
		#--------------------------------------------------------
		# Clear up ring nitrogens that end up as radicals
		clearmatch = ClearSmarts_NarinRing.findall(fragment)
		if clearmatch:
			for mat in clearmatch:
				# Matches are tuples, we only match one atom, so first element
				# of that tuple
				fragment.atoms[mat[0]-1].OBAtom.SetFormalCharge(0)
			fragment.OBMol.SetTotalCharge(0)
		#--------------------------------------------------------
		clearmatch = ClearSmarts_NchargedinRing.findall(fragment)
		if clearmatch:
			for mat in clearmatch:
				# Matches are tuples, we only match one atom, so first element
				# of that tuple
				fragment.atoms[mat[0]-1].OBAtom.SetFormalCharge(0)
			fragment.OBMol.SetTotalCharge(0)
		#--------------------------------------------------------
		#clearmatch = ClearSmarts_Nv2unchargedinRing.findall(fragment)
		#if clearmatch:
		#	for mat in clearmatch:
		#		# Matches are tuples, we only match one atom, so first element
		#		# of that tuple
		#		# Add a hydrogen atom
		#		hydrogen = fragment.OBMol.NewAtom()
		#		hydrogen.SetAtomicNumber(1)
		#		hbond = fragment.OBMol.NewBond()
		#		hbond.
		#		fragment.atoms[mat[0]-1].OBAtom.SetFormalCharge(0)
		#	fragment.OBMol.SetTotalCharge(0)
		#--------------------------------------------------------
		fraglist.append(fragment.write("can").split("\t")[0])
	return fraglist


testsmiles = "CCCC1=NN(C2=C1NC(=NC2=O)C3=C(C=CC(=C3)S(=O)(=O)N4CCN(CC4)C)OCC)C"

def main():
	if len(sys.argv) < 2:
		print "No input file provided: Murcko.py filetosprocess.ext"
		print "The script will determine which file type to read from by the extension."
		print "It is recommended you run your structures through,\nfor example, ChemAxon's Standardizer first."
		sys.exit(1)
	molnum = 0
	Fragments = dict()
	for mol in pybel.readfile(sys.argv[1].split('.')[1], sys.argv[1]):
		molnum += 1
		if not (molnum % 10):
			print "Molecules processed:", molnum
		#if molnum == 210:
		#	break
		#print mol
		mol.OBMol.DeleteHydrogens()
		smiles = mol.write("smi").split("\t")[0]
		#print smiles
		#out.write(mol)
		#print "Number of rings:", len(mol.sssr)
		canmol = pybel.readstring("smi", smiles)
		FusedRingsMatrix = GetFusedRingsMatrix(canmol)
		FusedRings = GetFusedRings(FusedRingsMatrix, len(canmol.sssr))
		#print FusedRings
		RingSystems = GetAtomsInRingSystems(canmol, FusedRings, inclexo=True)
		# Delete all non-ring atoms: this is now done in GetCanonicalFragments()
		#for ringnum in range(len(mol.sssr)):
		#	mol = pybel.readstring("smi", smiles)
		#	ratoms = list(mol.sssr[ringnum]._path)
		#	#print "Atoms in ring:", sorted(ratoms, reverse=True)
		#	#Delete complementary atoms
		#	remove = list(set(range(1,len(mol.atoms)+1)).difference(set(ratoms)))
		#	for a in sorted(remove, reverse=True):
		#		mol.OBMol.DeleteAtom(mol.atoms[a-1].OBAtom)
		#	#print mol
		#	#out.write(mol)
		# Get all rings/ring systems
		frags = GetCanonicalFragments(smiles, RingSystems)
		for frag in frags:
			if frag in Fragments:
				Fragments[frag] += 1
			else:
				Fragments[frag] = 1

	# Write results to file
	print "Writing results to file."
	out = pybel.Outputfile("sdf", "fragments.sdf", overwrite=True)
	d = Fragments
	for k, v in sorted(d.items(), key=itemgetter(1), reverse=True):
		mol = pybel.readstring("smi", k)
		mol.data["COUNT"] = v
		mol.OBMol.DeleteHydrogens()
		out.write(mol)
	out.close()



if __name__ == '__main__':
	main()


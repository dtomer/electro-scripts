#!/usr/bin/python
import numpy as np, sys

files = sys.argv
files.pop(0)
mlen = len(max(files)) + 5

print "%-*s  " % (mlen,  "system"),
print "%7s %7s %7s %7s " % ("nics0", "nics0zz", "nics1", "nics1zz")
for x in sorted(files):
    coord = []
    iso = []
    st= []
    with open(x, "r") as f:
        for line in f:
            if "Symbolic Z-Matrix" in line:
                while not (line == "\n"):
                    line = f.next()
                    if "Bq" in line:
                        coord.append(np.array(line.split()[-3:], float))
            if "SCF GIAO" in line:
                while not (line == "\n"):
                    line = f.next()
                    if "Bq" in line:
                        iso.append(float(line.split()[-4]))
                        m1 = np.zeros(shape=(3,3))
                        for i in range(0,3):
                            line=f.next()
                            m2 = line.split()
                            m1[i][0] = float(m2[-5])
                            m1[i][1] = float(m2[-3])
                            m1[i][2] = float(m2[-1])
                        st.append(m1)
    print "%-*s  " % (mlen,  x),
    for i in range(0,len(coord),2):
        dir = coord[i+1] - coord[i]
        nics0 = -1.0/3.0* np.trace(st[i])
        nics1 = -1.0/3.0* np.trace(st[i+1])
        nics0zz = -np.dot(dir,np.dot(st[i],dir))
        nics1zz = -np.dot(dir,np.dot(st[i+1],dir))
        print "%7.3f %7.3f %7.3f %7.3f   " % (nics0, nics0zz, nics1, nics1zz),
    print

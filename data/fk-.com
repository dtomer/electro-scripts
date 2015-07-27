%chk=xxx.chk
%Mem=9600Mb
%NProcShared=8
#P B3LYP/6-31+G(d,p)
   geom=check guess=read  Int=(Grid=UltraFine)
   symm=follow pop=hirshfeld
   SCRF(SMD,Solvent=generic,Read) out=wfn

xxx fukui-

-1 2

EpsInf=2.014
HBondAcidity=0.0
HBondBasicity=0.379
SurfaceTensionAtInterface=59.59
Eps=89.78
CarbonAromaticity=0.0
ElectronegativeHalogenicity=0.0

xxx.wfn


#!/usr/bin/perl -w
use File::Copy;

for $seed (@ARGV) {

$seed=~ s/.com//g;
$seed=~ s/.log//g;
$seed=~ s/.wfn//g;
open WFN, "$seed.wfn" or die "Cannot find the file '$ARGV[0]'";
# system("sed -i 's/TOTAL ENERGY/THE  HF ENERGY/' $seed.wfn");
@atoms=[];
while (<WFN>) {
  if (/GAUSSIAN/) {
    $i=0;
    $_=<WFN>;
    do {
      $atoms[$i] = substr $_, 0, 8;
      @i= split;
      $i++;
      $_=<WFN>;
    } while !(/CENTRE ASSIGNMENTS/);
  }
}
print "$#atoms atoms\n";

open LOG, "$seed.log" or die "Cannot find the file '$seed.log'. wfn and gaussian files should have the same name!";
while (<LOG>) {
  if (/alpha electrons/) {
    @i= split;
    $alpha= $i[0];
    last;
  }
}

print "processing $seed...\n";

$alpha++;


$LLimit = 1.0e-3;
for $i (0..$#atoms) {
    mkdir "di-$seed" if (! -e "di-$seed");
    if (-e "di-$seed/$seed-$i.int") {
        open F, "grep '  L ' di-$seed/$seed-$i.int |";
        $_ = <F>;
        if (defined $_) {@k = split} 
          else {@k = (0,2*$LLimit)};
    }      
    if (abs($k[-1]) > $LLimit) {
        print "Lagrangian in atom $i too high, rerunning, L= $k[-1]\n" if (-e "di-$seed/$seed-$i.int");
        print "Integration for atom $i not available, rerunning\n" if (not  -e "di-$seed/$seed-$i.int");
        close F;
  	    open INP, ">di-$seed/$seed-$i.inp";
  	    print INP "$seed-$i";
  	    $intg = "2" if ($i ==0);
    	print INP "
$atoms[$i]
PROMEGA
96 64 200
OPTIONS
INTEGER 2
 6 1     calculate AOM 
 9 $alpha
REAL 0 ";
  	close INP;
    @k = [1,2];		
    open PBS, ">di-$seed/pbs.SF.$seed-$i";
    print PBS
"#----------------------------------------------
#PBS -S /bin/bash
#PBS -l select=1:ncpus=8
#PBS -l walltime=08:30:00
#PBS -N PM-$seed-$i
#PBS -M  daniele.tomerini\@u-picardie.fr
#PBS -mb -me
#PBS -j oe
#----------------------------------------------
                        
cd \$PBS_O_WORKDIR
                        
a.correttalocsp  $seed-$i  $seed $seed-$i $seed-$i > $seed-$i.int
";
                        
   	close PBS;
	chdir "di-$seed";
        system("qsub pbs.SF.$seed-$i") ; 
	chdir "../";               
    }
}
}


sub distance() {
  @i[0..2] = @_[0..2];
  @j[0..2] = @_[3..5];
  my $b= 0.0;
  
  for my $i (0..2) {
    $b += ($i[$i]-$j[$i])*($i[$i]-$j[$i]);
  }
  $b = sqrt($b);
}



#!/usr/bin/perl -w

#use Permutor;

$loc = $ARGV[0];

$loc =~ s/.com/.loc/g;
$loc =~ s/.log/.loc/g;
$loc =~ s/.wfn/.loc/g;

open LOC, "$loc" or die "File $loc.loc does not exist. Exiting...\n";
$seed= substr $loc, 0, -4;
$KAt= 0;

while (<LOC>) {
  ($NAt[$KAt],$lmo,$AtName[$KAt],$NumAt[$KAt])  = split;
  $ind[$NAt[$KAt]]=$KAt;
  @po=();
  while (scalar(@po<$lmo)) {
    $_=<LOC>;
    @i = split;
    push(@po,@i);
  }
  $_=<LOC>;
  ($LogQ,$NFbeta,$Ialpha1) = split;
  @LogQ = split(//, $LogQ);
  @{$AOM[$KAt]}=();
  $LMot = $lmo*($lmo+1)/2;
  while (scalar(@{$AOM[$KAt]}<$LMot)) {
    $_=<LOC>;
    @i = split;
    push(@{$AOM[$KAt]},@i);
  }
  $KAt++;
}

$LogQ =~ tr/TF/10/;
@LogQ = split(//, $LogQ);
$KAt--;
$lmo--;
$Ialpha1--;
$NFbeta--;


for  $jk (0..$KAt) {
  $k=-1;
  for $i (0..$lmo) {
    for $j (0..$i) {
      $k++;
      $S[$i][$j][$jk] = $AOM[$jk]->[$k];
    }
  }
}

for  $jk (0..$KAt-1) {
  for $kl ($jk..$KAt) {
    $faaa[$kl]=0.0;
    $faab[$kl]=0.0;
    $faba[$jk][$kl]=0.0;
    $fabb[$jk][$kl]=0.0;
    if ($LogQ[0] or $LogQ[2]) {
      for $i (0..$lmo) {
        for $j (0..$i) {
          $hh=2.0;
          $hh=1.0 if ($i==$j);
     	  $anmin = sqrt($po[$i]*$po[$j])/2.0;
          $faaa[$kl]-= $hh*$anmin*$S[$i][$j][$kl]*$S[$i][$j][$kl];
          $faab[$kl]-= $hh*$anmin*$S[$i][$j][$kl]*$S[$i][$j][$kl];
          next if ($jk==$kl);
          $faba[$jk][$kl]+= $hh*$anmin*$S[$i][$j][$kl]*$S[$i][$j][$jk];
          $fabb[$jk][$kl]+= $hh*$anmin*$S[$i][$j][$kl]*$S[$i][$j][$jk];
        }
      }
    }
    if ($LogQ[3]) {
      for $i (0..$Ialpha1-1) {
        for $j (0..$i) {	
          $hh=2.0;
          $hh=1.0 if ($i==$j);
          $faaa[$kl]-= $hh*$S[$i][$j][$kl]*$S[$i][$j][$kl];
          $faab[$kl]-= $hh*$S[$i][$j][$kl]*$S[$i][$j][$kl];
          next if ($jk==$kl);
          $faba[$jk][$kl]+= $hh*$S[$i][$j][$kl]*$S[$i][$j][$jk];
          $fabb[$jk][$kl]+= $hh*$S[$i][$j][$kl]*$S[$i][$j][$jk];
	    }
      }		
      for $i (0..$Ialpha1-1) {
        for $j ($Ialpha1..$lmo) {
          $hh=1.0 if ($i==$j);
          $faaa[$kl]-= $hh*$S[$i][$j][$kl]*$S[$i][$j][$kl];
          next if ($jk==$kl);
          $faba[$jk][$kl]+= $hh*$S[$i][$j][$kl]*$S[$i][$j][$jk];   
	    }
      }		
      for $i ($Ialpha1..$lmo) {
        for $j ($Ialpha1..$i) {	
          $hh=2.0;
          $hh=1.0 if ($i==$j);
          $faaa[$kl]-= $hh*$S[$i][$j][$kl]*$S[$i][$j][$kl];
          next if ($jk==$kl);
          $faba[$jk][$kl]+= $hh*$S[$i][$j][$kl]*$S[$i][$j][$jk];
	    }
      }	
    }
    if ($LogQ[1]) {
      for $i (0..$NFbeta-1) {
        for $j (0..$i) {	  
          $hh=2.0;
          $hh=1.0 if ($i==$j);	
  	      $anmin = sqrt($po[$i]*$po[$j]);
          $faaa[$kl]-= $hh*$anmin*$S[$i][$j][$kl]*$S[$i][$j][$kl];
          next if ($jk==$kl);
          $faba[$jk][$kl]+= $hh*$anmin*$S[$i][$j][$kl]*$S[$i][$j][$jk];
	    }
      }	
      for $i ($NFbeta..$lmo) {
        for $j ($NFbeta..$i) {	  
          $hh=2.0;
          $hh=1.0 if ($i==$j);	
  	      $k=($i*($i+1))/2+$j;
          $anmin = sqrt($po[$i]*$po[$j]);
          $faab[$kl]-= $hh*$anmin*$S[$i][$j][$kl]*$S[$i][$j][$kl];
          next if ($jk==$kl);
          $fabb[$jk][$kl]+= $hh*$anmin*$S[$i][$j][$kl]*$S[$i][$j][$jk];
	    }
      }	
    }

    $faba[$jk][$kl]*= 2.0;
    $fabb[$jk][$kl]*= 2.0;
    $deloc[$jk][$kl] = $faba[$jk][$kl]+$fabb[$jk][$kl] if($jk != $kl);
  }
}

for  $jk (0..$KAt) {
  $j=0;
  $AN[$jk]=0;
  $BN[$jk]=0;
  if ($LogQ[0] or $LogQ[2]) {
    for $i (0..$lmo) {
      $AN[$jk]+= $AOM[$jk]->[$j]*$po[$i];
      $BN[$jk]+= $AOM[$jk]->[$j]*$po[$i];
      $j+=$i+2;
    }
    $AN[$jk]=0.5*$AN[$jk];
    $BN[$jk]=0.5*$BN[$jk];
  }
  if ($LogQ[3]) { 
    for $i (0..$Ialpha1-1) {
      $AN[$jk]+= $AOM[$jk]->[$j]*$po[$i];
      $BN[$jk]+= $AOM[$jk]->[$j]*$po[$i];
      $j+=$i+2;
    }
    for $i (0..$lmo-1) {
      $AN[$jk]+= $AOM[$jk]->[$j]*$po[$i];
      $j+=$i+2;
    }
  }

  if ($LogQ[1]) { 
    for $i (0..$NFbeta-1) {
      $AN[$jk]+= $AOM[$jk]->[$j]*$po[$i];
      $j+=$i+2;
    }
    for $i ($NFbeta..$lmo) {
      $BN[$jk]+= $AOM[$jk]->[$j]*$po[$i];
      $j+=$i+2;
    }
  } 
}


for $kl (0..$KAt) {
  $vloc[$kl]= -$faaa[$kl]-$faab[$kl];  	
}

open OUT, ">$seed.din";

for $jk (0..$KAt-1) {
  for $kl ($jk+1..$KAt) {
    print OUT "*** DELOCALIZATION and LOCALIZATION INDEXES FOR ATOMS A and B: $AtName[$jk]$NumAt[$jk] and $AtName[$kl]$NumAt[$kl]\n";
        printf OUT "ALPHA ELECTRONS                %22.14f\n", $AN[$jk];
        printf OUT "BETA ELECTRONS                 %22.14f\n", $BN[$jk];
        printf OUT "TOTAL ELECTRONs                %22.14f\n", $BN[$jk]+$AN[$jk];
        printf OUT "SPIN DENSITY                   %22.14f\n", $BN[$jk]-$AN[$jk];
        printf OUT "DELOCALIZATION INDEX           %22.14f\n", $deloc[$jk][$kl];
        printf OUT "DELOCALIZATION INDEX ALPHA     %22.14f\n", $faba[$jk][$kl];
        printf OUT "DELOCALIZATION INDEX BETA      %22.14f\n", $fabb[$jk][$kl];
        printf OUT "LOCALIZATION INDEX OF ATOM A   %22.14f\n", $vloc[$jk];
        printf OUT "LOCALIZATION INDEX OF ATOM B   %22.14f\n", $vloc[$kl];
        printf OUT "ALPHA FERMI CORRELATION OF A   %22.14f\n", $faaa[$jk];
        printf OUT "ALPHA FERMI CORRELATION OF B   %22.14f\n\n", $faaa[$kl];
  }
}

open SPD, ">$seed.spinden";
for $jk (0..$KAt) {
  printf  SPD " % 8s  % 10.6f % 10.6f % 8.4f\n", "$AtName[$jk]$NumAt[$jk]", $AN[$jk], $BN[$jk], abs($BN[$jk]-$AN[$jk]);
}

close SPD;


%sref=
("CC", 1.389,
 "CN", 1.318,
 "NC", 1.318,
 "NN", 1.518,
 "CO", 0.970,
 "OC", 0.970);

# reference: On the performance of some aromaticity indices: A critical assessment using a test set

print "\n"; foreach $i (0..$#AtName) {print "$AtName[$i]$NumAt[$i] "}; print "\n";

shift(@ARGV);
print "Insert the atom numbers corresponding to the ring (spaced):" if (scalar(@ARGV) <1);
$_ = <STDIN> if (scalar(@ARGV) <1);
@_= @ARGV if (scalar(@ARGV) >1);
@_=split if (scalar(@ARGV) <1);


foreach $i (@_) {
  die "Atom $i is not defined or calculated: check the input or the loc file" if (not defined $ind[$i]);
  $i=$ind[$i]; 
#  die "I do not have the data for '$AtName[$i]$NumAt[$i] ': only carbon for now!" if ($AtName[$i] ne "C");
}

foreach $i (@_) {
  $V[$i]= $AN[$i]+$BN[$i]-$vloc[$i];
}


$NRing = scalar (@_)-1;
$FLU= 0.0;
@di=();
# $PDI=0.0;
for $i (0..$NRing-1) {
  @k = ($V[$_[$i]],$V[$_[$i+1]]) if ($V[$_[$i]] < $V[$_[$i+1]]);
  @k = ($V[$_[$i+1]],$V[$_[$i]]) if ($V[$_[$i+1]] <= $V[$_[$i]]);
  
#  @k = sort($V[$_[$i]],$V[$_[$i+1]]);
  ($i1,$i2) =  ($_[$i],$_[$i+1]) if ($_[$i] < $_[$i+1]);
  ($i2,$i1) =  ($_[$i],$_[$i+1]) if ($_[$i] >= $_[$i+1]);
  $di[$i]=$deloc[$i1][$i2];
  $FLU+= ($k[1]/$k[0]*($deloc[$i1][$i2] /$sref{"$AtName[$i1]$AtName[$i2]"} -1))**2;
   printf "$NRing %4s %4s  %.3f  %.3f -- (%.3f %.3f)  -->  %.3e\n", 
        "$AtName[$i1]$NumAt[$i1]", 
        "$AtName[$i2]$NumAt[$i2]",
        $deloc[$i1][$i2], 
        $sref{"$AtName[$i1]$AtName[$i2]"}, 
        $k[1], 
        $k[0],  
        ($k[1]/$k[0]*($deloc[$i1][$i2] /$sref{"$AtName[$i1]$AtName[$i2]"} -1))**2;
 
}

$sum=0;
$std=0;
for $i (0..$NRing-1) {
     $sum+=$di[$i];
}

$average=$sum/$NRing;
 $std=0;
 for $i (0..$NRing-1) {
     $std+=($di[$i]- $average)*($di[$i]- $average)
 }
 $std=sqrt($std/$NRing);


#for $i (0..2) {
##  $PDI += $deloc[$_[$i]][$_[$i+3]] if ($_[$i] < $_[$i+3]);
#  $PDI += $deloc[$_[$i+3]][$_[$i]] if ($_[$i] > $_[$i+3]);
#}

 printf "%-9s %-9s %-9s\n", "FLU",  "delta mean", "std";
  printf "%-9.4f %-9.4f %-9.4f\n", $FLU/$NRing, $average, $std;

printf "FLU = %10.6f\n",  $FLU/$NRing;

#printf "PDI = %10.6f\n",   $PDI/3;
#
#$MCI= 0.0;
#

#$perm = new List::Permutor @_[0..$NRing-1];

$i = 0;

#while (@set = $perm->next) {
#    print "One order is @set.\n";
#    $i++; 
#}

# @set = @_[0..$NRing-1];
$A = 0.0;

sub max ($$) { $_[$_[0] < $_[1]] }
sub min ($$) { $_[$_[0] > $_[1]] }





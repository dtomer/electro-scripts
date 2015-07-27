#!/usr/bin/perl 

use Permutor;

%sref=
    ("CC", 1.389,
     "CN", 1.318,
     "NC", 1.318,
     "NN", 1.518,
     "CO", 0.970,
     "OC", 0.970);

@b = @ARGV;
$x = $b[0]; 
$x =~ s/.log//g;
@Ring = "";
#printf "%.25s ", $x;
open LOC, "$x.loc" or die;
@Ring = @b[1..$#b];
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
close LOC;
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
            $S[$j][$i][$jk] = $S[$i][$j][$jk];
        }
    }
}

for  $jk (0..$KAt-1) {
    for $kl ($jk..$KAt) {
        $faaa[$kl]=0.0;
        $faab[$kl]=0.0;
        $faba[$jk][$kl]=0.0;
        $fabb[$jk][$kl]=0.0;
        $k=-1;
        if ($LogQ[0] or $LogQ[2]) {
            for $i (0..$lmo) {
                for $j (0..$i) {
                    $k++;
                    $hh=2.0;
                    $hh=1.0 if ($i==$j);
 	                $anmin = sqrt($po[$i]*$po[$j])/2.0;
                    $faaa[$kl]-= $hh*$anmin*$AOM[$kl]->[$k]*$AOM[$kl]->[$k];
                    $faab[$kl]-= $hh*$anmin*$AOM[$kl]->[$k]*$AOM[$kl]->[$k];
                    next if ($jk==$kl);
                    $faba[$jk][$kl]+= $hh*$anmin*$AOM[$kl]->[$k]*$AOM[$jk]->[$k];
                    $fabb[$jk][$kl]+= $hh*$anmin*$AOM[$kl]->[$k]*$AOM[$jk]->[$k];
                }
            }
        }
        if ($LogQ[3]) {
            for $i (0..$Ialpha1-1) {
                for $j (0..$i) {	
                    $k++;
                    $hh=2.0;
                    $hh=1.0 if ($i==$j);
                    $faaa[$kl]-= $hh*$AOM[$kl]->[$k]*$AOM[$kl]->[$k];
                    $faab[$kl]-= $hh*$AOM[$kl]->[$k]*$AOM[$kl]->[$k];
                    next if ($jk==$kl);
                    $faba[$jk][$kl]+= $hh*$AOM[$jk]->[$k]*$AOM[$kl]->[$k];
                    $fabb[$jk][$kl]+= $hh*$AOM[$jk]->[$k]*$AOM[$kl]->[$k];
	            }
            }		
            for $i (0..$Ialpha1-1) {
                for $j ($Ialpha1..$lmo) {
                    $k++;
                    $hh=1.0 if ($i==$j);
                    $faaa[$kl]-= $AOM[$kl]->[$k]*$AOM[$kl]->[$k];
                    next if ($jk==$kl);
                    $faba[$jk][$kl]+= $AOM[$jk]->[$k]*$AOM[$kl]->[$k];   
	            }
            }		
            for $i ($Ialpha1..$lmo) {
                for $j ($Ialpha1..$i) {	
                    $k++;
                    $hh=2.0;
                    $hh=1.0 if ($i==$j);
                    $faaa[$kl]-= $hh*$AOM[$kl]->[$k]*$AOM[$kl]->[$k];
                    next if ($jk==$kl);
                    $faba[$jk][$kl]+= $hh*$AOM[$jk]->[$k]*$AOM[$kl]->[$k];
	            }
            }	
        }
        if ($LogQ[1]) {
            for $i (0..$NFbeta-1) {
                for $j (0..$i) {	  
                    $k++;
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
        $vloc[$kl]= -$faaa[$kl]-$faab[$kl];  	
    }
}

for  $jk (0..$KAt) {
    $AN[$jk]=0;
    $BN[$jk]=0;
    if ($LogQ[0] or $LogQ[2]) {
        for $i (0..$lmo) {
        $AN[$jk]+= $S[$i][$i][$jk]*$po[$i];
            $BN[$jk]+= $S[$i][$i][$jk]*$po[$i]; 
        }
        $AN[$jk]=0.5*$AN[$jk];
        $BN[$jk]=0.5*$BN[$jk];
    }
    if ($LogQ[3]) { 
    for $i (0..$Ialpha1-1) {
            $AN[$jk]+= $S[$i][$i][$jk]*$po[$i];
            $BN[$jk]+= $S[$i][$i][$jk]*$po[$i];
        }
        for $i (0..$lmo-1) {
            $AN[$jk]+= $S[$i][$i][$jk]*$po[$i];
        }
    }
    if ($LogQ[1]) { 
        for $i (0..$NFbeta-1) {
             $AN[$jk]+= $S[$i][$i][$jk]*$po[$i];
        }
        for $i ($NFbeta..$lmo) {
            $BN[$jk]+= $S[$i][$i][$jk]*$po[$i];
        }
    } 
}
    
$err = 0;
foreach $i (@Ring) {
    die  "Atom $i is not defined or calculated: check the input or the loc file" if (not defined $ind[$i]);
    $i=$ind[$i];
}

foreach $i (@Ring) {
    $V[$i]= $AN[$i]+$BN[$i]-$vloc[$i];
}
    
open SPD, ">$x.spinden";
for $jk (0..$KAt) {
    printf  SPD " % 8s  % 10.6f % 10.6f % 8.4f\n", "$AtName[$jk]$NumAt[$jk]", $AN[$jk], $BN[$jk], abs($BN[$jk]-$AN[$jk]);
}
close SPD;

$NRing = scalar (@Ring);
$FLU= 0.0;
$PDI=0.0;

for $i (1..$NRing-1) {
    $k[0] = 0;
    $k[1] = 0;
    @k = ($V[$Ring[$i]],$V[$Ring[$i-1]]) if ($V[$Ring[$i]] < $V[$Ring[$i-1]]); 
    @k = ($V[$Ring[$i-1]],$V[$Ring[$i]]) if ($V[$Ring[$i-1]] <= $V[$Ring[$i]]);
    ($i1,$i2) =  ($Ring[$i],$Ring[$i-1]) if ($Ring[$i] < $Ring[$i-1]);
    ($i2,$i1) =  ($Ring[$i],$Ring[$i-1]) if ($Ring[$i] >= $Ring[$i-1]);
    $FLU+= ($k[1]/$k[0]*($deloc[$i1][$i2] /$sref{"$AtName[$i1]$AtName[$i2]"} -1))**2;
}

for $i (0..2) {
  $PDI += $deloc[$Ring[$i]][$Ring[$i+3]] if ($Ring[$i] < $Ring[$i+3]);
  $PDI += $deloc[$Ring[$i+3]][$Ring[$i]] if ($Ring[$i] > $Ring[$i+3]);
}

 printf "  %10.6f  ",   $FLU/$NRing;

printf " %10.6f ",   $PDI/3;
for $i (@Ring) {
   printf " % 10.6f ", $AN[$i] + $BN[$i];
}
for $i (@Ring) {
   printf " % 10.6f ", $AN[$i] - $BN[$i];
}
print "\n"   


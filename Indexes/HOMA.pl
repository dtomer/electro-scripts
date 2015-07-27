#!/usr/bin/perl -w

open LOG, $ARGV[0] or die "Cannot find the file '$ARGV[0]'";
$errorflag =1;
shift(@ARGV);

# alpha constant for a series of atom types
$al{"CC"} = 257.7;
$al{"CN"} = 93.52;
$al{"CO"} = 157.38;
$al{"CP"} = 118.91;
$al{"CS"} = 94.09;
$al{"NN"} = 130.33;
$al{"NO"} = 57.21;

# equilibrium distances for atom types
$ro{"CC"}=1.388;
$ro{"CN"}=1.334;
$ro{"CO"}=1.265;
$ro{"CP"}=1.698;
$ro{"CS"}=1.677;
$ro{"NN"}=1.309;
$ro{"NO"}=1.248;

# intitializing the average bond length and their number according to their kind 
while (($key, $value) = each(%al)){ 
    $aver{$key} = 0;
    $nbonds{$key} = 0
}

# looking for the summary line in gaussian
while (<LOG>) {
    if (/GINC/) {
        $summary="";
        while (index($summary, '\\\@') == -1) {
            $_ =~ s/^\s+|\s+$//g;
            $summary .= $_;
            $_ = <LOG>;
        } 
    }
    $errorflag =0 if (/Error termination/);
}      

# separating the geometry part in the summary
# it is the various input of the gaussian separated by \\
@all = split (/\\\\/ ,$summary); 
@geometry = split (/\\/ ,$all[3]);

# listed with the final geometry, but we do not use it
$ChargeSpin = "";
$ChargeSpin = shift @geometry;

# now the list is a comma separated array, and we extract what we need
$i=0;
foreach (@geometry) {
    @temp = split /,/;
    $atoms[$i+1] = $temp[0];
    for $j (0..2) { $coords[$i+1][$j] = $temp[$j+1] }
    $i++;  
}

@_= @ARGV if (scalar(@ARGV) >1);
@_=split if (scalar(@ARGV) <1);

$homa=1;

$Ener = 0;
$Geom = 0;

#Number of bonds is 1 less than the number of atoms
$N = scalar(@_)-1 ;
$aver=0;

;

$sum=0;
for $i (0..$N-1) {
    $i1 = $_[$i];
    $i2 = $_[$i+1];
    $bonds[$i] = 0;
    for $jj (0..2) { $bonds[$i] += ($coords[$i1][$jj] - $coords[$i2][$jj])*($coords[$i1][$jj] - $coords[$i2][$jj]) }
    $bonds[$i] = sqrt($bonds[$i]);
    
    $bt = join('',sort(split(//,"$atoms[$i1]$atoms[$i2]"))) ;

    $sum+= $bonds[$i];

    die "Bond type between $atoms[$i1] and $atoms[$i2] is undefined in the HOMA definitions implemented. Exiting..." if (not defined $ro{$bt});

    $BDiff = $bonds[$i] - $ro{$bt} ;
    $ToRemove = $al{$bt} * $BDiff*$BDiff / $N;
    $homa-=  $ToRemove ;

    $aver{$bt} += $bonds[$i] ;
    $nbonds{$bt}++;

    printf "%.3f  %.3f  %.3f\n", $bonds[$i] , $ro{$bt},  $ToRemove;
}

while (($key, $value) = each(%al)){
    $Ener += ($aver{$key}/$nbonds{$key} - $ro{$key}) * ($aver{$key}/$nbonds{$key} - $ro{$key}) * $al{$key} if ($nbonds{$key} > 0);
}


$average=$sum/$N;
$std=0;
for $i (0..$N-1) {
  $std+=($bonds[$i]- $average)*($bonds[$i]- $average)
}
$std=sqrt($std/$N);

for $i (0..$N-1) {
    $bt = join('',sort(split(//,"$atoms[$_[$i]]$atoms[$_[$i+1]]"))) ;
    $BDiff = $bonds[$i] - $aver{$bt}/$nbonds{$bt} ;
    $Geom += $al{$bt}/$N* $BDiff*$BDiff;
}




printf "%-9s %-9s %-9s %-9s %-9s\n", "HOMA",  "Energetic", "Geometric", "average", "std";
printf "%-9.4f %-9.4f %-9.4f %-9.4f %-9.4f\n", $homa, $Ener, $Geom, $average, $std;

print "Attention: gaussian terminated with an error\n" if not ($errorflag);



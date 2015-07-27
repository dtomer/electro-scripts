#!/usr/bin/perl 
@b = @ARGV;
open LOG, $b[0] ;

$H{"C"}=0;
$H{"N"}=1;
$H{"O"}=2;
$H{"P"}=3;
$H{"S"}=4;

$alpha[0][0]=257.7;
$alpha[0][1]=93.52;
$alpha[0][2]=157.38;
$alpha[0][3]=118.91;
$alpha[0][4]=94.09;
$alpha[1][0]=93.52;
$alpha[2][0]=157.38;
$alpha[3][0]=118.91;
$alpha[4][0]=94.09;
$alpha[1][1]=130.33;
$alpha[1][2]=57.21;
$alpha[2][1]=57.21;

$ro[0][0]=1.388;
$ro[0][1]=1.334;
$ro[0][2]=1.265;
$ro[0][3]=1.698;
$ro[0][4]=1.677;
$ro[1][0]=1.334;
$ro[2][0]=1.265;
$ro[3][0]=1.698;
$ro[4][0]=1.677;
$ro[1][1]=1.309;
$ro[1][2]=1.248;
$ro[2][1]=1.248;



while (<LOG>) {
  if (/Mulliken atomic charges\:/i) {
    $i=1;
    $_=<LOG>; $_=<LOG>;
    do {
      @h=split;
        $atoms[$i] = $h[1];
        $i++ ;
      $_=<LOG>;
    } while !(/Sum of Mulliken charges/);
  }
  if (/internal coordinates found in file/i) {
    $i=1;
    $_=<LOG>;
    do {
      @h=split(',', $_);
      $h[0] =~ s/\s+//;
      $atoms[$i] = $h[0];
      $i++ ;
      $_=<LOG>;
     } while !(/recover/i);
  }
  if (/Optimized Parameters/) {
    print "bonds:\n";
    $_=<LOG>; $_=<LOG>; $_=<LOG>; $_=<LOG>;$_=<LOG>;
    @i=split;
    $k = 0;
    while (($i[1] ne "A1")){
      $k++;
      $pair =  $i[2];
      $pair =~ tr/R(,)/    /;
      ($i,$j) = split(" ", $pair);
      $bonds[$i][$j]= $i[3];
      $bonds[$j][$i]= $i[3];
      $_=<LOG>;
      @i=split;
    }
  }
  if (/Number     Number       Type/) {
    $_=<LOG>; $_=<LOG>;
    $i=1;
    do {
       @h=split;
       for $j(0..2) {
         $coords[$i][$j] = $h[-3+$j];
       }
       $_=<LOG>;
       $i++;
    } while !(/-----------/);
  }
   $errorflag =1 if (/Error termination/);

}
close LOG;

@_= @b[1..scalar(@b)-1] if (scalar(@b) >1);
@_=split if (scalar(@b) <1);
$homa=1;
$N = scalar(@_-1) ;
$aver=0;
for $i (1..scalar(@_)-1) {
    $bonds[$_[$i]][$_[$i-1]] = 0;
    for $jj (0..2) {
        $bonds[$_[$i]][$_[$i-1]] += ($coords[$_[$i]][$jj] - $coords[$_[$i-1]][$jj])*($coords[$_[$i]][$jj] - $coords[$_[$i-1]][$jj]);
    }
  $bonds[$_[$i]][$_[$i-1]] = sqrt( $bonds[$_[$i]][$_[$i-1]]);
  die "There was no bond between atom $_[$i] and $_[$i-1]: exiting...\n" if (not defined $bonds[$_[$i]][$_[$i-1]]);
  die "Bond type between $H{$atoms[$_[$i]]} and $H{$atoms[$_[$i-1]]} is undefined in the HOMA definitions implemented. Exiting..." if (not defined $ro[$H{$atoms[$_[$i]]}][$H{$atoms[$_[$i-1]]}]);
  $hind = $alpha[$H{$atoms[$_[$i]]}][$H{$atoms[$_[$i-1]]}]/$N*(($bonds[$_[$i]][$_[$i-1]] - $ro[$H{$atoms[$_[$i]]}][$H{$atoms[$_[$i-1]]}])**2);
  $homa-=  $hind;
  print "$_[$i] $_[$i-1]  $hind $N \n";
  $aver+= $bonds[$_[$i]][$_[$i-1]];
close LOG;
}

printf "   %.3f  ", $homa;



#!/usr/bin/perl

open INT, $ARGV[0] or die;
$seed= substr $ARGV[0], 0, -4;
$i=-1;
while (<INT>) {
  if (/OVER ATOM/) {
    $i++;
    @i = split;
    $atom[$i] = "$i[-2]$i[-1]";
  }
  if (/ALPHA ELECTRONS/) {
    @i = split;
    $acharge[$i]=$i[-1];
  }
  if (/BETA ELECTRONS/) {
    @i = split;
    $bcharge[$i]=$i[-1];
  }
  if (/TOTAL ELECTRONS/) {
    @i = split;
    $tcharge[$i]=$i[-1];
  }  
}


open CHG, ">$seed.bch";
printf CHG "%-4s %-6s %-6s %-6s %-6s\n", "atom", "alpha", "beta", "total", "spin";
for $j (0..$i) {
  printf CHG "%-4s %.4f %.4f %7.4f %.4f\n", $atom[$j],  $acharge[$j], $bcharge[$j], $tcharge[$j], abs($bcharge[$j]-$acharge[$j]); 
} 

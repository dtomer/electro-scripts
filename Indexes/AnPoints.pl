#!/usr/bin/perl

@x = @ARGV;  

foreach $x (@x) {
  $x =~ s/.com//g;
  $x =~ s/.log//g;
  $x =~ s/.crt//g;
  $x =~ s/.wfn//g;
  $seed = $x;
  $x = "$x.crt";
  open CP, "$x" ;
  print "processing $x\n";
  $i=-1;
  $first = 1;
  $ik=0;
  while (<CP>) {
  $i++ if (/NEW CRITICAL POINT/);
  if  (/EIGENVALUES OF THE HESSIAN/) {
    $_ = <CP>;
    ($H1[$i],$H2[$i],$H3[$i]) = split;
  }
  if (/Rho\(r\)  /){
    ($j,$rho[$i]) = split;
  }
  if  (/DEL\*\*2/){
    ($j,$del[$i]) = split;
    $_ = <CP>;
    ($j,$G[$i]) = split;
    $_ = <CP>; $_ = <CP>; $_ = <CP>; $_ = <CP>;
    ($j,$V[$i]) = split;
#   print "$rho[$i] $del[$i] \n";
  }
  if ((/BOND PATH LINKED TO/) and ($first)){
    @i = split;
    $a1[$i]= "$i[4]$i[5]";
    $ik = $i[-3];
    $_ = <CP>; 
    @i = split;
    $b1[$i] = $i[-1];
    $first = 0;
    $_ = <CP>;
  }
  if  (/BOND PATH LINKED TO/){
    @i = split;
    $a2[$i]= "$i[4]$i[5]";
    $jk = $i[-3];
    $_ = <CP>;
    @i = split;
    $b2[$i] = $i[-1];
    $first=1;
    $_ = <CP>;
    if ($ik > $jk) {
      $ik = $a1[$i] ; 
      $a1[$i] = $a2[$i];
      $a2[$i] = $ik;
      $ik = $b1[$i];
      $b1[$i] = $b2[$i];
      $b2[$i] = $ik;
    }
  }
  if (/TOTAL BOND PATH LENGTH/){
    @i = split;
    $tb[$i]= $i[-1];
    $_ = <CP>;
    @i = split;
    $gb[$i] = $i[-1];
  }
  }

  $ii=$i;


  for  $i (0..$ii-1) {
    open Z,"$seed.din"; 
    $notfound = 1;
    $din[$i] =0;
    while (<Z>)  {
        
        if (index($_, "$a1[$i] and $a2[$i]") != -1) {
            $_= <Z>; $_= <Z>; $_= <Z>; $_= <Z>; $_= <Z>;
            @spl = split;
            $din[$i] = $spl[-1];
            $notfound = 0;
        }
    }
    close Z;
  } 
                
  close CP;
  $c1= 0.529177249;
  $c3= 1/($c1*$c1*$c1);
  $c5= 1/($c1*$c1*$c1*$c1*$c1);
  $e1= 2.6255;

  $c3= 1;
  $c5= 1;
  $e1= 1;

  $x =~ s/.crt//g;
  open Y, ">$x.bcrt";
  printf Y "%-10s %-5s %-5s %-5s %-5s %-11s %-11s %-11s %-11s %-11s %-11s %-11s %-11s %-11s %-11s %-11s %-11s\n", 
       "bonds", "glen", "len", "bp1", "bp2", "rho", "del**", "la1",  "la2",  "la3", "la1/la3", "eps", "G", "V", "V/G", "H", "DelInd";
  for $i (0..$ii-1) {
  printf Y  "%-10s %.3f %.3f %.3f %.3f % .4e % .4e % .4e % .4e % .4e % .4e % .4e % .4e % .4e % .4e % .4e % .4f\n",
   "$a1[$i]-$a2[$i]", 
    $gb[$i]*$c1,
    ($b1[$i]+ $b2[$i])*$c1,
    $b1[$i]*$c1,
    $b2[$i]*$c1,
    $rho[$i]*$c3,
    $del[$i]*$c3, 
    $H1[$i]*$c5,
    $H2[$i]*$c5,
    $H3[$i]*$c5,
    abs($H1[$i])/$H3[$i], 
    $H1[$i]/$H2[$i]-1, 
    $G[$i]*$e1, 
    $V[$i]*$e1,
    $V[$i]/ $G[$i],
    $V[$i]*$e1 + $G[$i]*$e1,
    $din[$i] ;
    
}
  close Y;
  close CP;
}

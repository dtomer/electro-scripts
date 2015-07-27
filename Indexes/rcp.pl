#!/usr/bin/perl -w

@x = @ARGV;  

foreach $x (@x) {
  $x =~ s/.com//g;
  $x =~ s/.log//g;
  $x =~ s/.crt//g;
  $x =~ s/.wfn//g;
  $x =~ s/.allcrt//g;
  $x = "$x.allcrt";
  next if (not -e $x);
  open CP, "$x" ;
  $i=-1;
  while (<CP>) {
  $i++ if (/NEW CRITICAL POINT FOUND/);  
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
  }
  }

  $imax = $i;
  close CP;
  $c1= 0.529177249;
  $c3= 1/($c1*$c1*$c1);
  $c5= 1/($c1*$c1*$c1*$c1*$c1);
  $e1= 2.6255;

  $c3= 1;
  $c5= 1;
  $e1= 1;

  $x =~ s/.crt//g;
  open Y, ">$x.rcrt";
  printf  "%-11s %-11s %-11s %-11s %-11s %-11s %-11s %-11s %-11s %-11s %-11s\n",
       "rho", "del**", "la1",  "la2",  "la3", "la1/la3", "eps", "G", "V", "V/G", "H";
  printf Y "%-11s %-11s %-11s %-11s %-11s %-11s %-11s %-11s %-11s %-11s %-11s\n",
       "rho", "del**", "la1",  "la2",  "la3", "la1/la3", "eps", "G", "V", "V/G", "H";
  for $i (0..$imax) {
    if ($H1[$i]*$H2[$i]*$H3[$i]< 0) {
        printf   "% .4e % .4e % .4e % .4e % .4e % .4e % .4e % .4e % .4e % .4e % .4e\n",
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
        $V[$i]*$e1 + $G[$i]*$e1 ;

        printf Y  "% .4e % .4e % .4e % .4e % .4e % .4e % .4e % .4e % .4e % .4e % .4e\n",
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
        $V[$i]*$e1 + $G[$i]*$e1 ;
    }
}
  close Y;
  close CP;
}

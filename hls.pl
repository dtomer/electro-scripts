 #!/usr/bin/perl
 use List::Util qw/ max min /;
 use Term::ANSIColor;

# This script uses input from gaussian files to 

 # First one is the string contained in the starting molecule
 # Second one in the reduced state

 @all = @ARGV;

 # Format settings
 $l  = longest(@all) +1;
 $fn = 5;
 $fs = $fn + 2;
 $f1 = "-".$fs."s";
 $f3 = "$fn"."f";
 $f2 = $l."s";


 printf "%-$f2 %$f1 %$f1 %$f1 %$f1 %$f1 %$f1\n", "system", "pot", "potzp", "homo", "lumo", "somo", "phi";

 foreach $X (sort(@all)){
     $seed = $X;
     $seed =~ s/.com//g;
     $seed =~ s/.log//g;
     if ((substr $seed, -1) ne "+") { $seedred ="$seed-"}
     else { $seedred=substr($seed, 0, -1) };

     if (-e "$seedred.log" ){
     printf "%-$f2", $seed;
     open X, "$X" or die "no such file, $X!";
     $ao = -1000;
     $av = 1000;
     $bo = -1000;
     $bv = 1000;

     $pass=1;
     $passb = 1;
     $found1=0;
     $found2=0;
     $pot1 =0;
     $pot2 =0;
     $homo = 0.0;
     $lumo = 0.0;

     while (<X>){
         if (/Alpha  occ/) {
             $x = $_;
             $pass = 1;
         }
         if (/Alpha virt/ and $pass) {
             @x= split(" ", $x);
             $ao = $x[-1];
             @x= split;
             $av = $x[-5];
             $pass = 0;
         }
        if (/Beta  occ/) {
             $x = $_;
             $passb = 1;
         }
         if (/Beta virt/ and $passb) {
             @x= split(" ", $x);
             $bo = $x[-1];
             @x= split;
             $bv = $x[-5];
             $passb=0;
         }
         if (/Sum of electronic and thermal Free Energies/){
             @i = split;
             $pot1 = $i[-1];
             $found1 = 1;
         }
         if (/Zero-point correction/){
             @i = split;
             $zp1= $i[-2];
         }
         $k++ if (/termination/);
     }

     close X;

     $sa = -1000;
     $sb = -1000;
     $X =~ s/$ne.log//g;


     open X, "$seedred.log" ;
     while (<X>){
         $somo = 0.0;
         if (/Alpha  occ/) {
             $x = $_;
         }
         if (/Alpha virt/ ) {
             @x= split(" ", $x);
             $sa = $x[-1];
         }
         if (/Beta  occ/) {
             $x = $_;
             $passb = 1;
         }
         if (/Beta virt/ ) {
             @x= split(" ", $x);
             $sb = $x[-1];
         }
        if (/Sum of electronic and thermal Free Energies/){
             @i = split;
             $pot2 = $i[-1];
             $found2 = 1;
         }
         if (/Zero-point correction/){
             @i = split;
             $zp2= $i[-2];
         }
     }
     printf  colored( sprintf("% .$f3 ", ($pot1 - $pot2)*27.211396132 - 1.46),"red"),  if ($found1 and $found2);
     printf  colored( sprintf("% .$f3 ", ($pot1 - $pot2+$zp1-$zp2)*27.211396132 - 1.46),"green"),  if ($found1 and $found2);
     printf "%$f1 %$f1 ", " x-$found1-$found2-x",  " x-$found1-$found2-x" if (!($found1 and $found2));
     $homo = max($ao, $bo);
     $lumo = min( $av, $bv);
     $somo = max($sa, $sb);
     $ei = (1/4.0)*($homo+$lumo)*($homo+$lumo)/($lumo-$homo) if ($homo != $lumo);
     if ($homo !=-1000) { printf "% .$f3 % .$f3 ", $homo, $lumo };
     if ($somo !=-1000) { printf "% .$f3 % .$f3 ", $somo, $ei };
     if ($somo ==-1000) { printf "%$f1  % .$f3 ", " xxx", $ei };
     printf" % .$f3  % .$f3\n", $pot1, $pot2 ;
     }
 }

 sub longest {
     my $max = -1;
     my $max_ref;
     for (@_) {
         if (length > $max) {  # no temp variable, length() twice is faster
             $max = length;
             $max_ref = \$_;   # avoid any copying
         }
     }
     $max
 }

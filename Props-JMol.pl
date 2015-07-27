#!/usr/bin/perl
use List::Util qw/ max min /;

 @allfiles = @ARGV;
 $head="";
 if (index($ARGV[-1], ".log") == -1) {
     $head=pop @allfiles;
 }
 # Format settings
 $l  = longest(@allfiles) +1;
 $f2 = $l."s";

 
open CHARGES, ">", "$head"."Charges";
open BADERCHS, ">", "$head"."BaderCH";
open HIRSHSD, ">", "$head"."SpinDen";
open FUKPLUS, ">", "Fuk+";
open FUKMIN, ">", "Fuk-";
open FUKDUAL, ">", "FukDual";
open BADERSD, ">", "$head"."BaderSD";
open BADERDELTA,">", "$head"."BaderDelta";

foreach $x (@allfiles) {
    $x =~ s/.log//g;
    print "\nProcessing $x ... ";
    
    @at=();
    @ch=();
    $atomnum=0;
    @chargebad=();
    @spbad=();

    open LOG, "$x.log";
    while (<LOG>) {
        if ((/l999/) ) {
            $summary="";
            while  ((index($summary, '\\\@') == -1 ) and  (index($summary, 'Error') == -1 )){
                $_ =~ s/^\s+|\s+$//g;
                $summary .= $_;
                $_ = <LOG>;
            }
        }
    }
    if ($summary =~/Error termination/) {
        print " Error termination\n";
        next
    }
    @all = split (/\\\\/ ,$summary);
    $myinp = $all[3];
    @geometry = split (/\\/ ,$all[3]);
    $atomnum= $#geometry;
    
    ($i1,$i2,$i3,$i4,$i5)=FindHirsh($x);
    @at =@$i1;
    @fa0=@$i2;
    @fb0=@$i3;
    @sd0=@$i4;
    @ch =@$i5;
    ($i1,$i2,$i3,$i4,$i5)=FindHirsh("Fukui/$x-fk+");
    @fa1=@$i2;
    @fb1=@$i3;
    @sd1=@$i4;
    ($i1,$i2,$i3,$i4,$i5)=FindHirsh("Fukui/$x-fk-");
    @fa2=@$i2;
    @fb2=@$i3;
    @sd2=@$i4;
    foreach $i (0..$atomnum){
        if (-e "di-$x/$x-$i.int"){
            open F, "grep 'ALPHA ELECTRONS' di-$x/$x-$i.int |";
            $_ = <F>;
            @a = split;
            $alphbad[$i] = $a[-1];
            close F;
            open F, "grep 'BETA ELECTRONS' di-$x/$x-$i.int |";
            $_ = <F>;
            @a = split;
            $betabad[$i] = $a[-1];
            close F;
            open F, "grep 'NET CHARGE' di-$x/$x-$i.int |";
            $_ = <F>;
            @a = split;
            $chargebad[$i] = $a[-1];
            $spbad[$i] = $alphbad[$i] - $betabad[$i];
            close F;
        }
    }
    
    foreach $i (0..$atomnum){
        if (-e "di-$x-/$x--$i.int"){
            open F, "grep 'NET CHARGE' di-$x-/$x--$i.int |";
            $_ = <F>;
            @a = split;
            $chargebadred[$i] = $a[-1];
            close F;
        }
    }

    $dir = "file:///C:/Users/Tomerini/Documents/Quinones-article/figures/procs/$x.cubes";
    $toplot = ""; 
    $surface = "isosurface sign aquamarine coral color translucent cutoff 0.05 ";
    
    print CHARGES"\n";
    printf CHARGES "%-$f2  ", $x;
    foreach $i (@ch){ printf CHARGES "% 7.3f ",$i ;} print CHARGES"\n";
    printf HIRSHSD "%-$f2  ", $x;
    foreach $i (@sd0){ printf HIRSHSD "% 7.3f ",$i ;} print HIRSHSD"\n";
    printf BADERCHS "%-$f2  ", $x;
    foreach $i (0.. $#ch){  printf BADERCHS "$at[$i]"; printf BADERCHS "%03d ","$i+1" }
    print BADERCHS"\n";
    printf BADERCHS "%-$f2  ", $x;
    foreach $i (@chargebad){ printf BADERCHS "% 7.5f ",$i ;} print BADERCHS"\n";
    printf BADERSD "%-$f2  ", $x;
    foreach $i (0.. $#ch){  printf BADERSD "$at[$i]"; printf BADERSD "%03d ","$i+1" }
    print BADERSD"\n";
    printf BADERSD "%-$f2  ", $x;
    foreach $i (@spbad){ printf BADERSD "% 7.5f ",$i ;} print BADERSD"\n";
    printf BADERDELTA "%-$f2  ", $x;
    foreach $i (0..$#chargebad){ printf BADERDELTA "% 7.3f ",$chargebadred[$i] - $chargebad[$i] ;} print BADERDELTA"\n";
    
    # Fukui Functions

    if (-e "Fukui/$x-fk+.log") {
        printf FUKPLUS "%-$f2  ", $x;
        @fkdual=();
        for $i (0..$#fa1) { 
            printf FUKPLUS "% 7.3f ",($fa0[$i]+$fb0[$i] - $fa1[$i]- $fb1[$i]);
            $fkdual[$i]=-(2*$fa0[$i]+2*$fb0[$i] - $fa2[$i]- $fb2[$i] -  $fa1[$i]- $fb1[$i])/2;
        } 
        print FUKPLUS"\n";
        printf FUKMIN "%-$f2  ", $x;
        for $i (0..$#fa2){ printf FUKMIN "% 7.3f ", ($fa2[$i]+$fb2[$i] - $fa0[$i]- $fb0[$i]);} print FUKMIN"\n";
        printf FUKDUAL "%-$f2  ", $x;
        for $i (0..$#fa1){ printf FUKDUAL "% 7.3f ", $fkdual[$i]} print FUKDUAL"\n";
        open XXX, ">$x.fkdual.jmol";
        print XXX " load \"$dir/$x.log\"; model last; $surface \"$dir/$x-HOMO.cube\"; color background white; select all; color label blue; font label 20 ;";
        foreach $i (0..$#at) { print XXX "select $at[$i]", $i+1, "; label "; printf XXX "% 5.2f ; ", $fkdual[$i]*100 } print XXX "\n";
        close XXX;
        open XXX, ">$x.sd.jmol";
        print XXX " load  \"$dir/$x.log\" ; model last; isosurface sign aquamarine coral color translucent cutoff 0.05   \"$dir/$x-HOMO.cube\"; color background white; select all; color label blue; font label 20 ;";
        foreach $i (0..$#at) {
        printf XXX "select $at[$i]%i; label \"% 5.2f |<color red>% 5.3f\"; ", $i+1, $sd0[$i]*100, $ch[$i] } ;
        print XXX " select all; set labelfront on ;\n";

    }

    
    # Format of charges and spin...
    $SDFormat="% 5.1f";
    $CHFormat="% 5.2f";

    # JMol files

    open XXX, ">$x.charge.jmol";
    print XXX " load \"$dir/$x.log\"; model last; $surface \"$dir/$x-HOMO.cube\"; color background white; select all; color label blue; font label 20 ;";
    foreach $i (0..$#at) { print XXX "select $at[$i]", $i+1, "; label "; printf XXX "% 5.3f ; ", $ch[$i] } print XXX "\n";
    print XXX " select all; set labelfront on ;\n";
    close XXX;
    open XXX, ">$x.sd.jmol";
    print XXX " load  \"$dir/$x.log\" ; model last; $surface  \"$dir/$x-HOMO.cube\"; color background white; select all; color label blue; font label 20 ;";
    foreach $i (0..$#at) {
      printf XXX "select $at[$i]%i; label % 5.2f ; ", $i+1, $sd0[$i]*100, } ;
    print XXX " select all; set labelfront on ;\n";
    close XXX;
    open XXX, ">$x.baderch.jmol";
    print XXX " load \"$dir/$x.log\"; model last;  color background white; select all; color label black; font label 28 monospaced bold;";
    foreach $i (0..$#at) { print XXX "select $at[$i]", $i+1, "; label "; printf XXX "$CHFormat ; ", $chargebad[$i] } print XXX "select all;\n";
    print XXX " select all; set labelfront on ;\n";
    close XXX;
    open XXX, ">$x.baderspinden.jmol";
    print XXX " load \"$dir/$x.log\"; model last;  color background white; select all; color label blue; font label 20 ;";
    foreach $i (0..$#at) { print XXX "select $at[$i]", $i+1, "; label "; printf XXX "$SDFormat ; ", $spbad[$i]*100 } print XXX "\n";
    print XXX " select all; set labelfront on ;\n";
    close XXX;

    #open XXX, ">$x.baderdelta.jmol";
    #print XXX " load \"$dir/$x.log\"; model last;  color background white; select all; color label black; font label 28 monospaced bold;";
    #foreach $i (0..$#at) { print XXX "select $at[$i]", $i+1, "; label "; printf XXX "% 5.3f ; ", $chargebadred[$i] - $chargebad[$i] } print XXX "select all;\n";
    #close XXX;

   }

sub FindHirsh(){
  ($infile)=@_;
  if (-e "$infile.log") {
    open X,"$infile.log";
    my @AtSym;
    my @HA;
    my @HB;
    my @SD;
    my @CH;
    while (<X>) {
        if (/Hirshfeld populations/) {
            $_= <X>; $_= <X>;
            $i=0;
            do {
                @k = split;
                $AtSym[$i]= $k[1] ;
                $HA[$i]= $k[3] ;
                $HB[$i]= $k[4] ;
                $SD[$i]= $k[3]-$k[4];
                $i++;
                $_= <X>;
            } while (not /Tot/);
        }
        if (/Hirshfeld spin densities, charge/) {
            $_= <X>;$_= <X>;
            $i=0;
            do {
                @k = split;
                $CH[$i] = $k[3];
                $i++;
                $_=<X>;
            } while (not /Tot/);
        }
    }
    close X;
    return (\@AtSym,\@HA, \@HB, \@SD, \@CH);
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

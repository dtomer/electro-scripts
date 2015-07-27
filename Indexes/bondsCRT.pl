#!/usr/bin/perl

open F, $ARGV[0];
while (<F>) {
  @x = split;
  @ring = @x[1..6];
  $x[0] =~ s/.log//g;
#  $str = "C$ring[$ARGV[1]]-C$ring[$ARGV[2]]";
#  $str = "C$ring[3]-O";
  $str = "C3-";
  open X, "$x[0].bcrt" ;
  while (<X>) {
   if (/$str/)  {
      @u = split;
#      print "$x[0] $_";
      print "$x[0] $_" if (index($u[0], "4") != -1);
   }
 }
 close X;
}  
  open X, $x[0];
  

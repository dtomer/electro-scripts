#!/usr/bin/perl


#
@x = @ARGV;
print "@x\n";
foreach $x (@x) {
  $x =~ s/.log//g;
  print "processing $x... \n";
  $i = 0;
  @allloc = glob "di-$x/*loc";
  for $y (@allloc) {
    system("cat $y >> $x.loc");
  }
}



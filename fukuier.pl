#!/usr/bin/perl

use Time::HiRes qw(usleep nanosleep);

$data = "$ENV{'HOME'}/bin/data/";
$pbs = "$data/pbs.fk";
$bin = 
system("mkdir -p Fukui");
chdir "Fukui";
system("cp $pbs pbs");
system("cp $data/fk+.com .");
system("cp $data/fk-.com .");

@i = @ARGV;

foreach $i (@i){
  $i =~ s/.log//g;
  $z = "x".substr($i, -10);
  print "processing $i...";
  system("sed -e \"s/xxx/$i-fk-/ig\" fk-.com > $i-fk-.com");
  system("sed -e \"s/xxx/$i-fk+/ig\" fk+.com > $i-fk+.com");

  system("cp ../$i.chk $i-fk-.chk");
  system("cp ../$i.chk $i-fk+.chk");

  system("sed -e \"s/xxx/$i-fk-/ig\" pbs > pbs.g09.$i-fk-");
  system("sed -e \"s/xxx/$i-fk+/ig\" pbs > pbs.g09.$i-fk+");
  system("sed -i \"s/yyy/$z-fk-/ig\" pbs.g09.$i-fk-");
  system("sed -i \"s/yyy/$z-fk+/ig\" pbs.g09.$i-fk+");
  print "Done!\n";
  system("qsub pbs.g09.$i-fk-");
  system("qsub pbs.g09.$i-fk+");
  usleep(250);
}

unlink "pbs";
unlink "fk+.com";
unlink "fk-.com";


  

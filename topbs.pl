#!/usr/bin/perl -w


$pbs = "$ENV{'HOME'}/bin/data/pbs.g09";

@i = @ARGV;
foreach $i (@i) {
  $i =~ s/.com//g;
  $i =~ s/.log//g;
  $z = substr($i, -10);
  if (-e "$i.com"){
    system("sed -e \"s/xxx/$i/ig\" $pbs > pbs.g09.$i");
    system("sed -i \"s/yyy/$z/ig\" pbs.g09.$i");
    system("qsub pbs.g09.$i") unless ($ARGV[0] eq 'no') ;

  }
}



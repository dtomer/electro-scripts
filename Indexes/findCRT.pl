#!/usr/bin/perl 

print "Files to print:", "@ARGV\n...Starting...\n";
foreach $wfn (@ARGV) {
$wfn =~ s/.log/.wfn/g;
$wfn =~ s/.com/.wfn/g;

open WFN, $wfn or next ;

print "processing $wfn...\n";
$seed= substr $wfn, 0, -4;

system("sed -i 's/TOTAL ENERGY/THE  HF ENERGY/' $seed.wfn");

@atoms=();
@coord=();

while (<WFN>) {
  if (/GAUSSIAN/) {
    $i=0;
    $_=<WFN>;
    do {
      $atoms[$i] = substr $_, 0, 8;
      @i= split;
      @{$coord[$i]}= @i[4..6];
      $i++;
      $_=<WFN>;
    } while !(/CENTRE ASSIGNMENTS/);
  }
}
close WFN;

open FOREXT, ">forext";
print FOREXT "CriticalPoints
1
6
2
3
0
0
0
9
";
close FOREXT;
system("a.ext $seed < forext > $seed-1.out");
system("cp $seed.crt $seed.allcrt");
@nbond=();
@nring = ();
@alist =();
@aring = ();
@ringenv = ();
@splitCP=();
@rings=();
@$bonds=();
$r=0;
$b=0;
@cp=();

open CP, "$seed.crt";
while (<CP>) {
  if (/CRITICAL POINTS/) {
    $i=0;
    while (<CP>) {
      $cp[$i] = $_;
      @{$splitCP[$i]} = split ;  
      $i++;
    }
  }
}
close CP;


for $j (0..$#cp) {
    if ($cp[$j] =~ /(3, 1)/){
      $rings[$b] = $j;
      $b++;
    }
    if ($cp[$j] =~ /(3,-1)/) {
      $bonds[$r] = $j;
      $r++;
    }
}

print "Found $r bonds and $b rings";

open FOREXT, ">forext";
print FOREXT "CriticalPoints \n1";
foreach $i (@bonds) {
  print FOREXT "
1
$splitCP[$i]->[5] $splitCP[$i]->[7]
1
1";
}
print FOREXT "\n9";
close FOREXT;

system("a.ext $seed < forext > $seed-2.out");
open MEO, ">picc";
open CP, "$seed.crt";
$i=0;
$first = 1;
while (<CP>) {
  if (/BOND PATH LINKED/ and $first) {
    $cp[$bonds[$i]] = $_;
    $first=0;
    $_ = <CP>;
  }
  if (/BOND PATH LINKED/)  {
    $cp[$bonds[$i]] = "$cp[$bonds[$i]] '$_'\n";   
    $i++;
    $first = 1;   
  }
}

for $i (0..$#atoms) {
  $alist[$i] ="";
  $aring[$i] = "";
  $ringenv[$i] = "";
  $nring[$i] = 0;
  foreach $k (@rings) {
    $rdist = distance(@{$coord[$i]}[0..2],@{$splitCP[$k]}[1..3]);
if ($rdist < 3.5) {
      $nring[$i]++;
      $aring[$i] = "$aring[$i] $splitCP[$k]->[1] $splitCP[$k]->[2] $splitCP[$k]->[3]\n";
      $bondnum=0;
      $bwarn = 0;
      foreach $j (@bonds) {
       if ($cp[$j] =~ /$atoms[$i]/) {
        $bondnum++;
        if (distance(@{$splitCP[$j]}[1..3],@{$splitCP[$k]}[1..3]) < $rdist) {
         $bwarn++;
         $ringenv[$i] = "$ringenv[$i] $bondnum";
         $ringenv[$i] = "$ringenv[$i] warning" if ($bwarn> 2);
        }
       }
      }
      $ringenv[$i] = "$ringenv[$i] 0 0 \n";
    }
  }
  print MEO "$i:\n";
  foreach $j (@bonds) {
    if ($cp[$j] =~ /$atoms[$i]/) {
      $alist[$i] = "$alist[$i] $splitCP[$j]->[1] $splitCP[$j]->[2] $splitCP[$j]->[3]\n";
      print MEO "$cp[$j]";
       $nbond[$i]++;
  } 
}
  print MEO"---\n";
}

system("AnPoints.pl $seed.crt > $seed.bcrt")
}

sub distance() {
  @i[0..2] = @_[0..2];
  @j[0..2] = @_[3..5];
  my $b= 0.0;

  for my $i (0..2) {
    $b += ($i[$i]-$j[$i])*($i[$i]-$j[$i]);
  }
  $b = sqrt($b);
}

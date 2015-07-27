#!/usr/bin/perl 

$home = "$ENV{'HOME'}/bin";

@allwfn = @ARGV;
print "Files to process: ",  join(", ",@allwfn),"\n Starting...\n";
foreach $wfn (@allwfn) {
    open WFN, $wfn or die "Cannot find the file '$wfn'";
    print "processing $wfn...\n";

    $seed = $wfn;
    $seed =~ s/.com//g;
    $seed =~ s/.log//g;
    $seed =~ s/.wfn//g;

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
    
    
    open LOG, "$seed.log" or die "Cannot find the file '$seed.log'. wfn and gaussian files should have the same name!";
    while (<LOG>) {
        if (/alpha electrons/) {
            @i= split;
            $alpha= $i[0];
            $beta= $i[-3];
            last;
        }
    }
    close LOG;

    open FOREXT, ">forext";
    print FOREXT "CriticalPoints\n1\n6\n2\n3\n0\n0\n0\n9\n";
    close FOREXT;

    system("$home/Gatti/a.ext $seed < forext > tempout");
    unlink "tempout";

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
            $rings[$ir] = $j;
            $r++;
        }
        if ($cp[$j] =~ /(3,-1)/) {
            $bonds[$b] = $j;
            $b++;
        }
    }

    print "\nFound $b bonds and $r rings\n";

    open FOREXT, ">forext";
    print FOREXT "CriticalPoints \n1";
    foreach $i (@bonds) {
        print FOREXT "\n1\n$splitCP[$i]->[5] $splitCP[$i]->[7]\n1\n1";
    }
    print FOREXT "\n9";
    close FOREXT;

    system("$home/Gatti/a.ext $seed < forext > tempout");
    unlink "tempout";

    open MEO, ">picc";
    open CP, "$seed.crt";
    $i=0;
    while (<CP>) {
        if (/BOND PATH LINKED/) {
            $cp[$bonds[$i]] = $_;
            do { $_ = <CP>; } while (not /BOND PATH LINKED/);
            $cp[$bonds[$i]] = "$cp[$bonds[$i]] '$_'\n";   
            $i++;   
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
                $bnum=0;
                $u[0] = 999;
                $u[1] = 999;
                $v[0] = 1000;
                $v[1] = 1000;
                foreach $j (@bonds) {
                    if (index($cp[$j], $atoms[$i]) != -1)  {
                        $bnum++;
                        $jj = distance(@{$splitCP[$j]}[1..3], @{$splitCP[$k]}[1..3]) ;
                        if ($jj < $u[0]) {
                            $u[1] = $u[0];
                            $v[1] = $v[0];
                            $u[0] = $jj;
                            $v[0] = $bnum;
                        } else { 
                            if ($jj < $u[1]) {
                                $u[1] = $jj; 
                                $v[1] = $bnum;
                            }
                        }    
                    }
                }
                if ($bnum>1) {
                    $nring[$i]++;
                    $aring[$i] = "$aring[$i] $splitCP[$k]->[1] $splitCP[$k]->[2] $splitCP[$k]->[3]\n";
                    $ringenv[$i] = "$ringenv[$i] $v[0] $v[1] 0 0 \n";
                }    
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
    }


    $alpha++;

    system("mkdir -p di-$seed");

    for $i (0..$#atoms) {
        open PINP, ">di-$seed/$seed-$i.inp";
        print PINP "$seed\n";
        print PINP "$atoms[$i] \nPROAIM\n$nbond[$i] $nring[$i] 0\n$alist[$i]$aring[$i]$ringenv[$i] 64 48 96\nOPTIONS\nINTEGER 2\n 6 1     calculate AOM\n 9 $alpha\nREAL 0\n";
        close PINP;
    }


    system("cp $seed.log di-$seed/.");
    system("cp $seed.wfn di-$seed/.");

    $time=int($#atoms/12)+1;
    $octtime=$time*8;
    open PBS, ">pbs.SF.$seed";
    print PBS
"#!/bin/csh -f

#PBS -V
#PBS -j oe -N SF-$seed
#
#PBS -l nodes=1:ppn=8
#PBS -l cput=$octtime:00:00,walltime=00:$time:00:00
#

cd \$PBS_O_WORKDIR/di-$seed
";

    for $i (0..$#atoms) {
        print PBS "$home/Gatti/a.correttalocsp  $seed-$i  $seed $seed-$i $seed-$i > $seed-$i.int\n";
    }
    print PBS "compact.pl $seed.wfn\n";
    close PBS;
    system("qsub pbs.SF.$seed") ;
}


#subroutines

sub distance() {
  @i[0..2] = @_[0..2];
  @j[0..2] = @_[3..5];
  my $b= 0.0;

  for my $i (0..2) {
    $b += ($i[$i]-$j[$i])*($i[$i]-$j[$i]);
  }
  $b = sqrt($b);
}






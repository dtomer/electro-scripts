#!/usr/bin/perl

use Term::ANSIColor;

$dir = "$ENV{'HOME'}/bin/data";

$l  = longest(@ARGV) +1;
$f2 = $l."s";

foreach $file (@ARGV) {
    $file =~ s/.log//g;
    if (-e "$file-.log") {
        ($hf1, $zpe1, $th1) = GetData("$file");
        ($hf2, $zpe2, $th2) = GetData("$file-");
        printf "%-$f2  ", $file;
        printf colored( sprintf("% .5f", ($hf1 - $hf2)*27.211396132 - 1.46),"red");
        printf "% .3f % .3f \n", $zpe1-$zpe2, $th1-$th2;
        
    } 
    
}




sub GetData() {
    ($x)= @_;
    open LOG, "$x.log" or die "no $x.log file";
    while (<LOG>) {
        if (/l9999/) {
            $summary="";
            while (index($summary, '\\\@') == -1) {
                $_ =~ s/^\s+|\s+$//g;
                $summary .= $_;
                $_ = <LOG>;
            }
        }
    }
    @all = split (/\\\\/ ,$summary);
    $i = 0;
    for $c (@all) {
        $j=0;
        @c= split (/\\/ ,$c);
        for $d (@c) {
            $j++;
	    if (index($d, "HF=" ) != -1) {
		@k= split (/=/ ,$d);
              $hf = $k[-1];
	    }
            if (index($d, "ZeroPoint=" ) != -1) {
              @k= split (/=/ ,$d);
              $zpe = $k[-1];
            }
            if (index($d, "Thermal=" ) != -1) {
              @k= split (/=/ ,$d);
              $th = $k[-1];
            }

        }
        $i++;
    }
    return ($hf, $zpe, $th); 
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


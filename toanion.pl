#!/usr/bin/perl -w

@x = @ARGV;
foreach $x (@ARGV) {
    print "processing  $x\n";
    @k = ();
    $x =~ s/.com//g;
    open X, "$x.com" or die "no file";
    while (<X>) {
        if ( /^\s*$/ ) {
            $_ = <X>;
            push  (@k, $_);
        }
    }
    if (substr($x, -1) eq "+") {
        $new = substr($x, 0, -1)
    } else {$new = "$x-"}

    @chmul = split(" ", $k[1]);
    if ($chmul[1] == 1) {$newchmul[1] = 2} else {$newchmul[1] = 1};
    $newchmul[0] = $chmul[0]-1;   
    system("sed -e \"s/$x/$new/ig\" $x.com > $new.com");
    system("sed -i 's/$chmul[0] $chmul[1]/$newchmul[0] $newchmul[1]/g'  $new.com")
}

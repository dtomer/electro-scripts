#!/usr/bin/perl

sub combine;

$dir = "$ENV{'HOME'}/bin/data";
$xxx1 = "$dir/com.opt.1";
$xxx2 = "$dir/com.opt.2";
$xxx3 = "$dir/com.opt.3";


$charge=0;
$mul=1;
system("mkdir -p nosolvent");
system("mkdir -p solvent");

$nsubs = shift(@ARGV);
foreach $seed (@ARGV){

  $seed =~ s/.smi//g;
  open X, "$seed.smi";
  $mol = <X>;
  close X;
  open X, "$seed.pos" or die "no $seed.pos file\n";
  if ($nsubs == 0) {
         $newname="0N_$seed";
         print  $newname;
         $newsmi=$mol;
         print "  $newsmi\n";
         system("obabel -:\"$newsmi\" -O $newname.in.mol --gen3D");
	 system("obminimize -o mol $newname.in.mol > $newname.mol");
         system("obabel $newname.mol -O $newname.xyz");
         system("cp $newname.xyz $newname");
         system("sed '1,2d' $newname.xyz > $newname");
         system("(cat $xxx1; echo '$charge $mul'; cat $newname; echo '  ' ) > nosolvent/$newname.com");
         system("perl -p -i -e \"s/xxx/$newname/g\"  nosolvent/$newname.com");
         system("(cat $xxx2; echo '$charge $mul'; cat $newname  $xxx3) > solvent/$newname.com");
         system("perl -p -i -e \"s/xxx/$newname/g\"  solvent/$newname.com");
         system("rm $newname");
  }
  else {
    $_ = <X>;
    @map = split;
    close X;
    @rest = CreateSet($mol, @map);
    my @map2;
    for $x  (@map) {
      push(@map2,$x) if ($x !=0)
    }
    $string = $mol;
    @x = combine \@rest, $nsubs; 
    @y = combine \@map2, $nsubs;
    for $i ( 0 .. $#x ) {
         $subname = join('-', @{$y[$i]});
         $newname=$subname."N_$seed";
         print  $newname;
         $newsmi=$mol;
         foreach (@{$x[$i]}) {
             substr($newsmi,$_,1) = 'N';
         }
         print "  $newsmi\n";
         system("obabel -:\"$newsmi\" -O $newname.in.mol --gen3D");
    }
    
    
    system("babel  *$seed*.in.mol U.mol  -m  --unique");	
    foreach $mols (glob ("U*$seed*mol")) {
	unlink $mols if (-z $mols );
    }
 
    for $i ( 0 .. $#x ) {
         $subname = join('-', @{$y[$i]});
         $newname=$subname."N_$seed";
         foreach (@{$x[$i]}) {
             substr($newsmi,$_,1) = 'N';
         }
         if (-e "U$newname.in.mol") {
         	system("obminimize -o mol U$newname.in.mol > $newname.mol");
         	system("obabel $newname.mol -O $newname.xyz");
         	system("sed '1,2d' $newname.xyz > $newname");
         	system("(cat $xxx1; echo '$charge $mul'; cat $newname; echo '  ' ) > nosolvent/$newname.com");
         	system("perl -p -i -e \"s/xxx/$newname/g\"  nosolvent/$newname.com");
         	system("(cat $xxx2; echo '$charge $mul'; cat $newname  $xxx3) > solvent/$newname.com");
         	system("perl -p -i -e \"s/xxx/$newname/g\"  solvent/$newname.com");
         	system("rm $newname");
                unlink  "U$newname.in.mol";
	}
    }
  }
}




sub CreateSet {
    my ($inmol, @map) = @_;
    my @outmol;
    $offset=0;
    my $result = index($inmol, "C", $offset);
    while ($result != -1) {
        $offset = $result + 1;
        $test = shift @map;
        push(@outmol,$result) if ($test != 0);
        $result = index($inmol, "C", $offset);
    }
    return @outmol;
}


sub combine {

  my ($list, $n) = @_;
  die "Insufficient list members" if $n > @$list;

  return map [$_], @$list if $n <= 1;

  my @comb;

  for (my $i = 0; $i+$n <= @$list; ++$i) {
    my $val  = $list->[$i];
    my @rest = @$list[$i+1..$#$list];
    push @comb, [$val, @$_] for combine \@rest, $n-1;
  }

  return @comb;
}



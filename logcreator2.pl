#!/usr/bin/perl


$dir = "$ENV{'HOME'}/bin/data";
$xxx1 = "$dir/com.opt.1";
$xxx2 = "$dir/com.opt.2";
$xxx3 = "$dir/com.opt.3";


system("mkdir -p nosolvent");
system("mkdir -p solvent");

if (defined($ARGV[0])) {
  $i2 = $ARGV[0];
  $i2 =~ s/.smi//g;
  $i1=$ARGV[1];
  $ch = $ARGV[2];
  $mul = $ARGV[3];
  open S, $ARGV[0] or die "no such file";
  $_ = <S>;
  @x = split;
  $str = $x[0];
  print "\ndealing with file $i2\nsmile $str\nposition $i1\n\n";
} else { die "Undefined smile file to deal with"};

%subs=
("H","",
"F","(F)",
"Cl","(Cl)",
"Br","(Br)",
"NO2","(N(=O)=O)",
"NH2", "(N)",
"O-", "([O-])",
"Ac", "(C(=O)C)",
"Me", "(C)",
"MeO-", "(C[O-])",
"CN", "(C#N)",
"NCH32","(N(C)C)",
"CF3", "(C(F)(F)F)",
"COF", "(C(=O)F)",
"COCl", "(C(=O)Cl)",
"CHO", "(C=O)",
"OCH3","(OC)",
"COO-", "(C(=O)[O-])",
"COOMe", "(C(=O)OC)",
"N3", "(N=[N+]=[N-])",
"ONO2", "(ON(=O)=O)",
"SO3-", "(S(=O)(=O)[O])",
"TBu", "(C(C)(C)C)",
"SO2F", "(S(=O)(=O)F)",
"POF2", "(P(=O)(F)F)",
"SO2CN", "(S(=O)(=O)C#N)",
"SO2CF3", "(S(=O)(=O)C(F)(F)F)",
"OCN", "(OC#N)",
"SCN", "(SC#N)"
);

%ions=
("SO3", "1",
"BOH3", "1",
"O-","1",
"MeO-",1,
"COO-",1);

# The more, the merrier


# SMILES string for the molecule. X and Y where to attach the substituents
# Instead of O-Li-O, use O-S-O. For some reason babel process them better

my $occ = () = $str =~ /X/g; # Number of X occurrencies, useful to calculate the charge if X is anion

foreach my $k ( keys %subs) {
        $x = $str;
        $i = $subs{$k};
        $x =~ s/X/$i/g;
        
        $name="$i1-$k-$i2";
        print  "obabel -:\"$x\" -O $name.com --gen3D\n";
        system("obabel -:\"$x\" -O $name.xyz --gen3D");

        system("cp $name.xyz $name");
        system("sed '1,2d' $name.xyz > $name");
#  system("perl -p -i -e \"s/S /Li/g\"  $i1-$k-$i2");
        $charge = $ch;
        if (exists $ions{$k}) {
            $charge=$charge-$occ};
                
        system("(cat $xxx1; echo '$charge $mul'; cat $name; echo '  ' ) > nosolvent/$name.com");
        system("perl -p -i -e \"s/xxx/$name/g\"  nosolvent/$name.com");
        system("(cat $xxx2; echo '$charge $mul'; cat $name  $xxx3) > solvent/$name.com");
        system("perl -p -i -e \"s/xxx/$name/g\"  solvent/$name.com");       
        system("rm $name");
    
}

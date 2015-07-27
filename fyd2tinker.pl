#!/usr/bin/perl 

# Extract the values of the potential from FYD files and put them into a file good for TINKER
#

$ff = "$ENV{'HOME'}/bin/data/amber99.prm";


open LIB, "frcmod.known";
open CH, "Mol-sm_m1-c1.mol2";

%proton= 
    ("H",1,"He",2,
    "Li",3,"Be",3,"B",5,"C",6,"N",7,"O",8,"F",9,"Ne",10,
    "Na",11,"Mg",12,"Al",13,"Si",14,"P",15,"S",16,"Cl",17,"Ar",18,
    "K",19,"Ca",20,"Br",35,
    "Rb",37,"Sr",38,"I",53);
# Atomic number of some common atoms. Add if missing!


# Read the charges
 
while (<LIB>) {
    if (/MASS/){
        $i=1;
        $_ = <LIB>;
        while (/from/){
            @l = split;
            # Identify the type with a numeric label
            $llabel{$l[0]}=$i;
            $mass[$i]=$l[1];
            # $pol[$i]= $l[2]; # no idea what this is!
            $i++;
            $_ = <LIB>;
        }
    }
    if (/BOND/){
        $i=0;
        $_ = <LIB>;
        while (/from/){
            @l= split /[-\s\/]+/, $_;
            #identify the atoms in the bond
            $bo_at1[$i]= $llabel{$l[0]};
            $bo_at2[$i]= $llabel{$l[1]};
            $bo_k[$i]=$l[2];
            $bo_D[$i]=$l[3];
            $i++;
            $_ = <LIB>;
        }
    }
    if (/ANGLE/){
        $i=0;
        $_ = <LIB>;
        while (/from/){
            @l= split /[-\s\/]+/, $_;
            #identify the atoms in the angle
            $an_at1[$i]= $llabel{$l[0]};
            $an_at2[$i]= $llabel{$l[1]};
            $an_at3[$i]= $llabel{$l[2]};
            $an_k[$i]=$l[3];
            $an_T[$i]=$l[4];
            $i++;
            $_ = <LIB>;
        }
    }
    if (/DIHEDRAL/){
        $i=0;
        $_ = <LIB>;
        while (/from/){
            @l= split /[-\s\/]+/, $_;
            #identify the atoms in the bihefral
            $di_at1[$i]= $llabel{$l[0]};
            $di_at2[$i]= $llabel{$l[1]};
            $di_at3[$i]= $llabel{$l[2]};
            $di_at4[$i]= $llabel{$l[3]};
            $di_V[$i]=$l[5];
            $di_Phase[$i]=$l[6];
            $di_Period[$i]=$l[7];
            $_ = <LIB>;
            $i++;
        }
    }
    if (/IMPROPER/){
        $i=0;
        $_ = <LIB>;
        while (/from/){
            @l= split /[-\s\/]+/, $_;
            $im_at1[$i]= $llabel{$l[0]};
            $im_at2[$i]= $llabel{$l[1]};
            $im_at3[$i]= $llabel{$l[2]};
            $im_at4[$i]= $llabel{$l[3]};
            $im_V[$i]=$l[4];
            $im_Phase[$i]=$l[5];
            $im_Period[$i]=$l[6];
            $i++;
            $_ = <LIB>;
        }
    }
    if (/NONBON/){
        $i=0;
        $_ = <LIB>;
        while (/from/){
            @l= split /[-\s\/]+/, $_;
            $nb[$i]=$llabel{$l[0]};
            $nb_R[$i]=$l[1];
            $nb_eps[$i]=$l[2];
            $i++;
            $_ = <LIB>;
        }
    }
}
close LIB;

while (<CH>) {
    if (/USER_CHARGES/) {
        $_ = <CH>;
        $_ = <CH>;
        $i=0;
        while (/LIG/) {
            @line = split;
            $label[$i]=$line[1];
            # Giving the atom name defined in the line its numeric label from above
            $id[$i]=$line[0];
            $type[$i]=$llabel{$line[5]};
            $ltype[$i]=$line[5];
            $charge[$i]=$line[8];
            $_ = <CH>;
            $i++;
        }
    }
    if (/<TRIPOS>BOND/) {
        for $i (@id){
            $conect[$i]=0;
        }
        $_ = <CH>;
        while (not /SUBSTRUCTURE/) {
            @l= split;
            $conect[$l[1]]++;
            $conect[$l[2]]++;
            $_ = <CH>;
        }
    }
}

close CH;


# From here on, we write the definitions from the read file, into a prm file

system("cp $ff amber99.prm");
open OUT,">>", "amber99.prm";

print OUT "

      #############################
      ##                         ##
      ##  Atom Type Definitions  ##
      ##                         ##
      #############################

";

for $i (0..$#label){
    $j=$type[$i];
    # This guesses the atomic symbol. Second letter is needed only if lower case (should distinguish between CA (atom type) and Ca (Calcium))
    $secondletter= substr $ltype[$i], 1, 1;
    $Atom=substr $ltype[$i], 0, 1;
    $Atom.=$secondletter if ($secondletter =~ /[a-z]/);
    printf  OUT "%-8s %6d %4d    %-5s %-28s %3d %9.3f  %3d \n", "atom", $id[$i], $j, $ltype[$i], "\"$label[$i]\"", $proton{$Atom}, $mass[$j], $conect[$id[$i]]
}

print OUT "
      ################################
      ##                            ##
      ##  Van der Waals Parameters  ##
      ##                            ##
      ################################


";

for $i (0..$#nb){
    printf  OUT "%-8s %6d %20.4f %10.4f\n", "vdw", $nb[$i], $nb_R[$i], $nb_eps[$i]; 
}

print OUT "


      ##################################
      ##                              ##
      ##  Bond Stretching Parameters  ##
      ##                              ##
      ##################################

";

for $i (0..$#bo_at1){
    printf  OUT "%-8s %6d %4d %15.2f %10.4f\n", "bond", $bo_at1[$i], $bo_at2[$i], $bo_k[$i], $bo_D[$i];
}

print OUT "


      ################################
      ##                            ##
      ##  Angle Bending Parameters  ##
      ##                            ##
      ################################

";

for $i (0..$#an_at1){
    printf  OUT "%-8s %6d %4d %4d %10.2f %10.2f\n", "angle", $an_at1[$i], $an_at2[$i], $an_at3[$i], $an_k[$i], $an_T[$i];
}

print OUT "

      #####################################
      ##                                 ##
      ##  Improper Torsional Parameters  ##
      ##                                 ##
      #####################################


";

for $i (0..$#im_at1){
    printf  OUT "%-8s %6d %4d %4d %4d %16.3f %6.1f %2d", "imptors", $im_at1[$i], $im_at2[$i], $im_at3[$i], $im_at4[$i],  $im_V[$i], $im_Phase[$i],  $im_Period[$i];
    print OUT "\n" # remember to add the condition for angle < 0!
}

print OUT "


      ############################
      ##                        ##
      ##  Torsional Parameters  ##
      ##                        ##
      ############################


";

for $i (0..$#di_at1){
     printf  OUT "%-8s %6d %4d %4d %4d %16.3f %6.1f %2d", "torsion", $di_at1[$i], $di_at2[$i], $di_at3[$i], $di_at4[$i],  $di_V[$i], $di_Phase[$i],  $di_Period[$i];
     print OUT "\n" # remember to add the condition for angle < 0!
 }

print OUT "



      ########################################
      ##                                    ##
      ##  Atomic Partial Charge Parameters  ##
      ##                                    ##
      ########################################


";

for $i (0..$#charge){
    printf  OUT "%-8s %6d %20.4f\n", "charge", $id[$i], $charge[$i];
}


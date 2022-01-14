#!/usr/bin/perl

$s=10;

$pi=3.14159265358979323846264338;

open(OUT,">PB_radial.txt");

for ($h=-30; $h<=30; $h+=1) {
    for ($k=-30; $k<=30; $k+=1) {

         # Create the center (parent Poisson-binomial process, F uniform)

         $ranx=rand();
         $rany=rand();
         $x=$h+2*$s*($ranx-1/2);
         $y=$k+2*$s*($rany-1/2);
         print OUT "$h\t$k\tCenter\t$x\t$y\n";

        # Create the child, radial process (up to 15 points per center)

         $M=int(15*rand());

         for ($m=0; $m<$M; $m++) {
             $ran1=rand();
             $ran2=rand();
             $factor=log($ran2/(1-$rand2));
             $x1=$x+$factor*cos(2*$pi*$ran1);
             $y1=$y+$factor*sin(2*$pi*$ran1);
             print OUT "$h\t$k\tLocal\t$x1\t\t$y1\n";
         }
    }
}
close(OUT);

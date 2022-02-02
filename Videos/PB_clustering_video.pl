#!/usr/bin/perl
use List::Util qw(min),qw(max);
use warnings;

$Nprocess=4;   #9    # number of processes in the process superimposition
$seed=32431;  #82431    # arbitrary number
srand($seed);   # initialize random generator
$s=0.15; # .15;        # scaling factor
$width=800;

for ($i=0; $i<$Nprocess; $i++) {
    $shiftX[$i]=rand();
    $shiftY[$i]=rand(); 
}

$processID=0;
for ($h=0; $h<$width; $h++) {
    for ($k=0; $k<$width; $k++) {
        $bitmap[$h][$k]=255;
    }
}

for ($h=-25; $h<=25; $h++) {       
    for ($k=-25; $k<=25; $k++) {    
#        for ($processID=0; $processID<$Nprocess; $processID++) { # BEGIN FOR 1016

            $ranx=rand();
            $rany=rand();
            $ranID=rand();
            if ($ranID < 0.20) {
                $processID=0;
            } elsif ($ranID < 0.60) {
                $processID=1; 
            } elsif ($ranID < 0.90) {
                $processID=2; 
            } else {
                $processID=3;
            }
            $x=$shiftX[$processID]+$h+$s*log($ranx/(1-$ranx)); 
            $y=$shiftY[$processID]+$k+$s*log($rany/(1-$rany));
 
            if (($x>-3)&&($x<3)&&($x>-3)&&($x<3)) {
                $xmod=1+$x-int($x);   # x modulo 2/lambda
                $ymod=1+$y-int($y);   # y modulo 2/lambda
                $pixelX=int($width*$xmod/2);   
                $pixelY=int($width*(2-$ymod)/2); # pixel (0,0) at top left corner
                $bitmap[$pixelX][$pixelY]=$processID;
            }
#        }  # END FOR 1016
    }
}

$window=1;
$nloop=250;       # number of times the image is filtered 

#----------------------------------------------------------------

use GD::Simple; 
    
$im1=GD::Simple->new($width, $width); # handle for the cluster image
$im1->fgcolor('black');
$im1->rectangle(0, 0, $width-1, $width-1); 


$col[0]= $im1->colorAllocate(255,0,0); 
$col[1]= $im1->colorAllocate(0,0,255); 
$col[2]= $im1->colorAllocate(255,179,0); 
$col[3]= $im1->colorAllocate(0,179,0);
$col[4]= $im1->colorAllocate(0,0,0); 
$col[255]= $im1->colorAllocate(0,0,0);

for ($pixelX=1; $pixelX<$width-1; $pixelX++) {
    for ($pixelY=1; $pixelY<$width-1; $pixelY++) {
        $topProcessID=$bitmap[$pixelX][$pixelY];
        $im1->setPixel($pixelX,$pixelY,$col[$topProcessID]);
    }
}
$filename="img_000.png";
print "$filename ...\n";
open(OUT,">$filename"); 
binmode OUT;    # save as binary file
print OUT $im1->png;
close(OUT);

#----------------------------------------------------------------

for ($loop=1; $loop<=$nloop; $loop++) { # BEGIN 1201

    for ($pixelX=1; $pixelX<$width-1; $pixelX++) {
        for ($pixelY=1; $pixelY<$width-1; $pixelY++) {
            $oldBitmap[$pixelX][$pixelY]=$bitmap[$pixelX][$pixelY];
        }
    }

    for ($pixelX=1; $pixelX<$width-1; $pixelX++) {
        for ($pixelY=1; $pixelY<$width-1; $pixelY++) {
            $x=$pixelX;
            $y=$pixelY;
            $topProcessID=$oldBitmap[$x][$y];
            if (($topProcessID==255)||($loop>50)) { 
                $r=rand();
                if ($r<0.25) {
                    $x=$x+1; if ($x>$width-2) { $x-=$width-2; }
                } elsif ($r<0.5) {
                    $x=$x-1; if ($x<1) { $x+=$width-2; }
                } elsif ($r<0.75) {
                    $y=$y+1; if ($y>$width-2) { $y-=$width-2; }
                } else {
                    $y=$y-1; if ($y<1) { $y+=$width-2; }         
                } 
                if (($loop>=50)&&($oldBitmap[$x][$y]==255)) {
                    $x=$pixelX;
                    $y=$pixelY;
                }
            }
            $topProcessID=$oldBitmap[$x][$y];  
            $bitmap[$pixelX][$pixelY]=$topProcessID;
            $im1->setPixel($pixelX,$pixelY,$col[$topProcessID]);
        }
    }

#------------------------------------------------------------------

    if ($loop<10) {
        $filename="img_00"."$loop".".png";
    } elsif ($loop<100) {
        $filename="img_0"."$loop".".png";
    } else {
        $filename="img_"."$loop".".png";
    }
    print "$filename ...\n";
    open(OUT,">$filename"); 
    binmode OUT;    # save as binary file
    print OUT $im1->png;
    close(OUT);

} # END 1201



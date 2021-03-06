#!/usr/bin/perl
use warnings;

# PART 1: Initialization

$Nprocess=5;       # number of processes in the process superimposition
$seed=82431;      # arbitrary number
srand($seed);   # initialize random generator
$s=0.15;        # scaling factor
$epsilon=0.0000000001; # for numerical stability

$sep="\t";      # TAB character 
for ($i=0; $i<$Nprocess; $i++) {
    $shiftX[$i]=rand();
    $shiftY[$i]=rand();
    $stretchX[$i]=1;
    $stretchY[$i]=1;
    $string[$i]=$sep;   
    # $i TABs separating x and y coordinates in output file for points
    # originating from process $i; Used to easily create a scatterplot in Excel 
    # with a different color for each process.
    $sep=$sep."\t";  
}

$processID=0;
$string="\t"; 

$m=0;
for ($h=0; $h<400; $h++) {
    for ($k=0; $k<400; $k++) {
        $bitmap[$h][$k]=255;
    }
}

# PART 2: Generate point process, its modulo 2 version; save to bitmap and output files.

open(OUT,">PB_NN.txt");  # the points of the process 
open(OUT2,">PB_NN_mod.txt");  # the same points modulo 2/lambda both in x and y directions

for ($h=-25; $h<=25; $h++) {       
    for ($k=-25; $k<=25; $k++) {    
        for ($processID=0; $processID<$Nprocess; $processID++) { # BEGIN FOR 1016

            $ranx=rand();
            $rany=rand();
            $x=$shiftX[$processID]+$stretchX[$processID]*$h+$s*log($ranx/(1-$ranx)); 
            $y=$shiftY[$processID]+$stretchY[$processID]*$k+$s*log($rany/(1-$rany));
            $a[$m]=$x;
            $b[$m]=$y;
            $process[$m]=$processID;
            $m++;
            print OUT "$processID\t$h\t$k\t$x$string[$processID]$y\n";  
            # replace $string[$processID] by \t if you don't care about Excel

            if (($x>-20)&&($x<20)&&($x>-20)&&($x<20)) {
                $xmod=1+$x-int($x);   # x modulo 2/lambda
                $ymod=1+$y-int($y);   # y modulo 2/lambda
                $pixelX=int(200*$xmod);   
                $pixelY=int(200*(2-$ymod)); # pixel (0,0) at top left corner
                $bitmap[$pixelX][$pixelY]=$processID;
                print OUT2 "$xmod$string[$processID]$ymod\n";  
                # replace $string[$processID] by \t if you don't care about Excel
            }
        }  # END FOR 1016
    }
}
close(OUT2);
close(OUT);

# PART 3: Find nearest neighbor points, and compute nearest neighbor distances.

open(OUT,">PB_NN_dist_small.txt");
open(OUTf,">PB_NN_dist_full.txt");

for ($i=0; $i<$m; $i++) { # BEGIN FOR 1010

    $mindist=99999999;
    $flag=-1;

    if (($a[$i]>-20)&&($a[$i]<20)&&($b[$i]>-20)&&($b[$i]<20)) { # BEGIN IF 1015
        $flag=0;

        for ($j=0; $j<$m; $j++) { # BEGIN FOR 1012

            $dist=sqrt(($a[$i]-$a[$j])**2 + ($b[$i]-$b[$j])**2);  
            if (($dist<=$mindist+$epsilon)&&($i!=$j)) {  
                $NNx[$i]=$a[$j];  # x-coordinate of nearest neighbor of point $i
                $NNy[$i]=$b[$j];  # y-coordinate of nearest neighbor of point $i
                $NNidx[$i]=$j;    # indicates that point $j is nearest neighbor to point $i
                # NNidxHash{$i} is the list of points having $i as nearest neighbor
                #    points i that list are separated by character "~"
                if (abs($dist-$mindist)<$epsilon) { 
                    $NNidxHash{$i}=$NNidxHash{$i}."~$j";
                } else {    
                    $NNidxHash{$i}="$j";
                }
                $mindist=$dist;
            }
        }  # END FOR 1012

        if ($i % 1000==0) { print "Finding NN's of point $i\n"; }
        print OUT "$i\t$mindist\n";
        print OUTf "$i\t$NNidx[$i]\t$NNidxHash{$i}\t$a[$i]\t"  . 
                   "$b[$i]\t$NNx[$i]\t$NNy[$i]\t$mindist\n";
    }  # END IF 1015
}  # END FOR 1010
close(OUTf);
close(OUT);

# PART 4: Produce data to use in R code that generates the nearest neighbors picture.

open(OUT,">PB_r.txt");
print OUT "idx\tnNN\tNNindex\ta\tb\taNN\tbNN\tprocessID\tNNprocessID\n";
foreach $idx (keys %NNidxHash) {
    $NNlist=$NNidxHash{$idx};
    @list=split("~",$NNlist);
    $nelts=$#list;
    for ($n=0; $n<=$nelts; $n++) {
        $NNindex=$list[$n];
        print OUT "$idx\t$n\t$NNindex\t$a[$idx]\t$b[$idx]\t$a[$NNindex]\t" .
                  "$b[$NNindex]\t$process[$idx]\t$process[$NNindex]\n";
    }
}
close(OUT);

# PART 5: Creates density and cluster images.

require './GD_util.pl';

$window=20; 
$nloop=3;      # number of times the image is filtered 

GD_Maps($window,$nloop,"PB-cluster3.png","PB-density3.png",@bitmap);

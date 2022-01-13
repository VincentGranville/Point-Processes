# Small library consisting of the function GS_Maps, to create 400 x 400 images
# in PNG format, to plot density and cluster maps. Based on the GD graphics library 
# (https://libgd.github.io/). 
# 
# Includes a built-in density estimation technique based on histogram equalization,
# correction for boundary effect, color palette management, and image filtering to 
# detect clusters, with manipulations at the pixel level.  
#
# This library is used in PB_NN.pl

sub GD_Maps {

# Input:
#
#   $window: size of the filtering window (3x3, 5x5, up to 20x20)
#   $nloop: number of times the image is filtered
#   @bitmap2: 401 x 401 array storing the pixel values in memory
#   $img_clusters_name: name of output image (PNG file where each color relates to a 
#       particular point process in a mixture or combination of multiple processes)
#   $img_density_name: name of output image (PNG file where each grey level relates to
#       the concentration or density of points at a particular location; dark if high)
#

use GD::Simple; 

my ($window,$nloop,$img_clusters_name,$img_density_name,@bitmap2) = (@_); 

#---
# PART 1: allocate first image (clustering), allocate colors (palette)

$im1=GD::Simple->new(401, 401);
$im1->fgcolor('black');
$im1->rectangle(0, 0, 400, 400); 

$col[0]= $im1->colorAllocate(255,0,0);
$col[1]= $im1->colorAllocate(0,0,255);
$col[2]= $im1->colorAllocate(255,179,0);
$col[3]= $im1->colorAllocate(0,0,0);
$col[4]= $im1->colorAllocate(0,179,0);
$col[255]= $im1->colorAllocate(255,255,255);

#--- PART 2: iteratively creates two bitmaps:
#
# $bitmap2: to store the pixels of the clustering image
# $densityMap: to store the pixels of the density image

for ($loop=0; $loop<$nloop; $loop++) { # BEGIN 1201

  print "loop $loop out of $nloop\n";

  for ($pixelX=1; $pixelX<400; $pixelX++) {
    for ($pixelY=1; $pixelY<400; $pixelY++) {
      $oldBitmap[$pixelX][$pixelY]=$bitmap2[$pixelX][$pixelY];
    }
  }

  for ($pixelX=1; $pixelX<400; $pixelX++) {
    for ($pixelY=1; $pixelY<400; $pixelY++) {

      @count=();
      $density=0;
      $maxcount=0;
      $topProcessID=255; # dominant processID near (pixelX, pixelY)

      for ($u=-$window;$u<=$window; $u++) { # BEGIN 1210
        for ($v=-$window;$v<=$window; $v++) {
          $x=$pixelX+$u;
          $y=$pixelY+$v;
          if ($x<1) { $x+=399; }   # boundary effect correction
          if ($y<1) { $y+=399; }   # boundary effect correction
          if ($x>399) { $x-=399; } # boundary effect correction
          if ($y>399) { $y-=399; } # boundary effect correction
          $dist2=(1+$u**2 + $v**2)**0.5; 
          $processID=$oldBitmap[$x][$y];
          if ($processID < 255) { 
            $count[$processID]+=1/$dist2;
            if ($count[$processID]>$maxcount) { 
              $maxcount=$count[$processID];
              $topProcessID=$processID;
            }
            $density+=1/$dist2;  
          }
        }
      }   # END 1210

      $density=$density/(10**$loop); 
      $densityMap[$pixelX][$pixelY]+=$density;
      $bitmap2[$pixelX][$pixelY]=$topProcessID;
    }
  }

} # END 1201

#---
# PART 3 
#   - assign pixel colors to cluster image and output image
#   - get list of all densities observed in the density image
#
#  %densityCountHash (hash table) store the list of density values, to
#     be used for frequency equalization in PART 4

my %densityCountHash=();  # use to rebalance grey levels

for ($pixelX=1; $pixelX<400; $pixelX++) {
  for ($pixelY=1; $pixelY<400; $pixelY++) {
    $topProcessID=$bitmap2[$pixelX][$pixelY];
    $density=$densityMap[$pixelX][$pixelY];
    $densityCountHash{$density}++;
    $im1->setPixel($pixelX,$pixelY,$col[$topProcessID]);
  }
}

open(OUT,">$img_clusters_name"); 
binmode OUT;
print OUT $im1->png;
close(OUT);

#---
# PART 4: frequency equalization, then output density image  

my %densityColorHash=();
my $size=keys %densityCountHash;  # number of elements in hash
my $counter=0;

foreach $density (sort {$a <=> $b} keys %densityCountHash) {
  $counter++;
  $quant=$counter/$size;   # always between zero and one
  if ($quant < 0.08) { 
    $densityColorHash{$density}=0;
  } elsif ($quant < 0.18) {
    $densityColorHash{$density}=30;
  } elsif ($quant < 0.28) {
    $densityColorHash{$density}=55;
  } elsif ($quant < 0.42) {
    $densityColorHash{$density}=90;
  } elsif ($quant < 0.62) {
    $densityColorHash{$density}=120;
  } elsif ($quant < 0.80) {
    $densityColorHash{$density}=140;
  } elsif ($quant < 0.95) {
    $densityColorHash{$density}=170;
  } else {
    $densityColorHash{$density}=254;
  }
}

# allocate second image (density image)

$im2=GD::Simple->new(401, 401);
$im2->fgcolor('black');
$im2->rectangle(0, 0, 400, 400); 

# allocate grey levels (palette)

for ($i=0;$i<255; $i++) {
  $col[$i]= $im2->colorAllocate(255-$i,255-$i,255-$i);
}

# create density image pixel by pixel

for ($pixelX=1; $pixelX<400; $pixelX++) {
  for ($pixelY=1; $pixelY<400; $pixelY++) {
    $density=$densityMap[$pixelX][$pixelY];  ## 
    $color=$densityColorHash{$density};
    $im2->setPixel($pixelX,$pixelY,$col[$color]);  
  }
}

# output density image

open(OUT,">$img_density_name"); 
binmode OUT;
print OUT $im2->png;
close(OUT);

}
1;

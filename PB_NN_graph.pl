#---
# Detection of connected components for undirected nearest neighbor graph
#
#   Each point has exactly one nearest neighbor
#      (the program will work even if this is not the case)
#   Very fast, requires about 2n steps for nearest neighbor graph
#   Worst case (all points interconnected): requires n^2 steps 
#---
# PART 1: Read output file from PB-NN.pl
#
# $idx = index of n-th point
# $NNIdx[$idx] = index of nearest point to n-th point

$n=0;
open(IN,"<PB_dist_full.txt"); # input file
while ($inp=<IN>) {
  $inp=~s/\n//g;
  @aux=split(/\t/,$inp);
  $idx=$aux[0];
  $idxHash{$idx}++;
  $point[$n]=$idx;
  $NNIdx[$idx]=$aux[1];
  $n++;
}

# $hash{$idx} is the list of points (separated by ~) connected to point $idx
# $idx is the index of the i-th point in the input file
# points are referred to by their index (or label); $k is an index

%hash=();
for ($i=0; $i<$n; $i++) {

  $idx=$point[$i];
  $substring="~$NNIdx[$idx]";
  $string="$hash{$idx}";  
  if ((index($string, $substring) == -1)&&($substring ne "~")) {
    $hash{$idx}=$hash{$idx}."~$NNIdx[$idx]";
  }

  # to make the graph undirected: $NNIdx[$idx] is nearest neighbor
  # to $idx; add the reverse connection

  $substring="~$idx";
  $string="$hash{$NNIdx[$idx]}";
  if ((index($string, $substring) == -1)&&($substring ne "~")) {
    $hash{$NNIdx[$idx]}=$hash{$NNIdx[$idx]}."~$idx";

  }
}

#---
# PART 2: detect the connected components 

$i=0;
$steps=0;
while ($i<$n) { # WHILE 344

  # skip points already assigned to a connected component
  while (($status[$point[$i]] ==-1)&&($i<$n)) {  
    # point[i] already assigned to a clique, move to next point
    $i++;
  }
 
  # find clique that point[i] belongs to

  $nstack=1;
  $idx=$point[$i];
  $stack[0]=$idx;   # initialize the point stack, by adding $idx 
  $onStack[$idx]=1;
  $size=1;  # size of the stack at any given time

  while ($nstack>0) {  # WHILE 118

    $idx=$stack[$nstack-1];

    if (($size==1)&&($status[$idx]==-1)) {
      print "Warning: incomplete data [idx=$idx]\n"; 
      $nstack=0; # forces exit from loop WHILE 118
    }

    if ($status[$idx] != -1) { # IF 555
      $status[$idx]=-1;  # idx considered processed
      # add point idx to connected component being created
      #   (identified by its first point: $point[$i])
      if ($i<$n) { 
        $cliqueHash{$point[$i]}=$cliqueHash{$point[$i]}."~$idx"; 
      }

      $nstack--;
      @aux=split("~",$hash{$idx});
      $n_aux=$#aux;
      for ($k=1; $k<=$n_aux; $k++) { # FOR 412
        # loop over all points that have point $idx as nearest neighbor
        $idx2=$aux[$k];
        $stat=$status[$idx2];
        if ($status[$idx2] != -1) {  # IF 556 
          # add point $idx2 on the stack if it is not there yet
          if ($onStack[$idx2] != 1) {
            $stack[$nstack]=$idx2;
            $nstack++;
          }
          $onStack[$idx2]=1;
        } # END IF 556
      } # END FOR 412
    } # END IF 555
  } # END WHILE 118
} # END WHILE 344

#---
# PART 3: print output
# 
# Here $clique stands for connected component 

open(OUT,">pbcc.txt");
foreach $clique (keys %cliqueHash) {
  $count=() = $cliqueHash{$clique} =~ /\~/g; 

  # $count is the number of points in connect component $clique
  # $cliqueHash{$clique} is the string containing all the points of $clique
  #     points (their index) are separated by character ~

  print OUT "$cliqueHash{$clique}\t$count\n";
}
close(OUT);

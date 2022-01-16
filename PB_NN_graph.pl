# PART 1: Initialization. 

$n=0;
open(IN,"<PB_dist_full.txt"); # input file
while ($inp=<IN>) {
    $inp=~s/\n//g;  # current row
    @aux=split(/\t/,$inp); 
    $idx=$aux[0];  # first column
    $idxHash{$idx}++;
    $point[$n]=$idx;
    $NNIdx[$idx]=$aux[1];  # second column
    $n++; # number of points (that is, number of rows in input file)
}
close(IN);

%hash=();
for ($i=0; $i<$n; $i++) {
    $idx=$point[$i];
    $substring="~$NNIdx[$idx]";
    $string="$hash{$idx}";
    if ((index($string, $substring) == -1)&&($substring ne "~")) {
        $hash{$idx}=$hash{$idx}."~$NNIdx[$idx]";
    }
    $substring="~$idx";
    $string="$hash{$NNIdx[$idx]}";
    if ((index($string, $substring) == -1)&&($substring ne "~")) {
        $hash{$NNIdx[$idx]}=$hash{$NNIdx[$idx]}."~$idx";
    }
}

# PART 2: Find the connected components 

$i=0;

while ($i<$n) { # BEGIN WHILE 344

    # skip points already assigned to a connected component
    while (($status[$point[$i]] ==-1)&&($i<$n)) {  
        # point[i] already assigned to a clique, move to next point
        $i++;
    }
 
    $nstack=1;
    $idx=$point[$i];
    $stack[0]=$idx;   # initialize the point stack, by adding $idx 
    $onStack[$idx]=1;
    $size=1;  # size of the stack at any given time

    while ($nstack>0) {  # BEGIN WHILE 118
        $idx=$stack[$nstack-1];
        if ($status[$idx] != -1) { # BEGIN IF 555
            $status[$idx]=-1;  # idx considered processed
            if ($i<$n) {  $cliqueHash{$point[$i]}=$cliqueHash{$point[$i]}."~$idx";  }
            $nstack--;
            @aux=split("~",$hash{$idx});
            $n_aux=$#aux;
            for ($k=1; $k<=$n_aux; $k++) { # BEGIN FOR 412
                # loop over all points that have point $idx as nearest neighbor
                $idx2=$aux[$k];
                $stat=$status[$idx2];
                if ($status[$idx2] != -1) {  # BEGIN IF 556 
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

# PART 3: Save results.

open(OUT,">PB_cc.txt");
foreach $clique (keys %cliqueHash) {
    $count=() = $cliqueHash{$clique} =~ /\~/g; 
    print OUT "$cliqueHash{$clique}\t$count\n";
}
close(OUT);

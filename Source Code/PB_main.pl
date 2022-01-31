#!/usr/bin/perl

use Math::Trig;
use strict;
use warnings;

my $n2;              # Simulation: Xk with index k between -n2 and +n2
my $n1;              # compute E[N(B)], Var[N(B)]: k between -n1 and +n1
                     # n1 much larger than s (if F has thick tail)
                     # reduce n1 if program too slow [speed ~ O(n1 log n1)]
my ($s,$lambda);     # scaling factor and intensity (both > 0)
my ($aa,$bb);        # interval B used to compute exact Expectation and var
my $r;               # to compute r-th moment of T (r>0)
                     # E[T^r] tends to r!/(lambda)^r as s tends to infinity 

my @model=("Uniform","Logistic","Cauchy");
my $code;                         # pointer to one of the above models 
my $type;                         # name of the model
my ($exp,$var,$prod,$moment);     # output statistics

my $pi= 3.1415926535897932384626433;
my $seed=4565;   # allows for replicability (to produce same random numbers each time)

$lambda=1; 
$aa=-0.75;
$bb=0.75;   # B=[aa, bb]
$r=0.5;        # to compute E[T^r]

$n1=10000;  
$n2=30000;  

open(OUT,"> PB_main.txt");    # computations saved in file pb.txt
print OUT "Type\tlambda\ts\ta\tb\tr\tE[N]\tVar[N]\tP[N=0]\t";
print OUT "E[T]\tVar[T]\tE[T^r]\n";

for ($code=0; $code<=2; $code++) {
    $type=$model[$code]; # code 0 = Uniform, 1 = Logistic, 2 = Cauchy 
    for ($s=0.05; $s<=40; $s+=0.2) {
        print OUT "$type\t$lambda\t$s\t$aa\t$bb\t$r\t"; # output results in text file
        print "F = $type | lambda = $lambda | s=$s\n";  # show progress on the screen
  
        # Compute E[N(B)], Var[(B)], P[B=0] via formula
        ($exp,$var,$prod)=E_and_Var_N ($type,$lambda,$s,$aa,$bb,$n1);
        print OUT "$exp\t$var\t$prod\t";  # output results in text file

        # Compute E[T], Var[T] via simulations
        srand($seed);  # to produce same random deviates each time (for replicability)
        ($exp,$var,$moment)=var_T($type,$lambda,$s,$r,$n2);
        print OUT "$exp\t$var\t$moment\n";  # output results in text file
    }
}
close(OUT);

sub E_and_Var_N {

    # Return E[N(B)], Var[N(B)] and P[N(B)=0] with B=[aa, bb]
    # expectation -> E[N(B)]
    # variance    -> Var[N(B)]
    # product     -> P[N(B)=0]
    # Type specifies the distribution F, lambda the intensity, s the scaling factor

    my ($type,$lambda,$s,$aa,$bb,$n) = (@_);   # input parameters
    my ($expectation,$variance,$product);      # output

    my $k;                   # local 
    my ($f1,$f2,$flag);      # local

    $variance=0;
    $expectation=0;
    $product=0;

    $flag=0;

    for ($k=-$n1; $k<=$n1; $k++){ 
        $f1=CDF($type,$lambda,$s,$k,$bb);
        $f2=CDF($type,$lambda,$s,$k,$aa);

        if (1-$f1+$f2 == 0) {  $flag=1; } else {
            $product+=log(1-$f1+$f2);
        }
        $expectation+=($f1-$f2);
        $variance+=(($f1-$f2)*(1-$f1+$f2));
    }
    if ($flag==1) { $product=0; } else {
        $product=exp($product);
    }
    return($expectation,$variance,$product);
}

sub var_T {

    # Return var(T) and E(T^r) computed on simulated data (2n+1 points)
    # Type specifies the distribution F, lambda the intensity, s the scaling factor
    # r=1 yields the expectation

    my ($type,$lambda,$s,$r,$n) = (@_);      # input parameters
    my ($expectation,$variance,$moment_r);   # output

    my $ranx;      # local 
    my $dist;      # local 
    my ($m,$k);    # local 
    my ($k1,$k2);  # local  
    my (@x,@xs);   # local 

    @x  =();
    @xs =();
    $m=0;
    for ($k=-$n; $k<=$n; $k++) {
        $ranx=rand();
        $x[$m] =deviate($type,$lambda,$s,$k);    
        $m++;
    }
    @xs  = sort { $a <=> $b } @x;   # sort by numerical order

    $expectation=0;
    $variance=0;
    $moment_r=0;

    $k1=int($m/4);
    $k2=int(3*$m/4);

    for ($k=$k1; $k<=$k2; $k++) {
        $dist=($xs[$k]-$xs[$k-1]);
        $expectation+=$dist;
        $variance+=($dist*$dist);
        $moment_r+=($dist**$r);
    }
    $expectation =$expectation/($k2-$k1+1);
    $variance =($variance/($k2-$k1+1))-($expectation*$expectation);
    $moment_r=$moment_r/($k2-$k1+1);

    return($expectation,$variance,$moment_r);
}

sub deviate {

    # Generate random deviate for F determined by type
    # centered at k/lambda, scaling factor s

    my ($type,$lambda,$s,$k) = (@_); # input
    my $z;                   # output
    my $ranx;              # local variable

    $ranx=rand();
    if ($type eq "Logistic") {
        $z=$k/$lambda+$s*log($ranx/(1-$ranx));
    } elsif ($type eq "Uniform") {
        $z=$k/$lambda+2*$s*($ranx-1/2);
    } elsif ($type eq "Cauchy") {
        $z=$k/$lambda+$s*tan($pi*($ranx-1/2));
    }
    return($z);
}

sub CDF {

    # Returns F((x-k/lambda)/s), with F determined by type

    my ($type,$lambda,$s,$k,$x) = (@_); # input
    my $z;             #output

    if ($type eq "Logistic") {
        $z= 1/2+ (1/2)*tanh(($x-$k/$lambda)/(2*$s));
    } elsif ($type eq "Uniform") {
        $z= 1/2 + ($x-$k/$lambda)/(2*$s);
        if ($z<=0) { $z=0; }
        if ($z>1) { $z=1; }
    } elsif ($type eq "Cauchy") {
        $z= 1/2 +atan(($x-$k/$lambda)/$s)/$pi;
    }
    return($z);
}

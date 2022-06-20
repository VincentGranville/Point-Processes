# PB_main.py

import math
import random
random.seed(100)

model=("Uniform","Logistic","Cauchy")
pi= 3.1415926535897932384626433
seed=4565   # allows for replicability (to produce same random numbers each time)

llambda=1   # represents lambda [lambda is reserved keyword in Python]
aa =-0.75   # B=[aa, bb] is the interval used to compute exact Expectation and var
bb = 0.75   # see aa
r  = 0.50   # to compute E[T^r], r>0
            # E[T^r] tends to r!/(lambda)^r as s tends to infinity
n1 = 10000  # compute E[N(B)], Var[N(B)]: k between -n1 and +n1
            # n1 much larger than s (if F has thick tail)
            # reduce n1 if program too slow [speed ~ O(n1 log n1
n2 = 30000  # Simulation: Xk with index k between -n2 and +n2

#---------------------------------------------------------------------------------
def main():

  OUT=open('PB_main.txt',"w")    # computations saved in file pb.txt
  line = "Type\tlambda\ts\ta\tb\tr\tE[N]\tVar[N]\tP[N=0]\t";
  line = line+"E[T]\tVar[T]\tE[T^r]\n";
  OUT.write(line)

  for type in model:
    s=0.05
    while s <= 40:
      line=str(type)+"\t"+str(llambda)+"\t"+str(s)+"\t"+str(aa)+"\t"+str(bb)+"\t"+str(r)+"\t"
      print("F = ",type," | lambda = ",llambda," | s=",s)  # show progress on the screen
  
      # Compute E[N(B)], Var[(B)], P[B=0] via formula
      (exp,var,prod)=E_and_Var_N(type,llambda,s,aa,bb,n1)
      line=line+str(exp)+"\t"+str(var)+"\t"+str(prod)+"\t"

      # Compute E[T], Var[T] via simulations
      random.seed(seed)  # to produce same random deviates each time (for replicability)
      (exp,var,moment)=var_T(type,llambda,s,r,n2)
      line=line+str(exp)+"\t"+str(var)+"\t"+str(moment)+"\n"

      OUT.write(line)
      s=s+0.2

  OUT.close()

#---------------------------------------------------------------------------------

def E_and_Var_N(type,llambda,s,aa,bb,n):

  # Return E[N(B)], Var[N(B)] and P[N(B)=0] with B=[aa, bb]
  # expectation -> E[N(B)]
  # variance    -> Var[N(B)]
  # product     -> P[N(B)=0]
  # Type specifies the distribution F, lambda the intensity, s the scaling factor

  variance=0
  expectation=0
  product=0
  flag=0

  for k in range(-n1,n1+1): 
    f1=CDF(type,llambda,s,k,bb)
    f2=CDF(type,llambda,s,k,aa)
    if 1-f1+f2 == 0:  
      flag=1 
    else:
      product=product+math.log(1-f1+f2)
    expectation=expectation+(f1-f2)
    variance=variance+((f1-f2)*(1-f1+f2))
  if flag==1: 
    product=0 
  else:
    product=math.exp(product)
  return[expectation,variance,product]

#---------------------------------------------------------------------------------

def var_T(type,llambda,s,r,n):

  # Return var(T) and E(T^r) computed on simulated data (2n+1 points)
  # Type specifies the distribution F, lambda the intensity, s the scaling factor
  # r=1 yields the expectation

  xs=[]
  m=0

  for k in range(-n,n+1): 
    ranx=random.random()
    xs.append(deviate(type,llambda,s,k))   
    m=m+1
  xs.sort() 
  expectation=0
  variance=0
  moment_r=0
  k1=int(m/4)
  k2=int(3*m/4)
  for k in range(k1,k2+1): 
    dist=(xs[k]-xs[k-1])
    expectation=expectation+dist
    variance=variance+(dist*dist)
    moment_r=moment_r+(dist**r)
  expectation=expectation/(k2-k1+1)
  variance=(variance/(k2-k1+1))-(expectation*expectation)
  moment_r=moment_r/(k2-k1+1)
  return[expectation,variance,moment_r]

#---------------------------------------------------------------------------------

def deviate(type,llambda,s,k):

  # Generate random deviate for F determined by type
  # centered at k/lambda, scaling factor s

  ranx=random.random()
  if type == "Logistic":
    z=k/llambda+s*math.log(ranx/(1-ranx))
  elif type == "Uniform":
    z=k/llambda+2*s*(ranx-1/2)
  elif type == "Cauchy":
    z=k/llambda+s*math.tan(pi*(ranx-1/2))
  return(z)

def CDF(type,llambda,s,k,x):

  # Returns F((x-k/lambda)/s), with F determined by type

  if type == "Logistic":
    z= 1/2+ (1/2)*math.tanh((x-k/llambda)/(2*s))
  elif type == "Uniform":
    z= 1/2 + (x-k/llambda)/(2*s)
    if z<=0: 
      z=0
    if z>1: 
      z=1
  elif type == "Cauchy":
    z= 1/2 +math.atan((x-k/llambda)/s)/pi;
  return(z)

#---------------------------------------------------------------------------------

main()





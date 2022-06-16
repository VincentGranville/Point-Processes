# PB_NN.py  
# lambda = 1

import numpy as np
import math
import random

#------------------------------------------------------------------------
# PART 1: Initialization

Nprocess=5       # number of processes in the process superimposition
seed=82431      # arbitrary number
random.seed(seed) # initialize random generator 
s=0.15  # scaling factor
method=1  # method=0 is fastest
NNflag=False
epsilon=0.0000000001 # for numerical stability

sep="\t"      # TAB character 
shiftX=[]
shiftY=[]
stretchX=[]
stretchY=[]
a=[]
b=[]
process=[]
sstring=[]   # string in Perl version

for i in range(Nprocess) :
  shiftX.append(random.random())
  shiftY.append(random.random())
  stretchX.append(1.0)
  stretchY.append(1.0)
  sstring.append(sep)   
  # i TABs separating x and y coordinates in output file for points
  # originating from process i; Used to easily create a scatterplot in Excel 
  # with a different color for each process.
  sep=sep + "\t"

processID=0
m=0  # number of points generated
height,width = (400, 400)

bitmap = [[255 for k in range(height)] for h in range(width)]

#------------------------------------------------------------------------
# PART 2: Generate point process, its modulo 2 version; save to bitmap and output files.

OUT  = open("PB_NN.txt", "w")     # the points of the process 
OUT2 = open("PB_NN_mod.txt", "w") # the same points modulo 2/lambda both in x and y directions

for h in range(-25,26):   
    for k in range(-25,26):  
        for processID in range(Nprocess): 
            ranx=random.random()
            rany=random.random()
            x=shiftX[processID]+stretchX[processID]*h+s*math.log(ranx/(1-ranx)) 
            y=shiftY[processID]+stretchY[processID]*k+s*math.log(rany/(1-rany))
            a.append(x)  # x coordinate attached to point m
            b.append(y)  # y coordinate attached to point m
            process.append(processID) # processID attached to point m
            m=m+1
            line=str(processID)+"\t"+str(h)+"\t"+str(k)+"\t"+str(x)+sstring[processID]+str(y)+"\n"
            OUT.write(line)
            # replace sstring[processID] by \t if you don't care about Excel

            if x>-20 and x<20 and x>-20 and x<20:
                xmod=1+x-int(x)   # x modulo 2/lambda
                ymod=1+y-int(y)   # y modulo 2/lambda
                pixelX=int(width*xmod/2)   
                pixelY=int(height*(2-ymod)/2) # pixel (0,0) at top left corner
                bitmap[pixelX][pixelY]=processID
                line=str(xmod)+sstring[processID]+str(ymod)+"\n"
                OUT2.write(line)  
                # replace sstring[processID] by \t if you don't care about Excel
OUT2.close()
OUT.close()

#------------------------------------------------------------------------
# PART 3: Find nearest neighbor points, and compute nearest neighbor distances.

if NNflag:

  OUT  = open("PB_NN_dist_small.txt", "w")     # the points of the process 
  OUTf = open("PB_NN_dist_full.txt", "w") # the same points modulo 2/lambda both in x and y directions

  NNx=[]
  NNy=[]
  NNidx=[]
  NNidxHash={}

  for i in range(m):
    NNx.append(0.0)
    NNy.append(0.0)
    NNidx.append(-1)
    mindist=99999999
    flag=-1
    if a[i]>-20 and a[i]<20 and b[i]>-20 and b[i]<20: 
      flag=0;
      for j in range(m):
        dist=math.sqrt((a[i]-a[j])**2 + (b[i]-b[j])**2) 
        if dist<=mindist+epsilon and i!=j: 
          NNx[i]=a[j]  # x-coordinate of nearest neighbor of point $i
          NNy[i]=b[j]  # y-coordinate of nearest neighbor of point $i
          NNidx[i]=j    # indicates that point $j is nearest neighbor to point $i
          #  NNidxHash[i] is the list of points having point i as nearest neighbor;
          #  these points are separated by "~" (usually only one point in NNidxHash[i]
          #  unless the simulated points are exactly on a lattice, e.g. if s = 0)
          if abs(dist-mindist) < epsilon: 
            NNidxHash[i]=NNidxHash[i]+"~"+str(j) 
          else:    
            NNidxHash[i]=str(j) 
          mindist=dist 
      if i % 100 == 0: 
        print("Finding Nearest neighbors of point",i)
      line=str(i)+"\t"+str(mindist)+"\n"
      OUT.write(line) 
      line=str(i)+"\t"+str(NNidx[i])+"\t"+str(NNidxHash[i])+"\t"+str(a[i])+"\t" 
      line=line+str(b[i])+"\t"+str(NNx[i])+"\t"+str(NNy[i])+"\t"+str(mindist)+"\n"
      OUTf.write(line) 

  OUTf.close()
  OUT.close()

#------------------------------------------------------------------------
# PART 4: Produce data to use in R code that generates the nearest neighbors picture.

if NNflag:

  OUT  = open("PB_r.txt","w")     
  OUT.write("idx\tnNN\tNNindex\ta\tb\taNN\tbNN\tprocessID\tNNprocessID\n")

  for idx in NNidxHash:
    NNlist=NNidxHash[idx]
    list=NNlist.split("~")
    nelts=len(list)
    for n in range(nelts): 
      NNindex=int(list[n])
      line=str(idx)+"\t"+str(n)+"\t"+str(NNindex)+"\t"+str(a[idx])+"\t"+str(b[idx])
      line=line+"\t"+str(a[NNindex])+"\t"+str(b[NNindex])+"\t"+str(process[idx])
      line=line+"\t"+str(process[NNindex])+"\n"
      OUT.write(line)  
                
  OUT.close()

#------------------------------------------------------------------------
# PART 5: Creates density and cluster images.

window=20   # determines size of local filter [the bigger, the smoother]
nloop=3     # number of times the image is filtered [the bigger, the smoother]
img_cluster="PB-cluster"  # use for output image filenames
img_density="PB-density"  # use for output image filenames

from GD_util import * 
GD_Maps(method,bitmap,Nprocess,window,nloop,height,width,img_cluster,img_density)

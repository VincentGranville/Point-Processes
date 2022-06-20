# PB_radial.py [www.MLTechniques.com]

import math
import random
random.seed(100)

s=10

pi=3.14159265358979323846264338

file=open('PB_radial.txt',"w")
for h in range(-30,31): 
    for k in range(-30,31): 

         # Create the center (parent Poisson-binomial process, F uniform)

         ranx=random.random()
         rany=random.random()
         x=h+2*s*(ranx-1/2)
         y=k+2*s*(rany-1/2)
         line=str(h)+"\t"+str(k)+"\tCenter\t"+str(x)+"\t"+str(y)+"\n"
         file.write(line)

        # Create the child, radial process (up to 15 points per center)

         M=int(15*random.random())

         for m in range(M): 
             ran1=random.random()
             ran2=random.random()
             factor=math.log(ran2/(1-ran2))
             x1=x+factor*math.cos(2*pi*ran1);
             y1=y+factor*math.sin(2*pi*ran1);
             line=str(h)+"\t"+str(k)+"\tLocal\t"+str(x1)+"\t"+str(y1)+"\n"
             file.write(line)
file.close()
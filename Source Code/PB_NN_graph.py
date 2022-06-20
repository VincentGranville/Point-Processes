# PB_NN_graph.py
#
# Compute connected components of nearest neighbor graph
# Input file has two tab-separated columns: idx and idx2
#   idx is the index of of point, idx2 is the index of a nearest neighbor to idx
# Output file has two fields, for each principal component:
#   the list of points it is made up (separated by ~), and the number of points

# Example. 

# Input:

# 100	101
# 100	103
# 101	100
# 101	102
# 103	100
# 103	102
# 102	101
# 102	100
# 102	103
# 102	104
# 104	102
# 106	105
# 105	107

# Output:

# ~100~103~102~104~101    5
# ~106~105~107    3

#-------------------------------------------------------------------------
# PART 1: Initialization. 

point=[]
NNIdx={}
idxHash={}

n=0
file=open('test.txt',"r") # input file 
lines=file.readlines()
for aux in lines:
  idx =int(aux.split('\t')[0])
  idx2=int(aux.split('\t')[1])
  if idx in idxHash:
    idxHash[idx]=idxHash[idx]+1
  else:
    idxHash[idx]=1
  point.append(idx)
  NNIdx[idx]=idx2
  n=n+1
file.close()

hash={}
for i in range(n):
  idx=point[i]
  if idx in NNIdx:
    substring="~"+str(NNIdx[idx])
  string="" 
  if idx in hash:
    string=str(hash[idx])
  if substring not in string: 
    if idx in hash:
      hash[idx]=hash[idx]+substring 
    else:
      hash[idx]=substring  
  substring="~"+str(idx)
  if NNIdx[idx] in hash: 
    string=hash[NNIdx[idx]]
  if substring not in string: 
    if NNIdx[idx] in hash:
      hash[NNIdx[idx]]=hash[NNIdx[idx]]+substring 
    else:
      hash[NNIdx[idx]]=substring 

#-------------------------------------------------------------------------
# PART 2: Find the connected components 

i=0;
status={}
stack={}
onStack={}
cliqueHash={}

while i<n:

  while (i<n and point[i] in status and status[point[i]]==-1):  
    # point[i] already assigned to a clique, move to next point
    i=i+1

  nstack=1
  if i<n:
    idx=point[i]
    stack[0]=idx;   # initialize the point stack, by adding $idx 
    onStack[idx]=1;
    size=1  # size of the stack at any given time

    while nstack>0:  
      idx=stack[nstack-1]
      if (idx not in status) or status[idx] != -1: 
            status[idx]=-1  # idx considered processed
            if i<n:  
              if point[i] in cliqueHash:
                cliqueHash[point[i]]=cliqueHash[point[i]]+"~"+str(idx)
              else: 
                cliqueHash[point[i]]="~"+str(idx)
            nstack=nstack-1 
            aux=hash[idx].split("~")
            aux.pop(0)  # remove first (empty) element of aux
            for idx2 in aux:
                # loop over all points that have point idx as nearest neighbor
                idx2=int(idx2)
                if idx2 not in status or status[idx2] != -1:   
                  # add point idx2 on the stack if it is not there yet
                  if idx2 not in onStack: 
                    stack[nstack]=idx2
                    nstack=nstack+1
                  onStack[idx2]=1

#-------------------------------------------------------------------------
# PART 3: Save results.

file=open('PB_cc.txt',"w")
for clique in cliqueHash:
  count=cliqueHash[clique].count('~') 
  line=cliqueHash[clique]+"\t"+str(count)+"\n"
  file.write(line)
file.close()
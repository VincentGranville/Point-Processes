# PB_clustering_video.py

import math
import random
from PIL import Image, ImageDraw    # ImageDraw to draw rectangles etc.
import moviepy.video.io.ImageSequenceClip  # to produce mp4 video

Nprocess=4       # number of processes in the process superimposition
seed=82431      # arbitrary number
random.seed(seed) # initialize random generator 
s=0.15  # scaling factor
shiftX=[]
shiftY=[]

for i in range(Nprocess) :
  shiftX.append(random.random())
  shiftY.append(random.random())
processID=0
height,width = (800, 800)
bitmap = [[255 for k in range(height)] for h in range(width)]

for h in range(-25,26):   
  for k in range(-25,26):  
    for processID in range(Nprocess): 
      ranx=random.random()
      rany=random.random()
      ranID=random.random()
      if ranID < 0.20:
        processID=0
      elif ranID < 0.60:
        processID=1
      elif ranID < 0.90:
        processID=2 
      else:
        processID=3
      x=shiftX[processID]+h+s*math.log(ranx/(1-ranx)) 
      y=shiftY[processID]+k+s*math.log(rany/(1-rany))
      if x>-3 and x<3 and x>-3 and x<3:
        xmod=1+x-int(x)   # x modulo 2/lambda
        ymod=1+y-int(y)   # y modulo 2/lambda
        pixelX=int(width*xmod/2)   
        pixelY=int(height*(2-ymod)/2) # pixel (0,0) at top left corner
        bitmap[pixelX][pixelY]=processID

#----------------------------------------------------------------

img1  = Image.new( mode = "RGBA", size = (width, height), color = (0, 0, 0) )
pix1  = img1.load()   # pix[x,y]=col[n] to modify the RGB color of a pixel
draw1 = ImageDraw.Draw(img1,"RGBA")

col1=[] 
col1.append((255,0,0,255))
col1.append((0,0,255,255))
col1.append((255,179,0,255))
col1.append((0,179,0,255))
col1.append((0,0,0,255))
for i in range(Nprocess,256):
  col1.append((0,0,0,255))
 
for pixelX in range(0,width): 
  for pixelY in range(0,height): 
        topProcessID=bitmap[pixelX][pixelY]
        pix1[pixelX,pixelY]=col1[topProcessID]

draw1.rectangle((0,0,width-1,height-1), outline ="black",width=1)
fname="img_0.png"
img1.save(fname)

#----------------------------------------------------------------

window=1
nloop=250       # number of times the image is filtered 

oldBitmap = [[255 for k in range(height)] for h in range(width)]
flist=[]

for loop in range(1,nloop+1): 
  print("loop",loop,"out of",nloop+1) 
  for pixelX in range(0,width): 
    for pixelY in range(0,height): 
      oldBitmap[pixelX][pixelY]=bitmap[pixelX][pixelY]
  for pixelX in range(1,width-1): 
    for pixelY in range(1,height-1):   
      x=pixelX
      y=pixelY
      topProcessID=oldBitmap[x][y]
      if topProcessID==255 or loop>50: 
        r=random.random()
        if r<0.25: 
          x=x+1 
          if x>width-2: 
            x=x-(width-2)
        elif r<0.5:
          x=x-1 
          if x<1: 
            x=x+width-2
        elif r<0.75:
          y=y+1 
          if y>height-2: 
            y=y-(height-2)
        else:
          y=y-1 
          if y<1: 
            y=y+height-2         
        if loop>=50 and oldBitmap[x][y]==255:
          x=pixelX
          y=pixelY
      topProcessID=oldBitmap[x][y]  
      bitmap[pixelX][pixelY]=topProcessID
      pix1[pixelX,pixelY]=col1[topProcessID]
  draw1.rectangle((0,0,width-1,height-1), outline ="black",width=1)
  fname="img_"+str(loop+1)+'.png'
  flist.append(fname)   
  img1.save(fname)

clip = moviepy.video.io.ImageSequenceClip.ImageSequenceClip(flist, fps=20) 
clip.write_videofile('img.mp4')

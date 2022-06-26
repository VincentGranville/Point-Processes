# image3R_orbit_enhanced.py [www.MLTechniques.com]

from PIL import Image, ImageDraw           # ImageDraw to draw ellipses etc.
import moviepy.video.io.ImageSequenceClip  # to produce mp4 video
from moviepy.editor import VideoFileClip   # to convert mp4 to gif

import numpy as np
import math
import random
random.seed(100)

#--- Global variables ---

m=1               # number of orbits (one for each value of sigma) 
nframe=20000      # number of images created in memory
ShowOrbit=True 
ShowDots=False
count=0           # frame counter 
r=10              # one out of every r image is included in the video
dot=4             # size of a point in the picture
step=0.01         # time increment in orbit

width = 3200      # width of the image
height =2400      # length of the image

images=[]

etax=[]    # real part of Dirichlet eta function
etay=[]    # real part of Dirichlet eta function
sigma=[]   # imaginary part of argument of Dirchlet eta
x0=[]      # value of etax on last video frame
y0=[]      # value of etay on last video frame
#col=[]    # RGB color of the orbit
colp=[]    # RGP points on the orbit
t=[]       # real part of argument of Dirchlet eta (that is, time in orbit)
flist=[]   # filenames of the images representing each video frame

etax=list(map(float,etax))
etay=list(map(float,etay))
sigma=list(map(float,sigma))
x0=list(map(float,x0))
y0=list(map(float,y0))
t=list(map(float,t))
flist=list(map(str,flist))

#--- Eta function ---

def G(tau,sig,nterms):
  sign=1
  fetax=0
  fetay=0
  for j in range(1,nterms):
    fetax=fetax+sign*math.cos(tau*math.log(j))/pow(j,sig)
    fetay=fetay+sign*math.sin(tau*math.log(j))/pow(j,sig)
    sign=-sign
  return [fetax,fetay]

#--- Initializing comet parameters ---

for n in range (0,m):
  etax.append(1.0)
  etay.append(0.0)
  x0.append(1.0)
  y0.append(0.0)
  t.append(0.0)       # start with t=0.0
sigma.append(0.75)
sigma.append(0.75) 
sigma.append(1.25) 
colp.append((0,0,255,80))
colp.append((255,0,0,80))
colp.append((255,180,0,80))

if ShowOrbit:
  minx=-2 
  maxx=3
else:
  minx=-1
  maxx=2 
minx=-2 ###
maxx=3  ####

rangex=maxx-minx
rangey=0.75*rangex
miny=-rangey/2
maxy=rangey/2
rangey=maxy-miny

img  = Image.new( mode = "RGB", size = (width, height), color = (255, 255, 255) )
imgCopy=img.copy() ######
# pix = img.load()   # pix[x,y]=col[n] to modify the RGB color of a pixel
draw = ImageDraw.Draw(img,"RGBA")
drawCopy = ImageDraw.Draw(imgCopy,"RGBA")

gx=width*(0.0-minx)/rangex
gy=height*(0.0-miny)/rangey
hx=width*(1.0-minx)/rangex
hy=height*(0.0-miny)/rangey
draw.ellipse((gx-8, gy-8, gx+8, gy+8), fill=(0,0,0,255)) 
draw.ellipse((hx-8, hy-8, hx+8, hy+8), fill=(0,0,0,255)) 
draw.rectangle((0,0,width-1,height-1), outline ="black",width=1)
draw.line((0,gy,width-1,hy), fill ="red", width = 1)
draw.ellipse((gx-8, gy-8, gx+8, gy+8), fill=(0,0,0,255)) 
drawCopy.ellipse((hx-8, hy-8, hx+8, hy+8), fill=(0,0,0,255)) 
drawCopy.rectangle((0,0,width-1,height-1), outline ="black",width=1)
drawCopy.line((0,gy,width-1,hy), fill ="red", width = 1)
countCopy=0

#--- Main Loop ---

for k in range (2,nframe,1): # loop over time, each t corresponds to an image
  if k %10 == 0:
    string="Building frame:" + str(k) + "> "
    for n in range (0,m):
      string=string+ " | " + str(t[n])
    print(string)
  for n in range (0,m):  # loop over the m orbits
    if k%r==0: 
      imgCopy.paste(img, (0, 0))
    if ShowOrbit:
      # save old value of etax[n], etay[n]
      x0.insert(n,width*(etax[n]-minx)/rangex)  
      y0.insert(n,height*(etay[n]-miny)/rangey)
    (etax[n],etay[n])=G(t[n],sigma[n],2000) # 500 -> tau
    x= width*(etax[n]-minx)/rangex
    y=height*(etay[n]-miny)/rangey
    if ShowOrbit:
      if k>2:
        # draw line from (x0[n],y0[n]) to (x,y)
        draw.line((int(x0[n]),int(y0[n]),int(x),int(y)), fill =colp[n], width = 0)
        if ShowDots:
          draw.ellipse((x-dot, y-dot, x+dot, y+dot), fill =colp[n])
        else:
          copyFlag=True
          drawCopy.ellipse((x-8, y-8, x+8, y+8), fill =(255,0,0)) ####
      t[n]=t[n]+step
    else:
      draw.ellipse((x-dot, y-dot, x+dot, y+dot), fill =colp[n]) 
      t[n]=t[n]+200*math.exp(3*sigma[n])/(1+t[n])  # 0.02  
  if k%r==0:    # this image gets included as a frame in the video
    draw.ellipse((gx-8, gy-8, gx+8, gy+8), fill=(0,0,0,255)) 
    draw.ellipse((hx-8, hy-8, hx+8, hy+8), fill=(0,0,0,255)) 
    drawCopy.ellipse((gx-8, gy-8, gx+8, gy+8), fill=(0,0,0,255)) 
    drawCopy.ellipse((hx-8, hy-8, hx+8, hy+8), fill=(0,0,0,255)) 
    fname='imgpy'+str(count)+'.png'
    count=count+1
    # anti-aliasing mechanism
    if not copyFlag:
      img2 = img.resize((width // 2, height // 2), Image.LANCZOS) #ANTIALIAS)
    else:
      img2 = imgCopy.resize((width // 2, height // 2), Image.LANCZOS) #ANTIALIAS)
    # output curent frame to a png file
    img2.save(fname)     # write png image on disk
    flist.append(fname)  # add its filename (fname) to flist
    images.append(img2)  # to produce Gif image

# output video file
clip = moviepy.video.io.ImageSequenceClip.ImageSequenceClip(flist, fps=20) 
clip.write_videofile('riemann.mp4')

# output gif file - commented out because it is way too large
#images[0].save('riemann.gif',save_all=True, append_images=images[1:],loop=0)



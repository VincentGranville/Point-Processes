from PIL import Image, ImageDraw           # ImageDraw to draw rectangles etc.

def GD_Maps(bitmap,Nprocess,window,nloop,height,width,img_cluster,img_density):

  #---------------------------------------------------------------------
  # PART 1: Allocate first image (clustering), including colors (palette)

  img1  = Image.new( mode = "RGBA", size = (width, height), color = (0, 0, 0) )
  pix1  = img1.load()   # pix[x,y]=col[n] to modify the RGB color of a pixel
  draw1 = ImageDraw.Draw(img1,"RGBA")

  col1=[] 
  col1.append((255,0,0,255))
  col1.append((0,0,255,255))
  col1.append((255,179,0,255))
  col1.append((0,0,0,255))
  col1.append((0,179,0,255))
  for i in range(Nprocess,256):
    col1.append((255,255,255,255))
  oldBitmap = [[255 for k in range(height)] for h in range(width)]
  densityMap= [[0.0 for k in range(height)] for h in range(width)]
  for pixelX in range(0,width): 
    for pixelY in range(0,height): 
      processID=bitmap[pixelX][pixelY]
      pix1[pixelX,pixelY]=col1[processID] 
  draw1.rectangle((0,0,width-1,height-1), outline ="black",width=1)
  fname=img_cluster+'.png'
  img1.save(fname)

  #---------------------------------------------------------------------
  # PART 2: Filter bitmap and densityMap 

  for loop in range(nloop): #  ($loop=0; $loop<$nloop; $loop++) # BEGIN 1201

    print("loop",loop,"out of",nloop)
    for pixelX in range(0,width): 
      for pixelY in range(0,height): 
        oldBitmap[pixelX][pixelY]=bitmap[pixelX][pixelY]

    for pixelX in range(0,width): 
      for pixelY in range(0,height):   
        count=[0] * Nprocess
        density=0
        maxcount=0
        topProcessID=255 # dominant processID near (pixelX, pixelY)
        for u in range(-window,window+1): 
          for v in range(-window,window+1):
            x=pixelX+u
            y=pixelY+v
            if x<0: 
              x+=width   # boundary effect correction
            if y<0: 
              y+=height   # boundary effect correction
            if x>=width: 
              x-=width  # boundary effect correction
            if y>=height: 
              y-=height # boundary effect correction
            dist2=(1+u**2 + v**2)**0.5  # ** is the power operator
            processID=oldBitmap[x][y]
            if processID < 255: 
              count[processID]=count[processID]+1/dist2
              if count[processID]>maxcount: 
                maxcount=count[processID]
                topProcessID=processID
              density=density+1/dist2 
        density=density/(10**loop)   # 10 at power loop (dampening)
        densityMap[pixelX][pixelY]=densityMap[pixelX][pixelY]+density
        bitmap[pixelX][pixelY]=topProcessID

    #---------------------------------------------------------------------
    # PART 3:  Some pre-processing; output cluster image

    densityCountHash={}  # use to rebalance gray levels
    for pixelX in range(0,width): 
      for pixelY in range(0,height):   
        topProcessID=bitmap[pixelX][pixelY]
        density=densityMap[pixelX][pixelY]
        if density in densityCountHash:
          densityCountHash[density]=densityCountHash[density]+1
        else:
          densityCountHash[density]=1
        pix1[pixelX,pixelY]=col1[topProcessID]

    draw1.rectangle((0,0,width-1,height-1), outline ="black",width=1)
    fname=img_cluster+str(loop)+'.png'
    img1.save(fname)

    #---------------------------------------------------------------------
    # PART 4: Equalize gray levels in the density image; output image as a PNG file 
    # Also try https://www.geeksforgeeks.org/python-pil-imageops-equalize-method/

    densityColorHash={} 
    col2=[]
    size=len(densityCountHash)  # number of elements in hash
    counter=0

    for density in sorted(densityCountHash):
      counter=counter+1
      quant=counter/size   # always between zero and one
      if quant < 0.08: 
        densityColorHash[density]=0
      elif quant < 0.18:
        densityColorHash[density]=30 
      elif quant < 0.28:
        densityColorHash[density]=55
      elif quant < 0.42:
        densityColorHash[density]=90
      elif quant < 0.62:
        densityColorHash[density]=120
      elif quant < 0.80:
        densityColorHash[density]=140
      elif quant < 0.95:
        densityColorHash[density]=170
      else:
        densityColorHash[density]=254

    # allocate second image (density image)

    img2  = Image.new( mode = "RGBA", size = (width, height), color = (0, 0, 0) )
    pix2  = img2.load()   # pix[x,y]=col[n] to modify the RGB color of a pixel
    draw2 = ImageDraw.Draw(img2,"RGBA")

    # allocate gray levels (palette)
    for i in range(0,256):
        col2.append((255-i,255-i,255-i,255))

    # create density image pixel by pixel
    for pixelX in range(0,width): 
      for pixelY in range(0,height):   
        density=densityMap[pixelX][pixelY] 
        color=densityColorHash[density]
        pix2[pixelX,pixelY]=col2[color]  

    # output density image
    draw2.rectangle((0,0,width-1,height-1), outline ="black",width=1)
    fname=img_density+str(loop)+'.png'
    img2.save(fname)

  return()

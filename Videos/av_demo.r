# install.packages('Cairo')
library('Cairo');

CairoPNG(filename = "c:/Users/vince/tex/av_demo%03d.png", width = 1200, height = 800); 
# https://www.rdocumentation.org/packages/Cairo/versions/1.5-14/topics/Cairo

data<-read.table("c:/Users/vince/tex/av_demo_vg2cb.txt",header=TRUE);

k<-data$k;
x<-data$x;   
y<-data$y;  
x2<-data$x2;   
y2<-data$y2; 
col<-data$col; 

for (n in 1:1000) {

  plot(x,y,pch=20,cex=0,col=rgb(0,0,0),xlab="",ylab="",axes=FALSE  );
  rect(-60, -60, 90, 30, density = NULL, angle = 45,
     col = rgb(0,0,0), border = NULL);
  # You need to adjust the size of the rectangle to your data

  a<-x[k <= n*20];
  b<-y[k <= n*20];
  a2<-x2[k <= n*20];
  b2<-y2[k <= n*20];
  c<-col[k <= n*20];
  arrows(a, b, a2, b2, length = 0, angle = 10, code = 2,
    col=rgb(  0.9*abs(sin(0.00100*col)),0.6*abs(sin(0.00075*col)),
    abs(sin(0.00150*col))  ));
}
dev.off();

png_files <- sprintf("c:/Users/vince/tex/av_demo%03d.png", 1:1000)
av::av_encode_video(png_files, 'c:/Users/vince/tex/av_demo_vg2cb.mp4', framerate = 12)


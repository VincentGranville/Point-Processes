# install.packages('Cairo')
library('Cairo');

CairoPNG(filename = "c:/Users/vince/tex/av_demo%03d.png", width = 600, height = 600);  # res=
data<-read.table("c:/Users/vince/tex/av_demo_vg2b.txt",header=TRUE);

k<-data$k;
x<-data$x;   
y<-data$y;  
x2<-data$x2;   
y2<-data$y2; 
col<-data$col; 

for (n in 1:500) {
  plot(x,y,pch=20,cex=0,col=rgb(0,0,0),xlab="",ylab="",axes=FALSE  );
  rect(-10, -20, 50, 50, density = NULL, angle = 45,
     col = rgb(0,0,0), border = NULL);
  a<-x[k <= n*20];
  b<-y[k <= n*20];
  a2<-x2[k <= n*20];
  b2<-y2[k <= n*20];
  c<-col[k <= n*20];
  arrows(a, b, a2, b2, length = 0, angle = 10, code = 2,
    col=rgb(  0.9*abs(sin(0.00200*col)),0.6*abs(sin(0.00150*col)),
    abs(sin(0.00300*col))  ));
}
dev.off();

png_files <- sprintf("c:/Users/vince/tex/av_demo%03d.png", 1:500)
av::av_encode_video(png_files, 'c:/Users/vince/tex/av_demo2b.mp4', framerate = 12)

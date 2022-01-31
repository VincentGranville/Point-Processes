# install.packages('Cairo')
library('Cairo');
# CairoWin(6,6);
CairoPNG(filename = "c:/Users/vince/tex/PB-hexa2.png", width = 600, height = 600);

data<-read.table("c:/Users/vince/tex/PB_r.txt",header=TRUE);
a<-data$a;  # x coordinate of point of the superimposed/mixture process 
b<-data$b;  # y coordinate of point of the superimposed/mixture process 
aNN<-data$aNN;  # x coordinate of nearest neighbor point to (a,b) across all processes
bNN<-data$bNN;  # y coordinate of nearest neighbor point to (a,b) across all processes
processID<-data$processID;

plot(a,b,xlim=c(0,15),ylim=c(0,15),pch=20,cex=0,
                    col=rgb(0,0,0),xlab="",ylab="",axes=TRUE  );
arrows(a, b, aNN, bNN, length = 0.10, angle = 10, code = 2,col=rgb(0.7,0.7,0.7));

aa<-data$a[processID == 0];
bb<-data$b[processID == 0];
points(aa,bb,col=rgb(1,0,0),pch=20,cex=1.75);

aa<-data$a[processID == 1];
bb<-data$b[processID == 1];
points(aa,bb,col=rgb(0,0,1),pch=20,cex=1.55);

aa<-data$a[processID == 2];
bb<-data$b[processID == 2];
points(aa,bb,col=rgb(1,0.7,0),pch=20,cex=1.75);

aa<-data$a[processID == 3];
bb<-data$b[processID == 3];
points(aa,bb,col=rgb(0,0,0),pch=20,cex=1.75);

aa<-data$a[processID == 4];
bb<-data$b[processID == 4];
points(aa,bb,col=rgb(0,0.7,0),pch=20,cex=1.75);

dev.off();

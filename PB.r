data<-read.table("c:/Users/vince/tex/PBr.txt",header=TRUE); 

a<-data$a;
b<-data$b;
aNN<-data$aNN;
bNN<-data$bNN;
processID<-data$processID;

plot(a,b,xlim=c(0,10.75),ylim=c(0,10.75),pch=20,cex=0,col=rgb(0,0,0),xlab="",ylab="",axes=TRUE  );
arrows(a, b, aNN, bNN, length = 0.10, angle = 10, code = 2,col=rgb(0,0,0));


aa<-data$a[processID == 0];
bb<-data$b[processID == 0];
points(aa,bb,col=rgb(1,0,0),pch=20,cex=1.75);

aa<-data$a[processID == 1];
bb<-data$b[processID == 1];
points(aa,bb,col=rgb(0,0,0.8),pch=20,cex=1.55);

aa<-data$a[processID == 2];
bb<-data$b[processID == 2];
points(aa,bb,col=rgb(1,0.7,0),pch=20,cex=1.75);

aa<-data$a[processID == 3];
bb<-data$b[processID == 3];
points(aa,bb,col=rgb(0.6,0.6,0.6),pch=20,cex=1.75);


library(RWeka)
library(ggplot2)
library(dplyr)
library(tidyr)

aminoacid<-read.arff("training.arff")
mat <- data.matrix(aminoacid[,1:140]);
limP=141
limN=nrow(mat);

mediaP=0; for (i in 1:limP ) { mediaP  = mediaP  + mat[i,] };mediaP= mediaP/limP;
mediaN=0; for (i in (limP+1 ):limN ) { mediaN  = mediaN  + mat[i,] };mediaN= mediaN/(limN-limP);

aaprofilestr=colnames(aminoacid[1:140])
for (i in 1:length(aaprofilestr)){aaprofilestr[i]=gsub("e", "", aaprofilestr[i]);aaprofilestr[i]= gsub("d", ".", aaprofilestr[i]);}

aminoacidframe<- data.frame ( AAprofileLength=aaprofilestr, Positive=mediaP, Negative=mediaN)
#df   <- gather(aminoacidframe, Control, Value, Positive:Negative)
positives=aminoacidframe[[2]]
negatives=aminoacidframe[[3]]
plot( positives,type="l", col="red")
lines( negatives,type="l", col="blue")

png(file="Aminoacids-Negatives.png", width=600, height=350)
plot( negatives,type="l", col="blue")
for (i in (limP+1 ):limN ) {  lines( mat[i,],type="l", col="gray" ) };
lines( negatives,type="l", col="blue")
legend(1, 4000, legend=c("All", "Mean"), col=c("gray", "blue"), lty=1:1, cex=0.8)
dev.off()

#Difference from negative mean
for (i in (limP+1 ):limN ) {  correlation=cor(negatives, mat[i,], method = 'pearson'); if (correlation < 0.95) {cat(sprintf("%dd;", i+144))} };
#Resemblance to positive mean
for (i in (limP+1 ):limN ) {  correlation=cor(positives, mat[i,], method = 'pearson'); if (correlation > 0.999) {cat(sprintf("%dd;", i+144))} };

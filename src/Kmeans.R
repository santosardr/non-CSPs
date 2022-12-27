library(RWeka)

data<-read.arff("training.arff")
PLUS=144;
Clusters=80;
fullresult <- SimpleKMeans(data, Weka_control(N = Clusters, S =100));
table(predict(fullresult), data$class);
result<-predict(fullresult);
limP=141;
limN=length(result);
pos<-result[1:limP];
neg<-result[(limP+1):limN];

cat(sprintf("\nNegative\n"));
for (i in 0:(Clusters)-1) { if( length (as.numeric(labels(neg[neg==i]))) < 30 ) { cat(sprintf("\n%02d (%02d)\t", i, length (as.numeric(labels(neg[neg==i])))));
cat(as.numeric(labels(neg[neg==i]))+PLUS)}}


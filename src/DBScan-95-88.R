library(RWeka)
WPM("load-packages", "optics_dbScan")
DBScan<-make_Weka_clusterer('weka/clusterers/DBSCAN', c("DBScan", "Weka_clusterers"), package = "optics_dbScan")
data<-read.arff("training.arff")

control<-c( "-E", 0.7, "-M", 6, "-A", "weka.core.EuclideanDistance", "--", "-R", "first-last" );
fullresult <- DBScan(data, control);
table(predict(fullresult), data$class);
result<-predict(fullresult);
limN=1048;
limP=length(result);
neg<-result[1:limN];pos<-result[(limN+1):limP];
cat(sprintf("\nFalse Negative\n"));neg[which(is.na(neg))];
cat(sprintf("\nFalse Positive\n"));pos[which(is.na(pos))];
length(as.numeric(labels(neg[which(is.na(neg))])));
length(as.numeric(labels(pos[which(is.na(pos))])))

printf <- function(...) cat(sprintf(...))
lista=as.numeric(labels(neg[which(is.na(neg))]))+144
for(item in lista){ printf("%dd;",  item) }


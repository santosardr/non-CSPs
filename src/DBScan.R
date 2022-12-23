library(RWeka)
WPM("load-packages", "optics_dbScan")
DBScan<-make_Weka_clusterer('weka/clusterers/DBSCAN', c("DBScan", "Weka_clusterers"), package = "optics_dbScan")
data<-read.arff("training.arff")

control<-c( "-E", 2, "-M", 6, "-A", "weka.core.EuclideanDistance", "--", "-R", "first-last" );
fullresult <- DBScan(data, control);
table(predict(fullresult), data$class);
result<-predict(fullresult);
limP=141;
limN=length(result);
pos<-result[1:limP];neg<-result[(limP+1):limN];
cat(sprintf("\nFalse Negative\n"));neg[which(is.na(neg))];
cat(sprintf("\nFalse Positive\n"));pos[which(is.na(pos))];
length(as.numeric(labels(neg[which(is.na(neg))])));
length(as.numeric(labels(pos[which(is.na(pos))])))

printf <- function(...) cat(sprintf(...))
lista=as.numeric(labels(neg[which(is.na(neg))]))+144+141
for(item in lista){ printf("%dd;",  item) }

lista=as.numeric(labels(neg[which(neg==1)]))+144+141;for(item in lista){ printf("%d ",  item) }
i=0; preditos=(  ); for indice in ${preditos[@]}; do indice=$[$indice+$i]; sed -i "$[indice]d" filtered.arff; i=$[$i-1];done



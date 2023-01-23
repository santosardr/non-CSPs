library(RWeka)
WPM("load-packages", "optics_dbScan")
DBScan<-make_Weka_clusterer('weka/clusterers/DBSCAN', c("DBScan", "Weka_clusterers"), package = "optics_dbScan")
data<-read.arff("training.arff")

control<-c( "-E", 0.7, "-M", 6, "-A", "weka.core.EuclideanDistance", "--", "-R", "first-last" );
fullresult <- DBScan(data, control);
table(predict(fullresult), data$class);
result<-predict(fullresult);
limP=141;
limN=length(result);
pos<-result[1:limP];neg<-result[(limP+1):limN];
printf <- function(...) cat(sprintf(...))
cat(sprintf("\nFalse Negative\n"));neg[which(is.na(neg))];
cat(sprintf("\nFalse Positive\n"));pos[which(is.na(pos))];
length(as.numeric(labels(neg[which(is.na(neg))])));
length(as.numeric(labels(pos[which(is.na(pos))])))

#for ( c in 0:3) { lista=as.numeric(labels(neg[which(neg==c)]))+144;for(item in lista){ printf("%dd;",  item) }}

lista=as.numeric(labels(neg[which(is.na(neg))]))+144
sink("filter3.result");
count=1;
upcount=0;
for(item in lista){
	 count=count+1
	 if (!count%%10000) {
	    upcount= upcount + 10000;
	    printf("%dd\n",  item-upcount)
	 }else{
		printf("%dd;",  item-upcount)
	}
}
sink();


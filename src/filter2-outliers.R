library(RWeka)

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

output <-c();

#Difference from negative mean
for (i in (limP+1 ):limN ) {  correlation=cor(negatives, mat[i,], method = 'pearson'); if (correlation < 0.999) {output<-append(output,i)}};

#Resemblance to positive mean
for (i in (limP+1 ):limN ) {  correlation=cor(positives, mat[i,], method = 'pearson'); if (correlation > 0.998) {output<-append(output,i)}};

outputsort <-sort(output[!duplicated(output)]);
sink("localsubcellular.result");
for (i in 1:length(outputsort)) {  cat(sprintf("%d\t1:?\t1:SECRETED\t1.0\n", outputsort[i])) };
sink()

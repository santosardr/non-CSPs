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

#Difference from negative mean

sink("localsubcellular.result");
#for (i in (limP+1 ):limN ) {  correlation=cor(negatives, mat[i,], method = 'pearson'); if (correlation < 0.9425) {cat(sprintf("%d\t1:?\t1:SECRETED\t1.0\n", i))} };

#Resemblance to positive mean
#sink();sink("localsubcellular.result");
for (i in (limP+1 ):limN ) {  correlation=cor(positives, mat[i,], method = 'pearson'); if (correlation > 0.9943) {cat(sprintf("%d\t1:?\t1:SECRETED\t1.0\n", i))} };
sink()

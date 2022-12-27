#!/bin/bash -

function randomgenerator()
{
    local rand=$(LC_ALL=C tr -dc '[:digit:]' < /dev/urandom|head -c8);
    local real=$(echo "scale=8;1048*($rand/100000000)"|bc -l);
    local integer=$(echo "scale=0;$real/1.0"|bc -l);
    if [ $integer -eq 0 ];
    then
	integer=1
    fi
    echo "$integer"
    }

if [ $1 -gt 0 -a $2 -gt 0 ];
then
    for run in $(seq 1 $2);
    do
	if [ -r training.arff ];
	then
	    rand=$(randomgenerator)
	    dela1=$[$rand  + 285 ];
	    rand=$(randomgenerator)
	    dela2=$[$dela1 + 1000];
	    rand=$(randomgenerator)
	    delb1=$[$rand  + 285 ];
	    rand=$(randomgenerator)
	    delb2=$[$delb1 + 1000];
	    run=$(echo "$dela1$delb1$dela2$delb2")
            printf  "\n%d,%d" $dela1 $delb1  >> group$1.result	    
	    sed "$[$dela1]d;$[$delb1]d;" training.arff > $run-training.arff
		if [ -r $run-training.arff ];
		then
		    java -cp  /usr/local/weka/weka.jar  weka.classifiers.trees.RandomForest -t $run-training.arff -d $run-model.bin  > /dev/null 2>&1
		    if [ -r $run-model.bin ];
		    then
			if [ -r validation1.arff ];
			then
			    java -cp  /usr/local/weka/weka.jar  weka.classifiers.trees.RandomForest -l $run-model.bin -p 0 -T validation1.arff > $run-teste1.result

			    sed -i "1,5d;s/[ ]\+/ /g; s/^[ ]//g; s/[ ]$//g;  s/[ ]/\t/g" $run-teste?.result
			    awk ' BEGIN{fp=0;fn=0;nn=0;np=0;ind=0}{ if($3~ /Indeterminate/) {ind++;}else if($3~ /NON-SECRETED/) {if($1>92)fn++;}else if($3~ /SECRETED/){if($1<=92)fp++;}else if($3~ /Noise/){if($1<=92)nn++; else np++}}END{ printf "\t%d\t%.2f\t%d\t%.2f\t%.2f", fp, (92-nn-fp)/(92-nn), fn, (14-np-fn)/(14-np), (92-nn-fp+14-np-fn)/(106-nn-np);}' $run-teste1.result >> group$1.result
                            printf "." 
			    
			    rm  $run-*.arff  $run-model.bin  $run-teste?.result
			else
			    echo no mask file
			fi
		    else
			echo model.bin missing 
		    fi
		else
		    echo training missing
		fi
	else
	    echo training missing
	fi
    done
else
    echo invalid parameters $1 $2 
fi

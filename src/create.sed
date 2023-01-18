#!/bin/bash
if [[ -r localsubcellular-filtered.arff && -r $1 ]]
then
	awk 'BEGIN{todel=""; cmd=0; count=1;step=10000} {
		if ($3 ~/1:SECRETED/ ) {
			if(todel==""){
				todel=sprintf("%dd", $1+144-cmd);
			}else{
				todel=sprintf("%s;%dd", todel, $1+144-cmd);
			}
			if(count%step==0){
				cmd=cmd+step;
				count=0;
				printf "sed -i \" %s \" localsubcellular-filtered.arff\n", todel;
				todel="";
				printf("\necho Step %d\n", cmd);
			}
			count=count+1;
		}
	}END{printf "sed -i \" %s \" localsubcellular-filtered.arff\n", todel;}'  $1 > $1.sed
else
	echo "Error: missing files"
fi

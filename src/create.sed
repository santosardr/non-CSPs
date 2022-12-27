#!/bin/bash
if [[ -r localsubcellular-filtered.arff && -r $1 ]]
then
	awk 'BEGIN{todel=""; cmd=0; count=1;passo=1000} {
		if ($3 ~/1:SECRETED/ ) {
			if(todel==""){
				todel=sprintf("%dd", $1-cmd);
			}else{
				todel=sprintf("%s;%dd", todel, $1-cmd);
			}
			if(count%passo==0){
				cmd=cmd+passo;
				count=0;
				printf "sed -i \" %s \" localsubcellular-filtered.arff\n", todel;
				todel="";
				printf("\necho Passo %d\n", cmd);
			}
			count=count+1;
		}
	}END{printf "sed -i \" %s \" localsubcellular-filtered.arff\n", todel;}'  $1 > $1.sed
else
	echo "Erro: faltam arquivos"
fi

#!/bin/bash
if [ -r test.faa -a -r ../bin/features -a -r propensity.dat ]
then

    #Create a link or copy the amino acid propensity file to the current folder

    #Process each labeled file with the software called 'features' compiled from the  common lisp language
    ../bin/features test.faa > wekatest.arff    

    #The following commands will assembler an ARFF file from the previous files
    head -n 1 wekatest.arff > weka.attributes
    sed -i '1d' wekatest.arff
    sed -i "s/\([a-zA-Z0-9]\+\)/@attribute \1 numeric#/g" weka.attributes
    tr '#' '\n' < weka.attributes > weka.attributes2
    tr -d '\t' < weka.attributes2 > weka.attributes
    cut -f 2- wekatest.arff > wekatest.arff2    
    sed -i "s/\t/,/g" wekatest.arff2
    sed -i "s/$/?/g" wekatest.arff2    
    echo '@relation localsubcellular' > localsubcellular.arff
    cat weka.attributes  >> localsubcellular.arff
    echo '@attribute class {SECRETED,NON-SECRETED}' >> localsubcellular.arff
    echo '@data' >> localsubcellular.arff
    cat wekatest.arff2  >> localsubcellular.arff 
    rm weka.attributes2 weka.attributes wekatest.arff2 wekatest.arff
    echo "File localsubcellular.arff for training is ready!"
else
    echo "To continue, please, provide the files 'test.faa' 'bin/features' and 'propensity.dat'"
fi

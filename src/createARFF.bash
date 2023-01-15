#!/bin/bash
#Split protein files between a negative and a positive container folder
if [ -r neg -a -r pos -a -r ../bin/features -a -r propensity.dat ]
then

    #Join all protein files, in fasta format, inside the correspondent labeled file
    cat neg/* > neg.faa
    cat pos/* > pos.faa

    #Create a link or copy the amino acid propensity file to the current folder

    #Process each labeled file with the software called 'features' compiled from the  common lisp language
    ../bin/features pos.faa > wekapos.arff    
    ../bin/features neg.faa > wekaneg.arff

    #The following commands will assembler an ARFF file from the previous files
    head -n 1 wekaneg.arff > weka.attributes
    sed -i '1d' weka*.arff
    sed -i "s/\([a-zA-Z0-9]\+\)/@attribute \1 numeric#/g" weka.attributes
    tr '#' '\n' < weka.attributes > weka.attributes2
    tr -d '\t' < weka.attributes2 > weka.attributes
    cut -f 2- wekapos.arff > wekapos.arff2    
    cut -f 2- wekaneg.arff > wekaneg.arff2
    sed -i "s/\t/,/g" weka*.arff2
    sed -i "s/$/SECRETED/g" wekapos.arff2    
    sed -i "s/$/NON-SECRETED/g" wekaneg.arff2    
    echo '@relation localsubcellular' > localsubcellular.arff
    cat weka.attributes  >> localsubcellular.arff
    echo '@attribute class {SECRETED,NON-SECRETED}' >> localsubcellular.arff
    echo '@data' >> localsubcellular.arff
    cat wekaneg.arff2 wekapos.arff2  >> localsubcellular.arff 
    rm weka*.attributes2 weka*.attributes weka*.arff2 weka*.arff neg.faa pos.faa 
    echo "File localsubcellular.arff for training is ready!"
    echo "For testing, exchange the labels by the punctuation signal used for questions (?)"
else
    echo "To continue, please, provide the folders 'neg' and 'pos', and files 'bin/features' and 'propensity.dat'"
    echo "Also, split protein files between the 'neg' (negative) and the 'pos' (positive) container folder"
fi

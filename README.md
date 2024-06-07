# Enhancing omics analyses of bacterial protein secretion via non-classical pathways


## Erratum


Please take note of the following erratum:

In the article, there was an error in the text regarding K Star. The corrected sentence should read as follows:


"However, K Star is a potential candidate for production based on its performance in our specific use case, which shows no false **positives**. It is important to note that it may exhibit false **positives** in other scenarios."


I apologize for any confusion this may have caused. I appreciate your understanding.


## Content


This repository contains mainly data and software to facilitate the creation of ARFF files for WEKA. Once your data is formatted to an ARFF, you can execute all software within the WEKA software. Read the methods in my article to learn how to proceed.


Besides the software to format data for WEKA, I added the pipeline SurfG+, which allows me to create a large data set (1050) negative for non-classical secreted proteins. SurfG+ is very helpful in classifying bacterial proteins according to localizations membrane (integral and partial), cytoplasm, and secreted.


## Fast-track


- Clone	this GitHub repository;

- Install Java 8, 11, or 17, and make it the default to the OS;

- Download and unpack the WEKA	software;

- Copy the 'weka.jar' to the '/usr/local/weka';	Otherwise, you will need	to edit	the run.validation1 and run.validation2 scripts indicating this file location;

- Make sure the files run.validation1 and run.validation2 are in execution mode. Otherwise:

```bash
chmod 755 run.validation*
```

- call the run.validation1 or run.validation2

```bash
./run.validation1
```

These validation scripts use the two test datasets described in the article.


## Running the predictor on your dataset

You will need a set of proteins in fasta format. Keep protein names as simple as possible to avoid processing errors across several scripts. In case of difficulties editing the protein names manually, I suggest using my program src/valifasta like this:

```bash
valifasta -i test.fasta -o test.fasta
```

After that, consider using my script 'src/createARFFtotest.bash'. This script expects to find the file 'test.faa' in the same directory within the script. Just run the script to create a file called 'localsubcellular.arff'.

```bash
./createARFFtotest.bash
```
To test your proteins, execute a command like this:

```bash
java -cp /usr/local/weka/weka.jar weka.classifiers.trees.RandomForest -l ../bin/myids5-89-93-90-a.bin  -p 0 -T localsubcellular.arff
```

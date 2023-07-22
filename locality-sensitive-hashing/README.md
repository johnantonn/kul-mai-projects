# Locality Sensitive Hashing
Implementation of locality sensitive hashing algorithm for finding similar pairs of Stack Overflow posts.

# Problem
Finding sets of similar objects in large collections is a simple problem with a variety of applications. Examples include identifying people with similar movie tastes, and identifying similar documents to avoid plagiarism among others.

## Formulation
__Given__: A similarity function `sim` that maps each pair of objects to a numeric score;

__Find__: All the pairs of objects `(x, y)` such that `sim(x, y) > t`, where `t` is a user-defined similarity threshold.

A naive approach would be to iterate over the document collection and compute the similarity of every all combinations. 
The complexity of this algorithm is quadratic with the number of objects in the collection. 
Such a complexity is acceptable for simple problems, but quickly becomes unpractical as the number of objects grows. 
For large collections of objects such as collections of web pages or movie recommendations with several million entries, 
computing the similarities using this algorithm can take weeks.

## Dataset
The dataset is obtained from [https://archive.org/details/stackexchange](https://archive.org/details/stackexchange). This is an anonymized dump of all user-contributed content on the Stack Exchange network. For this exercise, a subset of 1.25 million questions is saved in `Questions.xml` file, which comprises the primary input of the algorithm.

The file `Duplicates.xml` can be used to test the implementation. This file lists all questions which the community marked as duplicates. Note, however, that this file is not a ground truth for the LSH implementation. It only allows for performance comparison of the LSH implementation to the efforts of a large community. First, people make mistakes, so `Duplicates.xml` doesn't contain all duplicate questions. Second, it lists many questions which are only semantically related. For example, *"What's an efficient algorithm to find near-duplicate documents in a large collection?"* and *"How to discover similar text snippets in a large database?"* are semantically related, but are not what we mean by near duplicates. LSH deals with character-based similarity, which quite simply measures the character overlap between two sentences or documents. Near duplicate documents are of course also semantically related, so the LSH implementation should be able to identify a subset of the questions listed in `Duplicates.xml`.

# Solution
__Locality sensitive hashing (LSH)__ is an approximated method that can be used to find the pairs of objects with high similarity more efficiently. 
It hashes most similar objects into the same buckets, and most dissimilar objects into different buckets. Once all the objects have been sorted into buckets, 
one simply has to compute pairwise similarities among the pairs of objects that have been sorted into the same bucket. 
If the hashing function is properly designed, this can yield a drastic reduction of complexity.

# Implementation
The implementation reads a dataset of 1.25M Stack Overflow posts and performs shingling, minhashing and locality sensitive hashing to identify similar pairs of posts.

## Parameters
A list of parameters that the user can provide:
- `-method` bf or lsh: method used. Either bf for brute force or lsh for locality sensitive hashing. In the original version of the archive, only the bf method is implemented.
- `-dataFile` path: is the path to the XML archive with questions.
- `-testFile` path: is the path to the XML file with true duplicates.
- `-outputFile` path: discovered similar pairs are written to this file.
- `-treshold` double: similarity threshold.
- `-shingleLength` int: length of the shingles.
- `-numShingles` int: maximum number of unique shingles.
- `-seed` int: seed for the random generator. Runs with the same seed must produce identical results.
- `-maxQuestions` int: the maximum number of questions to consider. If set to n, DataHandler.java will only load questions 0, ..., n-1.
- `docsPerStep` int: the number of questions (XML documents) to read per step to avoid memory overflow.
- `numHashes` int: the number of different minhash functions to use in the LSH method.
- `numBands` int: the number of bands for the LSH method.
- `numBuckets` int: the number of buckets for the LSH method.
- `signaturesFile` path: the path to write the signatures matrix in the LSH method.

## How to run
Compile the `Runner.java` class:

`javac Runner.java`

and then execute the algorithm with the required arguments:

`java Runner -method lsh -dataFile <pathTo>/Questions.xml -testFile <pathTo>/Duplicates.xml -outputFile <pathTo>/output.xml -threshold 0.7 -shingleLength 10 -numShingles 10000 -maxQuestions 100000 -numHashes 100 -numBands 20 -numBuckets 50000`

The provided `DataHandler` will probably crash while parsing the full dataset of 1.25M, unless the following arguments are used after the `java` call: 
`-DentityExpansionLimit=2147480000 -DtotalEntitySizeLimit=2147480000 -Djdk.xml.totalEntitySizeLimit=2147480000`

## Results
Running the aforementioned command produces an output file containing the identifiers of question pairs with a similarity above the given threshold. The identifiers for the questions correspond to the identifiers in the `Questions.xml` file. 

If the `-signaturesFile` argument is set, the signatures are written to a CSV file where each column represents a document, the first row contains the documents' IDs and each successive row a hash:

`100,210,360,432,...`<br/>
`4,10,20,40,...`<br/>
`23,12,2,42,...`<br/>
`...`

Finally, a `results.csv` file is also written to the `-outputFile` parent directory that contains all the provided parameters, the scores achieved by the algorithm as well as the elapsed time. This data can be used to compare different runs and understand the effect of different values of various parameters to the final output.

# Disclaimer
This project and parts of the code are part of an assignment in the context of Big Data Analytics Programming course for the Master in Artificial Intelligence, KU Leuven.

# References
[Mining of Massive Datasets, ch3. Jure Leskovec, Anand Rajaraman, Jeff Ullman, 2019](http://infolab.stanford.edu/~ullman/mmds/ch3.pdf)

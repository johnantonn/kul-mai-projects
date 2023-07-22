
/**
 * Copyright (c) DTAI - KU Leuven – All rights reserved.
 * Proprietary, do not copy or distribute without permission.
 * Written by Pieter Robberechts, 2020
 */
import java.io.FileNotFoundException;
import java.util.Random;
import java.util.Set;
import java.util.List;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;

import javax.xml.stream.XMLStreamException;

/**
 * The Runner can be ran from the commandline to find the most similar pairs of
 * StackOverflow questions.
 */
public class Runner {

    public static void main(String[] args) {

        // Default parameters
        String dataFile = "";
        String testFile = null;
        String outputFile = "";
        String signaturesFile = null;
        String resultsFile = null;
        String method = "";
        int numHashes = -1;
        int numShingles = 1000;
        int numBands = -1;
        int numBuckets = 2000;
        int seed = 1234;
        int maxQuestions = -1;
        int shingleLength = -1;
        float threshold = -1;
        int docsPerStep = 1000;

        int i = 0;
        while (i < args.length && args[i].startsWith("-")) {
            String arg = args[i];
            if (arg.equals("-method")) {
                if (!args[i + 1].equals("bf") && !args[i + 1].equals("lsh")) {
                    System.err.println(
                            "The search method should either be brute force (bf) or minhash and locality sensitive hashing (lsh)");
                }
                method = args[i + 1];
            } else if (arg.equals("-numHashes")) {
                numHashes = Integer.parseInt(args[i + 1]);
            } else if (arg.equals("-numBands")) {
                numBands = Integer.parseInt(args[i + 1]);
            } else if (arg.equals("-numBuckets")) {
                numBuckets = Integer.parseInt(args[i + 1]);
            } else if (arg.equals("-numShingles")) {
                numShingles = Integer.parseInt(args[i + 1]);
            } else if (arg.equals("-seed")) {
                seed = Integer.parseInt(args[i + 1]);
            } else if (arg.equals("-dataFile")) {
                dataFile = args[i + 1];
            } else if (arg.equals("-testFile")) {
                testFile = args[i + 1];
            } else if (arg.equals("-signaturesFile")) {
                signaturesFile = args[i + 1];
            } else if (arg.equals("-outputFile")) {
                outputFile = args[i + 1];
            } else if (arg.equals("-maxQuestions")) {
                maxQuestions = Integer.parseInt(args[i + 1]);
            } else if (arg.equals("-shingleLength")) {
                shingleLength = Integer.parseInt(args[i + 1]);
            } else if (arg.equals("-threshold")) {
                threshold = Float.parseFloat(args[i + 1]);
            } else if (arg.equals("-docsPerStep")) {
                docsPerStep = Integer.parseInt(args[i + 1]);
            } else if (arg.equals("-resultsFile")) {
                resultsFile = args[i + 1];
            }
            i += 2;
        }

        Shingler shingler = new Shingler(shingleLength, numShingles);
        DataHandler dh = new DataHandler(maxQuestions, shingler, dataFile);
        Set<SimilarPair> similarItems = null;
        BruteForceSearch bfSearcher = null;
        LSH lshSearcher = null;

        if (method.equals("bf")) {
            bfSearcher = new BruteForceSearch(dh, threshold);
        } else if (method.equals("lsh")) {
            if (numHashes == -1 || numBands == -1) {
                throw new Error("Both -numHashes and -numBands are mandatory arguments for the LSH method");
            }
            Random rand = new Random(seed);
            lshSearcher = new LSH(dh, threshold, numHashes, numBands, numBuckets, numShingles, rand, docsPerStep);
        }

        long startTime = System.currentTimeMillis();

        System.out.println("Searching items more similar than " + threshold + " ... ");
        if (method.equals("bf")) {
            similarItems = bfSearcher.getSimilarPairsAboveThreshold();
        } else if (method.equals("lsh")) {
            similarItems = lshSearcher.getSimilarPairsAboveThreshold();
        }

        double elapsedTime = (System.currentTimeMillis() - startTime) / 1000.0;
        System.out.println("done! Took " + elapsedTime + " seconds.");
        System.out.println("--------------");

        if (method.equals("lsh") && signaturesFile != null) {
            // Save signatures matrix to file
            saveSignaturesToFile(lshSearcher.getSignaturesMatrix(), lshSearcher.reader, signaturesFile, numHashes);
        }
        savePairs(outputFile, similarItems);
        if (testFile != null) {
            if (resultsFile != null)
                saveParamsToFile(resultsFile, docsPerStep, numHashes, numShingles, numBands, numBuckets, seed,
                        maxQuestions, shingleLength, threshold, elapsedTime);
            testPairs(similarItems, SimilarPairParser.read(testFile), dh.idToDoc, resultsFile);
        }
    }

    /**
     * Save pairs and their similarity.
     * 
     * @param similarItems
     */
    public static void savePairs(String outputFile, Set<SimilarPair> similarItems) {
        try {
            SimilarPairWriter.save(outputFile, similarItems);
            System.out.println("Found " + similarItems.size() + " similar pairs, saved to '" + outputFile + "'");
            System.out.println("--------------");
        } catch (FileNotFoundException e) {
            System.err.println("The file '" + outputFile + "' does not exist!");
        } catch (XMLStreamException e) {
            e.printStackTrace();
        }
    }

    /**
     * Save signatures matrix to file
     * 
     * @param sigMatrix      The signature matrix
     * @param reader         The Reader object
     * @param signaturesFile The file path to store the signature matrix
     * @param numHashes      The number of hash functions
     */
    public static void saveSignaturesToFile(List<List<Integer>> sigMatrix, Reader reader, String signaturesFile,
            int numHashes) {
        try {
            FileWriter csvWriter = new FileWriter(signaturesFile);
            BufferedWriter bw = new BufferedWriter(csvWriter);
            String line = "";
            // Document id's
            for (int d = 0; d < sigMatrix.size(); d++) {
                line += Integer.toString(reader.getExternalId(d)) + ",";
            }
            bw.write(line.replaceAll(",$", "") + "\n");
            // Signatures
            for (int h = 0; h < numHashes; h++) {
                line = "";
                for (int d = 0; d < sigMatrix.size(); d++) {
                    line += Integer.toString(sigMatrix.get(d).get(h)) + ",";
                }
                bw.write(line.replaceAll(",$", "") + "\n");
            }
            bw.flush();
            bw.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * Test pairs identified as similar
     * 
     * @param results
     * @param references
     * @param processedDocs
     */
    public static void testPairs(Set<SimilarPair> results, Set<SimilarPair> references, List<Integer> processedDocs,
            String resultsFile) {
        int truePosCount = 0;
        int falsePosCount = 0;
        int falseNegCount = 0;
        for (SimilarPair result : results) {
            if (references.contains(result)) {
                truePosCount++;
            } else {
                falsePosCount++;
            }
        }
        for (SimilarPair reference : references) {
            if (processedDocs.contains(reference.id1) && processedDocs.contains(reference.id2)
                    && !results.contains(reference)) {
                falseNegCount++;
            }
        }
        double precision = (double) truePosCount / (truePosCount + falsePosCount);
        double recall = (double) truePosCount / (truePosCount + falseNegCount);
        double f1 = 2d * truePosCount / (2 * truePosCount + falsePosCount + falseNegCount);
        System.out.println("Test results:");
        System.out.println("TP: " + truePosCount + ", FP: " + falsePosCount + ", FN: " + falseNegCount + ", F1: " + f1);
        if (resultsFile != null)
            saveResultsToFile(resultsFile, truePosCount, falsePosCount, falseNegCount, precision, recall, f1);
    }

    public static void saveParamsToFile(String resultsFile, int docsPerStep, int numHashes, int numShingles,
            int numBands, int numBuckets, int seed, int maxQuestions, int shingleLength, float threshold,
            double elapsedTime) {
        try {
            FileWriter csvWriter = new FileWriter(resultsFile, true);
            BufferedWriter bw = new BufferedWriter(csvWriter);
            String line = String.join(",", Integer.toString(docsPerStep), Double.toString(elapsedTime),
                    Integer.toString(maxQuestions), Integer.toString(numShingles), Integer.toString(shingleLength),
                    Integer.toString(numHashes), Integer.toString(numBands), Integer.toString(numBuckets),
                    Integer.toString(seed), Float.toString(threshold));
            bw.write(line + ",");
            bw.flush();
            bw.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void saveResultsToFile(String resultsFile, int truePosCount, int falsePosCount, int falseNegCount,
            double precision, double recall, double f1) {
        try {
            FileWriter csvWriter = new FileWriter(resultsFile, true);
            BufferedWriter bw = new BufferedWriter(csvWriter);
            String line = String.join(",", Integer.toString(truePosCount), Integer.toString(falsePosCount),
                    Integer.toString(falseNegCount), Double.toString(precision), Double.toString(recall),
                    Double.toString(f1));
            bw.write(line + "\n");
            bw.flush();
            bw.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}

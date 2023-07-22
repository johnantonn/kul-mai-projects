
/**
 * Copyright (c) DTAI - KU Leuven – All rights reserved.
 * Proprietary, do not copy or distribute without permission.
 * Written by Pieter Robberechts, 2020
 */
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import java.util.Collections;

/**
 * Implementation of minhash and locality sensitive hashing (lsh) to find
 * similar objects.
 *
 */
public class LSH extends SimilaritySearcher {

    // number of hash functions
    protected int numHashes;

    // number of bands
    protected int numBands;

    // number of buckets
    protected int numBuckets;

    // max number of shingles
    protected int numValues;

    // object to generate random numbers
    protected Random rand;

    // documents per step
    protected int docsPerStep;

    // signature matrix
    protected List<List<Integer>> signaturesMatrix;

    /**
     * Construct an LSH similarity searcher.
     *
     * @param reader     a data Reader object
     * @param threshold  the similarity threshold
     * @param numHashes  number of hashes to use to construct the signature matrix
     * @param numBands   number of bands to use during locality sensitive hashing
     * @param numBuckets number of buckets to use during locality sensitive hashing
     * @param numValues  the number of unique values that occur in the objects' set
     *                   representations (i.e. the number of rows of the original
     *                   characteristic matrix)
     * @param rand       should be used to generate any random numbers needed
     */
    public LSH(Reader reader, double threshold, int numHashes, int numBands, int numBuckets, int numValues, Random rand,
            int docsPerStep) {
        super(reader, threshold);
        this.numHashes = numHashes;
        this.numBands = numBands;
        this.numBuckets = numBuckets;
        this.numValues = numValues;
        this.rand = rand;
        this.docsPerStep = docsPerStep;
        this.signaturesMatrix = new ArrayList<List<Integer>>();
    }

    /**
     * Returns the pairs with similarity above threshold (approximate).
     */
    @Override
    public Set<SimilarPair> getSimilarPairsAboveThreshold() {
        Set<SimilarPair> similarPairsAboveThreshold = new HashSet<SimilarPair>();

        // Unihash parameters
        int[] aParams = new int[numHashes];
        int[] bParams = new int[numHashes];
        int[] pParams = new int[numHashes];
        for (int i = 0; i < numHashes; i++) {
            aParams[i] = rand.nextInt();
            bParams[i] = rand.nextInt();
            pParams[i] = Primes.findLeastPrimeNumber((i + 1) * numValues);
        }

        // Proceed step-wise in chunks of docsPerStep
        while (reader.curDoc < reader.getNumDocuments() - 1) {
            reader.readChunks(docsPerStep);

            // Minhashing
            List<List<Integer>> sigSubMatrix = minhash(aParams, bParams, pParams);
            for (int i = 0; i < sigSubMatrix.size(); i++) {
                signaturesMatrix.add(sigSubMatrix.get(i));
            }
        }

        // LSH
        int numRows = numHashes / numBands;
        Map<Integer, ArrayList<Integer>> hashBuckets;
        for (int b = 0; b < numBands; b++) { // for each band
            hashBuckets = new HashMap<Integer, ArrayList<Integer>>();

            for (int d = 0; d < reader.getNumDocuments(); d++) {
                String rVector = "";
                for (int r = b * numRows; r < (b + 1) * numRows; r++) {
                    rVector += Integer.toString(signaturesMatrix.get(d).get(r));
                }
                int rVectorHash = Math.abs(MurmurHash.hash32(rVector, 1234)) % numBuckets;
                ArrayList<Integer> cands;
                if (hashBuckets.containsKey(rVectorHash)) {
                    cands = hashBuckets.get(rVectorHash);
                    for (int i = 0; i < cands.size(); i++) {
                        double sigSim = signaturesSim(signaturesMatrix.get(d), signaturesMatrix.get(cands.get(i)));
                        if (sigSim > threshold) {
                            similarPairsAboveThreshold.add(new SimilarPair(reader.getExternalId(cands.get(i)),
                                    reader.getExternalId(d), sigSim));
                        }
                    }
                } else {
                    cands = new ArrayList<Integer>();
                }
                cands.add(d);
                hashBuckets.put(rVectorHash, cands);
            }

        }

        return similarPairsAboveThreshold;
    }

    /**
     * Implementation of minhash algorithm
     * 
     * @param p array of prime numbers
     * @param a array of a parameters
     * @param b array of b parameters
     */
    private List<List<Integer>> minhash(int[] a, int[] b, int[] p) {

        List<List<Integer>> sigMatrix = new ArrayList<List<Integer>>();

        // Initialize to +inf
        Integer posInf = Integer.MAX_VALUE;
        for (int d = 0; d < reader.getObjectMapping().size(); d++) {
            List<Integer> infList = new ArrayList<Integer>(Collections.nCopies(numHashes, posInf));
            sigMatrix.add(infList);
        }

        // Minhashing
        for (int r = 0; r < numValues; r++) { // for each row
            int[] hashedRow = new int[numHashes];
            for (int h = 0; h < numHashes; h++) { // for each hash function
                hashedRow[h] = uniHash(r, a[h], b[h], p[h]) % numValues;
            }
            for (int d = 0; d < reader.getObjectMapping().size(); d++) { // for each column
                if (reader.getObjectMapping().get(d).contains(r)) {
                    for (int h = 0; h < numHashes; h++) { // for each hash function
                        if (hashedRow[h] < sigMatrix.get(d).get(h))
                            sigMatrix.get(d).set(h, hashedRow[h]);
                    }
                }
            }
        }

        return sigMatrix;
    }

    /**
     * Implementation of universal hashing h(x) = (a*x + b) % p
     * 
     * @param num the input integer
     * @param a   the a coefficient
     * @param b   the b coefficient
     * @param p   prime integer
     */
    private int uniHash(int num, int a, int b, int p) {

        int hash = Math.abs(a * num + b) % p;

        return hash;
    }

    /**
     * Calculates the similarity between two arrays of signatures
     * 
     * @param sigList1 first signature array list
     * @param sigList2 second signature array list
     */
    private double signaturesSim(List<Integer> sigList1, List<Integer> sigList2) {

        int matches = 0;
        int size = sigList1.size();

        for (int i = 0; i < size; i++) {
            if (sigList1.get(i) == sigList2.get(i))
                matches++;
        }

        return ((double) matches / size);
    }

    /**
     * Returns the signature matrix
     */
    public List<List<Integer>> getSignaturesMatrix() {
        return this.signaturesMatrix;
    }
}

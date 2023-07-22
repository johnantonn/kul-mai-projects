package edu.kul.mai.bdap;

import scala.Tuple2;

import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.sql.SparkSession;
import org.apache.spark.api.java.function.*;

import java.util.Arrays;
import java.util.List;
import java.util.regex.Pattern;

public class TripLength {
    private static final Pattern SPACE = Pattern.compile(" "); // space pattern
    private static final double R = 6371.009; // earth's radius in km

    public static void main(String[] args) throws Exception {

        if (args.length < 2) {
            System.err.println("Usage: TripLength <inputFile> <outputDir>");
            System.exit(1);
        }

        // Spark session
        SparkSession spark = SparkSession.builder().appName("TripLength").getOrCreate();

        // Timer start
        long startTime = System.currentTimeMillis();

        // Data lines
        long t1 = System.currentTimeMillis();
        JavaRDD<String> lines = spark.read().textFile(args[0]).javaRDD();
        long t2 = System.currentTimeMillis();
        System.out.println("Read lines to RDD: " + (t2 - t1) + " milliseconds");

        // Point distances
        long t3 = System.currentTimeMillis();
        JavaRDD<Integer> pDist = lines.map(new Function<String, Integer>() {
            public Integer call(String s) {
                List<String> sList = Arrays.asList(SPACE.split(s));
                double phi1 = Math.toRadians(Double.parseDouble(sList.get(2)));
                double phi2 = Math.toRadians(Double.parseDouble(sList.get(5)));
                double dPhi = phi2 - phi1;
                double dLambda = Math.toRadians(Double.parseDouble(sList.get(6)) - Double.parseDouble(sList.get(3)));
                double a = Math.sin(dPhi / 2) * Math.sin(dPhi / 2)
                        + Math.sin(dLambda / 2) * Math.sin(dLambda / 2) * Math.cos(phi1) * Math.cos(phi2);
                double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
                return (int) Math.ceil(R * c);
            }
        });
        long t4 = System.currentTimeMillis();
        System.out.println("Compute point distances: " + (t4 - t3) + " milliseconds");

        // Unary count pairs
        long t5 = System.currentTimeMillis();
        JavaPairRDD<Integer, Integer> pDistPairs = pDist.mapToPair(d -> new Tuple2<>(d, 1));
        long t6 = System.currentTimeMillis();
        System.out.println("Pair point distances to 1: " + (t6 - t5) + " milliseconds");

        // Aggregate count pairs
        long t7 = System.currentTimeMillis();
        JavaPairRDD<Integer, Integer> counts = pDistPairs.reduceByKey((i1, i2) -> i1 + i2);
        long t8 = System.currentTimeMillis();
        System.out.println("Group counts: " + (t8 - t7) + " milliseconds");

        // Save RDD to file
        try {
            long t9 = System.currentTimeMillis();
            counts.sortByKey().saveAsTextFile(args[1]); // sort first
            long t10 = System.currentTimeMillis();
            System.out.println("Save results to file: " + (t10 - t9) + " milliseconds");
        } catch (Exception e) {
            System.err.println("Failed to save rdd to file.");
            System.err.println(e.getStackTrace());
        }

        // Timer end
        long endTime = System.currentTimeMillis();
        System.out.println("Total elapsed time: " + (endTime - startTime) + " milliseconds");

        // Stop spark session
        spark.stop();
    }
}

import org.apache.hadoop.conf.Configuration
import org.apache.spark.{SparkContext, SparkConf}
import org.apache.spark.rdd.RDD

import org.bson.BSONObject
import com.mongodb.hadoop.{
  MongoInputFormat, MongoOutputFormat,
  BSONFileInputFormat, BSONFileOutputFormat}
import com.mongodb.hadoop.io.MongoUpdateWritable
import com.mongodb.BasicDBList
import java.io._

import com.cloudera.datascience.lsa._
import com.cloudera.datascience.lsa.ParseWikipedia._
import com.cloudera.datascience.lsa.RunLSA._
import org.apache.spark.rdd.EmptyRDD
import scala.collection.mutable.ListBuffer
import org.apache.spark.mllib.linalg._
import org.apache.spark.mllib.linalg.distributed.RowMatrix
import breeze.linalg.{DenseMatrix => BDenseMatrix, DenseVector => BDenseVector, SparseVector => BSparseVector}
import org.apache.spark.mllib.regression._
import org.apache.spark.rdd._
import org.apache.spark.mllib.tree.RandomForest
import org.apache.spark.mllib.tree.model.RandomForestModel
import org.apache.spark.mllib.util.MLUtils

@transient val mongoConfig = new Configuration()
mongoConfig.set("mongo.input.uri",
    "mongodb://localhost:27017/cordir.project")
val documents = sc.newAPIHadoopRDD(
    mongoConfig,                // Configuration
    classOf[MongoInputFormat],  // InputFormat
    classOf[Object],            // Key type
    classOf[BSONObject])        // Value type

mongoConfig.set("mongo.input.uri",
    "mongodb://localhost:27017/cordir.projetDocConcept")
val documentsDocConcept = sc.newAPIHadoopRDD(
    mongoConfig,                // Configuration
    classOf[MongoInputFormat],  // InputFormat
    classOf[Object],            // Key type
    classOf[BSONObject])        // Value type

:type documents 
def mergeBSON( a:BSONObject, b:BSONObject ) : BSONObject = {
      a.putAll(b)
      return a
}
var joinedDocuments=documents.map(a=>(a._1.toString,a._2)).join(documentsDocConcept.map(a=>(a._1.toString,a._2))).map(a => (a._1,mergeBSON(a._2._1,a._2._2)))
//joinedDocuments.map(a => (a._1,mergeBSON(a._2._1,a._2._2))).take(1).foreach(println)
val data=joinedDocuments.map(a => LabeledPoint(a._2.get("totalCost").asInstanceOf[Double],new DenseVector(a._2.get("value").asInstanceOf[BasicDBList].toArray.asInstanceOf[Array[Double]])))
val splits = data.randomSplit(Array(0.7, 0.3))
val (trainingData, testData) = (splits(0), splits(1))

// Train a RandomForest model.
// Empty categoricalFeaturesInfo indicates all features are continuous.
val numClasses = 2
val categoricalFeaturesInfo = Map[Int, Int]()
val numTrees = 3 // Use more in practice.
val featureSubsetStrategy = "auto" // Let the algorithm choose.
val impurity = "variance"
val maxDepth = 4
val maxBins = 32

val model = RandomForest.trainRegressor(trainingData, categoricalFeaturesInfo,
  numTrees, featureSubsetStrategy, impurity, maxDepth, maxBins)

// Evaluate model on test instances and compute test error
val labelsAndPredictions = testData.map { point =>
  val prediction = model.predict(point.features)
  (point.label, prediction)
}
val testMSE = labelsAndPredictions.map{ case(v, p) => math.pow((v - p), 2)}.mean()
println("Test Mean Squared Error = " + testMSE)
println("Learned regression forest model:\n" + model.toDebugString)

// Save and load model
model.save(sc, "target/tmp/myRandomForestRegressionModel")
exit

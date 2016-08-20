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
import org.apache.spark.ml.feature.StringIndexer
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
    "mongodb://localhost:27017/cordis.project")
val documents = sc.newAPIHadoopRDD(
    mongoConfig,                // Configuration
    classOf[MongoInputFormat],  // InputFormat
    classOf[Object],            // Key type
    classOf[BSONObject])        // Value type

mongoConfig.set("mongo.input.uri",
    "mongodb://localhost:27017/cordis.projetDocConcept")
val documentsDocConcept = sc.newAPIHadoopRDD(
    mongoConfig,                // Configuration
    classOf[MongoInputFormat],  // InputFormat
    classOf[Object],            // Key type
    classOf[BSONObject])        // Value type

def mergeBSON( a:BSONObject, b:BSONObject ) : BSONObject = {
      a.putAll(b)
      return a
}
/*
def generateArray( programme:Double,funding:Double,country:Double, a:BasicDBList ) : Array[Double] = {
        var ree:Array[Double] =Array.fill[Double](a.size()+3)(0)
        ree(0)=programme
        ree(1)=funding
        ree(2)=country
    
        for(i <- 3 to a.size()-1){
          ree(i)=a.get(i).asInstanceOf[Double]
        }
        return ree
}*/
 def generateArray( country:Double, a:BasicDBList ) : Array[Double] = {
        var ree:Array[Double] =Array.fill[Double](a.size()+2)(0)
        ree(0)=programme
        ree(1)=country
    
        for(i <- 2 to a.size()-1){
          ree(i)=a.get(i).asInstanceOf[Double]
        }
        return ree
}   


var joinedDocuments=documents.map(a=>(a._1.toString,a._2)).join(documentsDocConcept.map(a=>(a._1.toString,a._2))).map(a => (a._1,mergeBSON(a._2._1,a._2._2)))
//joinedDocuments.map(a => (a._1,mergeBSON(a._2._1,a._2._2))).take(1).foreach(println)


var keys=joinedDocuments.map(a=>(a._2.get("programme"),1)).reduceByKey((a,b)=>a+b).keys.collect()
var count=0
var progMap:Map[String,Int] = Map()
for (key <- keys) {
    progMap += key.toString -> count
    count=count+1
}

keys=joinedDocuments.map(a=>(a._2.get("fundingScheme"),1)).reduceByKey((a,b)=>a+b).keys.collect()
count=0
var foundMap:Map[String,Int] = Map()
for (key <- keys) {
    foundMap += key.toString -> count
    count=count+1
}

keys=joinedDocuments.map(a=>(a._2.get("coordinatorCountry"),1)).reduceByKey((a,b)=>a+b).keys.collect()
count=0
var countryMap:Map[String,Int] = Map()
for (key <- keys) {
    countryMap += key.toString -> count
    count=count+1
}

val data=joinedDocuments.map(a => LabeledPoint(a._2.get("catCostNum").asInstanceOf[Double],new DenseVector(generateArray(
    progMap(
    countryMap(a._2.get("coordinatorCountry").toString).asInstanceOf[Double],
    a._2.get("value").asInstanceOf[BasicDBList]))))
val splits = data.randomSplit(Array(0.7, 0.3),7)
val (trainingData, testData) = (splits(0), splits(1))

val numClasses = 4
val categoricalFeaturesInfo = Map[Int, Int]((0,84))
val numTrees = 100  // Use more in practice.
val featureSubsetStrategy = "auto" // Let the algorithm choose.
val impurity = "gini"
val maxDepth = 15
val maxBins = 84


/*
val data=joinedDocuments.map(a => LabeledPoint(a._2.get("catCostNum").asInstanceOf[Double],new DenseVector(generateArray(
    progMap(a._2.get("programme").toString).asInstanceOf[Double],
    foundMap(a._2.get("fundingScheme").toString).asInstanceOf[Double],
    countryMap(a._2.get("coordinatorCountry").toString).asInstanceOf[Double],
    a._2.get("value").asInstanceOf[BasicDBList]))))
val splits = data.randomSplit(Array(0.7, 0.3))
val (trainingData, testData) = (splits(0), splits(1))

val numClasses = 6
val categoricalFeaturesInfo = Map[Int, Int]((0,23),(1,45),(2,84))
val numTrees = 50 // Use more in practice.
val featureSubsetStrategy = "auto" // Let the algorithm choose.
val impurity = "gini"
val maxDepth = 7
val maxBins = 84
*/
val model = RandomForest.trainClassifier(trainingData, numClasses, categoricalFeaturesInfo,
  numTrees, featureSubsetStrategy, impurity, maxDepth, maxBins)

// Evaluate model on test instances and compute test error
val labelsAndPredictions = testData.map { point =>
  val prediction = model.predict(point.features)
  (point.label, prediction)
}
val testErr = labelsAndPredictions.filter(r => r._1 != r._2).count.toDouble / testData.count()
println("Test Error = " + testErr)
//println("Learned regression forest model:\n" + model.toDebugString)
labelsAndPredictions.groupBy(a=>a._1)
implicit def bool2int(b:Boolean) = if (b) 1 else 0
var results=labelsAndPredictions.map(a=>((a._1,a._2),((a._1==a._2):Int,(a._1!=a._2):Int))).reduceByKey((a,b)=>(a._1+b._1,a._2+b._2))
for (res <- results) {
    println(res)
}
model.save(sc, "randomForestClassificationModel")
exit

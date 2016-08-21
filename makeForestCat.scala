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

/* Suppression des répertoire de résultat */
def removeAll(path: String) = {
    def getRecursively(f: File): Seq[File] = 
      f.listFiles.filter(_.isDirectory).flatMap(getRecursively) ++ f.listFiles
    getRecursively(new File(path)).foreach{f => 
      if (!f.delete()) 
        throw new RuntimeException("Failed to delete " + f.getAbsolutePath)}
  }
if(new File("randomForestClassificationModel").exists())
removeAll("randomForestClassificationModel")
new File("randomForestClassificationModel").delete()

/* Chargement des données */
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

/* joindre deux BSONObject */
def mergeBSON( a:BSONObject, b:BSONObject ) : BSONObject = {
      a.putAll(b)
      return a
}

 def generateArray( country:Double, funding:Double,a:BasicDBList ) : Array[Double] = {
        var ree:Array[Double] =Array.fill[Double](a.size()+2)(0)
        
        ree(0)=country
        ree(1)=funding
        for(i <- 2 to a.size()-1){
          ree(i)=a.get(i).asInstanceOf[Double]
        }
        return ree
}   

/* On joint les deux collection */
var joinedDocuments=documents.map(a=>(a._1.toString,a._2)).join(documentsDocConcept.map(a=>(a._1.toString,a._2))).map(a => (a._1,mergeBSON(a._2._1,a._2._2)))
//joinedDocuments.map(a => (a._1,mergeBSON(a._2._1,a._2._2))).take(1).foreach(println)


/* Transformation des schémas en indicatrice */
var keys=joinedDocuments.map(a=>(a._2.get("fundingScheme"),1)).reduceByKey((a,b)=>a+b).keys.collect()
var count=0
var foundMap:Map[String,Int] = Map()
for (key <- keys) {
    foundMap += key.toString -> count
    count=count+1
}

/* Transformation des pays en indicatrice */
keys=joinedDocuments.map(a=>(a._2.get("coordinatorCountry"),1)).reduceByKey((a,b)=>a+b).keys.collect()
count=0
var countryMap:Map[String,Int] = Map()
for (key <- keys) {
    countryMap += key.toString -> count
    count=count+1
}

/* Creation des données constitué la catégorie de coûts , pays et schéma */
val data=joinedDocuments.map(a => LabeledPoint(a._2.get("catCostNum").asInstanceOf[Double],new DenseVector(generateArray(
    countryMap(a._2.get("coordinatorCountry").toString).asInstanceOf[Double],
    foundMap(a._2.get("fundingScheme").toString).asInstanceOf[Double],
    a._2.get("value").asInstanceOf[BasicDBList]))))

/* Création du jeu d'apprentissage et de validation */
val splits = data.randomSplit(Array(0.7, 0.3),7)
val (trainingData, testData) = (splits(0), splits(1))

/* Paramétrage de l'algorithme */
/* Nombre de classe */
val numClasses = 3
val categoricalFeaturesInfo = Map[Int, Int]((0,84),(1,45))
val numTrees = 100  // Use more in practice.
val featureSubsetStrategy = "auto" // Let the algorithm choose.
val impurity = "gini"
val maxDepth = 13
val maxBins = 84


val model = RandomForest.trainClassifier(trainingData, numClasses, categoricalFeaturesInfo,
  numTrees, featureSubsetStrategy, impurity, maxDepth, maxBins,7)

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

//Save for visualization
new File("model.txt").delete()
var f = new FileWriter("model.txt") 
f.write(model.toDebugString)
f.close() 

model.save(sc, "randomForestClassificationModel")
exit

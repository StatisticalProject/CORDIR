import org.apache.hadoop.conf.Configuration
import org.apache.spark.{SparkContext, SparkConf}
import org.apache.spark.rdd.RDD

import org.bson.BSONObject
import com.mongodb.hadoop.{
  MongoInputFormat, MongoOutputFormat,
  BSONFileInputFormat, BSONFileOutputFormat}
import com.mongodb.hadoop.io.MongoUpdateWritable

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


@transient val mongoConfig = new Configuration()
mongoConfig.set("mongo.input.uri",
    "mongodb://localhost:27017/cordir.project")
val documents = sc.newAPIHadoopRDD(
    mongoConfig,                // Configuration
    classOf[MongoInputFormat],  // InputFormat
    classOf[Object],            // Key type
    classOf[BSONObject])        // Value type

:type documents 
val stopWords = sc.broadcast(ParseWikipedia.loadStopWords("deps/lsa/src/main/resources/stopwords.txt")).value
var lemmatized = documents.map(s=> (s._2.get("_id").toString,ParseWikipedia.plainTextToLemmas(s._2.get("objective").toString, stopWords, ParseWikipedia.createNLPPipeline())))
val numTerms = 1000
val k = 100 // nombre de valeurs singuliers à garder
val nbConcept = 30

val filtered = lemmatized.filter(_._2.size > 1)
val documentSize=documents.collect().length
println("Documents Size : "+documentSize)
println("Number of Terms : "+numTerms)
val (termDocMatrix, termIds, docIds, idfs) = ParseWikipedia.termDocumentMatrix(filtered, stopWords, numTerms, sc)

val outputConfig = new Configuration()
outputConfig.set("mongo.output.uri","mongodb://localhost:27017/cordir.projetIdfs")
sc.parallelize(idfs.toSeq).saveAsNewAPIHadoopFile("file:///this-is-completely-unused",classOf[Object],classOf[BSONObject],classOf[MongoOutputFormat[Object, BSONObject]],outputConfig)
outputConfig.set("mongo.output.uri","mongodb://localhost:27017/cordir.projetTermDocMatrix")
termDocMatrix.zipWithIndex().map(a => (a._2,a._1.toArray)).saveAsNewAPIHadoopFile("file:///this-is-completely-unused",classOf[Object],classOf[BSONObject],classOf[MongoOutputFormat[Object, BSONObject]],outputConfig)
outputConfig.set("mongo.output.uri","mongodb://localhost:27017/cordir.projetTermIds")
sc.parallelize(termIds.toSeq).saveAsNewAPIHadoopFile("file:///this-is-completely-unused",classOf[Object],classOf[BSONObject],classOf[MongoOutputFormat[Object, BSONObject]],outputConfig)
outputConfig.set("mongo.output.uri","mongodb://localhost:27017/cordir.projetDocIds")
sc.parallelize(docIds.toSeq).saveAsNewAPIHadoopFile("file:///this-is-completely-unused",classOf[Object],classOf[BSONObject],classOf[MongoOutputFormat[Object, BSONObject]],outputConfig)

  val mat = new RowMatrix(termDocMatrix)

  val svd = mat.computeSVD(k, computeU=true)
  val topConceptTerms = RunLSA.topTermsInTopConcepts(svd, nbConcept, numTerms, termIds)
  val topConceptDocs = RunLSA.topDocsInTopConcepts(svd, nbConcept, documentSize, docIds)

  var all=sc.emptyRDD[(String,Double)]
  import collection.mutable.HashMap
  val docConcept = new HashMap[String,ListBuffer[Double]]()
  var count=0
  for ( a <- topConceptDocs) {
    count+=1
    for ( (b,c) <- a) {
      if (!docConcept.contains(b)) {
        docConcept.put(b, new ListBuffer[Double]())
      }
      docConcept(b) += c
    }
    for((k,v) <- docConcept){
      while(v.size<count){
        v+=0.0
      }
    }
  }
  //Add notes


var docConceptRDD=sc.parallelize(docConcept.toSeq)
  
var toWrite=docConceptRDD.map(a => (a._1, a._2.toArray))

val outputConfig = new Configuration()
  outputConfig.set("mongo.output.uri",
    "mongodb://localhost:27017/cordir.projetDocConcept")
toWrite.saveAsNewAPIHadoopFile(
    "file:///this-is-completely-unused",
    classOf[Object],
    classOf[BSONObject],
    classOf[MongoOutputFormat[Object, BSONObject]],
    outputConfig)

	
//make labeled point

val termConcept = new HashMap[String,ListBuffer[Double]]()
count=0
for ( a <- topConceptTerms) {
    count+=1
    for ( (b,c) <- a) {
      if (!termConcept.contains(b)) {
        termConcept.put(b, new ListBuffer[Double]())
      }
      termConcept(b) += c
    }
    for((k,v) <- termConcept){
      while(v.size<count){
        v+=0.0
      }
    }
  }
var parr=sc.parallelize(termConcept.toSeq)
val outputConfig = new Configuration()
outputConfig.set("mongo.output.uri","mongodb://localhost:27017/cordir.projetTermConcept")
parr.map(a => (a._1,a._2.toArray)).coalesce(1,true).saveAsNewAPIHadoopFile("file:///this-is-completely-unused",classOf[Object],classOf[BSONObject],classOf[MongoOutputFormat[Object, BSONObject]],outputConfig)

  

exit

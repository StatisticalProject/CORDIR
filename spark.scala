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


exit

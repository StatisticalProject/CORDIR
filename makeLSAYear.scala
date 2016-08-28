import org.apache.hadoop.conf.Configuration
import org.apache.spark. {
 SparkContext,
 SparkConf
}
import org.apache.spark.rdd.RDD

import org.bson.BSONObject
import com.mongodb.hadoop. {
 MongoInputFormat,
 MongoOutputFormat,
 BSONFileInputFormat,
 BSONFileOutputFormat
}
import com.mongodb.hadoop.io.MongoUpdateWritable
import com.mongodb.MongoClient

import java.io._
import java.util._
import com.cloudera.datascience.lsa._
import com.cloudera.datascience.lsa.ParseWikipedia._
import com.cloudera.datascience.lsa.RunLSA._
import org.apache.spark.rdd.EmptyRDD
import scala.collection.mutable.ListBuffer
import org.apache.spark.mllib.linalg._
import org.apache.spark.mllib.linalg.distributed.RowMatrix
import breeze.linalg. {
 DenseMatrix => BDenseMatrix, DenseVector => BDenseVector, SparseVector => BSparseVector
}
import org.apache.spark.mllib.regression._
import org.apache.spark.rdd._
import scala.collection.mutable.ArrayBuffer
import collection.mutable.HashMap

//Access mongodb 
var client = new MongoClient("localhost", 27017)
var db = client.getDatabase("cordis")

/* Chargement des projets */
@transient val mongoConfig = new Configuration()
mongoConfig.set("mongo.input.uri",
 "mongodb://localhost:27017/cordis.project")
val documents = sc.newAPIHadoopRDD(
  mongoConfig, // Configuration
  classOf[MongoInputFormat], // InputFormat
  classOf[Object], // Key type
  classOf[BSONObject]) // Value type

/* Chargement des stop word */
var stopWords = sc.broadcast(ParseWikipedia.loadStopWords("deps/lsa/src/main/resources/stopwords.txt")).value

//clean of tables
db.getCollection("projetDocConceptYear").drop()
db.getCollection("projetTermConceptYear").drop()

/* Boucle sur les années */
for (year <- 2006 to 2022) {
 /* Selection des projets contenant l'année */     
 var select = documents.filter(a => a._2.get("years").asInstanceOf[List[Double]].contains(year.asInstanceOf[Double]))
 println(year + ":" + select.count())
 /* si il y a des résultats, on lance le même calcul que sur le total*/    
 if (select.count() > 0) {

  /* Extraction des objectifs et transformation en lemme */
  var lemmatized = select.map(s => (s._2.get("_id").toString, ParseWikipedia.plainTextToLemmas(s._2.get("objective").toString, stopWords, ParseWikipedia.createNLPPipeline())))
  val numTerms = 1000 // Nombre de terme
  val k = 100 // nombre de valeurs singuliers à garder
  val nbConcept = 30 // Nombre de concetps
  /* On élimine les termes de moins de un caractère */
  val filtered = lemmatized.filter(_._2.size > 1)
  
  val documentSize = select.count().asInstanceOf[Int]
  println("Documents Size : " + documentSize)
  println("Number of Terms : " + numTerms)
  /* calcul de la matrice termes/documents */
  val(termDocMatrix, termIds, docIds, idfs) = ParseWikipedia.termDocumentMatrix(filtered, stopWords, numTerms, sc)

  /* Changement en matrice */
  val mat = new RowMatrix(termDocMatrix)
  /* Calcul de la Décomposition en Valeur Singulière*/
  val svd = mat.computeSVD(k, computeU = true)
  /* récupération des termes/concepts */
  val topConceptTerms = RunLSA.topTermsInTopConcepts(svd, nbConcept, numTerms, termIds)
  /* récupération des documents/concepts*/
  val topConceptDocs = RunLSA.topDocsInTopConcepts(svd, nbConcept, documentSize, docIds)

  var all = sc.emptyRDD[(String, Double)]
  /* Transformation de résultats des concepts/documents en documents/concetps*/
  val docConcept = new HashMap[String, ListBuffer[Double]]()
  var count = 0
  for (a <- topConceptDocs) {
   count += 1
   for ((b, c) <- a) {
    if (!docConcept.contains(b)) {
     docConcept.put(b, new ListBuffer[Double]())
    }
    docConcept(b) += c
   }
   for ((k, v) <- docConcept) {
    while (v.size < count) {
     v += 0.0
    }
   }
  }
  
  /* Creation d'un RDD ave ce résultat */
  var docConceptRDD = sc.parallelize(docConcept.toSeq)
  /* on ajoute l'année à l'id du document */
  var toWrite = docConceptRDD.map(a => (year.toString + ":" + a._1, a._2.toArray))
  
  /* Sauvegarde dans MongoDB */
  var outputConfig = new Configuration()
  outputConfig.set("mongo.output.uri",
   "mongodb://localhost:27017/cordis.projetDocConceptYear")
  toWrite.saveAsNewAPIHadoopFile(
   "file:///this-is-completely-unused",
   classOf[Object],
   classOf[BSONObject],
   classOf[MongoOutputFormat[Object, BSONObject]],
   outputConfig)


  /** Idem que précédemment mais pour les termes et les concepts**/

  val termConcept = new HashMap[String, ListBuffer[Double]]()
  count = 0
  for (a <- topConceptTerms) {
   count += 1
   for ((b, c) <- a) {
    if (!termConcept.contains(b)) {
     termConcept.put(b, new ListBuffer[Double]())
    }
    termConcept(b) += c
   }
   for ((k, v) <- termConcept) {
    while (v.size < count) {
     v += 0.0
    }
   }
  }
  var parr = sc.parallelize(termConcept.toSeq)
  /* Sauvegarde dans MongoDB */
  outputConfig = new Configuration()
  outputConfig.set("mongo.output.uri", "mongodb://localhost:27017/cordis.projetTermConceptYear")
  parr.map(a => (year.toString + ":" + a._1, a._2.toArray)).coalesce(1, true).saveAsNewAPIHadoopFile("file:///this-is-completely-unused", classOf[Object], classOf[BSONObject], classOf[MongoOutputFormat[Object, BSONObject]], outputConfig)
 }
}


exit
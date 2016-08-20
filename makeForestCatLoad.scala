import org.apache.hadoop.conf.Configuration
import org.apache.spark.{SparkContext, SparkConf}
import org.apache.spark.rdd.RDD
import java.io._
import org.apache.spark.ml.feature.StringIndexer
import org.apache.spark.rdd.EmptyRDD
import scala.collection.mutable.ListBuffer
import org.apache.spark.mllib.linalg._
import org.apache.spark.mllib.linalg.distributed.RowMatrix
import org.apache.spark.mllib.regression._
import org.apache.spark.rdd._
import org.apache.spark.mllib.tree.RandomForest
import org.apache.spark.mllib.tree.model.RandomForestModel
import org.apache.spark.mllib.util.MLUtils
import com.fasterxml.jackson.databind.ObjectMapper
val smodel = RandomForestModel.load(sc, "randomForestClassificationModel")

var mapper = new ObjectMapper();

//Object to JSON in file
new File("model.txt").delete()
var f = new FileWriter("model.txt") 
f.write(smodel.toDebugString)
f.close() 

exit

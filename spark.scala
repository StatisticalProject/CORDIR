import org.apache.hadoop.conf.Configuration
import org.apache.spark.{SparkContext, SparkConf}
import org.apache.spark.rdd.RDD

import org.bson.BSONObject
import com.mongodb.hadoop.{
  MongoInputFormat, MongoOutputFormat,
  BSONFileInputFormat, BSONFileOutputFormat}
import com.mongodb.hadoop.io.MongoUpdateWritable
val mongoConfig = new Configuration()
mongoConfig.set("mongo.input.uri",
    "mongodb://localhost:27017/cordir.project")
val documents = sc.newAPIHadoopRDD(
    mongoConfig,                // Configuration
    classOf[MongoInputFormat],  // InputFormat
    classOf[Object],            // Key type
    classOf[BSONObject])        // Value type

val outputConfig = new Configuration()
  outputConfig.set("mongo.output.uri",
    "mongodb://localhost:27017/output.collection")

documents.saveAsNewAPIHadoopFile(
    "file:///this-is-completely-unused",
    classOf[Object],
    classOf[BSONObject],
    classOf[MongoOutputFormat[Object, BSONObject]],
    outputConfig)
exit

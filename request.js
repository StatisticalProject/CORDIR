db.project.aggregate(
    { 
	$group : {_id : "$topics", total : { $sum : 1 },totalCost:{$sum : '$totalCost'},avgCost:{$avg : '$totalCost'},stdDevCost:{$stdDevPop : '$totalCost'} }
    }
  ,
     {
	$sort : {total : -1}
     }).forEach(function(data){
  print(data._id+","+data.total+","+data.totalCost+","+data.avgCost+","+data.stdDevCost);
});
db.project.aggregate(
    { 
	$group : {_id : "$programme"
            ,count : { $sum : 1 }
            ,totalCost:{$sum : '$totalCost'},avgTotalCost:{$avg : '$totalCost'},stdDevTotalCost:{$stdDevPop : '$totalCost'}
            ,call:{$sum : '$call'},avgCall:{$avg : '$call'},stdDevCall:{$stdDevPop : '$call'}}
    }
  ,
     {
	$sort : {count : -1}
     }
     ,{
    $lookup: {
            from: "programme",
            localField: "_id",
            foreignField: "Code",
            as: "programeDesc"
        }
},
    { $redact: {
        $cond: {
           if: 
                { $not: [ { $or:[
                    {$eq: [ "$Language", "pl" ] },
                    {$eq: [ "$Language", "en" ] },
                    {$eq: [ "$Language", "it" ] },
                    {$eq: [ "$Language", "de" ] },
                    {$eq: [ "$Language", "es" ] }
                    ]}
                ]}
           ,
           then: "$$DESCEND",
           else: "$$PRUNE"
        }
    }
    }
     )
     
     .forEach(function(data){
  print(data._id +","+data.programeDesc[0].ShortTitle+","+data.count+","+data.totalCost+","+data.avgTotalCost+","+data.stdDevTotalCost+","+data.call+","+data.avgCall
         +","+data.stdDevCall
        
         );
});

var mapTopics = function() {
                       emit({topic:this.topics,programme:this.programme},1);
                   };
                   
;
var reducetopics = function(topicId, values) {
    return Array.sum(values)
                      };                  

db.project.mapReduce(
                     mapTopics,
                     reducetopics,
                     {out : "tmpResults"}
                   );
db.tmpResults.find();
db.tmpResults.aggregate(
    { 
	$group : {_id : "$_id.topic"
            ,count : { $sum : 1 }
            }
    }
  ,
     {
	$sort : {count : -1}
     })
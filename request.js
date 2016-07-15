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

db.project.find().snapshot().forEach( function (el) {
            if(!Array.isArray(el.topics)){
el.topics = el.topics.split(',');
            }
            if(!Array.isArray(el.participants)){
el.participants = el.participants.split(',');
            }
            if(!Array.isArray(el.participantCountries)){
el.participantsCountries = el.participantCountries.split(',');
            }
            if(!Array.isArray(el.subjects)){
el.subjects = el.subjects.split(',');
            }
            if(!Array.isArray(el.field21)){
el.field21 = el.field21.split(',');
            }
            if(!Array.isArray(el.field22)){
                if(typeof(el.field22) == "number")
                {
                     el.field22="INF"
                } 
el.field22 = el.field22.split(',');
                 
            }
            
db.project.save(el);
});

db.project.aggregate(
    { 
	$group : {_id : "$topics", count : { $sum : 1 }
            ,totalCost:{$sum : '$totalCost'},avgTotalCost:{$avg : '$totalCost'},stdDevTotalCost:{$stdDevPop : '$totalCost'}
            ,call:{$sum : '$call'},avgCall:{$avg : '$call'},stdDevCall:{$stdDevPop : '$call'}} 
    }
  ,
     {
	$sort : {count : -1}
     }).forEach(function(data){
  print(data._id +","+data.count+","+data.totalCost+","+data.avgTotalCost+","+data.stdDevTotalCost+","+data.call+","+data.avgCall
         +","+data.stdDevCall
        
         );
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





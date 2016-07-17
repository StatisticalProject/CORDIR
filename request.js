/*
db.activityType.drop();
db.brief.drop();
db.country.drop();
db.fundingScheme.drop();
db.organization.drop();
db.programme.drop();
db.project.drop();
db.sicCode.drop();
db.subjects.drop();
*/

//Changement des chaines en liste
db.project.find({}).forEach(function(el) {
    if (typeof(el.totalCost) == "string") {
        el.totalCost=0;
    }
    if (typeof(el.call) == "string") {
        el.call=0;
    }
    
    if (typeof(el.ecMaxContribution) == "string") {
        el.ecMaxContribution=0;
    }
    if (!Array.isArray(el.topics)) {
        el.topics = el.topics.split(',');
    }
    
    if (!Array.isArray(el.participants)) {
        el.participants = el.participants.split(',');
    }
    if (!Array.isArray(el.participantCountries)) {
        el.participantCountries = el.participantCountries.split(',');
    }
    if (!Array.isArray(el.subjects)) {
        el.subjects = el.subjects.split(',');
    }
    
    if (!Array.isArray(el.field21)) {
        el.field21 = el.field21.split(',');
    }
    if (!Array.isArray(el.field22)) {
        if (el.field22 == null) {
            el.field22 = "OTHER"
        }
        if (typeof(el.field22) == "number") {
            el.field22 = "INF"
        }
        el.field22 = el.field22.split(',');

    }

    db.project.save(el);
});
//Liste des topics par valeur et 
var mapTopics =function() {
     var sp=this.topics;
     for(i=0;i<sp.length;i++){
         emit( sp[i], 1);
     }
};
var reduceTopics =function(top,values) {
    return Array.sum(values);
}
//nettoyage
db.topicLists.drop();
//Comptage du nombre de topics
db.project.mapReduce(mapTopics,reduceTopics
    , {
        out: "topicLists"
    }
);
db.topicLists.find().count();
db.topicLists.find().sort({value:-1}).forEach(function(data) {
    print(data._id + "," + data.value );
});
//trie des projets par cout
db.project.find({totalCost:{$gt:5000000}}).sort({totalCost:-1}).limit(30).forEach(function(data) {
    print(data.title + "," + data.totalCost + "," + data.call);
});

//Aggregation des programmes
db.programmeAgreg.drop();
db.project.aggregate([{
    $group: {
        _id: "$programme",
        count: {
            $sum: 1
        },
        totalCost: {
            $sum: '$totalCost'
        },
        avgTotalCost: {
            $avg: '$totalCost'
        },
        stdDevTotalCost: {
            $stdDevPop: '$totalCost'
        },
        minTotalCost: {
            $min: '$totalCost'
        },
        maxTotalCost: {
            $max: '$totalCost'
        },
        call: {
            $sum: '$call'
        },
        avgCall: {
            $avg: '$call'
        },
        stdDevCall: {
            $stdDevPop: '$call'
        },
        minCall: {
            $min: '$call'
        }
        ,
        maxCall: {
            $max:  '$call'  
        }
    }
}, {
    $sort: {
        count: -1
    }
}, {
    $lookup: {
        from: "programme",
        localField: "_id",
        foreignField: "Code",
        as: "programeDesc"
    }
}, {
        $unwind : "$programeDesc"
    },
    { $match : {"programeDesc.Language":"fr"} 
     }
,{$out: "programmeAgreg" }]);

db.programmeAgreg.find().limit(30).forEach(function(data) {
    print(data._id + "," + data.programeDesc.ShortTitle + "," + data.count + "," + 
    data.totalCost + "," + data.avgTotalCost + "," + data.stdDevTotalCost + "," + data.minTotalCost + "," + data.maxTotalCost + "," +
    data.call + "," + data.avgCall + "," + data.stdDevCall + "," + data.minCall + "," + data.maxCall 

    );
});

//Aggregation par pays
db.countryAgreg.drop();

db.project.aggregate([
    {
        $unwind : "$participantCountries"
    },
    {
    $group: {
        _id: "$participantCountries",
        count: {
            $sum: 1
        },
        totalCost: {
            $sum: '$totalCost'
        },
        avgTotalCost: {
            $avg: '$totalCost'
        },
        stdDevTotalCost: {
            $stdDevPop: '$totalCost'
        },
        minTotalCost: {
            $min: '$totalCost'
        },
        maxTotalCost: {
            $max: '$totalCost'
        },
        call: {
            $sum: '$call'
        },
        avgCall: {
            $avg: '$call'
        },
        stdDevCall: {
            $stdDevPop: '$call'
        },
        minCall: {
            $min: '$call'
        }
        ,
        maxCall: {
            $max:  '$call'  
        }
    }
}, {
    $sort: {
        totalCost: -1
    }
}, {
    $lookup: {
        from: "country",
        localField: "_id",
        foreignField: "isoCode",
        as: "country"
    }
},
{
        $unwind : "$country"
    },
    { $match : {"country.language":"fr"} 
     }
,{$out: "countryAgreg" }]);

db.countryAgreg.find().forEach(function(data) {
    print( data.country.name + "," + data.count + "," + 
    data.totalCost + "," + data.avgTotalCost + "," + data.stdDevTotalCost + "," + data.minTotalCost + "," + data.maxTotalCost + "," +
    data.call + "," + data.avgCall + "," + data.stdDevCall + "," + data.minCall + "," + data.maxCall 

    );
});

db.subjCodeAgreg.drop();

db.project.aggregate([
    {
        $unwind : "$field22"
    },
    {
    $group: {
        _id: "$field22",
        count: {
            $sum: 1
        },
        totalCost: {
            $sum: '$totalCost'
        },
        avgTotalCost: {
            $avg: '$totalCost'
        },
        stdDevTotalCost: {
            $stdDevPop: '$totalCost'
        },
        minTotalCost: {
            $min: '$totalCost'
        },
        maxTotalCost: {
            $max: '$totalCost'
        },
        call: {
            $sum: '$call'
        },
        avgCall: {
            $avg: '$call'
        },
        stdDevCall: {
            $stdDevPop: '$call'
        },
        minCall: {
            $min: '$call'
        }
        ,
        maxCall: {
            $max:  '$call'  
        }
    }
}, {
    $sort: {
        totalCost: -1
    }
}, {
    $lookup: {
        from: "subjects",
        localField: "_id",
        foreignField: "Code",
        as: "subjectCode"
    }
},
{
        $unwind : "$subjectCode"
    }
,{$out: "subjCodeAgreg" }]);

db.subjCodeAgreg.find().limit(30).forEach(function(data) {
    print( data._id + "," + data.subjectCode.Title + "," + data.count + "," + 
    data.totalCost + "," + data.avgTotalCost + "," + data.stdDevTotalCost + "," + data.minTotalCost + "," + data.maxTotalCost + "," +
    data.call + "," + data.avgCall + "," + data.stdDevCall + "," + data.minCall + "," + data.maxCall 

    );
});
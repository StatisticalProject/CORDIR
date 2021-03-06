//Connection 
db = connect("cordis")

//Changement des chaines en liste
print("Traitements des projets");
db.project.find({}).forEach(function(el) {
    if (typeof(el.totalCost) == "undefined"  || 0 === el.totalCost.length){
        el.totalCost=0;
    }else{
        if (typeof(el.totalCost) == "string") {
            el.totalCost=parseInt(el.totalCost);
        }
    }
    if( typeof(el.ecMaxContribution) == "undefined"  || 0 === el.ecMaxContribution.length){
        el.ecMaxContribution=0;
    }else{
        if (typeof(el.ecMaxContribution) == "string") {
            el.ecMaxContribution=parseInt(el.ecMaxContribution);
        }
    }
    if (!Array.isArray(el.topics)) {
        el.topics = el.topics.split(';');
    }
    
    if (!Array.isArray(el.participants)) {
        el.participants = el.participants.split(';');
    }
    if (!Array.isArray(el.participantCountries)) {
        el.participantCountries = el.participantCountries.split(';');
    }
    if (!Array.isArray(el.subjects)) {
        if (el.subjects == null) {
            el.subjects = "OTHER"
        }
        if (typeof(el.subjects) == "number") {
            el.subjects = "INF"
        }
        el.subjects = el.subjects.split(';');
    }
    
    
    if (!el.years||!Array.isArray(el.years)) {
        el.endDate=new Date(el.endDate);
        el.startDate=new Date(el.startDate);
        el.period=el.endDate.getFullYear()-el.startDate.getFullYear()+1;
        if(el.period>0){
            el.years=Array.apply(0, Array(el.period)).map(function (element, index) { 
                return index + el.startDate.getFullYear();  
            });
        }else{
            el.years = [el.startDate.getFullYear()];
        }
        
    }
    

    db.project.save(el);
});

//Liste des topics par valeur
print("Liste des topics par valeur");

var mapTopics =function() {
     var sp=this.topics;
     if(Array.isArray(sp)){
         for(i=0;i<sp.length;i++){
             emit( sp[i], 1);
         }
     }else{
         emit( sp, 1);
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
//Sauvegarde dans un csv
print("topics,effectif");    
db.topicLists.find().limit(30).sort({value:-1}).forEach(function(data) {
    print(data._id + "," + data.value );
});


//trie des projets par cout
print("Les projets par cout");
print("Titres,Effectif,Contribution");
db.project.find({totalCost:{$gt:5000000}}).sort({totalCost:-1}).limit(30).forEach(function(data) {
    print(data.title + "," + data.totalCost + "," + data.ecMaxContribution);
});

//Aggregation des programmes
print("Aggregation des programmes");
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
        ecMaxContribution: {
            $sum: '$ecMaxContribution'
        },
        avgEcMaxContribution: {
            $avg: '$ecMaxContribution'
        },
        stdDevEcMaxContribution: {
            $stdDevPop: '$ecMaxContribution'
        },
        minEcMaxContribution: {
            $min: '$ecMaxContribution'
        }
        ,
        maxEcMaxContribution: {
            $max:  '$ecMaxContribution'  
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


print("Les Programmes");
print("Code,Titre,Effectif,CoutTotal,TotalMoyen,TotalEcartType,TotalMin,TotalMax,ContributionTotal,ContributionMoyenne,ContributionEcartType,ContributionMin,ContributionMax");
db.programmeAgreg.find().forEach(function(data) {
    print(data._id + "," + data.programeDesc.ShortTitle + "," + data.count + "," + 
    data.totalCost + "," + data.avgTotalCost + "," + data.stdDevTotalCost + "," + data.minTotalCost + "," + data.maxTotalCost + "," +
    data.ecMaxContribution + "," + data.avgEcMaxContribution + "," + data.stdDevEcMaxContribution + "," + data.minEcMaxContribution + "," + data.maxEcMaxContribution 

    );
});

print("Aggregation des programmes par annee");
db.programmeDateAgreg.drop();
db.project.aggregate([
    {
        $unwind : "$years"
    },{
    
    $group: {
        _id: {programme:"$programme",year:"$years"},
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
        ecMaxContribution: {
            $sum: '$ecMaxContribution'
        },
        avgEcMaxContribution: {
            $avg: '$ecMaxContribution'
        },
        stdDevEcMaxContribution: {
            $stdDevPop: '$ecMaxContribution'
        },
        minEcMaxContribution: {
            $min: '$ecMaxContribution'
        }
        ,
        maxEcMaxContribution: {
            $max:  '$ecMaxContribution'  
        }
    }
}, {
    $sort: {
        count: -1
    }
}, {
    $lookup: {
        from: "programme",
        localField: "_id.programme",
        foreignField: "Code",
        as: "programeDesc"
    }
}, {
        $unwind : "$programeDesc"
    },
    { $match : {"programeDesc.Language":"fr"} 
     }
,{$out: "programmeDateAgreg" }]);


print("Les Programmes");
print("Annee,Code,Titre,Effectif,CoutTotal,TotalMoyen,TotalEcartType,TotalMin,TotalMax,ContributionTotal,ContributionMoyenne,ContributionEcartType,ContributionMin,ContributionMax");
db.programmeDateAgreg.find().forEach(function(data) {
    print(data._id.year + "," +data._id.programme + ",\"" + data.programeDesc.ShortTitle.replace('"', "'").replace('"', "'") + "\"," + data.count + "," + 
    data.totalCost + "," + data.avgTotalCost + "," + data.stdDevTotalCost + "," + data.minTotalCost + "," + data.maxTotalCost + "," +
    data.ecMaxContribution + "," + data.avgEcMaxContribution + "," + data.stdDevEcMaxContribution + "," + data.minEcMaxContribution + "," + data.maxEcMaxContribution 

    );
});

//Aggregation par pays participants
print("Aggregation par pays participants");

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
        ecMaxContribution: {
            $sum: '$ecMaxContribution'
        },
        avgEcMaxContribution: {
            $avg: '$ecMaxContribution'
        },
        stdDevEcMaxContribution: {
            $stdDevPop: '$ecMaxContribution'
        },
        minEcMaxContribution: {
            $min: '$ecMaxContribution'
        }
        ,
        maxEcMaxContribution: {
            $max:  '$ecMaxContribution'  
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
}, {
    $lookup: {
        from: "country",
        localField: "_id",
        foreignField: "?euCode",
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
    data.ecMaxContribution + "," + data.avgEcMaxContribution + "," + data.stdDevEcMaxContribution + "," + data.minEcMaxContribution + "," + data.maxEcMaxContribution 

    );
});

//Aggregation par pays participants
print("Aggregation par pays coordinateurs");

db.countryCoorAgreg.drop();

db.project.aggregate([
    {
    $group: {
        _id: "$coordinatorCountry",
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
        ecMaxContribution: {
            $sum: '$ecMaxContribution'
        },
        avgEcMaxContribution: {
            $avg: '$ecMaxContribution'
        },
        stdDevEcMaxContribution: {
            $stdDevPop: '$ecMaxContribution'
        },
        minEcMaxContribution: {
            $min: '$ecMaxContribution'
        }
        ,
        maxEcMaxContribution: {
            $max:  '$ecMaxContribution'  
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
}, {
    $lookup: {
        from: "country",
        localField: "_id",
        foreignField: "?euCode",
        as: "country"
    }
},
{
        $unwind : "$country"
    },
    { $match : {"country.language":"fr"} 
     }
,{$out: "countryCoorAgreg" }]);

db.countryCoorAgreg.find().forEach(function(data) {
    print( data.country.name + "," + data.count + "," + 
    data.totalCost + "," + data.avgTotalCost + "," + data.stdDevTotalCost + "," + data.minTotalCost + "," + data.maxTotalCost + "," +
    data.ecMaxContribution + "," + data.avgEcMaxContribution + "," + data.stdDevEcMaxContribution + "," + data.minEcMaxContribution + "," + data.maxEcMaxContribution 

    );
});

//Etude par sujet

print("Etude par sujet");
db.subjCodeAgreg.drop();
db.project.aggregate([
    {
        $unwind : "$subjects"
    },
    {
    $group: {
        _id: "$subjects",
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
        ecMaxContribution: {
            $sum: '$ecMaxContribution'
        },
        avgEcMaxContribution: {
            $avg: '$ecMaxContribution'
        },
        stdDevEcMaxContribution: {
            $stdDevPop: '$ecMaxContribution'
        },
        minEcMaxContribution: {
            $min: '$ecMaxContribution'
        }
        ,
        maxEcMaxContribution: {
            $max:  '$ecMaxContribution'  
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

db.subjCodeAgreg.find().forEach(function(data) {
    print( data._id + "," + data.subjectCode.Title + ","+ data.count + "," + 
    data.totalCost + "," + data.avgTotalCost + "," + data.stdDevTotalCost + "," + data.minTotalCost + "," + data.maxTotalCost + "," +
    data.ecMaxContribution + "," + data.avgEcMaxContribution + "," + data.stdDevEcMaxContribution + "," + data.minEcMaxContribution + "," + data.maxEcMaxContribution 

    );
});
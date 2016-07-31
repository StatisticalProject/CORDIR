//Connection 
db = connect("cordir")

var max=db.project.find().sort({totalCost:-1}).limit(1) // for MAX
var min=db.project.find().sort({totalCost:+1}).limit(1) // for MIN

//Aggregation des programmes
print("Aggregation des programmes");
db.project.aggregate([{
    $group: {
        _id: null,
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
}]);
var maxVal=280086352.0;
db.eval(function() { 
db.project.find({}).forEach(function(el) {
    var maxVal=2308257.14168001+4721538.09920443;
    var count=100;
    for (var i = 0; i < count; i++) {
        j=i+1;
        if(el.totalCost<j*maxVal/count){
            el.totalCostFlag=parseInt(i*maxVal/count)+"-"+parseInt(j*maxVal/count);
            el.totalCostFlagMean=0.5*(j+i)*maxVal/count;
            el.totalCostFlagInt=i;
            db.project.save(el);
            return;
        }
    }
    el.totalCostFlag=">"+parseInt(j*maxVal/count)
    el.totalCostFlagInt=count;
    el.totalCostFlagMean=(280086352+maxVal)*0.5;
    db.project.save(el);
            
})
 });
db.totalCostAgreg.drop(); 
db.project.aggregate([{
    $group: {
        _id: {
            "totalCostFlag": "$totalCostFlag",
            "totalCostFlagMean": "$totalCostFlagMean",
            "totalCostFlagInt": "$totalCostFlagInt"
        },
        count: {
            $sum: 1
        }
    }
}, {
    $sort: {
        count: -1
    }
},{$out: "totalCostAgreg" }]);
db.totalCostAgreg.find().forEach(function(data) {
    print(data._id.totalCostFlag + "," + data._id.totalCostFlagMean +"," + data._id.totalCostFlagInt + "," + data.count );
});        

db.project.find().sort({totalcost:1}).skip(25607/4).limit(1)
db.project.find().sort({totalcost:1}).skip(2*25607/4).limit(1)
db.project.find().sort({totalcost:1}).skip(3*25607/4).limit(1)


db.project.createIndex( { totalcost: 1 } )

db.eval(function() { 
db.project.find({}).forEach(function(el) {
    if(el.totalCost<500000){
       el.catCost="<500k"
       el.catCostNum=0 
    }else
    if(el.totalCost<2800000){
       el.catCost="500k-2800k"
       el.catCostNum=1 
    }else
    if(el.totalCost<8000000){
       el.catCost="2800k-8M"
       el.catCostNum=2 
    }else{
       el.catCost=">8M"
       el.catCostNum=3 
    }
    db.project.save(el);
            
})
 });
 
db.project.aggregate([{
    $group: {
        _id: "$catCost",
        count: {
            $sum: 1
        }
    }
}, {
    $sort: {
        count: -1
    }
}]);
 
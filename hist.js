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
        count: -1
    }
}]);
var maxVal=280086352.0;
db.eval(function() { 
db.project.find({}).forEach(function(el) {
    var maxVal=2308257.14168001+2*4721538.09920443;
    var count=100;
    for (var i = 0; i < count; i++) {
        j=i+1;
        if(el.totalCost<j*maxVal/count){
            el.totalCostFlag=parseInt(i*maxVal/count)+"-"+parseInt(j*maxVal/count);
            el.totalCostFlagInt=i;
            db.project.save(el);
            return;
        }
    }
    el.totalCostFlag=">"+parseInt(j*maxVal/count)
    el.totalCostFlagInt=count;
    db.project.save(el);
            
})
 });
db.project.aggregate([{
    $group: {
        _id: ["$totalCostFlag","$totalCostFlagInt"],
        count: {
            $sum: 1
        }
    }
}, {
    $sort: {
        count: -1
    }
}]);
        
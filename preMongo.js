db = connect("cordis")

//Changement des chaines en liste
print("Traitements des projets");
db.project.find().snapshot().forEach(function(el) { 
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
        if (typeof(el.subjects) == "number") { 
            el.subjects = "INF" 
        } 
        el.subjects = el.subjects.split(','); 
    }
    if (typeof(el.totalCost) != "number") { 
            el.totalCost = parseFloat(el.totalCost) 
    }
    if (typeof(el.ecMaxContribution) != "number") { 
            el.ecMaxContribution = parseFloat(el.ecMaxContribution)
    }
    el.catCostNum=0;
    //On creer des classes de cout pour la modelisation
    if(el.totalCost<400000){
       el.catCost="<400k"
       el.catCostNum=0 
    }else
    if(el.totalCost<3000000){
       el.catCost="400k-3000k"
       el.catCostNum=1 
    }else
    if(el.totalCost>=3000000){
       el.catCost=">3000k"
       el.catCostNum=2 
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

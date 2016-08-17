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
        el.subjects = el.subjects.split(','); 
    } 
    if (!Array.isArray(el.field21)) { 
        el.field21 = el.field21.split(','); 
    } 
    if (!Array.isArray(el.field22)) { 
        if (typeof(el.field22) == "number") { 
            el.field22 = "INF" 
        } 
        el.field22 = el.field22.split(','); 
    } 
    //On creer des classes de cout pour la modelisation
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
}); 

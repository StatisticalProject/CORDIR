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
    //On creer des classes de cout pour la modelisation
    if(el.totalCost<193000){
       el.catCost="<193k"
       el.catCostNum=0 
    }else
    if(el.totalCost<1243000){
       el.catCost="193k-1243k"
       el.catCostNum=1 
    }else
    if(el.totalCost<2942000){
       el.catCost="1243k-2942k"
       el.catCostNum=2 
    }else{
       el.catCost=">2942k"
       el.catCostNum=3 
    }
    db.project.save(el); 
}); 

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
    //On creer des classes de cout
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
}); 

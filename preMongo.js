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
    db.project.save(el); 
}); 

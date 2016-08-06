mongoexport --db cordir --collection topicLists --fields _id,value --type=csv --out topicLists.csv
mongoexport --db cordir --collection programmeAgreg --fields _id,count,totalCost,avgTotalCost,stdDevTotalCost,minTotalCost,maxTotalCost,ecMaxContribution,avgEcMaxContribution,stdDevEcMaxContribution,minEcMaxContribution,maxEcMaxContribution,programeDesc.RCN,programeDesc.Code,programeDesc.Title,programeDesc.ShortTitle --type=csv --out programmeAgreg.csv
mongoexport --db cordir --collection programmeDateAgreg --fields _id.programme,_id.year,count,totalCost,avgTotalCost,stdDevTotalCost,minTotalCost,maxTotalCost,ecMaxContribution,avgEcMaxContribution,stdDevEcMaxContribution,minEcMaxContribution,maxEcMaxContribution,programeDesc.RCN,programeDesc.Code,programeDesc.Title,programeDesc.ShortTitle --type=csv --out programmeDateAgreg.csv
mongoexport --db cordir --collection countryAgreg --fields _id,count,totalCost,avgTotalCost,stdDevTotalCost,minTotalCost,maxTotalCost,ecMaxContribution,avgEcMaxContribution,stdDevEcMaxContribution,minEcMaxContribution,maxEcMaxContribution,country.euCode,country.isoCode,country.name --type=csv --out countryAgreg.csv
mongoexport --db cordir --collection countryCoorAgreg --fields _id,count,totalCost,avgTotalCost,stdDevTotalCost,minTotalCost,maxTotalCost,ecMaxContribution,avgEcMaxContribution,stdDevEcMaxContribution,minEcMaxContribution,maxEcMaxContribution,country.euCode,country.isoCode,country.name --type=csv --out countryCoorAgreg.csv
mongoexport --db cordir --collection subjCodeAgreg --fields _id,count,totalCost,avgTotalCost,stdDevTotalCost,minTotalCost,maxTotalCost,ecMaxContribution,avgEcMaxContribution,stdDevEcMaxContribution,minEcMaxContribution,maxEcMaxContribution,subjectCode.Group,subjectCode.Code,subjectCode.Title --type=csv --out subjCodeAgreg.csv

mongoexport --db cordir --collection projetTermConceptYear --fields _id,value --type=csv --out projetTermConceptYear.csv

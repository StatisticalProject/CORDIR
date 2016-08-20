mongo clean.sh
./import.sh
mongo preMongo.js
./sparkLaunch.sh makeLSA.scala
./sparkLaunch.sh makeLSAYear.scala

mongoexport --db cordis --collection projetTermConceptYear --fields _id,value --type=csv --out projetTermConceptYear.csv
mongoexport --db cordis --collection projetTermConcept --fields _id,value --type=csv --out projetTermConcept.csv


./sparkLaunch.sh makeForestCat.scala
./sparkLaunch.sh makeForestCatLoad.scala
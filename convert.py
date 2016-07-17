# mongoimport --db cordir --collection project --file "data/cordis-fp7projects.csv" --type csv --headerline
# mongoimport --db cordir --collection organization --file "data/cordis-fp7organizations.csv" --type csv --headerline
# mongoimport --db cordir --collection brief --file "data/cordis-fp7briefs.csv" --type csv --headerline
# mongoimport --db cordir --collection country --file "data/cordisref-countries.csv" --type csv --headerline
# mongoimport --db cordir --collection fundingScheme --file "data/cordisref-projectFundingSchemeCategory.csv" --type csv --headerline
# mongoimport --db cordir --collection activityType --file "data/cordisref-organizationActivityType.csv" --type csv --headerline
# mongoimport --db cordir --collection programme --file "data/cordisref-FP7programmes.csv" --type csv --headerline
# mongoimport --db cordir --collection sicCode --file "data/cordisref-sicCode.csv" --type csv --headerline
# mongoimport --db cordir --collection subjects --file "data/subjects.csv" --type csv --headerline

import csv
def convertCSV( str ):
    with open(str+".mongo", 'wb') as csvfileW:
        writer = csv.writer(csvfileW, delimiter=',')
        with open(str, 'rb') as csvfileR:
            reader = csv.reader(csvfileR, delimiter=';')
            for row in reader:
                 writer.writerow(row)    

convertCSV("data/cordis-fp7briefs.csv")
convertCSV("data/cordis-fp7projects.csv")
convertCSV("data/cordis-fp7organizations.csv")
convertCSV("data/cordis-fp7briefs.csv")
convertCSV("data/cordisref-countries.csv")
convertCSV("data/cordisref-projectFundingSchemeCategory.csv")
convertCSV("data/cordisref-organizationActivityType.csv")
convertCSV("data/cordisref-FP7programmes.csv")
convertCSV("data/cordisref-sicCode.csv")

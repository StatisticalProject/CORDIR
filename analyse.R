library(ggplot2)
#Chargement des données
projects <- read.csv(file="data/cordis-fp7projects.csv.mongo", header=TRUE, sep=",")
#Transformation et conversion 
projects$totalCost=gsub(",", ".", projects$totalCost)
projects$totalCost=as.double(projects$totalCost)
projects$ecMaxContribution=gsub(",", ".", projects$ecMaxContribution)
projects$ecMaxContribution=as.double(projects$ecMaxContribution)
projects$ratioContribTotal=projects$ecMaxContribution/projects$totalCost
projects$startDate=as.Date(projects$startDate)
projects$endDate=as.Date(projects$endDate)

#Analyse univarié

#Analyse des couts
par(mfrow=c(1,3))
summary(projects$totalCost)
boxplot(projects$totalCost)
title("Cout total")
summary(projects$ecMaxContribution)
boxplot(projects$ecMaxContribution)
title("Maximum contribution")
summary(projects$ratioContribTotal)
boxplot(projects$ratioContribTotal)
title("Ratio contribution / cout total")
par(mfrow=c(1,1),cex=0.5)


#analyse des programmes
g <- ggplot(projects, aes(projects$programme))
# Number of cars in each class:
g + geom_bar()+xlab("")+ylab("Effectif")  +theme(axis.text.x=element_text(angle=20, hjust=1))

#analyse des pays

country<-as.data.frame(sort(table(projects$coordinatorCountry),decreasing=TRUE))
country<-country[country$Freq>50,]

  plot(country)
  g <- ggplot(data=country, aes(x=country$Var1,y=country$Freq))
  # Number of cars in each class:
  g + geom_bar(stat="identity")+xlab("")+ylab("Effectif")  +theme(axis.text.x=element_text(angle=20, hjust=1))

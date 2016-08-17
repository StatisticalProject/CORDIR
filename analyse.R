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

  g <- ggplot(data=country, aes(x=country$Var1,y=country$Freq))
  # Number of cars in each class:
  g + geom_bar(stat="identity")+xlab("")+ylab("Effectif")  +theme(axis.text.x=element_text(angle=20, hjust=1))

#Analyse des status
g <- ggplot(projects, aes(projects$status))
# Number of cars in each class:
g + geom_bar()+xlab("")+ylab("Effectif")  +theme(axis.text.x=element_text(angle=20, hjust=1))
  
  
#Analyse des topics
topics<-as.data.frame(sort(table(projects$topics),decreasing=TRUE))
topics<-topics[topics$Freq>180,]
g <- ggplot(data=topics, aes(x=topics$Var1,y=topics$Freq))
g + geom_bar(stat="identity")+xlab("")+ylab("Effectif")  +theme(axis.text.x=element_text(angle=20, hjust=1))

#Analyse des funding scheme
fundingScheme<-as.data.frame(sort(table(projects$fundingScheme),decreasing=TRUE))
fundingScheme<-foundingScheme[foundingScheme$Freq>180,]
g <- ggplot(data=fundingScheme, aes(x=fundingScheme$Var1,y=fundingScheme$Freq))
g + geom_bar(stat="identity")+xlab("")+ylab("Effectif")  +theme(axis.text.x=element_text(angle=20, hjust=1))

#Analyse des sujets
subject<-as.data.frame(sort(table(projects$subjects),decreasing=TRUE))
subject<-subject[subject$Freq>180,]
g <- ggplot(data=subject, aes(x=subject$Var1,y=subject$Freq))
g + geom_bar(stat="identity")+xlab("")+ylab("Effectif")  +theme(axis.text.x=element_text(angle=20, hjust=1))

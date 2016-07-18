programmeDateAgreg <- read.csv("programmeDateAgreg.csv")
programmeDateAgreg<-programmeDateAgreg[order(programmeDateAgreg$X_id.programme, programmeDateAgreg$X_id.year),]
programmes<-programmeDateAgreg$X_id.programme
png("programmeDateAgregTotal.png",width = 800,height = 600)
plot(0, 0, xlim = c(2006,2021), ylim = range(programmeDateAgreg$totalCost/1000000), type = "n", col=programmes)
legend(2006,7500,unique(programmes),col=1:length(programmes),pch=1)
cole<-1
for(prog in levels(programmeDateAgreg$X_id.programme)){
  data<-programmeDateAgreg[programmeDateAgreg$X_id.programme==prog,]
  lines(data$totalCost/1000000 ~ data$X_id.year,title=prog,col=cole)
  cole<-cole+1
}
dev.off()
png("programmeDateAgregNbProject.png",width = 800,height = 600)
plot(0, 0, xlim = c(2006,2021), ylim = range(programmeDateAgreg$count), type = "n", col=programmes)
legend(2006,6500,unique(programmes),col=1:length(programmes),pch=1)
cole<-1
for(prog in levels(programmeDateAgreg$X_id.programme)){
  data<-programmeDateAgreg[programmeDateAgreg$X_id.programme==prog,]
  lines(data$count ~ data$X_id.year,title=prog,col=cole)
  cole<-cole+1
}
dev.off()

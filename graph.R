programmeDateAgreg <- read.csv("programmeDateAgreg.csv")
programmeDateAgreg<-programmeDateAgreg[order(programmeDateAgreg$totalCost,programmeDateAgreg$X_id.programme, programmeDateAgreg$X_id.year),]
programmes<-programmeDateAgreg$X_id.programme
png("programmeDateAgreg.png",width = 1200,height = 1000)
plot(0, 0, xlim = c(2006,2021), ylim = range(programmeDateAgreg$totalCost), type = "n", col=programmes)
legend(2006,6500000000,unique(programmes),col=1:length(programmes),pch=1)
cole<-1
for(prog in levels(programmeDateAgreg$X_id.programme)){
  data<-programmeDateAgreg[programmeDateAgreg$X_id.programme==prog,]
  lines(data$totalCost ~ data$X_id.year,title=prog,col=cole)
  cole<-cole+1
}
dev.off()

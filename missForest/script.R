rawdat <- read.csv('missForest/temp_in.csv', header=TRUE)
#rawdat <- fread('missForest/temp_in.csv') # Use fread to speedup for large files

# Run the missForest method
library(missForest)

rawdat <- as.data.frame(rawdat)
xAttr <- colnames(rawdat)

for (t.co in 1:length(xAttr)){
  if (is.na(pmatch('disc',xAttr[t.co]))){
    rawdat[,t.co] <- as.numeric(rawdat[,t.co])
  } else {
    nVal <- max(rawdat[,t.co], na.rm=TRUE)
    rawdat[,t.co] <- factor(rawdat[,t.co], levels=1:nVal, exclude=NaN)
  }
}

set.seed(81)
rawdat.imp <- missForest(rawdat)
rawdat.imp <- rawdat.imp$ximp
rawdat.imp <- lapply(rawdat.imp,as.numeric)
write.csv(rawdat.imp, 'missForest/temp_out.csv')

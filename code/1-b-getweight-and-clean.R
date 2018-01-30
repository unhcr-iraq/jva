#weight$meta.instanceID <- weight$KEY## Load SPSS file in order to get the weight
library(haven)
spssfile <- read_sav("data/Merged Dataset 07-09-2017_shared.sav")
#names(spssfile)
#str(spssfile)

## Load data from ODK
source("code/0-config.R")
data.weight <- read.csv("data/household.csv", sep=",", encoding="UTF-8", na.strings="")
#names(data.or)

## Checking unique ID in the 2 dataframe
#nrow(as.data.frame(unique(data.or$meta.instanceID)))
#nrow(as.data.frame(unique(spssfile$KEY)))

## saving formkey to keep together with the weighting

weight <- unique(spssfile[ ,c("KEY", "weights",  "Cluster")])


## Cf https://rpubs.com/trjohns/survey-cluster
## calculate fpc i.e the number of clusters that should be used to build the survey object
fpc <- nrow(as.data.frame(unique(weight$Cluster)))
weight$fpc <- fpc

write.csv(weight, "data/weight.csv", row.names = FALSE)
# names(household)

household <- merge(x = household, y = weight, by = "KEY")

## Save another version in order to add indicators
write.csv(household,"data/data2.csv")

library(survey)
## Survey design follows one-stage modality due to sampling with population proportional to size in the first stage
household.survey <- svydesign(ids = ~ Cluster ,  data = household ,  weights = ~ weights ,  fpc = ~fpc )

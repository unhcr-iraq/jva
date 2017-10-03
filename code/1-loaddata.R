rm(list = ls())


################################################################
## Load all required packages
source("code/0-packages.R")
#source("code/0-config.R")

### Double Check that you have the last version
#source("https://raw.githubusercontent.com/Edouard-Legoupil/koboloadeR/master/inst/script/install_github.R")
#install.packages("devtools")
#library("devtools")
#install_github("Edouard-Legoupil/koboloadeR")

library(koboloadeR)

## kobo_projectinit()

############################################################
#                                                          #
#   Position your form & your data in the data folder
#                                                          #
############################################################

##############################################
## Load form
#rm(form)
form <- "form.xls"
## Generate & Load dictionnary
kobo_dico(form)
dico <- read.csv(paste("data/dico_",form,".csv",sep = ""), encoding = "UTF-8", na.strings = "")
#rm(form)


#################################################################################
##### Re-encode correctly the dataset

#rm(data)

## Might need to be tweaked -- double check
#data.or <- read.csv(path.to.data, sep=",", encoding="UTF-8", na.strings="")

#names(data.or)
### Need to replace slash by point in the variable name
## get variable name from data
#datalabel <- as.data.frame( names(data.or))
#names(datalabel)[1] <- "nameor"
#datalabel$nameor <- as.character(datalabel$nameor)

## new variables name without /
#datalabel$namenew <- str_replace_all(datalabel$nameor, "/", ".")
## let's recode the variable of the dataset using short label - column 3 of my reviewed labels
#names(data.or) <- datalabel[, 2]


#################################################################################################################################
## Load all frames
#################################################################################################################################
library(readr)
household <- read_csv("data/SyrianVA2017_25072017.csv")
reg_question <- read_csv("data/SyrianVA2017_25072017_demo_reg_question.csv")
individual_registered <- read_csv("data/SyrianVA2017_25072017_individual_registered.csv")
difficulties_encountered <- read_csv("data/SyrianVA2017_25072017_critical_info_hh_difficulties_encountered.csv")

##################################################################
###### Restore links between frame
## household - demo_reg_question
## household - individual_registered
## household - critical_info_hh_difficulties_encountered




#################################################################################################################################
## Household
## fEW CHECK
#names(household)
#table(household$case_reachable-reachable)
# nrow(as.data.frame(unique(household$meta-instanceID)))
# nrow(as.data.frame(unique(household$KEY)))

cat("\n\nCheck Household\n")
household <- household
datalabel <- as.data.frame( names(household))
names(datalabel)[1] <- "nameor"
datalabel$nameor <- as.character(datalabel$nameor)
datalabel$namenew <- str_replace_all(datalabel$nameor, "-", ".")
names(household) <- datalabel[, 2]

## Remove rows for "not reachable"
#table(household[ ,8])
#str(household)
#names(household)

###################################################################################
##### Adding weight and removing some forms
cat("\n\n\n Adding weight and removing some forms \n\n\n\n")
weight <- read_csv("data/weight.csv")

household <- right_join(x = household, y = weight, by = "KEY")

#################################################################################################################################
## Case

cat("\n\nCheck cases\n")
reg_question <- reg_question
datalabel <- as.data.frame( names(reg_question))
names(datalabel)[1] <- "nameor"
datalabel$nameor <- as.character(datalabel$nameor)
datalabel$namenew <- str_replace_all(datalabel$nameor, "-", ".")
datalabel$namenew<- paste("section2.reg_question.", datalabel$namenew, sep="")
names(reg_question) <- datalabel[, 2]

## merge
#names(reg_question)
#levels(as.factor(household$SET.OF.section2.reg_question))
reg_question$SET.OF.demo.reg_question <- reg_question$section2.reg_question.SET.OF.reg_question
reg_question <- join(y= household, x= reg_question, by="SET.OF.demo.reg_question", type="right")

#################################################################################################################################
## Bio Data
# names(individual_registered)
cat("\n\nCheck individuals\n")
individual_registered <- individual_registered
datalabel <- as.data.frame( names(individual_registered))
names(datalabel)[1] <- "nameor"
datalabel$nameor <- as.character(datalabel$nameor)
datalabel$namenew <- str_replace_all(datalabel$nameor, "-", ".")
names(individual_registered) <- datalabel[, 2]


#names(individual_registered)
individual_registered <- join(y= household, x= individual_registered, by="SET.OF.individual_registered", type="right")
#names(individual_registered)

#################################################################################################################################
##
cat("\n\nCheck difficulties\n")

difficulties_encountered <- difficulties_encountered
datalabel <- as.data.frame( names(difficulties_encountered))
names(datalabel)[1] <- "nameor"
#str(datalabel$nameor)
#levels(datalabel$nameor)
datalabel$nameor <- as.character(datalabel$nameor)
datalabel$namenew <- str_replace_all(datalabel$nameor, "-", ".")
names(difficulties_encountered) <- datalabel[, 2]
#names(difficulties_encountered)
difficulties_encountered$SET.OF.critical_info_hh.difficulties_encountered <- difficulties_encountered$SET.OF.difficulties_encountered
difficulties_encountered <- join(y= household, x= difficulties_encountered, by="SET.OF.critical_info_hh.difficulties_encountered", type="right")





###################################################################################
##### Re-encode correctly the dataset
cat("\n\n\nNow re-encode data and label variables \n\n\n\n")


cat("\n\n\n Household \n\n\n\n")
# household1 <- kobo_split_multiple(household, dico)
household <- kobo_split_multiple(household, dico)
household <- kobo_encode(household, dico)
household <- kobo_label(household , dico)


cat("\n\n\n Individuals \n\n\n\n")
individual_registered <- kobo_split_multiple(individual_registered, dico)
individual_registered <- kobo_encode(individual_registered, dico)
individual_registered <- kobo_label(individual_registered , dico)


cat("\n\n\n Case \n\n\n\n")
reg_question <- kobo_split_multiple(reg_question, dico)
reg_question <- kobo_encode(reg_question, dico)
reg_question <- kobo_label(reg_question , dico)


cat("\n\nWrite backup\n")

write.csv(household, "data/household1.csv", row.names = FALSE)
write.csv(individual_registered, "data/individual_registered1.csv", row.names = FALSE)
write.csv(reg_question , "data/reg_question1.csv", row.names = FALSE)
write.csv(difficulties_encountered, "data/difficulties_encountered1.csv", row.names = FALSE)




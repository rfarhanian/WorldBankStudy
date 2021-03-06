################
# Makefile
# Ramin Farhanian
# Updated 13 July 2017
################

## Introduction to World Bank Study

##Setting working directory
cat("Changing working directory.\nCurrent working directory: ", getwd(), "\n")
setwd("/Users/raminfarhanian/projects/R/WorldBankStudy")
cat("working directory is changed to: ", getwd(), "\n")

## Libraries required

installLibrariesOnDemand <- function (packages)
{
  cat("Installing required libraries on demand:", packages , "\n")
  new.packages <- packages[!(packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  cat("Missing libraries installation is complete.", "\n")
}
installLibrariesOnDemand(c("repmis", "RCurl", "tidyr", "ggplot2"))

## Part 1: Introduction to the problem
## World bank has released the information about 190 countries in two files. The first file contains the data of Gross Domestic Product data for the 190 ranked countries 
## (https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv). It has 
## information about the countries with their short names, ranking, and Gross Domestic Product(https://en.wikipedia.org/wiki/Gross_domestic_product). 
## We also have additional detail data of these countries(coming from https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FEDSTATS_Country.csv). It consists  
## of name of the countries, the income group, regional information, currency, latest population census, latest household survery, source of most recent income and expenditure data,
## IMF data dissemination standard, latest trade data, latest water withdrawal data. These two files can help us find answers for the following questions.

##Questions
## 1- If we merge the country information by countryCode, how much additional detailed data do we have for 190 countries? 
## 2-Which country has the lowest 13th ranking? 
## 3-What are the average GDP rankings for the High income: OECD and High income nonOECD groups?
#  4-What does the plot of the GDP for all of the countries look like if you use ggplot2 to color your plot by Income Group.
#  5-If you cut the GDP ranking into 5 separate quantile groups, and make a table versus Income.Group, how many countries are Lower middle income but among the 38 nations with highest GDP?


## Part 2: Downloading required files
## Part 2-1: Downloading FGDP file
cat("Downloading GDP file:", "\n")
source("DownloadGdpFile.R")
cat("GDP File is downloaded successfully.", "\n")

## Part 2-2: Downloading Detail data file
cat("Downloading Detailed data file:", "\n")
source("DownloadDetailFile.R")
cat("Detail data file is downloaded successfully.", "\n")


# Part 3: Reading and cleaning the data
# After doing an initial review, I figured that some clean ups have to be made before merging process. 
#GDP data
# The first few lines are empty and contain invalid data.
# The header data is not correct and must be cleaned up.
# Empty and invalid lines should be skipped.
# GDP values in some lines should be trimmed.
# Invalid lines are in six categories:
# 1-Lines missing Gross Domestic Product value(line 197 to 220 in the original file).
# 2-Some lines are empty (line 1, 2, 3, 4, 196, 221, 223, 237)
# 3-Some lines comprise information about a region and not a country
# 4-The GDP value of many lines should be trimmed.
# 5-Some lines have an additonal invalid column (lines 67, 78, 100, 102, 119, 146)
# 6-Line 104 country information(Ivory Coast) is in French, and later I might need to replace it. But for now, I read the file in UTF-8 to avoid Internationalization issues.
# The data can be cleansed by changing header values, and removing lines with empty rankings, country code along with invalid columns.
# The ranking data should be transformed into Numeric to trim the empty spaces around some ranking values.
source("CleanGdpData.R")

# Detail data file
# Detail data file contains invalid detail information that should be cleansed. The invalid lines are in two categories: 
# 1-The lines that contain regional information. 
# Lines 55(East Asia & Pacific) to 58("Europe & Central Asia"), 113(Latin America & Caribbean), 
# 119(Latin America & Caribbean (all income levels)),  136(middle east), 139(Middle Income), 144(Middle East and North Africa), 153(North America), 
# 182(South Asia), 193-194(Sub-Saharan Africa), 228(world)
# 2-The lines that have income groups as country short names.
# Line 85(High income), 88(Heavily indebted poor countries)  
# 120(Least developed countries: UN classification), 121(Low income), 124(Lower middle income), 125(Low & middle income), 160(High income: nonOECD),
# 164(High income: OECD), 218(Upper middle income)
# They can be cleanse using "Income.Group" as invalid countries have no value for income group.
source("CleanDetailData.R")

# Part 4: Merging the data by country short code
# If we merge the country information by countryCode, how much additional detailed data do we have for 190 countries? 
mergeResult<-merge(gdpData,detailData, by="CountryCode")
firstAnswer<-NROW(mergeResult)
cat("Question 1: If we merge the country information by countryCode, how much additional detailed data do we have for 190 countries?" , firstAnswer, "\n")

#Part 5: Sorting the data
# Which country has the lowest 13th ranking?
source("Ranking.R")
cat("Question 2: Which country has the lowest 13th ranking?  ", getRanking(mergeResult, 13), "\n")



#Part 6: the average GDP rankings for the "High income: OECD" and "High income: nonOECD" groups
source("IncomeGroupAverageRanking.R")
cat("Question 3-1: What is the average GDP rankings for the High income: OECD? ", getIncomeGroupAverageRanking("High income: OECD"), "\n")
cat("Question 3-2: What is the average GDP rankings for the High income: nonOECD?", getIncomeGroupAverageRanking("High income: nonOECD"), "\n")


#Part 7 : GGPlot
# The plot of the GDP for all of the countries using ggplot2 to color your plot by Income Group.
source("GdpGGplot.R")

#Part 8: Fifth question
#5-If you cut the GDP ranking into 5 separate quantile groups, and make a table versus Income.Group, 
#how many countries are Lower middle income but among the 38 nations with highest GDP?
source("RichLowerMiddleIncome.R")

cat("Question 5: how many countries are Lower middle income but among the 38 nations with highest GDP?", getNumberOfRichestLowerMiddleIncome(mergeResult))

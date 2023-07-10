# this code use the package "predictrace" to predict the race of business owner


# librairies --------------------------------
library(readr)
library(dplyr)
library(stringr)
library(tigris)
library(sf)
library(data.table)
library(ggplot2)
library(reshape2)
library(crosstable)
library(tidyr)
library(scales)
library(predictrace)

# load data ----------------------------------
owner <- read_csv("data/mergent_intellect_executives/sample.csv.xz")

owner <- owner %>%
  mutate(fullname=paste0(firstname,' ',lastname))

# run the NLP model predictrace ---------------
firstname_perdiction <- predict_race(owner$firstname, probability = TRUE)
lastname_perdiction <- predict_race(owner$lastname, probability = TRUE)
#perdiction <- predict_race(owner$fullname, probability = TRUE)

# group the result into white and non-white




# save the output -----------------------------


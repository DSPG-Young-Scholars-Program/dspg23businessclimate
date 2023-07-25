# Exploratory Descriptive Analysis (EDA) --------------------
# libraries -----------------------------
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
library(tidygeocoder)
library(fuzzyjoin)
library(zipcodeR)

# load the data -------------------------
namesor <- read_csv("data/nlp_data/namsor_nlp.csv")

# create b&w plots for the wiki methodj (ethnicolr) -------------------------
plt_wiki_listing <- ggplot(namesor, aes(x=factor(flag_listing), y=prob_nw_eth_wiki)) +
  geom_boxplot()

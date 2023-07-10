# This file build the nlp test sample using Axle data

# libraries -------------------------------------------------
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




# load the data and select some variables -------------------
sample <-  read_csv("data/axle_data/Ethnicity/df_20001_DC_full.csv") %>%
  dplyr::select(company_name=`Company Name`,
                founding_year=`Year Established`,
                firstname=`Executive First Name`,
                lastname=`Executive Last Name`,
                title=`Executive Title`,
                gender=`Executive Gender`,
                ethnicity=`Executive Ethnicity`)

# select variables and do some treatment (issue with axle ethnicity - it is prediction based)
# list of ethnicity : African American,  Centl & SW Asian , Eastern European, Far Eastern, Hispanic, Mediterranean, Middle Eastern, Native American, Not Available, Pacific Islander, Scandinavian, South Asian, Western Europe
white_ethn_list <- c('Eastern European','Far Eastern','Mediterranean','Western Europe')

# filter not available and uncoded
sample <- sample %>%
  filter(!(ethnicity %in% c('Not Available','Uncoded'))) %>%
  mutate(race_axle=if_else(ethnicity %in% white_ethn_list,'white','non-white'))


# save the test sample
readr::write_csv(sample, xzfile('data/mergent_intellect_executives/axle_names_sample', compression = 9))


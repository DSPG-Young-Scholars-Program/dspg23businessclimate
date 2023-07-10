# extract owner in the mergent for the Fairfax county


# libraries -------------------------------------------------------
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


# address extraction from mergent
path = "/home/yhu2bk/Github/sdc.business_climate_dev/Microdata/Mergent_intellect/data/working/"
mi <-  read_csv(paste0(path,"mi_companies_details.csv.xz"))
temp_fairfax <- mi %>% 
  filter(`Physical County`=='FAIRFAX') %>% 
  select(company_name=`Company Name`, 
         duns = `D-U-N-S@ Number`, 
         address= `Physical Address`, 
         county= `Physical County`, 
         city=`Physical City`, 
         zipcode=`Physical Zipcode`, 
         state = `Physical State`,
         primary_naics = `Primary NAICS Code`,
         minority=`Minority Owned Indicator`,
         own_rent = `Owns/Rents`,
         Latitude, 
         Longitude=Longtitude) %>%
  mutate(minority=if_else(minority=='No',0,1))

# save the data for NLP modeling test
readr::write_csv(temp_fairfax, xzfile('data/mergent_intellect_fairfax/mi_address_details.csv.xz', compression = 9))




# subset to Fairfax counties --------------------------------------
executives <-  read_csv("data/mergent_intellect_executives/mi_executives.csv.xz")
fairfax <-  read_csv("data/mergent_intellect_fairfax/mi_fairfax_features_bg.csv")
dunslist <- unique(fairfax$duns)
executives <- executives %>%
  select(duns=`D-U-N-S@ Number`, company_name=`Company Name`, firstname=`First Name`, lastname=`Last Name`, title=`Title`, gender=`Gender` )

# filter businesses listed in fairfax, identify the owner and filter them
temp <- executives %>%
  filter(duns %in% dunslist)

# how many company have been listed in fairfax
print(paste0(length(unique(temp$duns)),' companies listed with executives in Fairfax out of ',length(unique(fairfax$duns)),' companies in fairfax'))

subset <- temp %>%
  mutate(search=grepl('Owner',title)) %>%
  filter(search==TRUE)
print(paste0(length(unique(subset$duns)),' companies listed with owner in Fairfax out of ',length(unique(fairfax$duns)),' companies in fairfax'))

# save the data for NLP modeling test
readr::write_csv(subset, xzfile('data/mergent_intellect_executives/sample.csv.xz', compression = 9))

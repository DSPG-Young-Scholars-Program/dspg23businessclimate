# libraries --------------------------------------------------------------------------------
library(readr)
library(dplyr)
library(stringr)
library(tigris)
library(sf)
library(data.table)
library(ggplot2)
library(reshape2)
#library(crosstable)
library(tidyr)
library(scales)
library(tidygeocoder)
library(tidycensus)
library(fuzzyjoin)
library(zipcodeR)


# 1. load data ----------------------------------------------------------------------------------
# load mergent intellect data
mi_address <- read_csv("data/mergent_and_library/mi_address_details.csv.xz") %>% select(duns, latitude, longitude)
mi_sf <- st_as_sf(mi_address, coords = c("longitude", "latitude"), crs = 4269, agr = "constant")


# download census 
tract_2010 <- tracts( 'VA', 'Fairfax County', year='2010') %>% select(geoid=GEOID10, geometry)
tract_2020 <- tracts( 'VA', 'Fairfax County', year='2020') %>% select(geoid=GEOID, geometry)

# demopgrahics data from acs
named_acs_var_list <- c(
  total_race = "B02001_001",
  wht_alone = "B02001_002"
)

#download acs data 
census_api_key('5a4a6b9546e29ec606ed7b6c53a29d63f4989343')
acs_2019 <- data.table::setDT(
  tidycensus::get_acs(
    state = "VA",
    county = '059',
    survey = "acs5",
    year = 2019,
    geography = 'tract',
    output = "wide",
    variables = named_acs_var_list,
    geometry = FALSE,
  )
)

acs <- acs_2019 %>% 
    mutate(prop_nwh=((total_raceE-wht_aloneE)/total_raceE) *100) %>% select(geoid=GEOID, prop_nwh)


# merging both mergent and census 
mi_geolocate_2019 <- st_join(st_transform(mi_sf, 4269), st_transform(tract_2010, 4269), join= st_within)
mi_acs_geolcate_2019 <- merge(mi_geolocate_2019, acs, by='geoid')
readr::write_csv(mi_acs_geolcate_2019, xzfile('data/mergent_and_library/mi_acs_geolocate.csv', compression = 9))


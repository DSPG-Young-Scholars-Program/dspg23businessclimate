---
  title: "get-acs-bc"
author: "Trinity Chamblin"
date: "2023-06-21"
output: html_document
---
  
#this will run in R markdown file
  ```{r}  
library(acs)
library(tidycensus)
library(tidyverse)
library(ggplot2)
library(plotly)
#API KEY for access
#census_api_key('9b96521ebfc61d11baf6a170f57d66011d3c8e9a', install = TRUE)

  
ffx_dem_2021<-get_acs(geography="block group",state= 'VA', county = '059', year= 2021, survey="acs5", variables=c(total_race = "B02001_001",
                                                                                                                  wht_alone = "B02001_002",
                                                                                                                  afr_amer_alone = "B02001_003",
                                                                                                                  native_alone = "B02001_004",
                                                                                                                  asian_alone = "B02001_005",
                                                                                                                  pacific_islander_alone = "B02001_006",
                                                                                                                  other_race = "B02001_007",
                                                                                                                  two_or_more = "B02001_008"), output = "wide")


ffx_dem_2021 = ffx_dem_2021 %>% mutate(not_wht = (total_raceE - wht_aloneE))
ffx_dem_2021 = ffx_dem_2021 %>% mutate(prop_wht=round((wht_aloneE/total_raceE), digits = 2))
ffx_dem_2021 = ffx_dem_2021 %>% mutate(prop_wht=round((wht_aloneE/total_raceE), digits = 2))
ffx_dem_2021 = ffx_dem_2021 %>% mutate(prop_not= (1-prop_wht))
ffx_dem_2021 <- ffx_dem_2021 %>% mutate(ffx_dem_2021, max_prop = pmin(prop_wht, not_wht))
ffx_dem_2021 <- ffx_dem_2021 %>% mutate(min_prop =(1-max_prop))

#find max and min of prop variable variable for each geoids by created df of block group distributions (acs)
ffx_dem_prop <- data.frame(GEOID =(ffx_dem_2021$GEOID), NAME=(ffx_dem_2021$NAME), prop_wht = (ffx_dem_2021$prop_wht), prop_not = (ffx_dem_2021$prop_not), max_prop = (ffx_dem_2021$max_prop), min_prop = (ffx_dem_2021$min_prop))

#write.csv(ffx_dem_prop, file ='~/Documents/DSPG/Data Commons/ffx_pop_dem.csv', row.names = FALSE)


```

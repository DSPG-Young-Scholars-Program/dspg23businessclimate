# This file build a master list of businesses in Fairfax, by combining Mergent intellect and the Library data

# libraries --------------------------------------------------------------------------------------------------------------------
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



# 1. Build the master list  -------------------------------------------------------------------------------------------------------

# load mergent intellect data
mi_address <- read_csv("data/mergent_intellect_fairfax/mi_address_details.csv.xz")

# clean mergent
mergent <- mi_address %>%
  mutate(company_name0 = str_remove_all(tolower(company_name), "limited liability company| incorporated| inc| llc"),
         company_name0=gsub("[,.]","",company_name0),
         state=if_else(state=='VIRGINIA','VA',''),
         city=tolower(city),
         county=tolower(county),
         zipcode=substr(zipcode,1,5),
         full_address=tolower(paste(str_trim(address),str_trim(county),str_trim(city),str_trim(zipcode),str_trim(state))) )

# load AtoZ data
library <- read_csv("data/mergent_intellect_fairfax/library_alpha/ffxlib_all.csv") %>%
  dplyr::select(company_name=`Business Name`, 
                address=Address,
                city=City,
                state=State,
                zipcode=ZIP)

# clean AtoZ
library <- library %>%
  mutate(company_name0 = str_remove_all(tolower(company_name), "limited liability company| incorporated| inc| llc"),
         company_name0=gsub("[,.]","",company_name0),
         state=if_else(state=='VIRGINIA','VA',''),
         city=tolower(city),
         zipcode=substr(zipcode,1,5),
         full_address=tolower(paste(str_trim(address),str_trim(city),str_trim(zipcode),str_trim(state))) ,
         ID=row_number())



# get the zipcode list from fairfax
temp <- search_county('Fairfax','VA')
fairfax_zipcode <- unique(temp$zipcode)


# 2. Combine mergent intellect and AtoZ (find the overlap) ---------------------------------------------------
overlap <- NULL

for (x in fairfax_zipcode){
  subset_library <- library %>% filter(zipcode==x) %>% dplyr::select(ID,company_name0,address,city,state,zipcode)
  subset_mergent <- mergent %>% filter(zipcode==x) %>% dplyr::select(company_name0,address_mergent=address)
  temp <- subset_library %>% 
    mutate(flag_overlap=if_else(company_name0 %in% unique(subset_mergent$company_name0),1,0)) 
  overlap <- rbind(overlap,temp)
}

# save the data
overlap <- overlap %>% filter(flag_overlap==1) 
readr::write_csv(overlap, xzfile('data/mergent_intellect_fairfax/overlap.csv.xz', compression = 9))




# Build the master list ---------------------------------------------------------------------------------------------
mergent_flagged <- read_csv("data/mergent_and_library/mergent_flagged.csv.xz") %>% 
  mutate(source='mergent intellect')
AtoZ_flagged <- read_csv("data/mergent_and_library/AtoZ_flagged.csv.xz") %>% 
  dplyr::select(duns=ID,company_name0,address,city,state,zipcode,flag_axle,flag_sbsd,flag_chamber,flag_yelp,flag_listing) %>%
  mutate(duns=as.character(duns),
         source='AtoZ (non-overlaped)')
overlap <- read_csv("data/mergent_and_library/overlap.csv.xz")

nonoverlap_AtoZ <- AtoZ_flagged %>% filter(!(duns %in% unique(overlap$ID)))
master_data_model <- rbind(mergent_flagged,nonoverlap_AtoZ)


# save the data
readr::write_csv(master_data_model, xzfile('data/mergent_intellect_fairfax/master_data.csv.xz', compression = 9))

# summary statistics
desc <- master_data_model %>%
  group_by(source) %>%
  summarise(business_count=length(duns),
            axle=sum(flag_axle),
            sbsd=sum(flag_sbsd),
            chamber=sum(flag_chamber),
            yelp=sum(flag_yelp),
            overall=sum(flag_listing))
desc
  


# get data on owner name for companies listed in the master -----
mergent_data_model <- master_data_model %>% filter(source=='mergent intellect')

# load executives data
executives <-  read_csv("data/mergent_intellect_fairfax/mi_executives.csv.xz")
fairfax_executives <- executives %>% filter()














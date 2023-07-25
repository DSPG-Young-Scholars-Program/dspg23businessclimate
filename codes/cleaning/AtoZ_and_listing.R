# This file prepare AtoZ data for classifying minority or not
# model of matching two list the following variables: company name, address, city, state, zipcode
#     - select the same zipcode (we found that some data like sbsd missnamed city. reason why we used zipcode)
#     - select the same 

# libraries --------------------------------------------------------------------------------
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


# 1. load data ----------------------------------------------------------------------------------
# load the data
library <- read_csv("data/mergent_and_library/ffxlib_all.csv") %>%
  mutate(duns=row_number())
readr::write_csv(library, xzfile('data/mergent_and_library/AtoZ_library.csv.xz', compression = 9))


library <- read_csv("data/mergent_and_library/AtoZ_library.csv.xz") %>%
  dplyr::select(company_name=`Business Name`, 
                address=Address,
                city=City,
                state=State,
                zipcode=ZIP)

executive_AtoZ <- library %>% 
  mutate(library, flag_small = ifelse('Employee Size' > 50, 1, 0)) %>%
  select('Business Name', Name, Title, duns, flag_small)

# clean AtoZ
library <- library %>%
  mutate(company_name0 = str_remove_all(tolower(company_name), "limited liability company| incorporated| inc| llc"),
         company_name0=gsub("[,.]","",company_name0),
         state=if_else(state=='VIRGINIA','VA',''),
         city=tolower(city),
         zipcode=substr(zipcode,1,5),
         full_address=tolower(paste(str_trim(address),str_trim(city),str_trim(zipcode),str_trim(state))) ,
         ID=row_number())

# find AtoZ data with the same company name and many address
warning_duplicate_name <- library %>%
  group_by(company_name0) %>%
  summarise(count=length(unique(address))) %>%
  filter(count>1)
warning_company_name <- unique(tolower(warning_duplicate_name$company_name0))

# get the zipcode list from fairfax
temp <- search_county('Fairfax','VA')
fairfax_zipcode <- unique(temp$zipcode)





# 2. flag axle data --------------------------------------------------------------------------------
axle <- read_csv("data/axle_data/data_axle_minority_fairfax.csv") %>% 
  dplyr::select(company_name=`Company Name`,address=Address,city=City,state=State,zipcode=`ZIP Code`)

axle_minority <- axle %>%
  filter(!is.na(company_name)) %>%
  mutate(company_name0 = str_remove_all(tolower(company_name), "limited liability company| incorporated| inc| llc"),
         company_name0=gsub("[,.]","",company_name0),
         city=tolower(city),
         address=tolower(address),
         zipcode=as.character(zipcode))

# merge the company name within the same city
library_axle_flagged <- NULL

for (x in fairfax_zipcode){
  # subset the two dataset to the same zipcode
  subset_library <- library %>% filter(zipcode==x) %>% dplyr::select(ID,company_name0,address,city,state,zipcode)
  subset_axle <- axle_minority %>% filter(zipcode==x) %>% dplyr::select(company_name0,address_axle=address)
  temp <- subset_library %>% 
    mutate(flag_axle=if_else(company_name0 %in% unique(subset_axle$company_name0),1,0)) 
  library_axle_flagged <- rbind(library_axle_flagged,temp)
}

print(paste0('Number of companies flagged as minority by Axle: ', sum(library_axle_flagged$flag_axle)))



# 3. flag sbsd data ----------------------------------------------------------------------------------
sbsd <- read_csv("data/listings/administrative_records/sbsd.csv") %>%
  dplyr::select(certification=`Certification Type`,
                company_name=`Company Name...7`,
                address=`Mailing Address...11`,
                city=`City...12`,
                state=`State...13`,
                zipcode=`Zip...14`
  )

# select only compnay from sbsd inside fairfax county based on zipcode
sbsd_minority <- sbsd %>%
  mutate(search=grepl('Minority',certification),
         company_name0 = str_remove_all(tolower(company_name), "limited liability company| incorporated| inc| llc"),
         company_name0=gsub("[,.]","",company_name0),
         address=tolower(address),
         city=tolower(city)) %>% 
  filter(search==TRUE) %>%
  filter(state=="VA") %>%
  filter(zipcode %in% fairfax_zipcode)
  
# merge the company name within the same city
library_sbsd_flagged <- NULL

for (x in fairfax_zipcode){
  # subset the two dataset to the same city
  subset_library <- library %>% filter(zipcode==x) %>% dplyr::select(ID,company_name0,address,zipcode)
  subset_sbsd <- sbsd_minority %>% filter(zipcode==x) %>% dplyr::select(company_name0,address_sbsd=address)
  temp <- subset_library %>% 
    mutate(flag_sbsd=if_else(company_name0 %in% unique(subset_sbsd$company_name0),1,0)) 
  library_sbsd_flagged <- rbind(library_sbsd_flagged,temp)
}

print(paste0('Number of companies flagged as minority by SBSD: ', sum(library_sbsd_flagged$flag_sbsd)))




# 4.flag chamber data -----------------------------------------------------------------------------------
chamber <- read_csv("data/mergent_intellect_fairfax/merged_chambers.csv") %>% 
  dplyr::select(company_name=`Business Name`, full_address=Address)

# find companies not without addresses and look up them in mergent
chamber0 <- chamber %>% filter(is.na(full_address)) %>%
  mutate(company_name0 = str_remove_all(tolower(company_name), "limited liability company| incorporated| inc| llc"),
         company_name0=gsub("[,.]","",company_name0))

library_chamber0 <- library %>%
  mutate(flag_chamber0=if_else(company_name0 %in% unique(chamber0$company_name0),1,0))

chamber1 <- chamber %>% filter(!is.na(full_address)) %>%
  mutate(company_name0 = str_remove_all(tolower(company_name), "limited liability company| incorporated| inc| llc"),
         company_name0=gsub("[,.]","",company_name0),
         address=sapply(strsplit(full_address, ","), "[", 1),
         city=sapply(strsplit(full_address, ","), "[", 2),
         state=str_sub(sapply(strsplit(full_address, ","), "[", 3),1,3),
         zipcode=str_sub(sapply(strsplit(full_address, ","), "[", 3),4,9),
         city0=sapply(strsplit(full_address, ","), "[", 3),
         state0=str_sub(sapply(strsplit(full_address, ","), "[", 4),1,3),
         zipcode0=str_sub(sapply(strsplit(full_address, ","), "[", 4),4,9),
         city=if_else(!is.na(state0),city0,city),
         state=if_else(!is.na(state0),state0,state),
         zipcode=if_else(!is.na(state0),zipcode0,zipcode))

# merge the company name within the same city
library_chamber1 <- NULL

for (x in fairfax_zipcode){
  # subset the two dataset to the same zipcode
  subset_library <- library %>% filter(zipcode==x) %>% 
    dplyr::select(ID,company_name0,address,zipcode)
  subset_yelp <- chamber1 %>% filter(zipcode==x) %>% dplyr::select(company_name0,city_yelp=city)
  temp <- subset_library %>% 
    mutate(flag_chamber1=if_else(company_name0 %in% unique(subset_yelp$company_name0),1,0)) 
  library_chamber1 <- rbind(library_chamber1,temp)
}

library_chamber_flagged <- merge(library_chamber0, library_chamber1[,c('ID','flag_chamber1')], by.x='ID') %>%
  mutate(flag_chamber=flag_chamber0+flag_chamber1)

print(paste0('Number of companies flagged as minority by chamber: ', sum(library_chamber_flagged$flag_chamber,na.rm=T)))




# 5. flag yelp data ---------------------------------------------------------------------------------------
#yelp_scrape <- read_csv("data/mergent_intellect_fairfax/yelpmergeffx.csv") %>% dplyr::select(company_name=`Business Name`, address=Address)
# combine data from yelp api
yelp_api_blk <- read_csv("data/listings/yelp/yelp_fusion/blk.csv") %>% dplyr::select(company_name=name, city=city, zipcode=zip_code)
yelp_api_asn <- read_csv("data/listings/yelp/yelp_fusion/blk.csv") %>% dplyr::select(company_name=name, city=city, zipcode=zip_code)
yelp_api_ltn <- read_csv("data/listings/yelp/yelp_fusion/blk.csv") %>% dplyr::select(company_name=name, city=city, zipcode=zip_code)
yelp_api <- rbind(yelp_api_blk,yelp_api_asn,yelp_api_ltn)

# select only compnay from sbsd inside fairfax county based on zipcode
yelp_minority <- yelp_api %>%
  mutate(company_name0 = str_remove_all(tolower(company_name), "limited liability company| incorporated| inc| llc"),
         company_name0=gsub("[,.]","",company_name0),
         city=tolower(city)) %>% 
  filter(zipcode %in% fairfax_zipcode)

# merge the company name within the same city
library_yelp_flagged <- NULL

for (x in fairfax_zipcode){
  # subset the two dataset to the same zipcode
  subset_library <- library %>% filter(zipcode==x) %>% 
    dplyr::select(ID,company_name0,address,zipcode)
  subset_yelp <- yelp_minority %>% filter(zipcode==x) %>% dplyr::select(company_name0,city_yelp=city)
  temp <- subset_library %>% 
    mutate(flag_yelp=if_else(company_name0 %in% unique(subset_yelp$company_name0),1,0)) 
  library_yelp_flagged <- rbind(library_yelp_flagged,temp)
}

print(paste0('Number of companies flagged as minority by Yelp: ', sum(library_yelp_flagged$flag_yelp)))


# combine all flag (the data is already combined) ------------------------------
library_flagged <- merge(library_axle_flagged, library_sbsd_flagged[,c('ID','flag_sbsd')], by='ID')
library_flagged <- merge(library_flagged, library_chamber_flagged[,c('ID','flag_chamber')], by='ID')
library_flagged <- merge(library_flagged, library_yelp_flagged[,c('ID','flag_yelp')], by='ID')

library_flagged <- library_flagged %>%
  mutate(flag_listing = if_else(flag_axle + flag_sbsd + flag_chamber + flag_yelp>0,1,0))

# descriptive analysis
Desc <- library_flagged %>%
  summarise(source=' Mergent intellect',
            Number=length(ID),
            axle=sum(flag_axle),
            sbsd=sum(flag_sbsd),
            chamber=sum(flag_chamber),
            yelp=sum(flag_yelp),
            overall=sum(flag_listing))

Desc

# save the data
readr::write_csv(library_flagged, xzfile('data/mergent_intellect_fairfax/AtoZ_flagged.csv.xz', compression = 9))
readr::write_csv(executive_AtoZ, xzfile('data/mergent_and_library/executive_AtoZ_flagged.csv.xz', compression = 9))


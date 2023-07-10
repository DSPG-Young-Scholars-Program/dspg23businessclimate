# This file prepare the Mergent data for classifying minority or not
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
# load mergent intellect data
mi_address <- read_csv("data/mergent_and_library/mi_address_details.csv.xz")

# clean mergent
mergent <- mi_address %>%
  mutate(company_name0 = str_remove_all(tolower(company_name), "limited liability company| incorporated| inc| llc"),
         company_name0=gsub("[,.]","",company_name0),
         state=if_else(state=='VIRGINIA','VA',''),
         city=tolower(city),
         county=tolower(county),
         zipcode=substr(zipcode,1,5),
         full_address=tolower(paste(str_trim(address),str_trim(county),str_trim(city),str_trim(zipcode),str_trim(state))),
         flag_mergent=minority)

# find mergent data with the same company name and many address
warning_duplicate_name <- mergent %>%
  group_by(company_name) %>%
  summarise(count=length(unique(duns))) %>%
  filter(count>1)
warning_company_name <- unique(tolower(warning_duplicate_name$company_name))

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
mergent_axle_flagged <- NULL

for (x in fairfax_zipcode){
  # subset the two dataset to the same zipcode
  subset_mergent <- mergent %>% filter(zipcode==x) %>% dplyr::select(duns,company_name0,address,city,state,zipcode,flag_mergent)
  subset_axle <- axle_minority %>% filter(zipcode==x) %>% dplyr::select(company_name0,address_axle=address)
  temp <- subset_mergent %>% 
    mutate(flag_axle=if_else(company_name0 %in% unique(subset_axle$company_name0),1,0)) 
  #%>% left_join(subset_axle[c('company_name0','address_axle')], by='company_name0') 
  mergent_axle_flagged <- rbind(mergent_axle_flagged,temp)
}

print(paste0('Number of companies flagged as minority by Axle: ', sum(mergent_axle_flagged$flag_axle)))




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
mergent_sbsd_flagged <- NULL

for (x in fairfax_zipcode){
  # subset the two dataset to the same city
  subset_mergent <- mergent %>% filter(zipcode==x) %>% dplyr::select(duns,company_name0,address,zipcode,flag_mergent)
  subset_sbsd <- sbsd_minority %>% filter(zipcode==x) %>% dplyr::select(company_name0,address_sbsd=address)
  temp <- subset_mergent %>% 
    mutate(flag_sbsd=if_else(company_name0 %in% unique(subset_sbsd$company_name0),1,0)) 
  #%>% left_join(subset_sbsd[c('company_name0','address_sbsd')], by='company_name0') 
  mergent_sbsd_flagged <- rbind(mergent_sbsd_flagged,temp)
}

print(paste0('Number of companies flagged as minority by SBSD: ', sum(mergent_sbsd_flagged$flag_sbsd)))





# 4.flag chamber data -----------------------------------------------------------------------------------
chamber <- read_csv("data/listings/chamber_of_commerce/merged_chambers.csv") %>% 
  dplyr::select(company_name=`Business Name`, full_address=Address)

# find companies not without addresses and look up them in mergent
chamber0 <- chamber %>% filter(is.na(full_address)) %>%
  mutate(company_name0 = str_remove_all(tolower(company_name), "limited liability company| incorporated| inc| llc"),
         company_name0=gsub("[,.]","",company_name0))

mergent_chamber0 <- mergent %>%
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
mergent_chamber1 <- NULL

for (x in fairfax_zipcode){
  # subset the two dataset to the same zipcode
  subset_mergent <- mergent %>% filter(zipcode==x) %>% dplyr::select(duns,company_name0,address,zipcode,flag_mergent)
  subset_yelp <- chamber1 %>% filter(zipcode==x) %>% dplyr::select(company_name0,city_yelp=city)
  temp <- subset_mergent %>% 
    mutate(flag_chamber1=if_else(company_name0 %in% unique(subset_yelp$company_name0),1,0)) 
  #%>% left_join(subset_yelp[c('company_name0','city_yelp')], by='company_name0') 
  mergent_chamber1 <- rbind(mergent_chamber1,temp)
}

mergent_chamber_flagged <- merge(mergent_chamber0, mergent_chamber1[,c('duns','flag_chamber1')], by.x='duns') %>%
  mutate(flag_chamber=flag_chamber0+flag_chamber1)

print(paste0('Number of companies flagged as minority by chamber: ', sum(mergent_chamber_flagged$flag_chamber)))






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
mergent_yelp_flagged <- NULL

for (x in fairfax_zipcode){
  # subset the two dataset to the same zipcode
  subset_mergent <- mergent[mergent$zipcode==x,] %>% dplyr::select(duns,company_name0,address,zipcode,flag_mergent
                                                                   )
  subset_yelp <- yelp_minority[yelp_minority$zipcode==x,] %>% dplyr::select(company_name0,city_yelp=city)
  temp <- subset_mergent %>% 
    mutate(flag_yelp=if_else(company_name0 %in% unique(subset_yelp$company_name0),1,0)) 
  #%>% left_join(subset_yelp[c('company_name0','city_yelp')], by='company_name0') 
  mergent_yelp_flagged <- rbind(mergent_yelp_flagged,temp)
}

print(paste0('Number of companies flagged as minority by Yelp: ', sum(mergent_yelp_flagged$flag_yelp)))





# combine all flag ----------------------------------------------------------------------------------------------------
mergent_flagged <- merge(mergent_axle_flagged, mergent_sbsd_flagged[,c('duns','flag_sbsd')], by='duns')
mergent_flagged <- merge(mergent_flagged, mergent_chamber_flagged[,c('duns','flag_chamber')], by='duns')
mergent_flagged <- merge(mergent_flagged, mergent_yelp_flagged[,c('duns','flag_yelp')], by='duns')
mergent_flagged <- mergent_flagged %>%
  mutate(flag_listing = if_else(flag_axle + flag_sbsd + flag_chamber + flag_yelp>0,1,0),
         flag_mergent_plus_listing=if_else(flag_listing + flag_mergent>0,1,0))
mergent_flagged <- merge(mergent_flagged, mergent[,c('duns','founding_year','primary_naics')], by='duns')

mergent_flagged <- mergent_flagged %>%
  mutate(founding_year=replace(founding_year,0,NA),
         naics2=as.numeric(substr(primary_naics, 1, 2)),
         naics_name=case_when(
           naics2==11 ~ "Agriculture, Forestry, Fishing and Hunting",
           naics2==21 ~ "Mining, Quarrying, and Oil and Gas Extraction",
           naics2==22 ~ "Utilities",
           naics2==23 ~ "Construction",
           naics2==31 | naics2==32 | naics2==33 ~ "Manufacturing",
           naics2==42 ~ "Wholesale Trade",
           naics2==44 | naics2==45 ~ "Retail Trade",
           naics2==48 | naics2==49 ~ "Transportation and Warehousing",
           naics2==51 ~ "Information",
           naics2==52 ~ "Finance and Insurance",
           naics2==53 ~ "Real Estate and Rental and Leasing",
           naics2==54 ~ "Professional, Scientific, and Technical Services",
           naics2==55 ~ "Management of Companies and Enterprises",
           naics2==56 ~ "Administrative and Support and Waste Management and Remediation Services",
           naics2==61 ~ "Educational Services",
           naics2==62 ~ "Health Care and Social Assistance",
           naics2==71 ~ "Arts, Entertainment, and Recreation",
           naics2==72 ~ "Accommodation and Food Services",
           naics2==81 ~ "Other Services (except Public Administration)",
           naics2==92 ~ "Public Administration",
           naics2==99 ~ "Nonclassifiable Establishments"))






# get the executives of those company ----------------------------------------------------------------------------------
# load the executives data
executives <-  read_csv("data/mergent_intellect_executives/mi_executives.csv.xz") 
mergent_flagged <- mergent_flagged %>%
  mutate(flag_executive_reported=if_else(duns %in% unique(executives$duns), 1,0))

# filter companies with executive
print(paste0('Number of companies with executives information : ', unique(length(executives$duns))))

# subset the executives data available
executive_reported <- executives %>%
  filter(duns %in% unique(mergent_flagged$duns[mergent_flagged$flag_executive==1])) 

# compute the flag
executive_reported <- executive_reported %>% 
  mutate(flag_owner=as.numeric(grepl('Owner',title)),
         flag_presi_vicepresi=as.numeric(grepl('President',title)))

# save the data
readr::write_csv(mergent_flagged, xzfile('data/mergent_and_library/mergent_flagged.csv.xz', compression = 9))
readr::write_csv(executive_reported, xzfile('data/mergent_intellect_executives/mergent_executive_flagged.csv.xz', compression = 9))






# identify small and sole_proprietor companies -----------------------------------------------------------------------
operation <-  read_csv("data/mergent_and_library/mi_operation.csv.xz") 











# descriptive statistics of minority flagged companies ---------------------------------------------------------------
desc1 <- mergent_flagged %>%
  summarise(Description='Listed as minority in MI',
            axle=sum(flag_axle),
            sbsd=sum(flag_sbsd),
            chamber=sum(flag_chamber),
            yelp=sum(flag_yelp),
            listing=sum(flag_listing),
            mergent_min=sum(flag_mergent),
            mergent_plus_listing=sum(flag_mergent_plus_listing),
            minority_both=mergent_min+listing-mergent_plus_listing,
            Total='')

desc2 <- mergent_flagged %>%
  filter(flag_executive_reported==1) %>%
  summarise(Description='Listed as minority with executives reported in MI',
            axle=sum(flag_axle),
            sbsd=sum(flag_sbsd),
            chamber=sum(flag_chamber),
            yelp=sum(flag_yelp),
            listing=sum(flag_listing),
            mergent_min=sum(flag_mergent),
            mergent_plus_listing=sum(flag_mergent_plus_listing),
            minority_both=mergent_min+listing-mergent_plus_listing,
            Total=length(duns))

desc3 <-c('Total number of company', length(axle$company_name), length(sbsd_minority$company_name),length(chamber$company_name),length(yelp_api$company_name),'',length(mergent$company_name),length(mergent$company_name),length(mergent$company_name),'')
desc <- rbind(desc1,desc2,desc3)
desc






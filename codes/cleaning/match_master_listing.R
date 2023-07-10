# This 

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
library(nominatimlite)


# upload mergent intellect companies details data ----------------------------------------------------------------------------
# load the master list
mi_address <- read_csv("data/mergent_intellect_fairfax/mi_address_details.csv.xz")
library <- read_csv("data/mergent_intellect_fairfax/library_alpha/ffxlib_all.csv") %>%
  dplyr::select(company_name=`Business Name`, 
                address=Address,
                city=City,
                state=State,
                zipcode=ZIP,
                owner_name=Name,
                title=Title,
                employment=`Employee Size`,
                home_based=`Home Based Business`,
                franchise=`Franchise Type`) %>%
  mutate(address0 = sub('(Ste|Apt|Unit).*', "", address),
         fulladdress=paste0(address0,', ',city,', ',state,', ',zipcode)) %>%
  filter(!is.na(address))


# load data from the listing
sbsd <- read_csv("data/listings/administrative_records/sbsd_fairfax.csv") 
axle <- read_csv("data/axle_minority/data_axle_minority_fairfax.csv") %>% dplyr::select(company_name=`Company Name`, address=Address)
chamber <- read_csv("data/mergent_intellect_fairfax/merged_chambers.csv") %>% dplyr::select(company_name=`Business Name`, address=Address)
yelp <- read_csv("data/mergent_intellect_fairfax/yelpmergeffx.csv") %>% dplyr::select(company_name=`Business Name`, address=Address)



# data treatment (clean company name): use the exact matching ----
# sbsd data treatment, search for minority, change the case
sbsd_minority <- sbsd %>%
  dplyr::select(certification=`Certification Type`, company_name=`Company Name`, address=`Mailing Address`, city=City, state=State, zip=Zip) %>%
  mutate(search=grepl('Minority',certification)) %>%
  filter(search==TRUE) %>%
  mutate(company_name0=gsub("[,.]","",tolower(company_name)))

# chamber data treatment: remove nan, change the case
chamber_minority <- chamber %>%
  filter(!is.na(company_name)) %>%
  mutate(company_name0=gsub("[,.]","",tolower(company_name)))

# yelp data treatment: extract text after the pattern in company name, change the case
yelp_minority <- yelp %>%
  filter(!is.na(company_name)) %>%
  mutate(company_name0=str_replace(company_name, '^\\d+\\.', ''))

# yelp data treatment: extract text after the pattern in company name, change the case
axle_minority <- axle %>%
  filter(!is.na(company_name)) %>%
  mutate(company_name0=gsub("[,.]","",tolower(company_name)))


# 2. match mergent with all the minority source  --------------------------------------------------------------------------------
sbsd_list <- unique(sbsd_minority$company_name0)
chamber_list <- unique(chamber_minority$company_name0)
yelp_list <- unique(yelp_minority$company_name0)
axle_list <- unique(axle_minority$company_name0)

mergent_flagged <- mi_address %>%
  mutate(company_name0=gsub("[,.]","",tolower(company_name)),
         flag_sbsd=if_else(company_name0 %in% sbsd_list,1,0),
         flag_chamber=if_else(company_name0 %in% chamber_list,1,0),
         flag_yelp=if_else(company_name0 %in% yelp_list,1,0),
         flag_axle=if_else(company_name0 %in% axle_list,1,0),
         count_flag = flag_sbsd + flag_chamber + flag_yelp + flag_axle,
         listing=if_else(count_flag>0,1,0))

library_flagged <- library %>%
  mutate(company_name0=gsub("[,.]","",tolower(company_name)),
         flag_sbsd=if_else(company_name0 %in% sbsd_list,1,0),
         flag_chamber=if_else(company_name0 %in% chamber_list,1,0),
         flag_yelp=if_else(company_name0 %in% yelp_list,1,0),
         flag_axle=if_else(company_name0 %in% axle_list,1,0),
         count_flag = flag_sbsd + flag_chamber + flag_yelp + flag_axle,
         listing=if_else(count_flag>0,1,0))

overlap_flagged <- overlap %>%
  mutate(company_name0=gsub("[,.]","",tolower(company_name)),
         flag_sbsd=if_else(company_name0 %in% sbsd_list,1,0),
         flag_chamber=if_else(company_name0 %in% chamber_list,1,0),
         flag_yelp=if_else(company_name0 %in% yelp_list,1,0),
         flag_axle=if_else(company_name0 %in% axle_list,1,0),
         count_flag = flag_sbsd + flag_chamber + flag_yelp + flag_axle,
         listing=if_else(count_flag>0,1,0))

temp0 <- mergent_flagged %>%
  summarise(source='Mergent Intellect',
            Number_company=length(duns),
            sbsd=sum(flag_sbsd),
            chamber=sum(flag_chamber),
            yelp=sum(flag_yelp),
            axle=sum(flag_axle),
            all_listing=sum(listing))

temp1 <- library_flagged %>%
  summarise(source='Library',
            Number_company=length(company_name),
            sbsd=sum(flag_sbsd),
            chamber=sum(flag_chamber),
            yelp=sum(flag_yelp),
            axle=sum(flag_axle),
            all_listing=sum(listing))

temp2 <- c('Total companies',0,length(sbsd_list),length(chamber_list),length(yelp_list),length(axle_list),0)
temp <- rbind(temp0, temp1, temp2)
temp



# 1. Build a master list of companies in fairfax (tract the source)
# select the main relevant variable in mergent

library_company <- library %>%
  dplyr::select(company_name=`Business Name`, address=Address) %>%
  mutate(company_name0=gsub("[,.]","",tolower(company_name)),
         source='library')

library_list <- unique(library_company$company_name0) 
overlap <- mergent_company %>% filter(company_name0 %in% library_list)



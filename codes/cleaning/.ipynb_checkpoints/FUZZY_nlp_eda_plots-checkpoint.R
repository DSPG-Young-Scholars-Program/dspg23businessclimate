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
companies <- read_csv("data/mergent_and_library/mergent_flagged_fuzzy.csv.xz")
owner <- read_csv("data/mergent_intellect_executives/mergent_intellect_executives_nlp.csv")
# data treatment ------------------------
temp <- companies %>% filter(duns %in% unique(owner$duns))
desc1 <- temp %>%
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
desc2 <- temp %>%
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
desc <- rbind(desc1,desc2)
desc
# merge the data
temp1 <- merge(owner, temp, by='duns', all.x=T)

# create b&w plots for the wiki methodj (ethnicolr) -------------------------
plt_wiki_listing <- ggplot(temp1, aes(x=factor(flag_listing), y=prob_nw_eth_wiki)) +
  geom_boxplot()

plt_wiki_sbsd <- ggplot(temp1, aes(x=factor(flag_sbsd), y=prob_nw_eth_wiki)) +
  geom_boxplot()

plt_wiki_axle <- ggplot(temp1, aes(x=factor(flag_axle), y=prob_nw_eth_wiki)) +
  geom_boxplot()

plt_wiki_chamb <- ggplot(temp1, aes(x=factor(flag_chamber), y=prob_nw_eth_wiki)) +
  geom_boxplot()

plt_wiki_yelp <- ggplot(temp1, aes(x=factor(flag_yelp), y=prob_nw_eth_wiki)) +
  geom_boxplot()

# create b&w plots for the florida (ethnicolr) -------------------------
plt_fl_reg_name_listing <- ggplot(temp1, aes(x=factor(flag_listing), y=prob_nw_eth_fl_reg_name)) +
  geom_boxplot()

plt_fl_reg_name_sbsd <- ggplot(temp1, aes(x=factor(flag_sbsd), y=prob_nw_eth_fl_reg_name)) +
  geom_boxplot()

plt_fl_reg_name_axle <- ggplot(temp1, aes(x=factor(flag_axle), y=prob_nw_eth_fl_reg_name)) +
  geom_boxplot()

plt_fl_reg_name_chamb <- ggplot(temp1, aes(x=factor(flag_chamber), y=prob_nw_eth_fl_reg_name)) +
  geom_boxplot()

plt_fl_reg_name_yelp <- ggplot(temp1, aes(x=factor(flag_yelp), y=prob_nw_eth_fl_reg_name)) +
  geom_boxplot()

# create b&w plots for the florida five cat (ethnicolr) -------------------------
plt_fl_fivecat_listing <- ggplot(temp1, aes(x=factor(flag_listing), y=prob_nw_eth_fl_five_cat)) +
  geom_boxplot()

plt_fl_fivecat_sbsd <- ggplot(temp1, aes(x=factor(flag_sbsd), y=prob_nw_eth_fl_five_cat)) +
  geom_boxplot()

plt_fl_fivecat_axle <- ggplot(temp1, aes(x=factor(flag_axle), y=prob_nw_eth_fl_five_cat)) +
  geom_boxplot()

plt_fl_fivecat_chamb <- ggplot(temp1, aes(x=factor(flag_chamber), y=prob_nw_eth_fl_five_cat)) +
  geom_boxplot()

plt_fl_fivecat_yelp <- ggplot(temp1, aes(x=factor(flag_yelp), y=prob_nw_eth_fl_five_cat)) +
  geom_boxplot()

# create b&w plots for the census fn method (ethnicolr) -------------------------
plt_census_fn_listing <- ggplot(temp1, aes(x=factor(flag_listing), y=prob_nw_eth_census_fn)) +
  geom_boxplot()

plt_census_fn_sbsd <- ggplot(temp1, aes(x=factor(flag_sbsd), y=prob_nw_eth_census_fn)) +
  geom_boxplot()

plt_census_fn_axle <- ggplot(temp1, aes(x=factor(flag_axle), y=prob_nw_eth_census_fn)) +
  geom_boxplot()

plt_census_fn_chamb <- ggplot(temp1, aes(x=factor(flag_chamber), y=prob_nw_eth_census_fn)) +
  geom_boxplot()

plt_census_fn_yelp <- ggplot(temp1, aes(x=factor(flag_yelp), y=prob_nw_eth_census_fn)) +
  geom_boxplot()

# create b&w plots for the census ln method (ethnicolr) -------------------------
plt_census_ln_listing <- ggplot(temp1, aes(x=factor(flag_listing), y=prob_nw_eth_census_ln)) +
  geom_boxplot()

plt_census_ln_sbsd <- ggplot(temp1, aes(x=factor(flag_sbsd), y=prob_nw_eth_census_ln)) +
  geom_boxplot()

plt_census_ln_axle <- ggplot(temp1, aes(x=factor(flag_axle), y=prob_nw_eth_census_ln)) +
  geom_boxplot()

plt_census_ln_chamb <- ggplot(temp1, aes(x=factor(flag_chamber), y=prob_nw_eth_census_ln)) +
  geom_boxplot()

plt_census_ln_yelp <- ggplot(temp1, aes(x=factor(flag_yelp), y=prob_nw_eth_census_ln)) +
  geom_boxplot()

# create b&w plots for the nc method -------------------------
plt_nc_listing <- ggplot(temp1, aes(x=factor(flag_listing), y=prob_nw_eth_nc)) +
  geom_boxplot()

plt_nc_sbsd <- ggplot(temp1, aes(x=factor(flag_sbsd), y=prob_nw_eth_nc)) +
  geom_boxplot()

plt_nc_axle <- ggplot(temp1, aes(x=factor(flag_axle), y=prob_nw_eth_nc)) +
  geom_boxplot()

plt_nc_chamb <- ggplot(temp1, aes(x=factor(flag_chamber), y=prob_nw_eth_nc)) +
  geom_boxplot()

plt_nc_yelp <- ggplot(temp1, aes(x=factor(flag_yelp), y=prob_nw_eth_nc)) +
  geom_boxplot()
# Analysis
# Analysis
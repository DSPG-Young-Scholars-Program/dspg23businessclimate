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
companies <- read_csv("data/mergent_and_library/mergent_flagged.csv.xz")
owner <- read_csv("data/mergent_intellect_executives/mergent_intellect_executives_nlp.csv")
zip_data <- read_csv("codes/cleaning/FUZZY_zipcodes_data.csv.xz")
namsor <- read_csv('data/nlp_data/namsor_nc_dataset.csv')
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

temp2 <-temp1 %>%
  filter(title == 'Owner')

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
# creating pie charts for neighborhoods  -------------------------
# Sample data
zipcode <- zip_data$zipcode
percent_flagged <- zip_data$percent_flagged

# Create a data frame with the sample data
data_df <- data.frame(zipcode, percent_flagged)

# Filter out rows with NaN or 0 in the percent_flagged column
data_df <- data_df[!is.nan(data_df$percent_flagged) & data_df$percent_flagged != 0, ]

# Create the bar plot using ggplot2
ggplot(data_df, aes(x = as.factor(zipcode), y = percent_flagged)) +
  geom_bar(stat = "identity", fill = "skyblue", width = 0.6) +
  labs(x = "Zipcode", y = "Percentage Flagged (%)", title = "Percentage of Flagged Minority Business Owners by Zipcode") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for better readability


# create all plots for only owner data  -------------------------

owner_plt_wiki_listing <- ggplot(temp2, aes(x=factor(flag_listing), y=prob_nw_eth_wiki)) +
  geom_boxplot()

owner_plt_fl_reg_name_listing <- ggplot(temp2, aes(x=factor(flag_listing), y=prob_nw_eth_fl_reg_name)) +
  geom_boxplot()

owner_plt_fl_fivecat_listing <- ggplot(temp2, aes(x=factor(flag_listing), y=prob_nw_eth_fl_five_cat)) +
  geom_boxplot()

owner_plt_census_fn_listing <- ggplot(temp2, aes(x=factor(flag_listing), y=prob_nw_eth_census_fn)) +
  geom_boxplot()

owner_plt_census_ln_listing <- ggplot(temp2, aes(x=factor(flag_listing), y=prob_nw_eth_census_ln)) +
  geom_boxplot()

owner_plt_nc_listing <- ggplot(temp2, aes(x=factor(flag_listing), y=prob_nw_eth_nc)) +
  geom_boxplot()


# create all plots for only pre-1964 data  -------------------------

temp4 <- temp1 %>%
  filter(founding_year<=1964)

pre_plt_wiki_listing <- ggplot(temp4, aes(x=factor(flag_listing), y=prob_nw_eth_wiki)) +
  geom_boxplot()

pre_plt_fl_reg_name_listing <- ggplot(temp4, aes(x=factor(flag_listing), y=prob_nw_eth_fl_reg_name)) +
  geom_boxplot()

pre_plt_fl_fivecat_listing <- ggplot(temp4, aes(x=factor(flag_listing), y=prob_nw_eth_fl_five_cat)) +
  geom_boxplot()

pre_plt_census_fn_listing <- ggplot(temp4, aes(x=factor(flag_listing), y=prob_nw_eth_census_fn)) +
  geom_boxplot()
pre_plt_census_ln_listing <- ggplot(temp4, aes(x=factor(flag_listing), y=prob_nw_eth_census_ln)) +
  geom_boxplot()

pre_plt_nc_listing <- ggplot(temp4, aes(x=factor(flag_listing), y=prob_nw_eth_nc)) +
  geom_boxplot()


# create all plots for only 2019and2020 data  -------------------------


temp3 <- temp1 %>%
  filter(founding_year>2010)

recent_plt_wiki_listing <- ggplot(temp3, aes(x=factor(flag_listing), y=prob_nw_eth_wiki)) +
  geom_boxplot()

recent_plt_fl_reg_name_listing <- ggplot(temp3, aes(x=factor(flag_listing), y=prob_nw_eth_fl_reg_name)) +
  geom_boxplot()

recent_plt_fl_fivecat_listing <- ggplot(temp3, aes(x=factor(flag_listing), y=prob_nw_eth_fl_five_cat)) +
  geom_boxplot()

recent_plt_census_fn_listing <- ggplot(temp3, aes(x=factor(flag_listing), y=prob_nw_eth_census_fn)) +
  geom_boxplot()

recent_plt_census_ln_listing <- ggplot(temp3, aes(x=factor(flag_listing), y=prob_nw_eth_census_ln)) +
  geom_boxplot()

recent_plt_nc_listing <- ggplot(temp3, aes(x=factor(flag_listing), y=prob_nw_eth_nc)) +
  geom_boxplot()


# create plot for NAMSOR -------------------------

namsor_plt_nc_listing <- ggplot(namsor, aes(x=factor(true_race), y=pred_race)) +
  geom_boxplot()

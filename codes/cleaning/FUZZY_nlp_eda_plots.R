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
# create b&w plots for the weighted methods combined -------------------------

# clean owner data to make it weighted + remove unncecessary columns 

cleaned_owner <- owner %>% select(-prob_nw_eth_census_fn, -prob_nw_eth_census_ln)
#weights <- c(0.556767, 0.545364, 0.548339, 0.548339)
# Calculate the sum of the weights
#sum_of_weights <- sum(weights)
# Calculate the weighted sum of the last 6 columns for each row
#cleaned_owner$weighted_sum <- rowSums(cleaned_owner[, tail(names(cleaned_owner), 4)] * weights) / sum_of_weights
# If you want to keep only the 'weighted_sum_last_6' column and drop the individual columns, you can do:



# Assuming you have a dataframe called cleaned_owner and a vector of weights
weights <- c(0.556767, 0.545364, 0.548339, 0.548339)

# Function to calculate the weighted sum for each row, considering only non-NA values
calculate_weighted_sum <- function(row) {
  non_na_values <- na.omit(row)
  weighted_sum <- sum(non_na_values * weights[1:length(non_na_values)])
  return(weighted_sum)
}

# Calculate the sum of non-NA weights
sum_of_weights <- sum(weights[!is.na(weights)])

# Apply the custom function to each row and store the result in 'weighted_sum' column
cleaned_owner$weighted_sum <- apply(cleaned_owner[, tail(names(cleaned_owner), 4)], 1, calculate_weighted_sum)

# Divide the 'weighted_sum' by the sum of non-NA weights
cleaned_owner$weighted_sum <- cleaned_owner$weighted_sum / sum_of_weights





df <- cleaned_owner[, -c((ncol(cleaned_owner) - 3):(ncol(cleaned_owner) - 1))]

temp2 <- cbind(temp1, cleaned_owner$weighted_sum)

plt_cleaned_owner <- ggplot(temp2, aes(x=factor(flag_listing), y=cleaned_owner$weighted_sum)) +
  geom_boxplot()

# Analysis
# create map

# load libraries
library(readr)
library(dplyr)
library(tigris)
library(ggplot2)

data <- read_csv('data/mergent_and_library/predicted_mergent.csv') %>%
  select(duns,flag_mergent,flag_predicted)
mi <- read_csv('data/mergent_and_library/mi_acs_geolocate.csv') %>%
  select(duns,geoid)

# merge the data
temp <- merge(data, mi, by='duns')
temp1 <- temp %>%
  group_by(geoid) %>%
  summarise(total=length(duns),
            mergent_minority=100*sum(flag_mergent)/total,
            predicted_minority=100*sum(flag_predicted)/total)

tract_2020 <- tracts( 'VA', 'Fairfax County', year='2020') %>% select(geoid=GEOID, geometry)
temp2 <- merge(temp1, tract_2020, by='geoid')

# map the number of minority
plt1 <- ggplot(data = temp2, aes(geometry = geometry, fill = mergent_minority)) +
  geom_sf() +
  scale_y_continuous() +
  scale_fill_gradient2(low='red',
                       mid='blue',
                       high='green',
                       aesthetics='fill') +
  labs(fill='Percentage', x='Latitude', y='Longitude', title='Distribution of minority owned businesses by census tracts using MI')
plt1

plt2 <- ggplot(data = temp2, aes(geometry = geometry, fill = predicted_minority)) +
  geom_sf() +
  scale_y_continuous() +
  scale_fill_gradient2(low='red',
                       mid='blue',
                       high='green',
                       aesthetics='fill') +
  labs(fill='Percentage', x='Latitude', y='Longitude', title='Distribution of minority owned businesses by census tracts using classifier')
plt2



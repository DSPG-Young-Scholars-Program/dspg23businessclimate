# This script allow to use yelp api and get data
# source: https://rpubs.com/fitzpatrickm8/yelpapi

# library
library('tidyverse')
library('httr')


#functions
# 1. function to format the data
yelp_httr_parse <- function(x) {
  
  parse_list <- list(id = x$id, 
                     name = x$name, 
                     rating = x$rating, 
                     review_count = x$review_count, 
                     latitude = x$coordinates$latitude, 
                     longitude = x$coordinates$longitude, 
                     address1 = x$location$address1, 
                     city = x$location$city, 
                     state = x$location$state, 
                     distance = x$distance)
  
  parse_list <- lapply(parse_list, FUN = function(x) ifelse(is.null(x), "", x))
  
  df <- data_frame(id=parse_list$id,
                   name=parse_list$name, 
                   rating = parse_list$rating, 
                   review_count = parse_list$review_count, 
                   latitude=parse_list$latitude, 
                   longitude = parse_list$longitude, 
                   address1 = parse_list$address1, 
                   city = parse_list$city, 
                   state = parse_list$state, 
                   distance= parse_list$distance)
  df
}



# create a token
client_id <- Sys.getenv("yelp_ID")
client_secret <- Sys.getenv("yelp_api_key")

res <- POST("https://api.yelp.com/oauth2/token",
            body = list(grant_type = "client_credentials",
                        client_id = client_id,
                        client_secret = client_secret))
token <- content(res)$access_token


# create a search url to collect the data
yelp <- "https://api.yelp.com"
term <- "minority"
location <- "Fairfax, VA"
categories <- NULL
limit <- 100
radius <- NULL
url <- modify_url(yelp, path = c("v3", "businesses", "search"),
                  query = list(term = term, location = location, 
                               limit = limit,
                               radius = radius))
res <- GET(url, add_headers('Authorization' = paste("bearer", client_secret)))
results <- content(res)


# format the data
results_list <- lapply(results$businesses, FUN = yelp_httr_parse)
business_data <- do.call("rbind", results_list)


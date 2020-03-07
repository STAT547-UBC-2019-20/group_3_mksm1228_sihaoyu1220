"This script cleans Airbnb raw data by:
1. combining seven dataset into one file
2. selecting useful variables
3. Convert price from dollar format to numeric format
Usage: load_data.R --path=<path> --filename=<filename>
" -> doc 

suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(here))
library(docopt)

opt <- docopt(doc) 


main <- function(path, filename) {
  print("Loading the datasets...")
  Vancouver <- suppressWarnings(suppressMessages(readr::read_csv(glue::glue(path,"Vancouver.csv"))))
  Montreal <- suppressWarnings(suppressMessages(readr::read_csv(glue::glue(path,"Montreal.csv"))))
  New_Brunswick <- suppressWarnings(suppressMessages(readr::read_csv(glue::glue(path,"New%20Brunswick.csv"))))
  Ottawa <- suppressWarnings(suppressMessages(readr::read_csv(glue::glue(path,"Ottawa.csv"))))
  Quebec <- suppressWarnings(suppressMessages(readr::read_csv(glue::glue(path,"Quebec.csv"))))
  Toronto <- suppressWarnings(suppressMessages(readr::read_csv(glue::glue(path,"Toronto.csv"))))
  Victoria <- suppressWarnings(suppressMessages(readr::read_csv(glue::glue(path,"Victoria.csv"))))
  print("Cleaning the datasets...")
Vancouver <- Vancouver %>% 
  select(id, host_id, host_is_superhost, city, property_type, room_type, accommodates, bathrooms, bedrooms, beds, cancellation_policy, price) %>% 
  mutate(city = "Vancouver")
Montreal <- Montreal %>% 
  select(id, host_id, host_is_superhost, city, property_type, room_type, accommodates, bathrooms, bedrooms, beds, cancellation_policy, price) %>% 
  mutate(city = "Montreal")
New_Brunswick <- New_Brunswick %>% 
  select(id, host_id, host_is_superhost, city, property_type, room_type, accommodates, bathrooms, bedrooms, beds, cancellation_policy, price) %>% 
  mutate(city = "New Brunswick")
Ottawa <- Ottawa %>% 
  select(id, host_id, host_is_superhost, city, property_type, room_type, accommodates, bathrooms, bedrooms, beds, cancellation_policy, price) %>% 
  mutate(city = "Ottawa")
Quebec <- Quebec %>% 
  select(id, host_id, host_is_superhost, city, property_type, room_type, accommodates, bathrooms, bedrooms, beds, cancellation_policy, price) %>% 
  mutate(city = "Quebec")
Toronto <- Toronto %>% 
  select(id, host_id, host_is_superhost, city, property_type, room_type, accommodates, bathrooms, bedrooms, beds, cancellation_policy, price) %>% 
  mutate(city = "Toronto")
Victoria <- Victoria %>% 
  select(id, host_id, host_is_superhost, city, property_type, room_type, accommodates, bathrooms, bedrooms, beds, cancellation_policy, price) %>% 
  mutate(city = "victoria")
cleaned_data <- rbind(Vancouver, Montreal, New_Brunswick, Ottawa, Quebec, Toronto, Victoria)
cleaned_data$price <- as.numeric(gsub('\\$|,', '', cleaned_data$price))
readr::write_csv(cleaned_data, here::here("Data", glue::glue(filename,".csv")))
print("The datasets have been cleaned successfully!")
}

#' Clean the Airbnb raw data and save the cleaned data in the data directory
#' @param path is the path to the Data folder
#' 
#' @param filename is the name of the cleaned data.

main(opt$path, opt$filename)

#path<-https://github.com/STAT547-UBC-2019-20/group_3_mksm1228_sihaoyu1220/raw/master/Data/"
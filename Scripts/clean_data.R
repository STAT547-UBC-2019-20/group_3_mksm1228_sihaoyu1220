"This script cleans Airbnb raw data by:
1. combining seven dataset into one file
2. selecting useful variables
3. Convert price from dollar format to numeric format
Usage: clean_data.R --path=<path> --filename=<filename>
" -> doc 

suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(here))
library(docopt)

opt <- docopt(doc) 


main <- function(path, filename) {
  print("Loading the datasets...")
  Vancouver <- suppressWarnings(suppressMessages(readr::read_csv(here::here(path,"Vancouver.csv"))))
  Montreal <- suppressWarnings(suppressMessages(readr::read_csv(here::here(path,"Montreal.csv"))))
  New_Brunswick <- suppressWarnings(suppressMessages(readr::read_csv(here::here(path,"New Brunswick.csv"))))
  Ottawa <- suppressWarnings(suppressMessages(readr::read_csv(here::here(path,"Ottawa.csv"))))
  Quebec <- suppressWarnings(suppressMessages(readr::read_csv(here::here(path,"Quebec.csv"))))
  Toronto <- suppressWarnings(suppressMessages(readr::read_csv(here::here(path,"Toronto.csv"))))
  Victoria <- suppressWarnings(suppressMessages(readr::read_csv(here::here(path,"Victoria.csv"))))
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
readr::write_csv(cleaned_data, here::here(path, glue::glue(filename,".csv")))
message(glue::glue("The datasets have been cleaned successfully! ",filename, ".csv has been saved in ", path, " folder."))
}

#' Clean the Airbnb raw data and save the cleaned data in the data directory
#' @param path is the path to the Data folder
#' @param filename is the name of the cleaned data.

main(opt$path, opt$filename)

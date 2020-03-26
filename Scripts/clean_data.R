"This script cleans Airbnb raw data by:
1. combining seven dataset into one file
2. selecting useful variables
3. Convert price from dollar format to numeric format
Usage: clean_data.R --path=<path> --filename=<filename>
" -> doc 

library(data.table)
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(here))
library(docopt)
suppressPackageStartupMessages(library(testthat))
suppressPackageStartupMessages(library(purrr))

opt <- docopt(doc) 


main <- function(path, filename) {
  
  test_that("path and filename are strings",{
    expect_true(is.character(path))
    expect_true(is.character(filename))
  })
  
  print("Loading the datasets...")
  files<-list.files(path = here::here("Data"),pattern = "*raw.csv")  
  list_of_data<-suppressWarnings(suppressMessages(sapply(here::here("Data",files), read_csv, simplify = FALSE)))
  print("Cleaning the datasets...")
  
  names(list_of_data) <- sub("_raw.csv", "", files)

  output <- list_of_data %>% 
    map(function(x) x %>% select(id, host_id, host_is_superhost, city, property_type, room_type, accommodates, bathrooms, bedrooms, beds, cancellation_policy, price)) %>% 
    map(function(x) x %>% mutate(city = as.character(names(which.max(table(x$city))))))
  output$`new-brunswick`$city <- "New Brunswick"

  cleaned_data <- bind_rows(output)
  cleaned_data$price <- as.numeric(gsub('\\$|,', '', cleaned_data$price))
  readr::write_csv(cleaned_data, here::here(path, glue::glue(filename,".csv")))

  test_that("File exists",{
    expect_true(file.exists(here::here("Data","cleaned_data.csv")))
  })

  message(glue::glue("The datasets have been cleaned successfully! ",filename, ".csv has been saved in ", path, " folder."))
}

#' Clean the Airbnb raw data and save the cleaned data in the data directory
#' @param path is the path to the Data folder
#' @param filename is the name of the cleaned data.

main(opt$path, opt$filename)

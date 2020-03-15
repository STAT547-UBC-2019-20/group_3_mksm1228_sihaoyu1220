"This script downloads the all Canadian Airbnb csv file from Inside Airbnb website.
Usage: load_data.R --data_url=<data_url> --city=<city>
" -> doc 
library(docopt)
library(data.table)
library(testthat)
library(here)
suppressPackageStartupMessages(library(testthat))

opt <- docopt(doc) 

main <- function(data_url, city) {
  test_that("data_url and city are strings",{
    expect_true(is.character(data_url))
    expect_true(is.character(city))
  })
  
  if (('Montreal' %in% city)|('Canada' %in% city)){
  message("Attempting to download Montreal data...")
  data <-  fread(paste0(data_url,"qc/montreal/2020-01-13/data/listings.csv.gz"))
  write.csv(data, here::here("Data", "Montreal.csv"))
  test_that("Montreal.csv exists",{
    expect_true(file.exists(here::here("Data", "Montreal.csv")))
  })
  message("Montreal data has been downloaded successfully!")
  }
  
  if (('New_Brunswick' %in% city)|('Canada' %in% city)){
  message("Attempting to download New Brunswick data...")
  data <-  fread(paste0(data_url,"nb/new-brunswick/2020-01-28/data/listings.csv.gz"))
  write.csv(data, here::here("Data", "New Brunswick.csv"))
  test_that("New Brunswick.csv exists",{
    expect_true(file.exists(here::here("Data", "New Brunswick.csv")))
  })
  message("New Brunswick data has been downloaded successfully!")
  }
  
  if (('Ottawa' %in% city)|('Canada' %in% city)){
  message("Attempting to download Ottawa data...")
  data <-  fread(paste0(data_url,"on/ottawa/2020-01-31/data/listings.csv.gz"))
  write.csv(data, here::here("Data", "Ottawa.csv"))
  test_that("Ottawa.csv exists",{
    expect_true(file.exists(here::here("Data", "Ottawa.csv")))
  })
  message("Ottawa data has been downloaded successfully!")
  }
  
  if (('Quebec' %in% city)|('Canada' %in% city)){
  message("Attempting to download Quebec data...")
  data <-  fread(paste0(data_url,"qc/quebec-city/2020-02-16/data/listings.csv.gz"))
  write.csv(data, here::here("Data", "Quebec.csv"))
  test_that("Quebec.csv exists",{
    expect_true(file.exists(here::here("Data", "Quebec.csv")))
  })
  message("Quebec data has been downloaded successfully!")
  }
  
  if (('Toronto' %in% city) |('Canada' %in% city)){
  message("Attempting to download Toronto data...")
  data <-  fread(paste0(data_url,"on/toronto/2020-02-14/data/listings.csv.gz"))
  write.csv(data, here::here("Data", "Toronto.csv"))
  test_that("Toronto.csv exists",{
    expect_true(file.exists(here::here("Data", "Toronto.csv")))
  })
  message("Toronto data has been downloaded successfully!")
  }
  
  if (('Vancouver' %in% city)|('Canada' %in% city)){
  message("Attempting to download Vancouver data...")
  data <-  fread(paste0(data_url,"bc/vancouver/2020-02-16/data/listings.csv.gz"))
  write.csv(data, here::here("Data", "Vancouver.csv"))
  test_that("Vancouver.csv exists",{
    expect_true(file.exists(here::here("Data", "Vancouver.csv")))
  })
  message("Vancouver data has been downloaded successfully!")
  }
  
  if (('Victoria' %in% city)|('Canada' %in% city)){
  message("Attempting to download Victoria data...")
  data <-  fread(paste0(data_url,"bc/victoria/2020-01-28/data/listings.csv.gz"))
  write.csv(data, here::here("Data", "Victoria.csv"))
  test_that("Victoria.csv exists",{
    expect_true(file.exists(here::here("Data", "Victoria.csv")))
  })
  message("Victoria data has been downloaded successfully!")
  }
  
  if (! city %in% c("Canada","Montreal","New_Brunswick","Ottawa","Quebec","Toronto","Vancouver","Victoria")){
    message(glue::glue("Error: ",city, " cannot be downloaded."))
  }
  
  if (city %in% c("Canada","Montreal","New_Brunswick","Ottawa","Quebec","Toronto","Vancouver","Victoria")){
    message("All datasets have been saved in Data folder")
  }
}

#' Download and save the Airbnb data in the data directory
#' @param data_url is the shared segment of URL for all Canada Airbnb dataset; it's not
#' a sepecific dataset link
#' 
#' @param city is a string. If `city` is `Canada`, download all Airbnb dataset in Canada;
#' If `city` is one of `Montreal`,`New_Brunswick`,`Ottawa`,`Quebec`,`Toronto`,`Vancouver`,`Victoria`,
#' download Airbnb dataset for that specific city. If `city` is none of the above, message error message.

test_that("Files exist", {
  expect_true(file.exists(here("Data", "Montreal.csv")))
  expect_true(file.exists(here("Data", "New Brunswick.csv")))
  expect_true(file.exists(here("Data", "Ottawa.csv")))
  expect_true(file.exists(here("Data", "Quebec.csv")))
  expect_true(file.exists(here("Data", "Toronto.csv")))
  expect_true(file.exists(here("Data", "Vancouver.csv")))
  expect_true(file.exists(here("Data", "Victoria.csv")))
})

main(opt$data_url, opt$city)

#data_url=http://data.insideairbnb.com/canada/

#Montreal: http://data.insideairbnb.com/canada/qc/montreal/2020-01-13/data/listings.csv.gz
#New Brunswick: http://data.insideairbnb.com/canada/nb/new-brunswick/2020-01-28/data/listings.csv.gz
#Ottawa: http://data.insideairbnb.com/canada/on/ottawa/2020-01-31/data/listings.csv.gz
#Quebec:http://data.insideairbnb.com/canada/qc/quebec-city/2020-02-16/data/listings.csv.gz
#Toronto:http://data.insideairbnb.com/canada/on/toronto/2020-02-14/data/listings.csv.gz
#Vancouver:http://data.insideairbnb.com/canada/bc/vancouver/2020-02-16/data/listings.csv.gz
#Victoria: http://data.insideairbnb.com/canada/bc/victoria/2020-01-28/data/listings.csv.gz
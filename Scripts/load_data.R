"This script downloads the all Canadian Airbnb csv file from Inside Airbnb website.
Usage: load_data.R --data_url=<data_url> 
" -> doc 
library(docopt)
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(here))
suppressPackageStartupMessages(library(testthat))
suppressPackageStartupMessages(library(purrr))
suppressPackageStartupMessages(library(readr))

opt <- docopt(doc) 

main <- function(data_url) {
  test_that("data_url and city are strings",{
    expect_true(is.character(data_url))
  })
  list_url <- list("qc/montreal/2020-01-13/data/listings.csv.gz", 
                   "nb/new-brunswick/2020-01-28/data/listings.csv.gz",
                   "on/ottawa/2020-01-31/data/listings.csv.gz",
                   "qc/quebec-city/2020-02-16/data/listings.csv.gz",
                   "on/toronto/2020-02-14/data/listings.csv.gz",
                   "bc/vancouver/2020-02-16/data/listings.csv.gz",
                   "bc/victoria/2020-01-28/data/listings.csv.gz")
  message("Trying to download the datasets...")
  list_data <- map(paste0(data_url,list_url),fread)
  message("All datasets have been successfully downloaded!")
  list_city <- substring(sub("/2020.*", "", list_url),4)
  invisible(capture.output(map2(list_data, list_city, ~write_csv(.x, path = here::here("Data",glue::glue(.y, "_raw.csv"))))))
  message("All datasets have been successfully saved in Data folder!")
}
#' Download and save the Airbnb data in the data directory
#' @param data_url is the shared segment of URL for all Canada Airbnb dataset; it's not
#' a sepecific dataset link

main(opt$data_url)

#data_url=http://data.insideairbnb.com/canada/

#Montreal: http://data.insideairbnb.com/canada/qc/montreal/2020-01-13/data/listings.csv.gz
#New Brunswick: http://data.insideairbnb.com/canada/nb/new-brunswick/2020-01-28/data/listings.csv.gz
#Ottawa: http://data.insideairbnb.com/canada/on/ottawa/2020-01-31/data/listings.csv.gz
#Quebec:http://data.insideairbnb.com/canada/qc/quebec-city/2020-02-16/data/listings.csv.gz
#Toronto:http://data.insideairbnb.com/canada/on/toronto/2020-02-14/data/listings.csv.gz
#Vancouver:http://data.insideairbnb.com/canada/bc/vancouver/2020-02-16/data/listings.csv.gz
#Victoria: http://data.insideairbnb.com/canada/bc/victoria/2020-01-28/data/listings.csv.gz
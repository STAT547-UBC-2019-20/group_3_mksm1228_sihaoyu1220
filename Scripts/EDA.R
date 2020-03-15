"This script performs EDA for cleaned Airbnb data. Output is four plots:
1. Barplot: shows the number of Airbnb listings in different Canadian cities
2. Proportional bar chart: shows how many Airbnb superhosts are there in different Canadian cities
3. Correllogram: shows relationship between the number of accommodates and other features of the listing
4. Side-by-side boxplot: shows the distribution of the price per night in different Canadian cities
Usage: EDA.R --data_path=<data_path> --image_path=<image_path>
" -> doc 
library(docopt)
suppressMessages(library(data.table))
suppressMessages(library(corrplot))
suppressMessages(library(tidyverse))
suppressMessages(library(testthat))

opt <- docopt(doc) 

main <- function(data_path, image_path) {
  
  test_that("data_path and image_path are strings",{
    expect_true(is.character(data_path))
    expect_true(is.character(image_path))
  })
  
  plot1(data_path, image_path)
  message("Barplot has been produced successfully!")
  plot2(data_path, image_path)
  message("Proportional bar chart has been produced successfully!")
  plot3(data_path, image_path)
  message("Correllogram has been produced successfully!")
  plot4(data_path, image_path)
  message("Side-by-side boxplot has been produced successfully!")
  message(glue::glue("All plots have been saved in the path ", image_path))
}

plot1 <- function(data_path, image_path){
  data <- read.csv(here::here(data_path))
  data %>% 
    ggplot(aes(x = fct_infreq(city)))+
    geom_bar(stat="count")+
    labs(x = "City", y = "Count", title = "Number of Listings by City") + 
    geom_text(stat='count',aes(label=..count..), vjust=-0.3, size=3.5) + 
    theme_bw() +
    theme(plot.title = element_text(hjust = 0.5))+
    suppressMessages(ggsave(here::here(image_path,"Number_of_listings.png")))
  
  test_that("plot 1 exists",{
    expect_true(file.exists(here::here("Images", "Number_of_listings.png")))
  })
}

plot2 <- function(data_path, image_path){
  data <- read.csv(here::here(data_path))
  host <- distinct(data, host_id, .keep_all = TRUE)
  plot <- host %>% 
    filter(host_is_superhost == TRUE | host_is_superhost == FALSE) %>% 
    ggplot()+
    geom_bar(mapping = aes(x=city, fill = host_is_superhost),
             position = "fill")+
    ylab("Proportion of superhost")+
    xlab("City")+
    ggtitle("Proportion of Superhosts by City")+
    scale_fill_brewer(name = "Superhost", palette="Paired")+
    theme_bw()+
    theme(plot.title = element_text(hjust = 0.5))+
    suppressMessages(ggsave(here::here(image_path,"Proportion_of_superhosts.png")))
  
  test_that("plot 2 exists",{
    expect_true(file.exists(here::here("Images", "Proportion_of_superhosts.png")))
  })
}

plot3 <- function(data_path, image_path){
  data <- read.csv(here::here(data_path))
  data[7:10] <- sapply(data[7:10] , as.double)
  corr <- cor(na.omit(data[7:10]))
  png(glue::glue(image_path,'/Correlation_between_room_facilities.png'))
  corrplot(corr, method="color", tl.srt=0,type="lower",
           title = "Correlation between room facilities",mar=c(0,0,1,0))
  dev.off()
  
  test_that("plot 3 exists",{
    expect_true(file.exists(here::here("Images", "Correlation_between_room_facilities.png")))
  })
}

plot4 <- function(data_path, image_path){
  options(warn = -1)
  data <- read.csv(here::here(data_path))
  ggplot(data)+geom_boxplot(aes(city, log10(price), group = city))+
                     suppressMessages(ggsave(here::here(image_path,"Boxplot_of_price.png")))
  
  test_that("plot 4 exists",{
    expect_true(file.exists(here::here("Images", "Boxplot_of_price.png")))
  })
}
#' Download and save the Airbnb data in the data directory
#' @param data_path is the path to load cleaned_data
#' @param image_path is where exported images should be saved (Images folder)

main(opt$data_path, opt$image_path)

#data_path = Data/cleaned_data.csv
#image_path = Images
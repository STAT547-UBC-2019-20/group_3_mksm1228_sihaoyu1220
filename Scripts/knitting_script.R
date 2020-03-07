"This scripts knits the draft to an html or pdf file. Please enter the file you 
wish to knit into the first argument and the file type 'html' or 'pdf' in the second
argument.

Usage: knitting_script.R<file, file_type>
" -> doc 

library(knitr)
library(docopt)
library(here)
library(testthat)

opt <- docopt(doc)

main <- function(file_type){
  file <- here("Docs", "Milestone 1.Rmd")
  if (file_type == "html"){
    rmarkdown::render(file, "html_document", output_dir = "Docs")
  }  
  if (file_type == "pdf"){
    rmarkdown::render(file, "pdf_document", output_dir = "Docs")
  }
  
  ### Tests
  
  test_that("Correct file type written", {
    if (file_type == "html"){
      expect_match("html", file_type)
    }
    if (file_type == "pdf"){
      expect_match("pdf", file_type)
    } 
    else {
      print("Please input 'html' or 'pdf.'")
    } 
  })
  
  
}

main(file_type)


main(opt$file, opt$file_type)

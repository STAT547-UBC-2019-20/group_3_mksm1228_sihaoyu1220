"This is a script that will knit the file to either html or pdf. Please enter
Final_Report.Rmd into the final_name argument and the file type (html or pdf) you wish
to knit the Final_Report.Rmd into.
Usage: knitting.R --file_name=Final_Report.Rmd --file_type=html/pdf
" -> doc 

library(knitr)
suppressMessages(library(docopt))
library(testthat)
suppressMessages(library(here))

opt <- docopt(doc)

main <- function(file_name, file_type){
  file_name <- here("Docs", file_name) # write down file name you want to knit
  if (file_type == "html"){
    test_that("Correct file input",{
      expect_match(file_name, "Final_Report.Rmd")
    })
    rmarkdown::render(file_name, "html_document", output_dir = "Docs")
      test_that("File exists",{
        expect_true(file.exists(here("Docs", "Final_Report.html")))
      })
    print("HTML file has been created and stored in Docs.")
  }  
  else if (file_type == "pdf"){
    test_that("Correct file input",{
      expect_match(file_name, "Final_Report.Rmd")
    })
    rmarkdown::render(file_name, "pdf_document", output_dir = "Docs")
      test_that("File exists",{
        expect_true(file.exists(here("Docs", "Final_Report.pdf")))
      })
    print("pdf file has been created and stored in Docs.")
  } 
  else {
    print("Please enter html or pdf into file_type.")
  }
    
}

main(opt$file_name,opt$file_type)
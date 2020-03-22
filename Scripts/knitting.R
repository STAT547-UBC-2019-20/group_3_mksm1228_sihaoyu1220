"This is a script that will knit the file to either html or pdf. Please enter
Final_Report.Rmd into the final_name argument and the file type (html or pdf) you wish
to knit the Final_Report.Rmd into.
Usage: knitting.R --rmd_file=<rmd_file>
" -> doc 

suppressMessages(library(knitr))
library(docopt)
suppressMessages(library(testthat))
suppressMessages(library(here))

opt <- docopt(doc)

# knitting RMD file to HTML and PDF simultaneously
# @param rmd_file is string 
# @example Rscript knitting.R --rmd_file="Final_Report.Rmd"

main <- function(rmd_file){
  rmarkdown::render(input = here("Docs", rmd_file), 
  output_format = c("pdf_document", "html_document"),
  output_dir = here("Docs")
  )
  print("Html and PDF documents have been succesfully created.")
  test_that("File exists",{
    expect_true(file.exists(here("Docs", "Final_Report.pdf")))
    expect_true(file.exists(here("Docs", "Final_Report.html")))
  })
}

main(opt$rmd_file)
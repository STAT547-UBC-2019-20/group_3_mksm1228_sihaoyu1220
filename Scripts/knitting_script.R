"This scripts knits the draft to an html or pdf file. Please enter the file you 
wish to convert into the first argument and the file type 'html' or 'pdf' in the second
argument."

Usage: knitting_script.R<file_type>
doc 

library(knitr)
library(docopt)


opt <- docopt(doc)

main <- function(file, file_type){
  if (file_type == "html"){
    rmarkdown::render(file, "html_document")
  }  
  if (file_type == "pdf"){
    rmarkdown::render(file, "pdf_document")
  }
  else {
    print("That is not a valid file format. Please enter 'html' or 'pdf.'")
  }}

main(file, opt$file_type)

### Tests
test_that("Check if file output",)

main(opt$file, opt$file_type)

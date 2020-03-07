"This scripts knits the draft to an html or pdf file. Please enter the file you 
wish to knit into the first argument and the file type 'html' or 'pdf' in the second
argument.

Usage: knitting_script.R<file_type>
" -> doc 

library(knitr)
library(docopt)
library(here)


opt <- docopt(doc)

main <- function(file_type){
  file <- here("Docs", file) # write down file name you want to knit
  if (file_type == "html"){
    rmarkdown::render(file, "html_document", output_dir = "Docs")
  }  
  if (file_type == "pdf"){
    rmarkdown::render(file, "pdf_document", output_dir = "Docs")
  }
  
  
  
}

main(file_type)


main(opt$file_type)

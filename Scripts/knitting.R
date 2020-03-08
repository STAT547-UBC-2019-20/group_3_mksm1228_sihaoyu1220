"This is a script that will knit the file to either html or pdf. Please enter file type 'html' or 'pdf'
in the argument.
Usage: knitting.R --file_name=<file_name> --file_type=<file_type>
" -> doc 

library(knitr)
library(docopt)
suppressMessages(library(here))

opt <- docopt(doc)

main <- function(file_name, file_type){
  file_name <- here("Docs", file_name) # write down file name you want to knit
  if (file_type == "html"){
    rmarkdown::render(file_name, "html_document", output_dir = "Docs")
    print("HTML file has been created and stored in Docs.")
  }  
  if (file_type == "pdf"){
    rmarkdown::render(file_name, "pdf_document", output_dir = "Docs")
    print("pdf file has been created and stored in Docs.")
  }
}

main(opt$file_name,opt$file_type)
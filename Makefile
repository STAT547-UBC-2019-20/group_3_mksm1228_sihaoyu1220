all: Docs/Final_Report.html Docs/Final_Report.pdf

# download data
#Data/Montreal.csv Data/New Brunswick.csv Data/Ottawa.csv Data/Quebec.csv Data/Toronto.csv Data/Vancouver.csv Data/Victoria.csv : Scripts/load_data.R
#	Rscript Scripts/load_data.R --data_url=http://data.insideairbnb.com/canada/ --city=Canada

Data/Montreal.csv: Scripts/load_data.R
	@rm -f Data/Montreal.csv
	@touch Data/Montreal.csv
	Rscript Scripts/load_data.R --data_url=http://data.insideairbnb.com/canada/ --city=Canada
	@mv -f Data/Montreal.csv $@
	
Data/New Brunswick.csv Data/Ottawa.csv Data/Quebec.csv Data/Toronto.csv Data/Vancouver.csv Data/Victoria.csv: Data/Montreal.csv
## Recover from the removal of $@
	@if test -f $@; then :; else \
	rm -f data.stamp; \
	$(MAKE) $(AM_MAKEFLAGS) Data/Montreal.csv; \
	fi

        
# clean data
Data/cleaned_data.csv : Scripts/clean_data.R Data/Montreal.csv Data/New Brunswick.csv Data/Ottawa.csv Data/Quebec.csv Data/Toronto.csv Data/Vancouver.csv Data/Victoria.csv
	Rscript Scripts/clean_data.R --path=Data --filename=cleaned_data

# EDA
Images/Number_of_listings.png Images/Proportion_of_superhosts.png Images/Correlation_between_room_facilities.png Images/Boxplot_of_price.png : Scripts/EDA.R Data/cleaned_data.csv
	Rscript Scripts/EDA.R --data_path=Data/cleaned_data.csv --image_path=Images

# linear regression

RDS/step_lm.rds Images/Model_Diagnostics.png : Data/cleaned_data.csv Scripts/linear_regression.R
	Rscript Scripts/linear_regression.R --datafile=cleaned_data.csv

# Knit report
Docs/Final_Report.html : Images/Number_of_listings.png Images/Proportion_of_superhosts.png Images/Correlation_between_room_facilities.png Images/Boxplot_of_price.png RDS/step_lm.rds Images/Model_Diagnostics.png Docs/Final_Report.Rmd Data/cleaned_data.csv Scripts/knitting.R
	Rscript Scripts/knitting.R --file_name=Final_Report.Rmd --file_type=html

Docs/Final_Report.pdf : Images/Number_of_listings.png Images/Proportion_of_superhosts.png Images/Correlation_between_room_facilities.png Images/Boxplot_of_price.png Docs/Final_Report.Rmd RDS/step_lm.rds Images/Model_Diagnostics.png Data/cleaned_data.csv Scripts/knitting.R
	Rscript Scripts/knitting.R --file_name=Final_Report.Rmd --file_type=pdf

clean :
	rm -f Data/*.csv
	rm -f Images/*.png
	rm -f RDS/*.rds
	rm -f Docs/*.html
	rm -f Docs/*.pdf
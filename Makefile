all: Docs/Final_Report.html Docs/Final_Report.pdf

## download data
#Data/new-brunswick_raw.csv Data/ottawa_raw.csv Data/quebec-city_raw.csv Data/toronto_raw.csv Data/vancouver_raw.csv Data/victoria_raw.csv Data/montreal_raw.csv : Scripts/load_data.R
#	Rscript Scripts/load_data.R --data_url=http://data.insideairbnb.com/canada/
#	@mv -t Data/montreal_raw.csv $@
#	
#Data/new-brunswick_raw.csv Data/ottawa_raw.csv Data/quebec-city_raw.csv Data/toronto_raw.csv Data/vancouver_raw.csv Data/victoria_raw.csv Data/montreal_raw.csv
## Recover from the removal of $@
#	@if test -f $@; then :; else \
#	rm -f data.stamp; \
#	$(MAKE) $(AM_MAKEFLAGS) Data/montreal_raw.csv; \
#	fi

# download data
Data/montreal_raw.csv Data/new-brunswick_raw.csv Data/ottawa_raw.csv Data/quebec-city_raw.csv Data/toronto_raw.csv Data/vancouver_raw.csv Data/victoria_raw.csv : Scripts/load_data.R
	Rscript Scripts/load_data.R --data_url=http://data.insideairbnb.com/canada/
      
# clean data
Data/cleaned_data.csv : Scripts/clean_data.R Data/montreal_raw.csv Data/new-brunswick_raw.csv Data/ottawa_raw.csv Data/quebec-city_raw.csv Data/toronto_raw.csv Data/vancouver_raw.csv Data/victoria_raw.csv
	Rscript Scripts/clean_data.R --path=Data --filename=cleaned_data

# EDA
Images/Number_of_listings.png Images/Proportion_of_superhosts.png Images/Correlation_between_room_facilities.png Images/Boxplot_of_price.png : Scripts/EDA.R Data/cleaned_data.csv
	Rscript Scripts/EDA.R --data_path=Data/cleaned_data.csv --image_path=Images

# linear regression

RDS/step_lm.rds Images/Model_Diagnostics.png : Data/cleaned_data.csv Scripts/linear_regression.R
	Rscript Scripts/linear_regression.R --datafile=cleaned_data.csv

# Knit report
Docs/Final_Report.html Docs/Final_Report.pdf : Images/Number_of_listings.png Images/Proportion_of_superhosts.png Images/Correlation_between_room_facilities.png Images/Boxplot_of_price.png RDS/step_lm.rds Images/Model_Diagnostics.png Docs/Final_Report.Rmd Data/cleaned_data.csv Scripts/knitting.R
	Rscript Scripts/knitting.R --rmd_file=Final_Report.Rmd 

clean :
	rm -f Data/*.csv
	rm -f Images/*.png
	rm -f RDS/*.rds
	rm -f Docs/*.html
	rm -f Docs/*.pdf
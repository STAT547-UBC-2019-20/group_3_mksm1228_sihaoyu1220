# author: YOUR NAME
# date: 2020-03-15

"This script is the main file that creates a Dash app.

Usage: app.R
"

# Libraries

library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)
library(ggplot2)
library(plotly)

app <- Dash$new()

# Load the data here
## YOUR SOLUTION HERE

app$layout(
  htmlDiv(
    list(
      htmlH1('Predictive Pricing Tool for Canadian Airbnb Listings')
    )
  )
)

app$run_server(debug=TRUE)
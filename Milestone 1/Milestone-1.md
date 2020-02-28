Milestone 1
================

**Airbnb predictive pricing tool for tourists coming to Canada**

**Introduction**

According to Statistics Canada, a recording breaking 22.1 million
international tourists from abroad visited Canada \[1\]. Hotels have
always been the mainstay of accommodations but often the prices are
unaffordable for short-term visitors. Airbnb has proven to be a
successful platform to match hosts with unused space and guests looking
for an affordable place to lodge. Although it is often more affordable
than hotels, it appears that the market price varies greatly from city
to city. In this analysis, we want to investigate which factors are most
likely influencing the price of Airbnb listings for cities in Canada.
This tool may potentially help visitors understand the reasoning behind
the cost of the listings.

\[1\]
<https://www150.statcan.gc.ca/n1/daily-quotidien/200221/dq200221b-eng.htm?indid=3635-2&indgeo=0>

``` r
data$id<-as.factor(data$id)
nlevels(data$id) 
```

    ## [1] 6181

There are 6181 listings.

``` r
data$host_id<-as.factor(data$host_id)
nlevels(data$host_id) #4261 hosts.
```

    ## [1] 4261

There are 4261 hosts.

Select useful variables.

``` r
data <- data %>% 
  select(id, host_id, host_is_superhost, host_listings_count, neighbourhood_cleansed, property_type, room_type, accommodates, bathrooms, bedrooms, beds, price, weekly_price, monthly_price, security_deposit, cleaning_fee, guests_included, extra_people, minimum_nights, maximum_nights, review_scores_rating)
```

Some EDA.

``` r
barplot(table(data$room_type), main="Room Type Summary")
```

![](Milestone-1_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

``` r
data$price <- as.numeric(gsub('[$,]', '', data$price))
plot(data$price, data$minimum_nights, main="minimum nights vs. price", xlab="price", ylab="minimum nights")
```

![](Milestone-1_files/figure-gfm/unnamed-chunk-7-1.png)<!-- -->

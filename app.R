# author: YOUR NAME
# date: 2020-03-15

"This script is the main file that creates a Dash app.

Usage: app.R
"

# Libraries

library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)
library(dashTable)
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(plotly))
suppressPackageStartupMessages(library(here))
suppressPackageStartupMessages(library(tidyverse))

app <- Dash$new()

# Load the data here
data <- read.csv(here("Data","cleaned_data.csv"),header=TRUE)
#remove outliers
data1 <- data %>% 
  filter(!is.na(price)) %>% 
  group_by(city) %>% 
  mutate(limitmin = quantile(price,c(0.25)) - 1.5 * (quantile(price,c(0.75))-quantile(price,c(0.25)))) %>% 
  mutate(limitmax = quantile(price,c(0.75)) + 1.5 * (quantile(price,c(0.75))-quantile(price,c(0.25)))) %>% 
  filter(price >= limitmin & price <= limitmax) %>% 
  mutate(new_acc = ifelse(accommodates>=6, 6, accommodates)) %>% 
  mutate(new_bed = round(ifelse(bedrooms>=3, 3, bedrooms))) %>% 
  mutate(new_bath = round(ifelse(bathrooms>=3, 3, bathrooms)))

levels(data1$cancellation_policy)[4] <- "strict"
levels(data1$cancellation_policy)[4] <- "super_strict"
levels(data1$cancellation_policy)[5] <- "super_strict"

#Create the city dropdowns
cityKey <- tibble(label = as.vector(unique(data1$city)),
                   value = as.vector(unique(data1$city)))
cityDropdown <- dccDropdown(
  id = "city",
  options = map(
    1:nrow(cityKey), function(i){
      list(label=cityKey$label[i], value=cityKey$value[i])
    }),
  value="Montréal"
)

#Create the superhost dropdowns
superhostKey <- tibble(label = c("Super Host","Regular Host"),
                  value =c("TRUE","FALSE"))
superhostDropdown <- dccDropdown(
  id = "superhost",
  options = map(
    1:nrow(superhostKey), function(i){
      list(label=superhostKey$label[i], value=superhostKey$value[i])
    }),
  value = "TRUE"
)

#Create the room type dropdowns
roomKey <- tibble(label = c("Apartment","Hotel room", "Private room","Shared room"),
                       value =c("Entire home/apt","Hotel room","Private room","Shared room"))
roomDropdown <- dccDropdown(
  id = "room_type",
  options = map(
    1:nrow(roomKey), function(i){
      list(label=roomKey$label[i], value=roomKey$value[i])
    }),
  value = "Entire home/apt"
)

#Create the cancellation policy dropdowns
policyKey <- tibble(label = c("Flexible","Moderate", "Strict","Super strict"),
                  value =c("flexible","moderate","strict","super_strict"))
policyDropdown <- dccDropdown(
  id = "cancellation_policy",
  options = map(
    1:nrow(policyKey), function(i){
      list(label=policyKey$label[i], value=policyKey$value[i])
    }),
  value = "flexible"
)

#Create the accomodates dropdowns
accKey <- tibble(label = c("1","2", "3","4","5","More than 5"),
                    value =c(1,2,3,4,5,6))
accDropdown <- dccDropdown(
  id = "accommodates",
  options = map(
    1:nrow(accKey), function(i){
      list(label=accKey$label[i], value=accKey$value[i])
    }),
  value = 1
)

#Create the bedrooms dropdowns
bedroomKey <- tibble(label = c("1","2","More than 2"),
                 value =c(1,2,3))
bedroomDropdown <- dccDropdown(
  id = "bedroom",
  options = map(
    1:nrow(bedroomKey), function(i){
      list(label=bedroomKey$label[i], value=bedroomKey$value[i])
    }),
  value = 1
)

#Create the bedrooms dropdowns
bathroomKey <- tibble(label = c("1","2","More than 2"),
                     value =c(1,2,3))
bathroomDropdown <- dccDropdown(
  id = "bathroom",
  options = map(
    1:nrow(bathroomKey), function(i){
      list(label=bathroomKey$label[i], value=bathroomKey$value[i])
    }),
  value = 1
)


make_plot <- function(cityname="Montréal", superhost = "TRUE", roomtype = "Entire home/apt", 
                      policy = "flexible", acc = 1, bedroom = 1, bathroom = 1){

  # gets the label matching the column value
  city_label <- cityKey$label[cityKey$value==cityname]
  superhost_label <- superhostKey$label[superhostKey$value==superhost]
  room_label <- roomKey$label[roomKey$value==roomtype]
  policy_label <- policyKey$label[policyKey$value==policy]
  acc_label <- accKey$label[accKey$value==acc]
  bedroom_label <- bedroomKey$label[bedroomKey$value==bedroom]
  bathroom_label <- bedroomKey$label[bathroomKey$value==bathroom]
  # make plot
    p <- data1 %>%
      filter(!is.na(price)) %>% 
      filter(city==cityname, host_is_superhost==superhost, room_type == roomtype,
             cancellation_policy==policy, new_acc == acc, new_bed == bedroom,
             new_bath==bathroom) %>% 
      ggplot(aes(x=price)) +
      geom_histogram()+
      theme(panel.background = element_rect(fill = "white", colour = "grey50"))+
      xlim(20, 250)
  
  ggplotly(p)
}

graph <- dccGraph(
  id = 'graph',
  figure=make_plot() # gets initial data using argument defaults
)

div_header <- htmlDiv(list(
  htmlH1('Predictive Pricing Tool for Canadian Airbnb Listings')
  ),
  style = list(
    backgroundColor = '#0DC810', ## COLOUR OF YOUR CHOICE
    textAlign = 'center',
    color = 'white',
    margin = 5,
    marginTop = 0
  ))
div_sidebar <- htmlDiv(
  list(htmlLabel('Select city:'),
       htmlBr(),
       cityDropdown,
       htmlLabel('Select superhost or regular host : '),
       htmlBr(),
       superhostDropdown,
       htmlLabel('Select room type : '),
       htmlBr(),
       roomDropdown,
       htmlLabel('Select cancellation policy : '),
       htmlBr(),
       policyDropdown,
       htmlLabel('Select number of accommodates : '),
       htmlBr(),
       accDropdown,
       htmlLabel('Select number of bedrooms : '),
       htmlBr(),
       bedroomDropdown,
       htmlLabel('Select number of bathrooms : '),
       htmlBr(),
       bathroomDropdown
  ),
  style = list('background-color' = '#BBCFF1',
               'padding' = 10,
               'flex-basis' = '20%')
)

app$layout(
  div_header,
  htmlDiv(
    list(
      div_sidebar,
      graph
    ), style = list('display' = 'flex',
                    'justify-content'='center')
  )
)

app$callback(
  #update figure of gap-graph-bar
  output=list(id = 'graph', property='figure'),
  #based on values of year, continent, y-axis components
  params=list(input(id = 'city', property='value'),
              input(id = 'superhost', property = 'value'),
              input(id = 'room_type', property = 'value'),
              input(id = 'cancellation_policy', property = 'value'),
              input(id = 'accommodates', property = 'value'),
              input(id = 'bedroom', property = 'value'),
              input(id = 'bathroom', property = 'value')),
  #this translates your list of params into function arguments
  function(cityname, superhost, roomtype,cancellation_policy,acc, bedroom, bathroom) {
    make_plot(cityname, superhost, roomtype,cancellation_policy,acc, bedroom, bathroom)
  })

app$run_server(debug=TRUE)
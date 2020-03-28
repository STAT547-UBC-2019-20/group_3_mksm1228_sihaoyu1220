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
library(shiny)

app <- Dash$new()

# Load the data here
data <- read.csv(here("Data","cleaned_data.csv"),header=TRUE)
#remove outliers
metadata <- data %>% 
  filter(!is.na(price)) %>% 
  group_by(city) %>% 
  mutate(limitmin = quantile(price,c(0.25)) - 1.5 * (quantile(price,c(0.75))-quantile(price,c(0.25)))) %>% 
  mutate(limitmax = quantile(price,c(0.75)) + 1.5 * (quantile(price,c(0.75))-quantile(price,c(0.25)))) %>% 
  filter(price >= limitmin & price <= limitmax) %>% 
  mutate(new_acc = ifelse(accommodates>=6, 6, accommodates)) %>% 
  mutate(new_bed = round(ifelse(bedrooms>=3, 3, bedrooms))) %>% 
  mutate(new_bath = round(ifelse(bathrooms>=3, 3, bathrooms)))

levels(metadata$cancellation_policy)[4] <- "strict"
levels(metadata$cancellation_policy)[4] <- "super strict"
levels(metadata$cancellation_policy)[5] <- "super strict"

#fixing city names
levels(metadata$city) <- c("Montreal", "New Brunswick", "Ottawa", "Quebec", "Toronto", "Vancouver", "Victoria")

#Create the city dropdowns
cityKey <- tibble(label = as.vector(unique(metadata$city)),
                   value = as.vector(unique(metadata$city)))
cityDropdown <- dccDropdown(
  id = "city",
  options = map(
    1:nrow(cityKey), function(i){
      list(label=cityKey$label[i], value=cityKey$value[i])
    }),
  value="Montreal"
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


make_plot <- function(cityname="Montreal", superhost = "TRUE", roomtype = "Entire home/apt", 
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
    p <- metadata %>%
      filter(!is.na(price)) %>% 
      filter(city==cityname, host_is_superhost==superhost, room_type == roomtype,
             cancellation_policy==policy, new_acc == acc, new_bed == bedroom,
             new_bath==bathroom) %>% 
      ggplot(aes(x=price)) +
      geom_histogram()+
      theme(panel.background = element_rect(fill = "white", colour = "grey50"))+
      xlim(20, 250)
  
  ggplotly(p,  width = 1000, height = 700, tooltip =FALSE)
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

# density plot for superhost
superhost_plot <- metadata %>%
                    filter(host_is_superhost==TRUE | host_is_superhost==FALSE) %>% 
                    ggplot(aes(x=price, color=host_is_superhost)) +
                    geom_density(adjust = 3)+
                    theme(panel.background = element_rect(fill = "white", colour = "grey50"))+
                    xlab("Price(CAD)")+
                    ylab("Density")+
                    ggtitle("Status of Host")+
                    scale_color_discrete(name = "Host is a Superhost", 
                                         labels = c("No", "Yes"))+
                    theme(legend.position = c(.95, .95),
                          legend.justification = c("right", "top"),
                          legend.box.just = "right",
                          legend.margin = margin(6, 6, 6, 6))
                      
                    

superhost_plot <-ggplotly(superhost_plot)
superhost_plot <-superhost_plot %>%
                  layout(legend = list(x = .6, y = .9),
                         title = "Superhost")



# density plot for cancellation policy
cancellation_plot <- metadata %>%
                      ggplot(aes(x=price, color=cancellation_policy)) +
                      geom_density(adjust = 3) +
                      theme(panel.background = element_rect(fill = "white", colour = "grey50"))+
                      xlab("Price(CAD)")+
                      ylab("Density")+
                      ggtitle("**Cancellation Policy**")
  
cancellation_plot <- ggplotly(cancellation_plot)
cancellation_plot <- cancellation_plot %>%
                        layout(legend = list(
                               x = .6, y = .9),
                               title = "Cancellation Policy")


city_plot <- metadata %>%
        ggplot(aes(x=price, color=city)) +
              geom_density(adjust = 3) +
              theme(panel.background = element_rect(fill = "white", colour = "grey50"))+
              xlab("Price(CAD)")+
              ylab("Density")+
              ggtitle("City")+
              scale_color_discrete(name = "City")
              
city_plot <-    ggplotly(city_plot)

room_plot <- metadata %>%
        ggplot(aes(x=price, color=room_type)) +
                geom_density(adjust = 3) +
                theme(panel.background = element_rect(fill = "white", colour = "grey50"))+
                xlab("Price(CAD)")+
                ylab("Density")+
                ggtitle("Room Type")+
                scale_color_discrete("Room Type")
room_plot <-  ggplotly(room_plot) 
room_plot <- room_plot %>%
              layout(legend = list(
              x = .5, y = .9),
              title = "Room Type")


accommodate_plot <-  metadata %>% 
                      filter(!is.na(accommodates)) %>% 
                      mutate(new_acc = ifelse(accommodates>=6, 6, accommodates)) %>% 
                      ggplot(aes(x=price, color=as.factor(new_acc))) +
                      geom_density(adjust = 3) +
                      theme(panel.background = element_rect(fill = "white", colour = "grey50"))+
                      xlab("Price(CAD)")+
                      ylab("Density")+
                      ggtitle("Accommodates")+
                      scale_color_discrete("Accommodates")
accommodate_plot <- ggplotly(accommodate_plot)
accommodate_plot <- accommodate_plot %>%
                    layout(legend = list(
                      x = .6, y = .9),
                      title = "Accommodates")


bathroom_plot <- metadata %>% 
                   filter(!is.na(bathrooms)) %>% 
                   mutate(new_bath = round(ifelse(bathrooms>=3, 3, bathrooms))) %>% 
                   filter(new_bath != 0) %>%
                   ggplot(aes(x=price, color=as.factor(new_bath))) +
                   geom_density(adjust = 3) +
                   theme(panel.background = element_rect(fill = "white", colour = "grey50"))+
                   xlab("Price(CAD)")+
                   ylab("Density")+
                   ggtitle("Bathrooms")+
                   scale_color_discrete("Bathrooms")
bathroom_plot <- ggplotly(bathroom_plot)
bathroom_plot <- bathroom_plot %>%
                 layout(legend = list(
                    x = .6, y = .9),
                    title = "Bathrooms")

                  
  
bedroom_plot <- metadata %>% 
                  filter(!is.na(bedrooms)) %>% 
                  mutate(new_bed = round(ifelse(bedrooms>=3, 3, bedrooms))) %>% 
                  filter(new_bed != 0) %>%
                  ggplot(aes(x=price, color=as.factor(new_bed))) +
                  geom_density(adjust = 3) +
                  theme(panel.background = element_rect(fill = "white", colour = "grey50"))+
                  xlab("Price(CAD)")+
                  ylab("Density")+
                  
                  ggtitle("Bedrooms")
bedroom_plot <- ggplotly(bedroom_plot) 
bedroom_plot <- bedroom_plot %>%
                layout(legend = list(
                  x = .6, y = .9),
                  title = "Bedrooms")


tabs <- dccTabs(id="tabs", value='tab-1', children=list(
    dccTab(label='Analysis', value='tab-1'),
    dccTab(label='Play', value='tab-2')
    ))


superhost_graph <- dccGraph(
  id = 'superhost-graph',
  figure = superhost_plot
)

cancellation_graph <- dccGraph(
  id = 'cancellation-graph',
  figure = cancellation_plot
)

city_graph <- dccGraph(
  id = 'city-graph',
  figure = city_plot
)

room_graph <- dccGraph(
  id = 'room-graph',
  figure = room_plot
)

accommodate_graph <- dccGraph(
  id = 'accommodate-graph',
  figure = accommodate_plot
)

bedroom_graph <- dccGraph(
  id = 'bedroom-graph',
  figure = bedroom_plot
)

bathroom_graph <- dccGraph(
  id = 'bathroom-graph',
  figure = bathroom_plot
)




content1 <- htmlDiv(
  list(
  htmlDiv(superhost_graph, style = list('width'= '33%','justify-content'='left')),
  htmlDiv(cancellation_graph, style = list('width'= '33%','justify-content'='center')),
  htmlDiv(room_graph, style = list('width'= '33%','justify-content'='right')), 
  htmlDiv(accommodate_graph, style = list('width'= '33%','justify-content'='left')),
  htmlDiv(bedroom_graph, style = list('width'= '33%','justify-content'='center')),
  htmlDiv(bathroom_graph, style = list('width'= '33%','justify-content'='right'))),
  style = list('display'='flex','flex-wrap'= 'wrap'))


content2 <-  htmlDiv(
  list(
    div_sidebar,
    graph
  ), style = list('display' = 'flex',
                  'justify-content'='center')
)

description <- htmlH3("The data was sourced from publicly available information from the official Airbnb site. It has been analyzed, cleaned and aggregated by Inside Airbnb. This app currently has two features which are termed 
                      Analysis and Play. In the Analysis tab, you will find density plots showing the distribution
                      of prices of Canadian Airbnb listings based on various factors. In the Play tab, you will 
                      be able to play with the various factors by adjusting them using a side bar and see how this
                      influences the price.")
app$layout(htmlDiv(list(
  div_header,
  description,
  tabs,
  htmlDiv(id='tabs-content')
)))

app$callback(output('tabs-content', 'children'),
             params = list(input('tabs', 'value')),
             function(tab){
               if(tab == 'tab-1'){
                 return(content1)
                   }
               else if(tab == 'tab-2'){
                 return(content2)
                 }
             }
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
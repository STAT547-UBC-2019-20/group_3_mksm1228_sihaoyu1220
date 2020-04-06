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
library(RColorBrewer)

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
  value = 2
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
bathroomKey <- tibble(label = c("0","1","2","More than 2"),
                     value =c(0,1,2,3))
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
   data <- metadata %>%
      filter(!is.na(price)) %>% 
      filter(city==cityname, host_is_superhost==superhost, room_type == roomtype,
             cancellation_policy==policy, new_acc == acc, new_bed == bedroom,
             new_bath==bathroom) 
   if (nrow(data)>=1){
   p  <- data %>% 
     ggplot(aes(x=price)) +
      geom_histogram()+
      theme(panel.background = element_rect(fill = "white", colour = "grey50"))+
      xlim(20, 250)
   }else{
     text = paste("No such listing in ", cityname, " :(")
     p<-ggplot() + 
       annotate("text", x = 4, y = 25, size=8, label = text) + 
       theme_bw() +
       theme(panel.grid.major=element_blank(),
             panel.grid.minor=element_blank(),axis.title.x=element_blank(),
             axis.text.x=element_blank(),
             axis.ticks.x=element_blank(),axis.title.y=element_blank(),
             axis.text.y =element_blank(),
             axis.ticks.y=element_blank(),panel.grid=element_blank(), 
             panel.background=element_rect(fill = "transparent",colour = NA),
             panel.border=element_blank())
   }
   ggplotly(p,  width = 1000, height = 700, tooltip =FALSE)
}

get_value <- function(cityname="Montreal", superhost = "TRUE", roomtype = "Entire home/apt", 
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
  dat <- metadata %>%
    filter(!is.na(price)) %>% 
    filter(city==cityname, host_is_superhost==superhost, room_type == roomtype,
           cancellation_policy==policy, new_acc == acc, new_bed == bedroom,
           new_bath==bathroom)
  value <- mean(dat$price)
  if (is.na(value)){
  # cityprice <- -14.695
  # if (cityname == "New Brunswick"){
  #   cityprice <- 0
  # } else if (cityname == "Quebec"){
  #   cityprice <- -3.655
  # } else if (cityname == "Ottawa"){
  #   cityprice <- -6.31
  # } else if (cityname == "Toronto"){
  #   cityprice <- 18.179
  # } else if (cityname == "Vancouver"){
  #   cityprice <- 35.634
  # } else if (cityname == "Victoria"){
  #   cityprice <- 19.07
  # }
  # 
  # superhostprice <- 2.604
  # if (superhost == "FALSE"){
  #   superhostprice <- 0
  # }
  # 
  # roomtypeprice <- 0
  # if (roomtype == "Hotel room"){
  #   roomtypeprice <- 8.142
  # } else if (roomtype == "Private room"){
  #   roomtypeprice <- -45.299
  # }else if (roomtype == "Shared room"){
  #   roomtypeprice <- -64.408
  # }
  # 
  # policyprice <- 0
  # if (policy == "moderate"){
  #   policytypeprice <- -2.398
  # } else if (policy == "strict"){
  #   policytypeprice <- 4.076
  # } else if (policy == "super strict"){
  #   policytypeprice <- 33.611
  # }
  # 
  # value<-round(cityprice+superhostprice+roomtypeprice+policyprice+acc*6.997+bathroom*10.316+bedroom*8.956,2)
    value <- 0
  }
  return(value)
}

graph <- dccGraph(
  id = 'graph',
  figure=make_plot() # gets initial data using argument defaults
)

div_header <- htmlDiv(list(
  htmlH1('Predictive Pricing Tool for Canadian Airbnb Listings')
  ),
  style = list(
    fontFamily = "Tahoma",
    backgroundColor = '#2C3E50', ## COLOUR OF YOUR CHOICE
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
       bathroomDropdown,
       htmlBr(),
       htmlDiv(id='my-div'),
       htmlBr(),
       htmlButton('Reset Button', id='button')
  ),
  style = list('background-color' = '#BBCFF1',
               'padding' = 10,
               'flex-basis' = '25%',
               'fontFamily' = 'Arial')
)

###############################Analysis Tab####################################################

# density plot for superhost

superhost_plot <- function(cityname = "Vancouver"){
            p <- metadata %>%
                    filter(city == cityname) %>%
                    filter(host_is_superhost == TRUE | host_is_superhost == FALSE) %>%
                    ggplot(aes(x=price, color=host_is_superhost)) +
                    geom_density(adjust = 3)+
                    theme(panel.background = element_rect(fill = "white", colour = "grey50"))+
                    xlab("Price (CAD) per Day")+
                    ylab("Density")+
                    ggtitle("Status of Host")+
                    scale_color_discrete(name = "Host is a Superhost", 
                                         labels = c("No", "Yes"))+
                    theme(legend.position = c(.95, .95),
                          legend.justification = c("right", "top"),
                          legend.box.just = "right",
                          legend.margin = margin(6, 6, 6, 6),
                          legend.title = element_blank())

              p  <- ggplotly(p)
                  

              p <- p %>%
                  layout(legend = list(x = .6, y = .9),
                         title = "Superhost"
                         )
}

# density plot for cancellation policy
cancellation_plot <- function(cityname = "Vancouver"){
                p <- metadata %>%
                      filter(city == cityname) %>%
                      ggplot(aes(x=price, color=cancellation_policy)) +
                      geom_density(adjust = 3) +
                      theme(panel.background = element_rect(fill = "white", colour = "grey50"))+
                      xlab("Price (CAD) per Day")+
                      ylab(" ")+
                      ggtitle("Cancellation Policy")+
                      theme(legend.title = element_blank())
  
                p <- ggplotly(p)
                p <- p %>%
                        layout(legend = list(
                               x = .9, y = .9),
                               title = "Cancellation Policy")

}
room_plot <- function(cityname = "Vancouver"){
      p <- metadata %>%
           filter(city == cityname) %>%
           ggplot(aes(x=price, color=room_type)) +
                geom_density(adjust = 3) +
                theme(panel.background = element_rect(fill = "white", colour = "grey50"))+
                xlab("Price (CAD) per Day")+
                ylab(" ")+
                ggtitle("Room Type")+
                scale_color_discrete("Room Type")+
                theme(legend.title = element_blank())
      p <- ggplotly(p) 
      p <- p %>%
              layout(legend = list(
              x = .5, y = .9),
              title = "Room Type")

}


accommodate_plot <- function(cityname = "Vancouver"){
              p <- metadata %>% 
                      filter(!is.na(accommodates)) %>% 
                      filter(city == cityname) %>%
                      mutate(new_acc = ifelse(accommodates>=6, "more than 5", accommodates)) %>% 
                      ggplot(aes(x=price, color=as.factor(new_acc))) +
                      geom_density(adjust = 3) +
                      theme(panel.background = element_rect(fill = "white", colour = "grey50"))+
                      xlab("Price (CAD) per Day")+
                      ylab("Density")+
                      ggtitle("Accommodates")+
                      scale_color_discrete(name = "Accommodates")+
                      theme(legend.title = element_blank())
              p <- ggplotly(p)
              p <- p %>%
                    layout(legend = list(
                      x = .6, y = .9),
                      title = "Accommodates")
}

bathroom_plot <- function(cityname = "Vancouver"){
            p <- metadata %>% 
                   filter(!is.na(bathrooms)) %>% 
                   filter(bathrooms != 0) %>%
                   filter(city == cityname) %>%
                   mutate(new_bath = ifelse(bathrooms>2, "more than 2", round(bathrooms))) %>% 
                   ggplot(aes(x=price, color=as.factor(new_bath))) +
                   geom_density(adjust = 3) +
                   theme(panel.background = element_rect(fill = "white", colour = "grey50"))+
                   xlab("Price (CAD) per Day")+
                   ylab(" ")+
                   ggtitle("Bathrooms")+
                   scale_color_discrete("Bathrooms")+
                   theme(legend.title = element_blank())
          p <- ggplotly(p)
          p <- p %>%
                 layout(legend = list(
                    x = .6, y = .9),
                    title = "Bathrooms"
                    )
}
                  
  
bedroom_plot <- function(cityname = "Vancouver"){
           p <- metadata %>% 
                  filter(!is.na(bedrooms)) %>% 
                  filter(city == cityname) %>%
                  filter(bedrooms != 0) %>%
                  mutate(new_bed = ifelse(bedrooms>2, "more than 2", round(bedrooms))) %>% 
                  ggplot(aes(x=price, color=as.factor(new_bed))) +
                  geom_density(adjust = 3) +
                  theme(panel.background = element_rect(fill = "white", colour = "grey50"))+
                  xlab("Price (CAD) per Day")+
                  ylab(" ")+
                  ggtitle("Bedrooms")+
                  theme(legend.title = element_blank())
                  
          p <- ggplotly(p) 
          p <- p %>%
                layout(legend = list(
                  x = .6, y = .9),
                  title = "Bedrooms")
}



######################################Analysis graphs#######################################
superhost_graph <- dccGraph(
  id = 'superhost-graph',
  figure = superhost_plot()
)

cancellation_graph <- dccGraph(
  id = 'cancellation-graph',
  figure = cancellation_plot()
)


room_graph <- dccGraph(
  id = 'room-graph',
  figure = room_plot()
)

accommodate_graph <- dccGraph(
  id = 'accommodate-graph',
  figure = accommodate_plot()
)

bedroom_graph <- dccGraph(
  id = 'bedroom-graph',
  figure = bedroom_plot()
)

bathroom_graph <- dccGraph(
  id = 'bathroom-graph',
  figure = bathroom_plot()
)


city_dropdown <- dccDropdown(
  id = 'city-dropdown',
  options = list(
    list(label = "Vancouver", value = "Vancouver"),
    list(label = "Montreal", value = "Montreal"),
    list(label = "Ottawa", value = "Ottawa"),
    list(label = "Quebec", value = "Quebec"),
    list(label = "Toronto", value = "Toronto"),
    list(label = "Victoria", value = "Victoria"),
    list(label = "New Brunswick", value = "New Brunswick")
  ),
  value = "Vancouver"
)

##############################Map#############################################

map_tab <- function(cityname="Montreal", superhost = "TRUE", roomtype = "Entire home/apt", 
                    policy = "flexible", acc = 1, bedroom = 1, bathroom = 1){
  
  city_label <- cityKey$label[cityKey$value==cityname]
  
  metadata <- metadata %>%
    filter(city==cityname, host_is_superhost==superhost, room_type == roomtype,
           cancellation_policy==policy, new_acc == acc, new_bed == bedroom,
           new_bath==bathroom)
  
  if (nrow(metadata)>0){
  map_data <- metadata %>%
    plot_ly(
      lat = ~latitude,
      lon = ~longitude,
      color = ~price,
      type = 'scattermapbox',
      size = 10, width = 1000, height = 700,
      colors = 'RdYlBu',
      alpha = 1,
      text = ~paste('</br> Price: $', price,
                    '</br> Neighbourhood: ', neighbourhood_cleansed), hoverinfo = "text")
  
  
  map_data <- map_data %>%
    layout(title = paste0(city_label, ' Airbnb Listings'),
           mapbox = list(
             style = 'carto-positron',
             zoom = 7.5,
             center = list(lon = ~median(longitude), lat = ~median(latitude))))
  } else {
    text = paste("No such listing in ", cityname, " :(")
    p<-ggplot() + 
      annotate("text", x = 4, y = 25, size=8, label = text) + 
      theme_bw() +
      theme(panel.grid.major=element_blank(),
            panel.grid.minor=element_blank(),axis.title.x=element_blank(),
            axis.text.x=element_blank(),
            axis.ticks.x=element_blank(),axis.title.y=element_blank(),
            axis.text.y =element_blank(),
            axis.ticks.y=element_blank(),panel.grid=element_blank(), 
            panel.background=element_rect(fill = "transparent",colour = NA),
            panel.border=element_blank())
    map_data <- ggplotly(p, width = 1000, height = 700, tooltip =FALSE)
  }
  map_data
}

map_plot = dccGraph(id = 'map', figure = map_tab())
################################Tabs################################################

tabs_styles = list(
  'height'= '66px'
)
tab_style = list(
  'borderBottom'= '1px solid #d6d6d6',
  'padding'= '10px',
  'fontWeight'= 'bold',
  'fontFamily' = 'Tahoma'
)

tab_selected_style = list(
  'borderTop'= '1px solid #d6d6d6',
  'borderBottom'= '1px solid #d6d6d6',
  'backgroundColor'= '#2C3E50',
  'color'= 'white',
  'padding'= '6px'
)


tabs <- dccTabs(id="tabs", value='tab-1', children=list(
  dccTab(label='Analysis', value='tab-1', style = tab_style, selected_style = tab_selected_style),
  dccTab(label='Play', value='tab-2', style = tab_style, selected_style = tab_selected_style),
  dccTab(label='Map', value='tab-3', style = tab_style, selected_style = tab_selected_style)
), style = tab_style)


################################Contents in each tab###################################

content1 <- htmlDiv(
  htmlDiv(
    list(
      htmlP("Please select a city from the dropdown below. The plots will update based on the city chosen."),
      htmlDiv(
        list(
          city_dropdown
        ), style=list('fontFamily' = 'Arial',
                      'padding' = 10,
                      'background-color' = '#2C3E50'
                      )
      ),
      htmlDiv(
        list(
          htmlDiv(
            list(
                 htmlBr(),
                 superhost_graph
        ), style=list('width'='33%')
      ),
      htmlDiv(
        list(
             htmlBr(),
             cancellation_graph
            ), style=list('width'='33%')
          ),
      htmlDiv(
        list(
             htmlBr(),
             room_graph
        ), style = list('width' = '33%')
      )), style = list('display' = 'flex', 'justify-content' = 'center', 'background-color' = '#2C3E50')),
      htmlDiv(
        list(
            htmlDiv(
              list(
                   htmlBr(),
                   accommodate_graph
                  ), style = list('width' = '33%')),
            htmlDiv(
               list(
                    htmlBr(),
                    bathroom_graph
                   ), style = list('width' = '33%')),
            htmlDiv(
               list(
                    htmlBr(),
                    bedroom_graph
                   ), style = list('width' = '33%')
            )), style = list('display' = 'flex', 'justify-content' = 'center', 'background-color' = '#2C3E50'))
  ), style = list('fontFamily' = 'Arial')) 
)




content2 <-  htmlDiv(
  list(
    div_sidebar,
    graph
  ), style = list('display' = 'flex',
                  'justify-content'='center')
)


content3 <- htmlDiv(
  list(
    div_sidebar,
    htmlBr(),
    htmlBr(),
    map_plot
  ), style = list('display' = 'flex',
                  'justify-content'='center')
)
description <- htmlDiv(
                  list(dccMarkdown("This Dash app will allow users to visualize which factors are most likely influencing the price of Canadian Airbnb listings. The data was sourced from publicly available information from the official Airbnb site. It has been analyzed, cleaned and aggregated by [Inside Airbnb](http://insideairbnb.com/get-the-data.html). This app currently has three features which are termed 
                      Analysis, Play and Map. The purpose of this dashboard is to help you understand
                      the influence of various factors, ranging from number of bedrooms to if the host is a superhost or not,
                      on the price of Canadian Airbnb listings."),  
                      dccMarkdown("In the Analysis tab, you will find density plots showing the distribution
                      of prices of Canadian Airbnb listings based on various factors. Density curves
                      that lean more to the right indicate a higher price. 
                      In the Play tab, you will be able to play with the various factors by adjusting them using the side bar and 
                      see how this influences the price. Finally, in the Map tab, you will be able to see the approximate location of the listings by adjusting the various factors on the side bar. If you hover over the listing, you will be able to see the price and the neighbourhood of the listing. Please note for different cities, you will either have to zoom-in or out to see all the listings.")), style = list(fontFamily = "Arial"))

#######################app layout##########################################
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
               else if(tab == 'tab-3'){
                 return(content3)
               }
             }
)
###############################app callback#############################
app$callback(
  output=list(id='my-div', property='children'),
  params=list(input(id = 'city', property='value'),
              input(id = 'superhost', property = 'value'),
              input(id = 'room_type', property = 'value'),
              input(id = 'cancellation_policy', property = 'value'),
              input(id = 'accommodates', property = 'value'),
              input(id = 'bedroom', property = 'value'),
              input(id = 'bathroom', property = 'value')),
  function(cityname, superhost, roomtype,cancellation_policy,acc, bedroom, bathroom) {
    price <- round(get_value(cityname, superhost, roomtype,cancellation_policy,acc, bedroom, bathroom),2)
    if (price > 0){
    sprintf("The approximate price is: $ %s", price)
    } else {
    glue::glue("Sorry, there is no such listing exists in ", cityname)
    }
  })

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
              input(id = 'bathroom', property = 'value'),
              input(id = "button", property = "n_clicks")),
  #this translates your list of params into function arguments
  function(cityname, superhost, roomtype,cancellation_policy,acc, bedroom, bathroom,button) {
    make_plot(cityname, superhost, roomtype,cancellation_policy,acc, bedroom, bathroom)
  })

app$callback(
  #update superhost graph
  output=list(id = 'superhost-graph', propert = 'figure'),
  params = list(input(id = 'city-dropdown', property = 'value')),
  function(pricedensity_city){
    superhost_plot(pricedensity_city)
  }
)

app$callback(
  #update cancellation graph
  output=list(id = 'cancellation-graph', propert = 'figure'),
  params = list(input(id = 'city-dropdown', property = 'value')),
  function(pricedensity_city){
    cancellation_plot(pricedensity_city)
  }
)

app$callback(
  #update room graph
  output=list(id = 'room-graph', propert = 'figure'),
  params = list(input(id = 'city-dropdown', property = 'value')),
  function(pricedensity_city){
    room_plot(pricedensity_city)
  }
)

app$callback(
  #update accommodates graph
  output=list(id = 'accommodate-graph', propert = 'figure'),
  params = list(input(id = 'city-dropdown', property = 'value')),
  function(pricedensity_city){
    accommodate_plot(pricedensity_city)
  }
)

app$callback(
  #update bedroom graph
  output=list(id = 'bedroom-graph', propert = 'figure'),
  params = list(input(id = 'city-dropdown', property = 'value')),
  function(pricedensity_city){
    bedroom_plot(pricedensity_city)
  }
)

app$callback(
  #update bathroom graph
  output=list(id = 'bathroom-graph', propert = 'figure'),
  params = list(input(id = 'city-dropdown', property = 'value')),
  function(pricedensity_city){
    bathroom_plot(pricedensity_city)
  }
)

app$callback(
  #update bathroom graph
  output=list(id = 'bedroom', property = 'value'),
  params = list(input(id = 'button', property  = 'n_clicks')),
  function(button){
    value = 1
  }
)

app$callback(
  #update bathroom graph
  output=list(id = 'accommodates', property = 'value'),
  params = list(input(id = 'button', property  = 'n_clicks')),
  function(button){
    value = 2
  }
)

app$callback(
  #update bathroom graph
  output=list(id = 'bathroom', property = 'value'),
  params = list(input(id = 'button', property  = 'n_clicks')),
  function(button){
    value = 1
  }
)

app$callback(
  #update bathroom graph
  output=list(id = 'city', property = 'value'),
  params = list(input(id = 'button', property  = 'n_clicks')),
  function(button){
    value = "Montreal"
  }
)

app$callback(
  #update bathroom graph
  output=list(id = 'superhost', property = 'value'),
  params = list(input(id = 'button', property  = 'n_clicks')),
  function(button){
    value = "TRUE"
  }
)

app$callback(
  #update bathroom graph
  output=list(id = 'room_type', property = 'value'),
  params = list(input(id = 'button', property  = 'n_clicks')),
  function(button){
    value = "Entire home/apt"
  }
)

app$callback(
  #update bathroom graph
  output=list(id = 'cancellation_policy', property = 'value'),
  params = list(input(id = 'button', property  = 'n_clicks')),
  function(button){
    value = "flexible"
  }
)

app$callback(
  #update map
  output=list(id = 'map', property = 'figure'),
  params=list(input(id = 'city', property='value'),
              input(id = 'superhost', property = 'value'),
              input(id = 'room_type', property = 'value'),
              input(id = 'cancellation_policy', property = 'value'),
              input(id = 'accommodates', property = 'value'),
              input(id = 'bedroom', property = 'value'),
              input(id = 'bathroom', property = 'value')),
  #this translates your list of params into function arguments
  function(cityname, superhost, roomtype,cancellation_policy,acc, bedroom, bathroom) {
    map_tab(cityname, superhost, roomtype, cancellation_policy,acc, bedroom, bathroom)
  })



app$run_server()
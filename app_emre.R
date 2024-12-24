
library(shiny)
library(tidyverse)
library(jsonlite)
library(ggplot2)
library(DT)
library(leaflet)
library(lubridate)
library(RColorBrewer)
library(scales)


my_df <- readRDS("[file_path]/isbike_20201118.rds")
json_df <- fromJSON(my_df)
final_df <- json_df[["dataList"]]


isbike_df <- final_df %>% 
    transmute(StationNo = as.integer(istasyon_no), 
              StationName = adi, 
              Available = as.integer(bos),
              Occupied = as.integer(dolu),
              Capacity = Available + Occupied,
              AvailabilityRate = round((Available / Capacity * 100), 1),
              Latitude = as.numeric(lat),
              Longtitude = as.numeric(lon),
              LastConnection = as.POSIXct(sonBaglanti,format='%Y-%m-%dT%H:%M:%S'),
              LastConnectionDay = day(LastConnection)) %>%
    mutate(AvailabilityRate = replace(AvailabilityRate, is.na(AvailabilityRate), 0),
           Latitude = replace(Latitude, is.na(Latitude), 0))

#Due to the geographic consistency, some of the station numbers are corrected manually
isbike_df$StationNo[isbike_df$StationName == "Dragos Şehir Üniversitesi"] <- 1001
isbike_df$StationNo[isbike_df$StationName == "Rönepark Sahil"] <- 6001
isbike_df$StationNo[isbike_df$StationName == "Aqua Florya"] <- 6002
isbike_df$StationNo[isbike_df$StationName == "Florya Sosyal Tesisler 1"] <- 6003
isbike_df$StationNo[isbike_df$StationName == "Florya Sosyal Tesisler 2"] <- 6004
isbike_df$StationNo[isbike_df$StationName == "Güneş Plajı"] <- 6005

anatolia_station <- isbike_df %>%
    filter((StationNo > 1000) & (StationNo <1899))

europe_station <- isbike_df %>%
    filter(StationNo > 5000)

test_station <- isbike_df %>%
    filter((StationNo > 1899) & (StationNo <2000))

anatolia_count <- nrow(anatolia_station)
europe_count <- nrow(europe_station)
test_count <- nrow(test_station)
total_count <- nrow(isbike_df)

station_types <- data.frame(
  StationGroup = c("Anatolia", "Europe", "Test"),
  StationNumber = c(
    round((anatolia_count / total_count) * 100, 1),
    round((europe_count / total_count) * 100, 1),
    round((test_count / total_count) * 100, 1)
  )
)


#station_types

bp <- ggplot(data = station_types, aes(x = "", y = StationNumber, fill = StationGroup)) +
  geom_bar(width = 1, stat = "identity")
pie <- bp + coord_polar("y", start = 0) +
  geom_text(aes(
    y = cumsum(StationNumber) - StationNumber / 2, 
    label = paste0(StationNumber, "%")
  ), size = 5) +
  labs(title = "Station Distribution by Region") +
  theme_void()
print(pie)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("isbike Stations"),
    
    tabsetPanel(
        tabPanel("General Information",
                 fluidRow(
                     column(6,
                            h2("R-Shiny Project"),
                            h3("Summary"),
                            br(),
                            div("The data is provided from ", code(a("IBB Open Data Portal", href="https://data.ibb.gov.tr")), " and gives 
                            the information about the Isbike stations' coordinates, availability status, station names and the last time 
                            that connected to the system while getting the report."),
                            
                            br(),
                            div(" The glimpse of the data as follows;"),
                            br(),
                            tags$li("Consists of 199 rows and 9 columns."),
                            tags$li("There are 85 stations in the Anatolian side, 111 stations in the European side and 3 test stations"),
                            tags$li("%59 percent of the all stations have 15 slots. The maximum capacity is 30 slots that have in 2 stations, where can be found in Florya."),
                            tags$li("The last connection was built with the all stations was on 18th of November around the same time, but the 15 of them don't have the same connection time. Therefore, it is suggested to checking those station in case having a problem."),
                            br(),
                            hr(),
                            #plotOutput("isbikeHist"), 
                            plotOutput("isbikeCapacity"),
                            ),
                     column(5,
                            leafletOutput("isbikeMap"),
                            #plotOutput("scattersize"),
                            hr(),
                            plotOutput("pie")))),
        tabPanel("Current Availability",

    # Sidebar with a slider input for number of bins 
            sidebarLayout(
                sidebarPanel(
                    sliderInput("available",
                                "Available Bikes:",
                                min = min(isbike_df$Available),
                                max = max(isbike_df$Available),
                                value = c(min(isbike_df$Available)+1, max(isbike_df$Available)-1),
                                step = 1),
                    sliderInput("availability",
                                "Availability Rate %:",
                                min = min(isbike_df$AvailabilityRate),
                                max = max(isbike_df$AvailabilityRate),
                                value = c(min(isbike_df$AvailabilityRate)+1, max(isbike_df$AvailabilityRate)-1),
                                step = 5),
                    checkboxInput("Anadolu", "Anatolian Side", TRUE),
                    checkboxInput("Avrupa", "European Side", TRUE),
                    checkboxInput("Test", "Test Stations", TRUE),
                    
                    
                ),
        
                # Show a plot of the generated distribution
                mainPanel(leafletOutput("leafletMap"), DTOutput("isbikeTable"))
                )
    )
    ))

# Define server logic required to draw a histogram
server <- function(input, output) {

    
    
    output$isbikeMap <- renderLeaflet({

        map_df <- isbike_df %>%
            filter(Longtitude != 0 & Latitude != 0)

        leaflet() %>%
            addProviderTiles("CartoDB.Positron") %>%
            addCircleMarkers(lng = map_df$Longtitude, lat = map_df$Latitude,
                             weight = 5, radius = 3,
                             popup = paste0(map_df$StationName,
                                            "<br/>Total Capacity: ", map_df$Capacity,
                                            "<br/>Available Bikes: ", map_df$Available,
                                            "<br/>Occupied Bikes: ", map_df$Occupied,
                                            "<br/>Last Connection: ", map_df$LastConnection))
        
    })
    
    output$scattersize <- renderPlot({
        ggplot(isbike_df, aes(x=as.double(Longtitude), y=as.double(Latitude), color=factor(Available))) +
                   geom_point(aes(size=5))+
            viridis::scale_color_viridis(discrete = TRUE, option = "A")+
            coord_cartesian(xlim=c(28.45, 29.5682), 
                            ylim = c(40.80269, 41.1916))+
            labs(title="Distribution of Availablity Based on Coordinations",
                 x="Longitute",
                 y="Latitude")
    })
    
    output$isbikeCapacity <- renderPlot({
        
        
        plot_df <- isbike_df %>% 
            filter(Capacity > 0) %>%
            count(Capacity, name = "Count") %>%
            mutate(Percentage = round(Count / sum(Count) * 100, 0)) %>%
            mutate(Capacity = as.character(Capacity)) %>%
            select(Capacity, Percentage)
            
        ggplot(plot_df, aes(x = reorder(Capacity, Percentage), y = Percentage)) + 
            geom_bar(stat = "identity", aes(fill=Capacity)) + 
            coord_flip() +
            labs(title = "Capacity Distribution of Stations", x = "Capacity", y = "Frequency") + 
            theme(legend.position = "none", plot.title = element_text(hjust = 0.5))
        
        
    })
    
    output$pie <- renderPlot({
        
        
        anatolia_station <- isbike_df %>%
            filter((StationNo > 1000) & (StationNo <1899))
        
        europe_station <- isbike_df %>%
            filter(StationNo > 5000)
        
        test_station <- isbike_df %>%
            filter((StationNo > 1899) & (StationNo <2000))
        
        # Safe calculation with fallbacks
        anatolia_count <- nrow(anatolia_station)
        europe_count <- nrow(europe_station)
        test_count <- nrow(test_station)
        total_count <- max(nrow(isbike_df), 1)  # Avoid division by zero
        
        station_types <- data.frame(
            StationGroup = c("Anatolia", "Europe", "Test"),
            Percentage = c(
              round((anatolia_count / total_count) * 100, 1),
              round((europe_count / total_count) * 100, 1),
              round((test_count / total_count) * 100, 1)
            )
        )
        
        # Check for empty data
        if (nrow(station_types) == 0) {
          return(NULL)  # Avoid rendering if data is empty
        }
        
        
        bp <-ggplot(data=station_types, aes(x="", y=Percentage, fill=StationGroup)) +
            geom_bar(width = 1, stat="identity")
        pie <- bp + coord_polar("y")+
            geom_text(aes(label = paste0(Percentage, "%")), color = "white", position = position_stack(vjust = 0.5))+
            labs(title="Percentage of stations based on location",
                 x="",
                 y="")+
            theme_void()
        pie
    })
    
    output$leafletMap <- renderLeaflet({
        
        isbike_df <- isbike_df
        isbike_df$StationNo[isbike_df$StationName == "Dragos Şehir Üniversitesi"] <- 1001
        isbike_df$StationNo[isbike_df$StationName == "Rönepark Sahil"] <- 6001
        isbike_df$StationNo[isbike_df$StationName == "Aqua Florya"] <- 6002
        isbike_df$StationNo[isbike_df$StationName == "Florya Sosyal Tesisler 1"] <- 6003
        isbike_df$StationNo[isbike_df$StationName == "Florya Sosyal Tesisler 2"] <- 6004
        isbike_df$StationNo[isbike_df$StationName == "Güneş Plajı"] <- 6005
        
        
        
        isbike_df$filtre <- 0
        if (input$Anadolu == TRUE){
            isbike_df$filtre[(isbike_df$StationNo >1000) & (isbike_df$StationNo < 1899)] <- 1
        }
        if (input$Avrupa == TRUE){
            isbike_df$filtre[(isbike_df$StationNo >5000)] <- 1
        }
        if (input$Test == TRUE){
            isbike_df$filtre[(isbike_df$StationNo >1899) & (isbike_df$StationNo < 2000)] <- 1
        }
        
        leaflet_df <- isbike_df %>% 
            filter(Longtitude != 0 & Latitude != 0) %>%
            filter(filtre == 1) %>%
            filter(AvailabilityRate >= input$availability[1], 
                   AvailabilityRate <= input$availability[2]) %>%
            filter(Available >= input$available[1], 
                   Available <= input$available[2]) %>%
            mutate(AvailableFactor = factor(Available))
        
        color_vec <- brewer.pal(n = 11, name = "RdYlGn")

        new <- color_vec[leaflet_df$AvailableFactor]
        new <- replace(new, is.na(new), "#006837")

        icons <- awesomeIcons(
            icon = "bicycle",
            iconColor = "white",
            library = "ion"
        )
        
        leaflet() %>%
            addProviderTiles("CartoDB.Positron") %>%
            addAwesomeMarkers(lng = leaflet_df$Longtitude, lat = leaflet_df$Latitude,
                              icon = icons,
                              popup = paste0(leaflet_df$StationName,
                                             "<br/>Total Capacity: ", leaflet_df$Capacity,
                                             "<br/>Available Bikes: ", leaflet_df$Available,
                                             "<br/>Occupied Bikes: ", leaflet_df$Occupied,
                                             "<br/>Last Connection: ", leaflet_df$LastConnection))
        
    })  
    
    output$isbikeTable <- renderDT({
        
        isbike_df <- isbike_df
        isbike_df$StationNo[isbike_df$StationName == "Dragos ?ehir ?niversitesi"] <- 1001
        isbike_df$StationNo[isbike_df$StationName == "R?nepark Sahil"] <- 6001
        isbike_df$StationNo[isbike_df$StationName == "Aqua Florya"] <- 6002
        isbike_df$StationNo[isbike_df$StationName == "Florya Sosyal Tesisler 1"] <- 6003
        isbike_df$StationNo[isbike_df$StationName == "Florya Sosyal Tesisler 2"] <- 6004
        isbike_df$StationNo[isbike_df$StationName == "G?ne? Plaj?"] <- 6005
        
        isbike_df$filtre <- 0
        if (input$Anadolu == TRUE){
            isbike_df$filtre[(isbike_df$StationNo >1000) & (isbike_df$StationNo < 1899)] <- 1
        }
        if (input$Avrupa == TRUE){
            isbike_df$filtre[(isbike_df$StationNo >5000)] <- 1
        }
        if (input$Test == TRUE){
            isbike_df$filtre[(isbike_df$StationNo >1899) & (isbike_df$StationNo < 2000)] <- 1
        }
        
        
        table_df <- isbike_df %>%
            filter(filtre == 1) %>%
            filter(Available >= input$available[1], Available <= input$available[2]) %>%
            filter(AvailabilityRate >= input$availability[1], AvailabilityRate <= input$availability[2]) %>%
            select(StationNo, StationName, Available, Occupied, Capacity, AvailabilityRate)
        
        table_df
        
    })
}

# Run the application 
shinyApp(ui = ui, server = server)

print(isbike_df,199)

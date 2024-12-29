# Project Title: Interactive Bike Station Analyzer with Shiny App in R

## Introduction

This R Shiny Application provides an interactive visualization regarding the Isbike stations' coordinates, availability status, station names and the last time that connected to the system wile getting the report. 

The data is provided from IBB Open Data Portal

## Key Features

### General Information Tab
- A static bar graph displays the capacity distribution of the stations.
- The actual locations of the bike stations are shown interactively on an Istanbul map, along with station details such as the name, total capacity, number of available bikes, number of occupied bikes, and the last connection date and time.
- A pie chart illustrates the percentages of bike stations located on the Anatolian side and the European side.

### Current Availability
A dynamic visualization of station details is provided. The dataset can be filtered using sliders based on the number of available bikes, availability rate (in percent), or station location. The map is dynamically updated according to the selected filters, along with a table at the bottom displaying details of the corresponding stations, such as station number, station name, number of available bikes, number of occupied bikes, total station capacity, and the station's availability rate.

## Dataset

The glimpse of the data as follows;

- Consists of 199 rows and 9 columns.
- There are 85 stations in the Anatolian side, 111 stations in the European side and 3 test stations
- %59 percent of the all stations have 15 slots. The maximum capacity is 30 slots that have in 2 stations, where can be found in Florya.
- The last connection was built with the all stations was on 18th of November around the same time, but the 15 of them don't have the same connection time. Therefore, it is suggested to checking those station in case having a problem.

## Deployment
The project has deployed to Shinyapp.io. Please use the link below to check the Shiny application.

https://eyurderi.shinyapps.io/bike_station_availability_visualization/

## Installation

1. Clone the repository
   `code https://github.com/emreyurderiportfolio/Portfolio/tree/main/Bike_Station_Availability_Visualization` 
2. Navigate to the project directory
3. Create a virtual environment and activate it
4. Install dependencies
   `code deps <- readLines("[file_path]/requirements.txt")
    install.packages(deps)`
5. Run in command prompt
   `code Rscript app.R`




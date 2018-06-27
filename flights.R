#Flight routes
#data from openflights.org
library(tidyverse)

#read routes data
routes <- read.csv("D:/rdump/data/flight/routes.dat", 
                   stringsAsFactors = FALSE, header = FALSE)
#extract origin and destination airports
routes <- routes[,c(3,5)]
#read airports data
airports <- read.csv("D:/rdump/data/flight/airports.dat", 
                     stringsAsFactors = FALSE, header = FALSE)
#extract airport code, lon and lat
airports <- airports[,c(5, 7, 8)]
#filter airports with no name
airports <- airports %>%
  filter(V5 != "\\N")
length(unique(airports$V5))
#join
routes2 <- routes %>%
  left_join(airports, c("V3" = "V5"))
routes2 <- routes2 %>%
  left_join(airports, c("V5" = "V5"))
tail(routes2)
routes2 <- routes2[complete.cases(routes2),]
routes2 <- routes2[sample(c(1:nrow(routes2)), 30000),]
#new internal routes only from hanh
routes3 <- read.csv("C:/Users/Lenovo/github/global/data/route fin intldomestic.csv",
                    stringsAsFactors = FALSE)
routes3 <- routes3 %>%
  filter(flag != 0)
#join again
routes3 <- routes3 %>%
  left_join(airports, c("SourceAirport" = "V5"))
routes3 <- routes3 %>%
  left_join(airports, c("Destinationairport" = "V5"))
tail(routes3)
#plot test with straight lines
geosource <- matrix(c(routes3$V8.x, routes3$V7.x), ncol = 2)
geodestination <- matrix(c(routes3$V8.y, routes3$V7.y), ncol = 2)
library(geosphere)
library(sp)
# library(reshape2)
library(maps)
library(maptools)
library(rgeos)
library(ggmap)
library(ggplot2)
require(rgdal)
library(plyr)
source("C:/Users/Lenovo/Documents/R_source/fort.R")
cgc <- gcIntermediate(geosource, geodestination, 30,
                      breakAtDateLine = TRUE,
                      addStartEnd = TRUE, sp = TRUE)
cgc.ff <- fortify.SpatialLinesDataFrame(cgc) #this takes long
# cgf.ff <- fortify(cgc)
rm(cgc)
#get worldmap
# couleur <- brewer.pal(9, "PuRd")
# read world shapefile from natural earth
# wmap <- readOGR(dsn="D:/R/Map/110m_cultural", layer="ne_110m_admin_0_countries")
# convert to dataframe
# wmap_df <- fortify(wmap)
#plot

#plot vars [default theme - light]
source.couleur <- "green4" #"green4"
destination.couleur <- "red1" #"red3"
mid.couleur <- "steelblue4"
backdrop.couleur <- "black" #"azure2" #"grey4"
outline.couleur <- "black"  #"slategrey"
landmass.couleur <- "gray95"
text.couleur <- "black"
alpha <- 0.1 #0.3 0.2
size <- 0.01 #0.02 0.01
legend.emplacement <- "none" #c(.12,.22)
plot <- ggplot() +
  # geom_polygon(aes(long,lat,group=group),
  #              size = 0.2, fill=landmass.couleur,
  #              colour = landmass.couleur,
  #              data=wmap_df) + #landmass backdrop
  # geom_polygon(aes(long,lat,group=group),
  #              size = 0.04, fill=NA,
  #              colour = outline.couleur,
  #              data=wmap_df, alpha=0.5) + #country boundary
  geom_line(aes(long, lat, group=group), col="darkgoldenrod1",
            data=cgc.ff, alpha = alpha,
            size= size) + #drawing great circle lines works .02,.03
  guides(alpha = "none") +
  theme(#plot.background = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_rect(fill='black', colour='black'),
        # panel.background = element_rect(fill=backdrop.couleur,
        #                                 colour=backdrop.couleur),
        legend.position = legend.emplacement,
        legend.background = element_rect(fill = NA,
                                         color=landmass.couleur),
        legend.text = element_text(size = 7, colour = text.couleur),
        legend.title = element_text(size = 8, colour = text.couleur),
        axis.text.x  = element_blank(),
        axis.text.y  = element_blank(),
        axis.ticks  = element_blank(),
        axis.title  = element_blank()
  ) +
  coord_equal() +
  geom_text(aes(x= 0, y=90, 
                label=""),
            color=text.couleur, size=5)
ggsave("hanhmie6.pdf", plot, dpi = 600, width = 420 , height = 297, units = "mm") #this takes time
ggsave("hanhmie6.png", plot, dpi = 600, width = 420 , height = 297, units = "mm") #this takes time
# require(ggmap)
# geocode("10 Wheaton Road, Stepney, South Australia, Australia")

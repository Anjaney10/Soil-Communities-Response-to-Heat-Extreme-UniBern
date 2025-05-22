#-- --- --
# Purpose of script: To generate a plot of final ODs versus the amount of supernatant
#-- --- --
# Script Title: Fig3C.R
#-- --- --
# Script Author: Zachary Michael Bailey
#-- --- --
# Script created on: 2025-03-02
# ------------------------------
# Clear the enivronment of variables
rm(list = ls())
# Load Standard Packages
require(tidyverse)
library("ggtext") # For italicized species names
###############################  Code for Figure 3C  #############################
# Set working directory
setwd("path/to/file/")
# Import data
data <- read.csv("Fig3_C_data.csv")
#### Making the Palette for our plots
# define a palette for plotting the 4 species
species_4pal_alphabetical = palette.colors(8, palette = "R4")[c(3, 5, 7, 2)] #in alphabetical order: grimontii, protegens, putida, veronii
species_4pal_speed = palette.colors(8, palette = "R4")[c(7, 5, 3, 2)] #from fast to slow: putida, protegens, grimontii, veronii
# Saving the theme 
fave_theme <- theme_light() + theme(text = element_text(size=15), panel.grid.major = element_blank(), panel.grid.minor = element_blank()) 
theme_set(fave_theme)
### Saving IC50 values
IC50_protegens <- unique(data$IC50[which(data$bacteria == "protegens")])
IC50_putida <- unique(data$IC50[which(data$bacteria == "putida")])
IC50_grimontii <- unique(data$IC50[which(data$bacteria == "grimontii")])
IC50_veronii <- unique(data$IC50[which(data$bacteria == "veronii")])
### Plot of Supernatant versus Final ODs with IC50 values
plot_fig3_C <- ggplot(data, aes(x = supernatant_percent, y = avg_OD, color = supernatant_origin)) +
  geom_point()+
  geom_errorbar(ymin = data$avg_OD-data$se_OD, 
                ymax = data$avg_OD+data$se_OD) +
  geom_line() +
  labs(title = "Effect of *P. protegens* on *Pseudomonas* growth",
       x = "Percentage of Supernatant",
       y = "Final OD600 value") +
  geom_vline(xintercept = 100, color = species_4pal_alphabetical[2])+ # The IC50 for protegens is > 100% and extends beyond xlim
  geom_vline(xintercept = IC50_putida, color = species_4pal_alphabetical[1])+
  geom_vline(xintercept = IC50_grimontii, color = species_4pal_alphabetical[3])+
  geom_vline(xintercept = IC50_veronii, color = species_4pal_alphabetical[4])+
  scale_color_manual(name = "Bacteria and Supernatant",
                     breaks = c("protegens_mono",
                                "protegens_putida_coculture",
                                "protegens_grimontii_coculture",
                                "protegens_veronii_coculture"),
                     labels = c("*P. protegens* Monoculture",
                                "*P. putida* in Protegens Co-culture",
                                "*P. grimontii* in Protegens Co-Culture",
                                "*P. veronii* in Protegens Co-Culture"
                     ),
                     values = species_4pal_alphabetical[c(2,1,3,4)]) +
  
  scale_x_continuous(breaks = c(0,10,20,30,40,50,60,70,80,90))+
  theme(axis.text.x = element_text(color = "black"),
        axis.text.y = element_text(color = "black"),
        legend.text = element_markdown(),
        plot.title = element_markdown(),
        axis.title.y = element_markdown(),
        strip.text = element_markdown())
### Save the plot
png(filename = "Figure_3_C.png", width= 9, height = 6, units = "in", res = 400, type = "cairo")
print(plot_fig3_C)
dev.off()

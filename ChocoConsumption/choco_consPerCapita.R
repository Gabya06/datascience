library(ggplot2)
library(ggthemes)
library(scales)
library(reshape)
library(plyr)

# source of data:
# http://caobisco.eu/public/images/page/caobisco-10072013170141-Ranking_of_consumption_FBW.pdf

# Load chocolate data
chocoData <- read.csv('~/dev/Rstudio/blogpost3/choco_consumption.csv')
# change names
names(chocoData) <- c('Countries','2006','2007','2008','2009','2010','2011')
# melt into a dataframe
choco_df <-melt(chocoData)
# remove na's produced
choco_df <- na.omit(choco_df)

# change names
names(choco_df)<- c('Countries','Year','Consumption')
# find top 15 consumptions
o = order(choco_df$Consumption, decreasing = T)[1:15]
choco_df[o,]
# ireland germany switzerland and Uk
top_choco <- choco_df[choco_df$Countries %in% c('IRELAND','GERMANY','SWITZERLAND','UNITED KINGDOM'),]

o_small<- order(choco_df$Consumption, decreasing = F)[1:15]
choco_df[o_small,]

east_choco<- choco_df[choco_df$Countries %in% c('ROMANIA','POLAND','BULGARIA','SLOVENIA'),]

# -----------------------------------------------------------------------------------------
# section includes plots for 4 countries: Ireland, Germany, Switzerland, Uk
# Line plot of consumption for each country for 20006-2011
# Line plot of consumption facetted for each country
# Density plot of consumption for each country
# Violin plot of consumption for each country
# Bar graph of consumption
# -----------------------------------------------------------------------------------------
# line plot of chocolate consumption in top 4 countries
plt_topchoco <- ggplot(top_choco, aes(x=Consumption, y = Year)) + 
  geom_line(aes(color = Countries, group = Countries), size =.7) + 
  theme_classic() + 
  scale_colour_brewer(type="div",palette="RdYlGn") + 
  theme(panel.background = element_rect(fill = "lightblue1")) +
  theme(panel.grid.major = element_line(size = 0.3,colour = 'white',linetype = 'dashed')) +
  theme(axis.title.y = element_text(angle = 0))+
  coord_flip() + 
  ggtitle('Countries with highest Chocolate Consumption in kg per Capital\n2006-2011')
plt_topchoco

# facet of top chocolate consumption
plt_topchoco_facets <- ggplot(top_choco, aes(x=Consumption, y = Year)) + 
  geom_line(aes(color = Countries, group = Countries), size =.7) + 
  geom_point()+ 
  facet_wrap(~Countries) +
  theme_classic() + 
  scale_colour_brewer(type="div",palette="RdYlGn") + 
  theme(panel.grid.major = element_line(size = 0.3,colour = 'white',linetype = 'dashed')) +
  theme(panel.background = element_rect(fill = "paleturquoise")) +
  coord_flip() + 
  ggtitle('Countries with highest Chocolate Consumption in kg per Capital\n2006-2011 (by Country)')
plt_topchoco_facets


# plot densities 
plt_dens <- ggplot(top_choco, aes(x=Consumption)) + 
  geom_density(aes(fill=Countries, y = ..scaled..), adjust = 1, position = 'stack', size=.3,colour = 'midnightblue') + 
  facet_wrap(~Countries) +
  scale_fill_brewer(palette = 'PiYG') + 
  scale_x_continuous(name = 'Consumption') +
  scale_y_continuous(name = 'Density') +
  theme(axis.title.y = element_text(angle = 0)) + 
  theme(panel.background = element_rect(fill = "snow")) +
  ggtitle('Density plot of chocolate consumption per capita (kg)')
plt_dens

# violin plot
plt_vio <- ggplot(top_choco, aes(x=Countries, y=Consumption)) + 
  geom_violin(aes(fill = Countries), adjust =1, scale ='width') +
  scale_fill_brewer(palette = 'Set3') + 
  theme(axis.text.x = element_text(colour="black")) + 
  theme(axis.text.y = element_text(colour="black")) + 
  xlab('') + 
  ylab('Consumption(kg)') +
  theme(panel.background = element_rect(fill = "lightblue2")) +
  theme(panel.grid.major = element_line(size = 0.3,colour = 'white',linetype = 'dashed')) +
  coord_flip() + 
  ggtitle('Violin  plot of chocolate consumption per capita (kg)')
plt_vio

# bar graph for each country
plt_bar <- ggplot(top_choco, aes(x=Consumption, y = Year)) +
  geom_bar(position = 'jitter', stat = 'identity',color = 'midnightblue', width = 1, aes(fill = Countries ,group = Countries)) +
  facet_wrap(~Countries) +  
  scale_color_discrete(label ='') +
  scale_fill_brewer(palette="PuRd") +
  theme(axis.title.y = element_text(angle = 0)) + 
  theme(panel.background = element_rect(fill = "mintcream")) +
  theme(panel.grid.major = element_line(size = 0.3,colour = 'gray',linetype = 'dashed')) +
  ggtitle('Bar graph of chocolate consumption by Country')
plt_bar

## check out eastern countries choco consumption
# plot densities 
plt_dens_east <- ggplot(east_choco, aes(x=Consumption)) + 
  geom_density(aes(fill=Countries, y = ..scaled..), adjust = 1, position = 'stack', size=.3,colour = 'midnightblue') + 
  facet_wrap(~Countries) +
  scale_fill_brewer(palette = 'YlGnBu') + 
  scale_x_continuous(name = 'Consumption') +
  scale_y_continuous(name = 'Density') +
  theme(axis.title.y = element_text(angle = 0)) + 
  theme(panel.background = element_rect(fill = "snow")) +
  ggtitle('Density plot of chocolate consumption per capita (kg)\nIn Eastern Europe')
plt_dens_east

# Line facet of chocolate consumption for eastern europe
plt_eastchoco_facets <- ggplot(east_choco, aes(x=Consumption, y = Year)) + 
  geom_line(aes(color = Countries, group = Countries), size =.7) + 
  geom_point()+ 
  facet_wrap(~Countries) +
  theme_classic() + 
  scale_colour_brewer(type="div",palette="RdYlGn") + 
  theme(panel.grid.major = element_line(size = 0.3,colour = 'white',linetype = 'dashed')) +
  theme(panel.background = element_rect(fill = "paleturquoise")) +
  coord_flip() + 
  ggtitle('Eastern Countries Chocolate Consumption in kg per Capital\n2006-2011 (by Country)')
plt_eastchoco_facets


plt_east_vio <- ggplot(east_choco, aes(x=Countries, y=Consumption)) + 
  geom_violin(aes(fill = Countries), adjust =1, scale ='width') +
  scale_fill_brewer(palette = 'Set3') + 
  theme(axis.text.x = element_text(colour="black")) + 
  theme(axis.text.y = element_text(colour="black")) + 
  xlab('') + 
  ylab('Consumption(kg)') +
  theme(panel.background = element_rect(fill = "lightblue2")) +
  theme(panel.grid.major = element_line(size = 0.3,colour = 'white',linetype = 'dashed')) +
  coord_flip() + 
  ggtitle('Violin  plot of chocolate consumption per capita in Eastern Europe (kg)')
plt_east_vio
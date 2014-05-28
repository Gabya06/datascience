# http://www.businessinsider.com/most-popular-jobs-in-america-2014-4
# http://www.bls.gov/oes/2013/may/largest.htm
library(ggplot2)
library(ggthemes)
library(scales)
# dont read file with factors and remove white spaces ****
library(reshape2)
library(grid) #for unit
options(stringsAsFactors= FALSE)
file <- read.csv('~/dev/Rstudio/data/oesm13all/oes_data_2013.csv' , strip.white=TRUE)


# select only  important data
occdata <- subset(file, select = c('area','area_title','area_type','naics','naics_title','occ_code','occ_title',
                                     'group','tot_emp','emp_prse','h_mean','a_mean','a_median')  )

# functions to get rid of spaces and commas
trim <- function (x) gsub("^\\s+|\\s+$", "", x)
trim_comma <- function (x) gsub(pattern = ",",replacement = "",x, fixed = TRUE)

# remove any rows with missing values for total employment and average annual and hourly wage 
occdata <- occdata[(!occdata$tot_emp %in% c("**","*","#")) & 
                     (!occdata$a_mean %in% c("*","#"))  & 
                     (occdata$h_mean!="*") ,]

# make sure no commas or white spaces
occdata$tot_emp <- trim(occdata$tot_emp)
occdata$tot_emp <- trim_comma(occdata$tot_emp)
occdata$a_mean <- trim(occdata$a_mean)
occdata$a_mean <- trim_comma(occdata$a_mean)


# subset data with grouped as detail
detail <- with(occdata, subset(occdata, (group=='detail')))

# subset data by major group
major <- with(occdata, subset(occdata, (group=='major')))

# convert from character to number
detail$tot_emp <- as.integer(detail$tot_emp)
detail$a_mean <- as.integer(detail$a_mean)

# aggregate total employee occupation and sort
detail_agg <- aggregate(tot_emp ~ occ_title, data = detail, sum, na.rm = TRUE)
detail_agg <- detail_agg[(order(detail_agg$tot_emp, decreasing = T)),]

# get top10 emploment occupations from detail set
top10 <- detail_agg[(1:10),]

y <- with(top10, rank(x = tot_emp,ties.method = "first"))
#top10<- top10[rank(x=top10$tot_emp, ties.method = "first"),]

# plot top10 occupations
ggplot(data = top10) + geom_bar(aes(y=(tot_emp/10000000), x=occ_title), stat="identity", fill = alpha("blue",.4)) +
  scale_y_continuous(label=comma,limits=c(0,2.5)) + coord_flip()

# attempt to add lines in between names for label
d1 <- lapply(top10$occ_title, function(x) paste (strwrap(x, 18), collapse = "\n"))
d2 <- melt(data = d1, varnames = c("num","label"), value.name = "labelName")
labels<- d2$labelName
labels[10] <-"Laborers and\nMat.Movers,\nHand Workers"
labels[9] <- "Janitors and\nCleaners\nExcl.Maids"
labels[8] <- "Admn.Assist,\nExcl.Legal,Med\nAnd Exec"
labels[7] <- "Cust Svc\nReps"
labels[6] <- "Waiters and\nWaitresses"
labels[5] <- "Food Prep \nand Serv. Workers,\nIncl.Fast Food"
labels[4] <- "Office Clerks"
labels[3] <- "Cashiers"
labels[2] <- "Reg.Nurses"
labels[1] <- "Retail\nSalespersons"

#levels(labels)[10]<- "Laborers and\nMat.Movers,\nHand Workers"

# set occupational titles to have breaks to be able to plot
top10$occ_title <- labels

# make dotplot of top10 occupations
gdot<- ggplot(data = top10,aes(x=tot_emp/10000000, y=occ_title, fill = tot_emp/10000000))+ 
                        #names.arg=occ_title)) + 
  geom_dotplot(stackgroups = TRUE, binwidth = 0.9, 
               dotsize=.4, binaxis = "y" , binposition="all") +
  scale_fill_gradient(low="blue", high="red")+
  scale_x_continuous(label=comma,limits=c(0,2.5), name ="Employment\n(Millions)") + 
  scale_y_discrete("Occupational Title") + #,labels=labels) +
  ggtitle(label = "Employment of Largest Occupations in US\nMay2013") +
  theme(panel.grid = element_line(size = 0.7, linetype = "dotted")) +
  theme(panel.background = element_rect(fill = "lightsteelblue")) +
  theme(axis.ticks = element_line(size = 1)) + 
  theme(axis.text = element_text(family = "Verdana", colour="black")) +
  theme(axis.text.x = element_text(angle = 0, size = 11)) +
  theme(axis.title.y = element_text(size = rel(1), angle = 0)) +
  theme(legend.position = "none") +
  theme(plot.title = element_text(family = "Verdana",face = "italic",size=12)) +
  geom_text(stat="identity", colour="white", size=4, hjust=1.7,vjust= .5,
            aes(x=tot_emp/10000000, label=signif(tot_emp/10000000,2))) +
  coord_flip() 
gdot  

#--------------------------------------------------------------------------------------------------------------
# scatter plot of total employment and occupational title
#--------------------------------------------------------------------------------------------------------------
# do not show legend for size: show_guide=F
# add breaks for employment in millions
# change size of bubbles: scale_size_discrete(range)
# make legend smaller: legend.key.size = unit(). Need grid for this
# make background darkblue
g_scat<- ggplot(data=top10, aes(x=tot_emp/10000000, y=occ_title, 
                           color = tot_emp/10000000))+ 
  geom_point(aes(size = factor(tot_emp)), show_guide = FALSE)  +
  scale_color_gradient(low="yellow", high="lightgreen", name ="Employment") +
  scale_size_discrete(range = c(4,10)) +
  theme(panel.background = element_rect(fill = "navyblue")) +
  theme(panel.grid = element_line(size = 0.25, linetype = "dotted")) +
  scale_x_continuous(label=comma, limits=c(1,2.5), 
                     breaks = c(seq(from = 1,to = 2.5,by = .25)),
                     name ="Employment\n(Millions)") +
  scale_y_discrete("Occupational Title") +
  theme(axis.text = element_text(family = "Verdana", colour="black")) +
  theme(axis.text.y = element_text(angle = 0, size = 10)) +
  theme(axis.title.y = element_text(size = rel(1), angle = 0,vjust = 1)) +
#   scale_size_discrete(range = c(4,10), name = "Size by\nEmployment Number", guide = "legend",
#                       label=rev(signif(top10$tot_emp/10000000,2)))+ #looks better w.o this
  theme(legend.key.size = unit(0.7, "cm")) +
  theme(legend.position = "bottom", legend.direction ="horizontal") +
  ggtitle(label = "Employment of Largest Occupations in US\nMay2013") 
g_scat
  
#--------------------------------------------------------------------------------------------------------------
# dot plot
#--------------------------------------------------------------------------------------------------------------
gdot2<- ggplot(data = top10,aes(x=tot_emp/10000000, y=occ_title, fill = tot_emp/10000000)) + 
  geom_dotplot(binwidth = 0.9, 
               dotsize=.5, binaxis = "y" , binpositions ="all") +
  scale_fill_gradient(low="blue", high="red", name ="Employment")+
  scale_x_continuous(label=comma,limits=c(1,2.5), name ="Employment\n(Millions)") + 
  scale_y_discrete("Occupational Title") +
  ggtitle(label = "Employment of Largest Occupations in US\nMay2013") +
  theme(panel.grid = element_line(size = 0.7, linetype = "dotted")) +
  theme(panel.background = element_rect(fill = "lightsteelblue")) +
  theme(axis.ticks = element_line(size = 1)) + 
  theme(axis.text = element_text(family = "Verdana", colour="black")) +
  theme(axis.text.x = element_text(angle = 0, size = 11)) +
  theme(axis.title.y = element_text(size = rel(1), angle = 0)) +
  theme(legend.key.size = unit(0.65, "cm")) +
  theme(legend.position = "bottom", legend.direction ="horizontal") +
  theme(plot.title = element_text(family = "Verdana",face = "italic",size=12)) +
  geom_text(stat="identity", colour="white", size=4, hjust=0.7,vjust= -0.9,
            aes(x=tot_emp/10000000, label=signif(tot_emp/10000000,2))) +
  coord_flip() 
gdot2  


#--------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------
# save obejcts
save(top10, file ="~/dev/Rstudio/blogpost2/top10.rdata")
load("~/dev/Rstudio/blogpost2/top10.rdata")
save(top10, top10_v2, file ="~/dev/Rstudio/blogpost2/top10.rdata")



top10_df <- top10
top10_df$tot_emp <- factor(top10$tot_emp, levels = top10_df[order(top10_df$tot_emp),"tot_emp"])


top10_df$levels <- factor(x = top10$tot_emp, levels = rev(levels(factor(top10_df$tot_emp))),ordered = T)
top10_df$levels <- levels(factor(x = top10$tot_emp, levels = c("1","2","3","4","5","6","7","8","9","10"),ordered = T))
detail_occ_mWage <- aggregate(tot_emp ~ occ_title + a_mean , data =detail, sum, na.rm=TRUE)

#--------------------------------------------------------------------------------------------------------------
## functions to wrap labels - add rows for every 15 characters
#--------------------------------------------------------------------------------------------------------------
#wr.lab <- wrap.label(top10$occ_title,15)

wrap.it <- function(x, len) 
  {
  apply(x, 
         function(y) paste (strwrap(x, len), collapse = "\n") )} # ,
         USE.NAMES = FALSE)
}

#d<-lapply(top10$occ_title, function(x) paste (strwrap(x, 10), collapse = "\n")) 

wrap.label <- function(x, len){
  if(is.list(x))
  {
    lapply(x, wrap.it, len)
  }
  else {
    wrap.it(x, len)
  }
}

#--------------------------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------
# section to import files
# ----------------------------------------------------------------------------------------------
library(plyr)
library(ggplot2)
library(ggthemes)
library(scales)
library(Hmisc) #for looking at data
# get a vector of the names in specified directory & list the files
f<-list.dirs(path = "/Users/Gabi/dev/datascience/MariaDecline/assets/",full.names = TRUE)
list.files(f)


# wd must match path##
setwd("/Users/Gabi/data/names/")

# set path to read all name files
path <- "/Users/Gabi/data/names/"

# create a list with files to read
filenames <- list.files(path = path, pattern = ".txt" )
                        #all.files = FALSE, full.names = FALSE, 
                        #recursive = FALSE, ignore.case = FALSE)
# names of columns
names<-c("Name","Sex","NameCount")

# helper function to read individual csv file and add a column with the year
# ret (what to return) will take in all files read
# get year info from name of file being read
# set col.name = NULL (dont want to import wrong names)
# add column to ret called Year
read_csv_filename <- function(filename){
  ret <- read.csv(filename, header=FALSE, col.names=names, stringsAsFactor=FALSE)
  year <- substr(filename, 4, 7)
  col.names <-NULL
  ret$Year <- year
  ret
}

# use llply to apply the read_CVS function to the filenames - dont need this
#import.list <- llply(filenames, read_csv_filename)

# use ldply to apply the read_csv function to read the filenames
# and return a dataframe
df <- ldply(filenames, read_csv_filename)
rownames(df)<-NULL
head(df)
tail(df)
str(df)


# ----------------------------------------------------------------------------------------------
# section to manipulate dataframe of all names: add totals for all and for females
# create dataframe for marys only and add percentages and sums
# ----------------------------------------------------------------------------------------------

# create a dataframe w total of population by year ##
year_pop_total <- ddply(df, .(Year) , function(x) sum(x$NameCount))
# create column for female totals
year_pop_f <- ddply(df[(df$Sex=="F"),], .(Year) , function(x) sum(x$NameCount))

# merge new column to df with totals for all population
df<- merge(df, year_pop_total,by.x = "Year", by.y = "Year",all.x = TRUE)
names(df)[5] <- "YearPopTotal"

# merge new column to df with totals for females
df<- merge(df, year_pop_f,by.x = "Year", by.y = "Year",all.x = TRUE)
names(df)[6] <- "YearPopFemale"

theMarys<-c("Mary","Marry","Marie","Mari","Marri","Marrie","Marye",
            "Maria","Marria")

mary<-df[df$Name %in% c("Mary","Marry","Marie","Mari","Marri","Marrie","Marye",
                      "Maria","Marria") & df$Sex =="F" ,]

# add percentages of total population
mary$PercentPop<- mary$NameCount/mary$YearPopFemale

# sum up just the marys
TotalMarys<- ddply(mary, .(Year), function(x) sum(x$NameCount))
# merge new column to mary dataframe
mary<-merge(x = mary,y = TotalMarys,by.x = "Year", by.y = "Year", all.x = TRUE)
# rename column names(mary)[7]<-"MaryTotalPop"
names(mary)[8]<-"MaryTotalPop"


# ----------------------------------------------------------------------------------------------
# section to plot marys (all variations)
# ----------------------------------------------------------------------------------------------

str(mary)
head(mary)
# quick plot to see counts - is it worth keeping all the names?
pltMary <- ggplot(mary, aes(x=Name,y=NameCount, color = Name)) +
  geom_line() + scale_y_continuous(label=comma) + 
  ggtitle("Different spelling of Mary and Maria") + 
  theme_economist_white() +
  scale_colour_brewer(type="div",palette="Set1")
pltMary

# ----------------------------------------------------------------------------------------------
# Section includes: graphs of Mary in time
# Changing mary names to only Mary, Maria and Marie (remove other variations)
# More graphs of mary in time
# very useful:
# http://cran.r-project.org/web/packages/ggplot2/ggplot2.pdf
# ----------------------------------------------------------------------------------------------

# change to only include Maria, Marie and Mary
#mary<-df[mary$Name %in% c("Mary","Marie","Maria") & df$Sex=="F" ,]
mary<-mary[mary$Name %in% c("Mary","Marie","Maria"),]
str(mary)
head(mary)

#basic plot
p <- ggplot(mary, aes(x=Name,y=NameCount, color = Name)) +
  geom_line() + 
  geom_point() +
  labs(title="Mary, Marie and Maria") + 
  theme_classic() +
  scale_colour_brewer(type="seq",palette="Set1") + 
  scale_y_continuous(label=comma) 
p


# use all data of all Mary's to plot by year
plt_mary1 <- ggplot(mary, aes(x=Year,y=NameCount)) + 
  geom_line(aes(color=factor(Name), group = Name)) +
  scale_color_discrete(name="") +
  scale_x_discrete(breaks=c(seq(1880,2012,by=10))) +
  scale_y_continuous(label=comma) + 
  theme_classic() +
  ggtitle("Mary, Marie and Maria\n 1880-2012") 
plt_mary1

# showing all mary names in time (same as #1)
plt_mary2 <- ggplot(mary, aes(x=Year,y=NameCount)) + 
  geom_point(aes(color=factor(Name), group = Name)) + 
  geom_line(color="grey") +
  scale_x_discrete(breaks=c(seq(1880,2012,by=20))) +
  scale_y_continuous(label=comma) + 
  theme_wsj(base_size = 8,color = "gray",title_family = "sans") +
  scale_color_brewer(type ="seq",palette = "PuRd",name="") +
  ggtitle("Trends of Mary: 1880-2012") 
plt_mary2


# plot the percentages throughout years
plt_mary_per <- ggplot(mary, aes(x=Year, y=PercentPop)) + 
  geom_line(aes(color=Name, group=Name),size = 1) + 
  scale_x_discrete(breaks=c(seq(1880,2012,by=10))) + 
  ggtitle("Mary, Marie and Maria \n As Percentages of Total Population \n 1880-2012") +
  scale_color_discrete(name="") + 
  scale_y_continuous(label = percent) +
  theme(panel.grid = element_line(size = 0.4, linetype = "dotted")) +
  theme(legend.position="bottom") + 
  theme(panel.background = element_rect(fill = "black")) +
  theme(axis.text.x = element_text(colour="black")) + 
  theme(axis.text.y = element_text(colour="black")) 
plt_mary_per


# ----------------------------------------------------------------------------------------------
# Section to compare to the top 2 names throughout the years (females only) with Mary
# useful:
# http://r.789695.n4.nabble.com/Subsetting-for-the-ten-highest-values-by-group-in-a-dataframe-td4334475.html
# ----------------------------------------------------------------------------------------------


# create data frame with only top 10 namecounts for each year (boys + girls)
# rank method is decreasing in count and subsetting on ordering for top 10
df_top10<-ddply(df, "Year",function(df) 
  df[order(rank(df$NameCount,ties.method = "first"), decreasing = T)[1:10],])

# should show 3 years worth (10rows per yr)
head(df_top10,30)

# create dataframe for females only
df_f <- df[(df$Sex=="F"),]

# add percentages of total female population to dataframe w only female names
df_f$PercentFemalePop<- df_f$NameCount/df_f$YearPopFemale

# top 2 girl names per year
df_f_top2 <- ddply(df_f,'Year', function(df_f)
  df_f[order(rank(df_f$NameCount, ties.method = "first"), decreasing = T)[1:2], ])

# Only Jennifer, Linda and Mary appear with significant trends - plot with facets
plt_top2 <- ggplot(df_f_top2[(df_f_top2$PercentFemalePop>0.035 & df_f_top2$NameCount >45000) ,], 
                 aes(x=Year,y=NameCount)) + 
  facet_wrap(~ Name, drop = T) + 
  geom_line( aes(color=factor(Name), group = Name)) + geom_point() +
  scale_color_discrete(name="Popular Names") + 
  theme_economist_white(horizontal = T , base_family = "Verdana", base_size = 10) + 
  scale_x_discrete(breaks=c(seq(1880,2012,by=10))) + 
  scale_y_continuous(label=comma) +
  theme(panel.grid = element_line(size = 0.4, linetype = "dotted")) +
  theme(legend.position="bottom") + 
  ggtitle("Most significant trend: Names with count above 3.5% \n Years: 1880-2012")
plt_top2

# Same as above - another look - no facets 
plt_top2_nf <- ggplot(df_f_top2[(df_f_top2$PercentFemalePop>0.035 & df_f_top2$NameCount >45000) ,], 
           aes(x=Year,y=NameCount)) +   
  geom_line(aes(x=Year, y=NameCount, color = factor(Name), group = Name)) +
  scale_x_discrete(breaks=c(seq(1880,2012,by=10))) + 
  theme_calc() +
  scale_color_discrete(name="Popular Names") + 
  theme(legend.position = "right") + 
  scale_y_continuous(limits=c(35000,70000),label=comma) +
  ggtitle("Top Girl Names - Percentage > 3.5% \n 1880 - 2012 ")
plt_top2_nf

# histogram of Top names
plt_hst <- ggplot(df_f_top2[(df_f_top2$PercentFemalePop>0.035 & df_f_top2$NameCount >45000) ,] ,
            aes(x=Year,y=NameCount)) + 
  geom_bar(aes(stat = "identity", fill=Name)) + scale_fill_brewer(palette="YlOrRd", type = "seq")+
  scale_color_discrete(name="Popular Names") + 
  scale_y_continuous(label=comma) + 
  scale_x_discrete(breaks=c(seq(1880,2012,by=10))) +
  ggtitle("Top Girl Names - Percentage > 3.5% \n 1880 - 2012 ") +
  theme(axis.text.x = element_text(colour="black")) + 
  theme(axis.text.y = element_text(colour="black")) +
  theme(panel.grid = element_line(size = 1, linetype = "dotted"))
plt_hst

# ----------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------
# Plots of names throughout the years - just experimenting
# ----------------------------------------------------------------------------------------------
df_f_top3 <- df_f_top2
p_top3_1900 <- ggplot(df_f_top3[(df_f_top3$Year<=1900 & df_f_top3$PercentFemalePop>0.025),], 
                      aes(x=Year,y=NameCount)) + 
  geom_line(aes(color=factor(Name), group = Name)) +
  scale_x_discrete(breaks=c(seq(1880,1910,by=5))) + 
  scale_color_discrete(name="") + 
  scale_y_continuous(label=comma) + 
  ggtitle("Top Girl Names - Percentage > 2.5%  ")
p_top3_1900


p_top1920 <- ggplot(df_f_top3[(df_f_top3$Year>=1900 & df_f_top3$Year<=1920 & df_f_top3$PercentFemalePop>0.03),], 
                    aes(x=Year,y=NameCount)) + 
  geom_line(aes(color=factor(Name), group = Name)) + geom_point() + 
  scale_x_discrete(breaks=c(seq(1900,1920,by=5)))+ scale_y_continuous(label=comma)
p_top1920

p_top1940 <- ggplot(df_f_top3[(df_f_top3$Year>=1920 & df_f_top3$Year<=1940 & df_f_top3$PercentFemalePop>0.03),], 
                    aes(x=Year,y=NameCount)) + 
  geom_line(aes(color=factor(Name), group = Name)) + geom_point() +
  scale_x_discrete(breaks=c(seq(1920,1940,by=5)))+ scale_y_continuous(label=comma)
p_top1940

p_top1960 <- ggplot(df_f_top3[(df_f_top3$Year>=1940 & df_f_top3$Year<=1960 & df_f_top3$PercentFemalePop>0.03),], 
                    aes(x=Year,y=NameCount)) + 
  geom_line(aes(color=factor(Name), group = Name)) + geom_point() +
  scale_x_discrete(breaks=c(seq(1940,1960,by=5)))+ scale_y_continuous(label=comma)
p_top1960

p_top1980 <- ggplot(df_f_top3[(df_f_top3$Year>=1960 & df_f_top3$Year<=1980 & df_f_top3$PercentFemalePop>0.03),], 
                    aes(x=Year,y=NameCount)) + 
  geom_line(aes(color=factor(Name), group = Name)) + geom_point() +
  scale_x_discrete(breaks=c(seq(1960,1980,by=2)))+ scale_y_continuous(label=comma)
p_top1980

p_top2000 <- ggplot(df_f_top3[(df_f_top3$Year>=1980 & df_f_top3$Year<=2012 & df_f_top3$PercentFemalePop>0.03),], 
                    aes(x=Year,y=NameCount)) + 
  geom_line(aes(color=factor(Name), group = Name)) + geom_point() +
  scale_x_discrete(breaks=c(seq(1980,2012,by=2))) + scale_y_continuous(label=comma)
p_top2000



# ----------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------


# create dataframe showing only mary's in top 10 position throughout years
mary_Top10<-df_top10[(df_top10$Name %in% c("Mary","Marie","Maria") & df_top10$Sex =="F"),]

# see years when Mary was in top 10 - no Maria or Marie...
plot_top_mary <- ggplot(mary_Top10, aes(x=Year,y=NameCount)) + 
  geom_line(aes(color=factor(Name), group = Name)) +
  scale_color_discrete(name="Girl Names") + 
  scale_x_discrete(breaks=c(seq(1880,2012,by=10)))+
  scale_y_continuous(label=comma) + theme_classic() +
  ggtitle("Mary was in top 10 \n Marie and Maria do not appear in top 10 \n 1880-2012")
plot_top_mary


# ----------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------

df_top10_f<- df_top10[(df_top10$Sex=="F"),]
# create order set of top 10 names by NameCount
ordered_top <- df_top10[order(df_top10$NameCount,decreasing = T),]
View(ordered_top,10)

library(Hmisc)
describe(ordered_top)



View(mary)


head(df1[order(df1$NameCount, decreasing = T),],n=10)

df1[order(df1$NameCount, decreasing = T)[1:10],]


df2<- ddply(df1,"NameCount", function(df1) 
  df1[order(df1$NameCount, decreasing = T)[1:10],])

df2 <-ddply(df1,c("NameCount"),subset,rank(NameCount)<=10)


d1974[order(rank(x = d1974$NameCount,ties.method = "first"),decreasing = T)[1:10],]



function(dat){
  
  dat[order(rank(dat,ties.method = "first"), decreasing = T)[1:10],]
}
  

df1<-df
df2 <-df
df1<-transform(df1, count.rank=ave(NameCount,Year, 
                              FUN = function(x) 
                                rank(-x, ties.method = "first")))
head(df1)

df1<- df1[order(df1$count.rank, decreasing = FALSE),]

head(df1)

df2<- transform(df2, count.rank=ave(NameCount,Year, FUN=function(x) 
  order(x, decreasing = FALSE)))



head(df2,n=20)
df2 <- df2[order(df2$count.rank),]
head(df2[order(df2$count.rank,decreasing = T),],n=20)
head(df2[order(df2$NameCount,decreasing = F),],n=20)
summary(df2)
# check some of the dataframes
#head(import.list[[2]][,2:4])
#head(import.list[[1]])



7065/1880


df<- do.call("rbind", sapply(filenames, read.csv, simplify = FALSE,header=FALSE))
head(df)

str(import.list)

sapply(paste("/Users/Gabi/data/names/",sep=".txt"),read.csv,check.names= FALSE, header=FALSE, 
       col.names = c("Name","Sex","NameCount","Year"))
                                        
list.files()
yob1880 <- read.csv(check.names = FALSE, header= FALSE, col.names = c("Name","Sex","NameCount"),
                    ("/Users/Gabi/data/names/yob1880.txt")) 
# assign yer                 
year.assign <- function(dat,yr){
  return(cbind(dat, Year = rep(yr,nrow(dat))))
}


year.assign <- function(dat,yr){
  return(data.frame(cbind(dat, Year = rep(yr,nrow(dat)))))
}


head(yob1880)

library(plyr)

d_ply(yob1880, .(Name), function(x) print(head(x)))
# this works
d_ply(yob1880, .("Year"), function(x) print(head(year.assign(x,1880))))

c<- data.frame(year.assign(yob1880,1800))


ddply(df[1], .("Year"), function(x) year.assign(x,1881))
ldply(ls, .("Year"), function(x) data.frame(year.assign(x,1800)))

ddply(yob1880, .("Year"), function(x) print(head(year.assign(x,1880))))


ddply(yob1880, year.assign(yob1880,1880))

head(year.assign(yob1880,1880))

c<- data.frame(year.assign(yob1880,1800))

head(yob1880)
yob1880["year"]<- year.assign(yob1880,1880)

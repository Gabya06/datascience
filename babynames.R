library(plyr)
library(ggplot2, scales)

#http://familyinequality.wordpress.com/2013/05/11/mary-free-fall-continues/#comments

# set path to read files
path <- "/Users/Gabi/data/names/recent/"

# set options
options(stringsAsFactors = FALSE, header = FALSE, check.names = FALSE)

# get a list of files ending in .txt
files <- list.files(path=path, pattern="*.txt")

# read files 1990-2012
for(file in files)
{
  perpos <- which(strsplit(file, "")[[1]]==".")
  year <- substr(file, 4, 7)
  assign(  
    gsub(" ","",substr(file, 1, perpos-1)),
    read.csv(check.names= FALSE, header=FALSE, col.names = c("Name","Sex","NameCount","Year"),
             paste(path,file,sep="")))
}
# add year info
yob1990[4]<-1990
yob1991[4]<-1991
yob1992[4]<-1992
yob1993[4]<-1993
yob1994[4]<-1994
yob1995[4]<-1995
yob1996[4]<-1996
yob1997[4]<-1997
yob1998[4]<-1998
yob1999[4]<-1999
yob2000[4]<-2000
yob2001[4]<-2001
yob2002[4]<-2002
yob2003[4]<-2003
yob2004[4]<-2004
yob2005[4]<-2005
yob2006[4]<-2006
yob2007[4]<-2007 
yob2008[4]<-2008
yob2009[4]<-2009
yob2010[4]<-2010
yob2011[4]<-2011
yob2012[4]<-2012


# bind all dataframes into one
x<- do.call(rbind, lapply(ls(pattern = "yob"),get))
tail(x)
head(x)


#agg1950 <- aggregate(Population ~ Location + Year, cleanpop1950, sum, na.rm=TRUE)
# aggregate by namecount (by name & year)

name_aggregate <- aggregate(NameCount ~ Name, x, sum)
agg<- aggregate(NameCount ~ Year + Name + Sex, x, sum)
head(name_aggregate)

# find top 8 names
top.names<- name_aggregate[order(name_aggregate$NameCount, decreasing = TRUE),]
top.fnames <- top.names[top.names$Sex =="F",]
head(top.names,n=8)


# sort to see top names
aggyr <- aggyr[order(-aggyr$Year, -aggyr$NameCount, decreasing=FALSE),]
#head(x[,1:4])
#head(x[x$Name =="Marrye" ,])

# find names like Mary
mary<-x[x$Name %in% c("Mary","Marry","Marie","Mari","Marri","Marrie","Marye",
                      "Maria","Marria") ,]

# remove row names from mary dataframe
row.names(mary) <- NULL
# females only
mary_f <- mary[mary$Sex =="F",]
row.names(mary_f)<- NULL
# males only 
mary_m <- mary[mary$Sex =="M",]
row.names(mary_m)<- NULL
# plot the boys named any variation of Mary
g_m<- ggplot(mary_m, aes(x=Year,y=NameCount)) + 
  geom_line(aes(color=factor(Name), group = Name)) +
  scale_color_discrete(name="Boy Names")  +  scale_y_continuous(label=comma) +
  labs(title = "Baby Boys named Mary from 1900-2010\n Reduced Data") 
g_m + facet_wrap(~Name)

# plot the various spellings of Mary
g_f<- ggplot(mary_f, aes(x=Year,y=NameCount)) + 
  geom_line(aes(color=factor(Name), group = Name)) +
  scale_color_discrete(name="Girl Names")  + scale_y_continuous(label=comma) +
  labs(title = "Baby Girls named Mary from 1900-2010\n Reduced Data") 
g_f + facet_wrap(~Name)

# need to look at just Maria and Mary - resubset
marys<-x[x$Name %in% c("Mary","Maria") ,]
marys <- marys[marys$Sex=="F",]
summary(marys)

# plot Mary and Maria
g_f1<- ggplot(marys, aes(x=Year,y=NameCount)) + 
  geom_line(aes(color=factor(Name), group = Name)) +
  scale_color_discrete(name="Girl Names - Mary's")  + scale_y_continuous(label=comma) +
  labs(title = "Baby Names \n Girls named Mary and Maria \n 1990-2012") 
g_f1 

# closer look at Maria & Mary side by side
g_f2<- ggplot(marys, aes(x=Year,y=NameCount)) + 
  geom_line(aes(color=factor(Name), group = Name)) +
  scale_color_discrete(name="Girl Names - Mary's")  + scale_y_continuous(label=comma) +
  labs(title = "Baby Names\n Girls named Mary and Maria \n 1990-2012") 
g_f2 + facet_wrap(~Name)

# histogram of both names - they switch popularity around 1996
h_f2 <- ggplot(marys, aes(x=Year, y=NameCount)) + 
  geom_histogram(stat="identity", aes(color = Name, group = Name)) +
  scale_y_continuous(label = comma) + labs(title = "Baby Names \n Mary and Maria - The Decline \n 1990-2012") 
h_f2 

# ---------------------------------------------------------- #
## Go back and check for most name counts to compare trends ##

# aggregate names by name and sex
name_s_agg <- aggregate(NameCount ~ Name + Sex, x, sum)
name_s_agg <- name_s_agg[order(name_s_agg$NameCount, decreasing = TRUE),]

# summary of all female name counts
total.fnames <- name_s_agg[name_s_agg$Sex =="F",]
# check out what the top 2 names are
head(total.fnames) # looks like Emily and Ashley are in #1 and # 2 

# find Emily and Ashley - to compare with Mary and Maria trend
top.fnames <- x[x$Name %in% c("Emily","Ashley"),]
top.fnames <- top.fnames[top.fnames$Sex =="F",]

# plot Emily and Ashley 
g_top_f1<- ggplot(top.fnames, aes(x=Year,y=NameCount)) + 
  geom_line(aes(color=factor(Name), group = Name)) +
  scale_color_discrete(name="Girl Names")  + scale_y_continuous(label=comma) +
  labs(title = "Baby Names - Top counts \n Girls named Emily and Ashley \n 1990-2012") 
g_top_f1


# compare with Mary and Maria
marys.top.fnames <- x[x$Name %in% c("Emily","Ashley","Mary","Maria"),]
marys.top.fnames <- marys.top.fnames[marys.top.fnames$Sex =="F",]

# look at trends
g_f3<- ggplot(marys.top.fnames, aes(x=Year,y=NameCount)) + 
  geom_line(aes(color=factor(Name), group = Name)) +
  scale_color_discrete(name="Girl Names - Mary's")  + scale_y_continuous(label=comma) +
  labs(title = "Baby Names\n Girls named Mary and Maria \n 1990-2012") 
g_f3 

# look at trends side by side
g_f4<- ggplot(marys.top.fnames, aes(x=Year,y=NameCount)) + 
  geom_line(aes(color=factor(Name), group = Name)) +
  scale_color_discrete(name="Girl Names - Mary's")  + scale_y_continuous(label=comma) +
  labs(title = "Baby Names\n Girls named Mary and Maria \n 1990-2012") 
g_f4 + facet_wrap(~Name)




marys[marys$Year==1994 & marys$Sex=="F",]

# test
mary_m[mary_m$Sex=="M",-2]
mary_m[mary_m$Name == "Mari",]

x1<- x[x$Name=="Maria",]
head(aggyr)
x[[,x$Name=="Sophia"]]
x[[x$Name=="Sophia"]]
head(x[,$Name],n=10)

head(x[order(-x$Year, - x$NameCount, decreasing = FALSE),])

aggyr[aggyr$Name=='M*',]
head(aggyr, n=100)
str(aggyr)
str(x)
tail(aggyr, n=100)

agg1950 <- agg1950[order(-agg1950$Year, agg1950$Population,decreasing =TRUE),]

aggyr[,aggyr$Name=="Maria"]

# add year
year.assign = function(dat,yr){
  return(cbind(data,year = rep(yr,nrow(dat))))
}






names(temp2001) <- names
names <- c("Name","Sex","NameCount","Year")

change.names <- function(x){
  names(x) <- c("Name","Sex","NameCount","Year")
  return(x)
}


dataf <- lapply(dfs, function(x){
  names(x) <- c("Name","Sex","NameCount","Year")
  return(x)
})





# create dataframe for counts of names by year
yearcounts <- ddply(.data = temp, .variables = .(year), .fun = summarize, 
                    grand.total = sum(NameCount))



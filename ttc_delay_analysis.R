library(ggplot2)
library(dplyr)
library(reshape2)
library(tm)
library(ggrepel)
setwd('C:\\Users\\Jerry\\Desktop\\Jerry\\projects\\ttc_delay')

delays=read.csv('ttc_delays.csv')
codes=read.csv('codes.csv')
readme=read.csv('readme.csv')

#reformat codes
codes=codes[c(3,4,7,8)]
codes=codes[-1,]
colnames(codes)=c('code','description','code','description')
codes=full_join(codes[c(1,2)], codes[c(3,4)], by='description')

replacena=function(x){
  return(ifelse(is.na(x[1]), x[2], x[1]))
}

codes$code.x=apply(codes[c('code.x', 'code.y')], 1, replacena)
codes=filter(codes, code.x!='', !is.na(code.x))
codes=codes[-3]
colnames(codes)[1]='code'
write.csv(codes, 'codes.csv', row.names=F)


######################################### start ############################################
library(ggplot2)
library(dplyr)
library(reshape2)
library(tm)
library(ggrepel)
setwd('C:\\Users\\Jerry\\Desktop\\Jerry\\projects\\ttc_delay')

delays=read.csv('ttc_delays.csv')
codes=read.csv('codes.csv')
readme=read.csv('readme.csv')

#exploration
# start with depays
delays$Date=as.Date(delays$Date)
delays$month=months(delays$Date)
delays$year=sapply(delays$Date, function(x){substr(x, 1, 4)})

delays.group=delays%>%group_by(Date)%>%summarise(n=n())

# plot by date
ggplot(data=delays.by.date)+
  geom_line(aes(x=Date, y=n)) #looks terrible, let's do by month

ggplot(data=filter(delays.by.date, Date>='2019-01-01', Date<'2020-01-01'))+
  geom_line(aes(x=Date, y=n)) #interesting plot, looks like a good ARIMA candidate

# trying balloon plot
delays.group=delays[c('year','month','Min.Delay')]
delays.group=delays.group%>%group_by(year, month)%>%summarise(delay_count=n(), mean_delay_time=mean(Min.Delay))
delays.group$month=factor(delays.group$month, month.name)

png(filename="delay_month_year.png",width=1920, height=1080)
ggplot(data=delays.group, aes(x=year,y=month, size=delay_count, alpha=mean_delay_time))+
  geom_point(color='purple', shape=15)+
  guides(alpha = guide_legend(override.aes = list(size = 20)))+
  scale_size(range=c(0,35))+
  labs(title='Delay Time and Count by Month')+
  theme(legend.title = element_text(size = 25),
        legend.text = element_text(size = 25),
        axis.text=element_text(size=25),
        plot.title=element_text(size=25),
        axis.title=element_text(size=25),
        panel.grid=element_line(size=1, color='grey'))
dev.off()

# plot by month
delays.group=delays%>%group_by(year, month)%>%summarise(n=n(), time=sum(Min.Delay))
png(filename="delay_month.png",width=1920, height=1080)
ggplot(data=delays.group, aes(x=n, y=time, color=month))+
  geom_point(size=15)+
  labs(x='Number of incidences', y='Sum of delay time', title='Delay incidences and time by month')+
  #geom_label_repel(size=10, label.size=0, box.padding=1)+
  theme(axis.text=element_text(size=18),
        plot.title=element_text(size=25),
        axis.title=element_text(size=20))
dev.off()

# plot by day of week
day.name=c('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')
delays.group=delays%>%group_by(Day)%>%summarise(n=n(), time=sum(Min.Delay))
png(filename="delay_dow.png",width=1920, height=1080)
ggplot(data=delays.group, aes(x=n, y=time, label=Day))+
  geom_point(size=15, color='red')+
  labs(x='Number of incidences', y='Sum of delay time', title='Delay incidences and time by day of week')+
  geom_label_repel(size=10, label.size=0, box.padding=1)+
  theme(axis.text=element_text(size=18),
        plot.title=element_text(size=25),
        axis.title=element_text(size=20))
dev.off()
# most common delays

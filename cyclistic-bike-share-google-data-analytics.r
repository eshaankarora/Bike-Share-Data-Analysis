{"metadata":{"kernelspec":{"name":"ir","display_name":"R","language":"R"},"language_info":{"name":"R","codemirror_mode":"r","pygments_lexer":"r","mimetype":"text/x-r-source","file_extension":".r","version":"4.0.5"}},"nbformat_minor":4,"nbformat":4,"cells":[{"source":"<a href=\"https://www.kaggle.com/code/eshaanarora2/cyclistic-bike-share-google-data-analytics?scriptVersionId=118662465\" target=\"_blank\"><img align=\"left\" alt=\"Kaggle\" title=\"Open in Kaggle\" src=\"https://kaggle.com/static/images/open-in-kaggle.svg\"></a>","metadata":{},"cell_type":"markdown","outputs":[],"execution_count":0},{"cell_type":"code","source":"#===========packages to be loaded from library for this project===========================\nlibrary(\"readr\")\nlibrary(\"skimr\")\nlibrary(\"dplyr\")\nlibrary(\"lubridate\")\nlibrary(\"tidyr\")\nlibrary(\"ggplot2\")\nlibrary(\"stringr\")\nlibrary(\"extrafont\")\nlibrary(\"scales\")","metadata":{"_uuid":"8f2839f25d086af736a60e9eeb907d3b93b6e0e5","_cell_guid":"b1076dfc-b9ad-4769-8c92-a6c4dae69d19","execution":{"iopub.status.busy":"2023-02-07T11:43:43.903307Z","iopub.execute_input":"2023-02-07T11:43:43.904876Z","iopub.status.idle":"2023-02-07T11:43:44.699723Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"#===========loading datasets into data frames=============================================\n#getwd()\nsetwd(\"/kaggle/input/cyclistic-rides-data-google\")\nx = list.files()\n#df <- read_csv(\"/kaggle/input/cyclistic-bike-share-rides-data-year-2022/202201-divvy-tripdata/202201-divvy-tripdata.csv\")\nmydf <- list()\n\nfor(i in c(1:12)){\n  mydf[[i]] <- read_csv(paste0(x[i],\"/\",x[i],\".csv\")) \n}","metadata":{"execution":{"iopub.status.busy":"2023-02-07T11:43:44.702167Z","iopub.execute_input":"2023-02-07T11:43:44.704171Z","iopub.status.idle":"2023-02-07T11:44:20.44978Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"#==========manipulating and cleaning each month's data frame=============================\n\n#Adding ride duration\nfor(i in seq_along(mydf)){\n  mydf[[i]] <- mydf[[i]] %>% mutate(ride_duration = ended_at - started_at)\n}\n\n#Adding weekday from date\nfor(i in seq_along(mydf)){\n  mydf[[i]] <- mydf[[i]] %>% mutate(weekday = wday(started_at, label=TRUE))\n}\n\n#Filtering data to remove ride ids with characters != 16, ride duration <0 and also to remove all null values in the dataset\n#and assigning it to a new data frame variable\nmydf_final <- list()\nfor(i in seq_along(mydf)){\n  mydf_final[[i]] <- mydf[[i]] %>% filter(nchar(ride_id) == 16 & ride_duration > 0) %>% drop_na()  \n}\n\n#Combining monthly data frames to one single yearly data fram\nmydf_final_yearly <- list()\nfor(i in seq_along(mydf_final)){\n  mydf_final_yearly <- rbind(mydf_final_yearly, mydf_final[[i]]) \n}\n\n#Cleaning station names with substrings \"&amp\" and \"Public Rack\"\nmydf_final_yearly_2 <- mydf_final_yearly %>% mutate(start_station_name = str_replace(start_station_name,\"&amp;\",\"&\"))\nmydf_final_yearly_2 <- mydf_final_yearly_2 %>% mutate(start_station_name = str_replace(start_station_name,\"Public Rack - \",\"\"),\n                                                     end_station_name = str_replace(end_station_name,\"Public Rack - \",\"\")) \n\n#Adding column for month\nmydf_final_yearly_2 <- mydf_final_yearly_2 %>% mutate(month = month(started_at, label = TRUE))","metadata":{"execution":{"iopub.status.busy":"2023-02-07T12:02:42.070092Z","iopub.execute_input":"2023-02-07T12:02:42.071964Z","iopub.status.idle":"2023-02-07T12:03:36.23649Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"#Overview of number of rides based on rider type\nsetwd('/kaggle/working')\nst1 <- mydf_final_yearly_2 %>% group_by(member_casual) %>% summarize(count_of_rides = n()) %>% \nmutate(proportion = round((count_of_rides/ sum(count_of_rides) * 100),2)) %>% \narrange(-proportion) %>% mutate(ypos = cumsum(proportion)-0.5*proportion)\n\nst1 <- st1 %>% mutate(ymax = cumsum(proportion))\nst1 <- st1 %>% mutate(ymin = ymax - proportion)\n\nggplot(data = st1, aes(xmin = 2, xmax = 4, ymin = ymin, ymax = ymax, fill = member_casual)) + geom_rect() + xlim(c(-2,4)) + coord_polar(theta = \"y\", start = 0) + \n  geom_label(aes(x=3, y = ypos, label = paste(str_to_title(member_casual),\"\\n\",\"(\",proportion,\"%)\")), size = 6, color = \"white\") + \n  theme_void() + \n  labs(title = \"Proportion of Rider Types \\n (Jan-Dec 2022)\") + \n  theme(legend.position = \"none\", plot.title = element_text(hjust = 0.5, vjust = -4, size = 25, family = \"Calibri Light\")) +\n  scale_fill_manual(values = c(\"#00337C\",\"#F45D1A\"))","metadata":{"execution":{"iopub.status.busy":"2023-02-07T11:45:07.221676Z","iopub.execute_input":"2023-02-07T11:45:07.222966Z","iopub.status.idle":"2023-02-07T11:45:07.904693Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"#Number of rides based on each month\nst2 <- mydf_final_yearly_2 %>% group_by(month(started_at, label = TRUE), member_casual) %>% summarize(count_of_rides = n())\nst2 <- st2 %>% rename(month = `month(started_at, label = TRUE)`)\nst2 <- st2 %>% mutate(monthly_rides = sum(count_of_rides))\nst2 <- st2 %>% mutate(proportion = round(count_of_rides/monthly_rides*100,1))\nst2 <- st2 %>%  arrange(month, desc(member_casual))\ntot = as.integer(count(mydf_final_yearly))\nst2 <- st2 %>% mutate(percent_of_rides = count_of_rides/tot*100)\nst2 <- st2 %>% mutate(ypos = cumsum(proportion/100)*sum(percent_of_rides) - 0.5*proportion/100*sum(percent_of_rides))\nst2 <- st2 %>% mutate(ypos2 = sum(percent_of_rides))\nggplot(data = st2, aes(x=month, y=percent_of_rides)) + \n  geom_bar(aes(fill = member_casual), stat = \"identity\") + \n  scale_y_continuous(limit = c(0,16), breaks = seq(0,16,by=2)) + \n  scale_fill_manual(values = c(\"#00337C\",\"#F45D1A\"), labels = str_to_title(c(\"Casual\",\"Member\")), name = \"Rider Type\") + \n  geom_text(aes(y= ypos, label = paste(proportion,\"%\")), size = 2.5, color =\"white\") + \n  labs(title =\"Monthly Share of Rides\", x = \"Month\", y = \"% of Total Rides\") +\n  theme(legend.position = c(0.88,0.86), legend.background = element_blank(), plot.title = element_text(hjust = 0.5), text = element_text(family = \"Calibri Light\"), panel.background = element_blank(), panel.grid.major.y = element_line(color = \"#DDDEEE\")) +\n  geom_label(aes(x=month, y=ypos2, label = round(ypos2,1) %>% paste(\"%\")), size = 2.5, vjust = -0.05, fill = \"#658864\", color = \"white\")","metadata":{"execution":{"iopub.status.busy":"2023-02-07T11:45:07.907052Z","iopub.execute_input":"2023-02-07T11:45:07.908451Z","iopub.status.idle":"2023-02-07T11:45:13.447297Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"#Number of rides based on each weekday\nst3 <- mydf_final_yearly_2 %>% group_by(member_casual,month(started_at,label=TRUE),weekday) %>% summarize(count = n())\n\nst3 <- st3 %>% rename(month = `month(started_at, label = TRUE)`)\nggplot(data = st3) + \n  geom_line(aes(x = weekday, y = count, color = member_casual, group = member_casual)) + \n  geom_point(aes(x = weekday, y = count, color = member_casual)) + \n  facet_wrap(~month) +\n  labs(title = \"Trend of Rides by Weekday of Each Month\", x = \"Weekday\", y = \"Number of Rides\") +\n  theme(legend.position = \"top\", legend.background = element_blank(), plot.title = element_text(hjust = 0.5), text = element_text(family = \"Calibri Light\"), panel.background = element_blank(), panel.grid.major.y = element_line(color = \"#DDDEEE\")) +\n  scale_color_manual(values = c(\"#00337C\",\"#F45D1A\"), labels = c(\"Casual\",\"Member\"), name = \"Rider Type\") +\n  scale_y_continuous(breaks = seq(0,80000,by=20000)) + scale_x_discrete(labels = as.numeric(st3$weekday))","metadata":{"execution":{"iopub.status.busy":"2023-02-07T11:45:13.449666Z","iopub.execute_input":"2023-02-07T11:45:13.450991Z","iopub.status.idle":"2023-02-07T11:45:19.448732Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"#Number of rides based on bike type\nst4 <- mydf_final_yearly %>% filter(member_casual == \"casual\") %>% group_by(rideable_type) %>% summarize(count_of_rides = n())\nst4 <- st4 %>% mutate(proportion = round(count_of_rides/sum(count_of_rides)*100,1))\nst4 <- st4 %>% arrange(desc(rideable_type))\nst4 <- st4 %>% mutate(ypos = cumsum(count_of_rides) - 0.5*count_of_rides)\nst4 <- st4 %>% mutate(ymax = cumsum(count_of_rides), ymin = cumsum(count_of_rides)-count_of_rides)\nggplot(data = st4) + \n  geom_rect(aes(xmin = 1, xmax = 2, ymin = ymin, ymax = ymax, fill = rideable_type)) + xlim(-1,2) +\n  coord_polar(theta = \"y\") +\n  theme_void() +\n  geom_label(aes(x=1.5, y=ypos, label = paste(str_to_title(str_replace(rideable_type,\"_bike\",\"\")), \"\\n(\", round(count_of_rides/sum(count_of_rides)*100,1),\"%)\"), fill = rideable_type), color = \"white\", size = 6, hjust = -0.05) +\n  labs(title = \"Share of Bike Types \\nfor Casual Riders\") +\n  theme(legend.position = \"none\", plot.title = element_text(hjust = 0.5, vjust = -5, size = 35), text = element_text(family = \"Calibri Light\")) +\n  scale_fill_manual(values = c(\"#0C6E7B\",\"#532b39\",\"#7d8513\"))\n\nst5 <- mydf_final_yearly %>% filter(member_casual == \"member\") %>% group_by(rideable_type) %>% summarize(count_of_rides = n())\nst5 <- st5 %>% mutate(proportion = round(count_of_rides/sum(count_of_rides)*100,1))\nst5 <- st5 %>% arrange(desc(rideable_type))\nst5 <- st5 %>% mutate(ypos = cumsum(count_of_rides) - 0.5*count_of_rides)\nst5 <- st5 %>% mutate(ymax = cumsum(count_of_rides), ymin = cumsum(count_of_rides)-count_of_rides)\nggplot(data = st5) + \n  geom_rect(aes(xmin = 1, xmax = 2, ymin = ymin, ymax = ymax, fill = rideable_type)) + xlim(-1,2) +\n  coord_polar(theta = \"y\") +\n  theme_void() +\n  geom_label(aes(x=1.5, y=ypos, label = paste(str_to_title(str_replace(rideable_type,\"_bike\",\"\")), \"\\n(\", round(count_of_rides/sum(count_of_rides)*100,1),\"%)\"), fill = rideable_type), color = \"white\", size = 6, hjust = -0.05) +\n  labs(title = \"Share of Bike Types \\nfor Annual Members\") +\n  theme(legend.position = \"none\", plot.title = element_text(hjust = 0.5, vjust = -5, size = 35), text = element_text(family = \"Calibri Light\")) +\n  scale_fill_manual(values = c(\"#0C6E7B\",\"#7d8513\"))","metadata":{"execution":{"iopub.status.busy":"2023-02-07T11:45:19.451064Z","iopub.execute_input":"2023-02-07T11:45:19.452382Z","iopub.status.idle":"2023-02-07T11:45:21.130146Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"#Top stations for casual riders\nst6 <- mydf_final_yearly_2 %>% group_by(member_casual,start_station_name) %>% summarize(count = n()) %>% arrange(member_casual,desc(count))\nst6 <- st6 %>% mutate(cum_percent = cumsum(count)/sum(count)*100)\n\nggplot(data = st6 %>% filter(member_casual == \"casual\")) + \n  geom_bar(aes(x=reorder(start_station_name,-count), y=count), stat = \"identity\", color = \"#2B3A55\") +\n  scale_y_continuous(limits = c(0,60000), sec.axis = sec_axis(~./600, name = \"Cumulative Percentage of Rides\"), breaks = c(0,12000,24000,36000,48000,60000)) + \n  geom_line(aes(x=reorder(start_station_name, -count), y=cum_percent*600), group = 1, color = \"#C7BCA1\") + \n  theme(axis.text.x = element_blank(), axis.line.y.left = element_line(color = \"black\"), axis.text.y.left = element_text(), axis.title.y.left = element_text(), axis.line.y.right = element_line(color = \"#73777B\"), axis.text.y.right = element_text(color = \"#73777B\"), axis.title.y.right = element_text(color = \"#73777B\"), text = element_text(family = \"Calibri Light\"), plot.title = element_text(hjust = 0.5)) +\n  geom_point(aes(x= \"Western Ave & Leland Ave\", y = 80.13738*600)) +\n  labs(title = \"Station-wise Count of Casual Rides\", x= \"Stations\", y = \"Number of Rides\") +\n  geom_text(x = \"Western Ave & Leland Ave\", y = 80.13738*600, label = \"Point of \\n80% Rides\", size = 5, hjust = -0.2)","metadata":{"execution":{"iopub.status.busy":"2023-02-07T11:45:21.132659Z","iopub.execute_input":"2023-02-07T11:45:21.13407Z","iopub.status.idle":"2023-02-07T11:45:23.233916Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"#Trip Duration based on Rider Type\nst7 <- mydf_final_yearly_2 %>% group_by(member_casual) %>% summarize(avg = mean(ride_duration/60), min = quantile(ride_duration/60)[1], q25 = quantile(ride_duration/60)[2], med = quantile(ride_duration/60)[3], q75 = quantile(ride_duration/60)[4], max = quantile(ride_duration/60)[5])\nggplot(data = mydf_final_yearly_2, aes(x = str_to_title(member_casual), y=ride_duration/60)) + \n  geom_boxplot(aes(fill = member_casual)) + \n  scale_y_continuous(breaks = seq(0,90,by=10)) + \n  geom_point(data = st7, aes(x=str_to_title(member_casual), y=avg), color = \"white\") +\n  coord_cartesian(ylim = c(0,90)) + \n  labs(x=\"Rider Type\", y=\"Ride Duration (in min)\", title = \"Ride Duration Distribution for \\n Casual Riders and Annual Members\") +\n  geom_text(data = st7, aes(x = str_to_title(member_casual), y = med, label = paste(\"median =\",round(med,1))), size = 2.75, hjust = 1.1, vjust = -0.5, color = \"white\") +\n  geom_text(data = st7, aes(x = str_to_title(member_casual), y = avg, label = paste(\"mean =\",round(avg, 1))), hjust = -0.1, size = 3, color = \"white\") +\n  theme(legend.position = \"null\", plot.title = element_text(hjust = 0.5, size = 15, family = \"Calibri Light\"), text = element_text(family = \"Calibri Light\"), panel.background = element_blank(), panel.grid.major.y = element_line(color = \"#DDDEEE\")) +\n  scale_fill_manual(values = c(\"#00337C\",\"#F45D1A\"))","metadata":{"execution":{"iopub.status.busy":"2023-02-07T11:51:33.628278Z","iopub.execute_input":"2023-02-07T11:51:33.629914Z","iopub.status.idle":"2023-02-07T11:52:01.957971Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"#Trip Duration based on Weekdays of Each Month\nst8 <- mydf_final_yearly_2 %>% group_by(member_casual, month(started_at, label = TRUE), weekday) %>% summarize(avg = mean(ride_duration/60), min = quantile(ride_duration/60)[1], q25 = quantile(ride_duration/60)[2], med = quantile(ride_duration/60)[3], q75 = quantile(ride_duration/60)[4], max = quantile(ride_duration/60)[5])\nst8 <- st8 %>% rename(month = `month(started_at, label = TRUE)`)\nggplot(data = mydf_final_yearly_2) +\n  geom_boxplot(aes(x = weekday, y=ride_duration/60, color = member_casual)) +\n  geom_point(data = st8, aes(x=weekday, y=avg, group = member_casual), color = \"black\", position = position_dodge(width = 0.75)) +\n  coord_cartesian(ylim = c(0,75)) +\n  scale_y_continuous(breaks = seq(0,100,by=20)) +\n  scale_x_discrete() +\n  facet_wrap(~month) +\n  labs(title = \"Trends of Ride Duration by Weekday of Each Month\", x = \"Weekday\", y = \"Ride Duration (in min)\") +\n  theme(legend.position = \"top\", legend.background = element_blank(), plot.title = element_text(hjust = 0.5, size = 15, family = \"Calibri Light\"), text = element_text(family = \"Calibri Light\"), panel.background = element_blank(), panel.grid.major.y = element_line(color = \"#DDDEEE\"), axis.text.x = element_text(face = \"bold\"), axis.text.y = element_text(face = \"bold\")) +\n  scale_color_manual(values = c(\"#00337C\",\"#F45D1A\"), name = \"Rider Type\", labels = c(\"Casual\", \"Member\"))","metadata":{"execution":{"iopub.status.busy":"2023-02-07T12:04:14.359177Z","iopub.execute_input":"2023-02-07T12:04:14.361341Z","iopub.status.idle":"2023-02-07T12:04:44.130748Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"#Trip Duration for Bike Type\nst9 <- mydf_final_yearly_2 %>% group_by(member_casual, rideable_type) %>% summarize(avg = mean(ride_duration/60), min = quantile(ride_duration/60)[1], q25 = quantile(ride_duration/60)[2], med = quantile(ride_duration/60)[3], q75 = quantile(ride_duration/60)[4], max = quantile(ride_duration/60)[5])\nggplot(data = mydf_final_yearly_2, aes(x=str_to_title(str_replace(rideable_type,\"_bike\",\"\")), y=ride_duration/60)) + \n  geom_boxplot(aes(fill = member_casual)) + \n  coord_cartesian(ylim = c(0,120)) + \n  scale_y_continuous(breaks = seq(0,120,by=20)) +\n  geom_point(data = st9, aes(x=str_to_title(str_replace(rideable_type,\"_bike\",\"\")), y=avg, group = member_casual), position = position_dodge(width = 0.75), color = \"white\") +\n  geom_text(data = st9, aes(x=str_to_title(str_replace(rideable_type,\"_bike\",\"\")), y=avg, group=member_casual), label = round(st9$avg,1), color = \"white\", size = 2, position = position_dodge(width = 0.75), hjust = -0.4) +\n  labs(title = \"Ride Duration Distribution \\nAmong Different Bike Types\", y=\"Ride Duration (in min)\", x=\"Bike Type\") +\n  theme(plot.title=element_text(hjust = 0.5), text = element_text(family = \"Calibri Light\"), legend.position = \"top\", legend.background = element_blank(), panel.grid.major.y = element_line(color = \"#DDDEEE\"), panel.background = element_blank()) +\n  scale_fill_manual(values = c(\"#00337C\",\"#F45D1A\"), name = \"Rider Type\", labels = c(\"Casual\",\"Member\"))","metadata":{"execution":{"iopub.status.busy":"2023-02-07T12:08:43.454845Z","iopub.execute_input":"2023-02-07T12:08:43.457405Z","iopub.status.idle":"2023-02-07T12:09:16.022576Z"},"trusted":true},"execution_count":null,"outputs":[]},{"cell_type":"code","source":"#Trips based on Hour of Each Weekday\nst10 <- mydf_final_yearly_2 %>% group_by(member_casual,weekday,hour(started_at)) %>% summarize(count = n())\nst10 <- st10 %>% rename(hour = `hour(started_at)`)\nst10 <- st10 %>% arrange(member_casual, weekday, desc(count))\nst10 <- st10 %>% mutate(percent = count*100/sum(count))\nst10 <- st10 %>% mutate(cum_percent = cumsum(percent))\nggplot(data = st10) +\n  geom_histogram(aes(x=hour, y=count, group = member_casual, fill = member_casual), stat = \"identity\", position = position_dodge(preserve = \"total\")) +\n  scale_x_continuous(breaks = seq(0,23,by=1)) +\n  scale_y_continuous(labels = label_comma()) + \n  facet_wrap(~weekday) +\n  labs(y=\"Number of Rides\", x=\"Hours of the Day\") +\n  theme(plot.title=element_text(hjust = 0.5), text = element_text(family = \"Calibri Light\"), legend.position = c(0.9,0.1), legend.background = element_blank(), panel.grid.major.y = element_line(color = \"#DDDEEE\"), panel.background = element_blank()) +\n  scale_fill_manual(values = c(\"#00337C\",\"#F45D1A\"), name = \"Rider Type\", labels = c(\"Casual\",\"Member\"))","metadata":{"execution":{"iopub.status.busy":"2023-02-07T12:16:39.184471Z","iopub.execute_input":"2023-02-07T12:16:39.186666Z","iopub.status.idle":"2023-02-07T12:16:40.810465Z"},"trusted":true},"execution_count":null,"outputs":[]}]}
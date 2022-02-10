library(mosaic)
library(tidyverse)
library(here)
library(ggthemes)
#Number 2
billboard = read.csv('../data/billboard.csv')

top10 <- billboard %>% 
  group_by(performer, song) %>% 
  summarise(
    count = n()
  ) %>% 
  arrange(desc(count)) %>% 
  head(10)
top10


unique_songs <- billboard %>% 
  filter(year != 1958) %>% 
  filter(year != 2021) %>% 
  group_by(year) %>% 
  distinct(song_id) %>% 
  summarise(
    count = n()
  )
ggplot(unique_songs)+
  geom_line(aes(x = year, y = count),color = "blue")+
  theme_classic()+
  labs(title = "Unique Songs by Year")+
  xlab("Year")+
  ylab("Cound of Unique Songs")+
  theme(plot.title.position = 'plot')

ten_week_hit <- billboard %>% 
  group_by(performer, song) %>% 
  summarise(
    count = n()
  ) %>% 
  arrange(desc(count)) %>% 
  filter(count >= 10) %>% 
  group_by(performer) %>% 
  summarise(count= n()) %>% 
  filter(count >=30)

ggplot(ten_week_hit, aes(fct_rev(fct_reorder(performer,count)),count))+
  geom_bar(stat = "identity")+
  coord_flip()+
  theme_classic()+
  labs(title = "Billboard Top Performers", subtitle = "Number of songs on billboard for at least 10 weeks")+
  ylab("Count of Songs")+
  xlab("Artist")+
  theme(plot.title.position = 'plot')


#Number 3
olympics_top20 = read.csv('../data/olympics_top20.csv')

top_height <-olympics_top20 %>% 
  group_by(sport) %>% 
  summarise(
    '95th_height' = quantile(height,probs = .95)  
  )

height_variation <- olympics_top20 %>% 
  group_by(event) %>% 
  summarise(
    sd = sd(height)
  ) %>% 
  arrange(desc(sd))

swimmers <- olympics_top20 %>% 
  filter(sport == 'Swimming') %>% 
  group_by(year, sex) %>% 
  summarise(
    avg_age = mean(age)
  )
ggplot(data = swimmers, aes(x = year, y = avg_age,color = sex))+
  geom_point()+
  geom_line()+
  theme_classic()+
  xlab("Year")+
  ylab("Average Age")+
  labs(title = "Average Age of Olympic Swimmers")+
  theme(plot.title.position = 'plot')
#Number 4

sclass = read.csv('../data/sclass.csv')

trim1 <- sclass %>% 
  filter(trim == '350')

trim2 <- sclass %>% 
  filter(trim == '65 AMG')

trim1_split = initial_split(trim1, prop=0.8) 
trim1_train = training(trim1_split)
trim1_test = testing(trim1_split)

k_grid = seq(2,100,by = 2)

trim1_knn = foreach(k = k_grid, .combine='rbind') %do% { 
  rmse(knnreg(price ~ mileage, data=trim1_train, k=k), trim1_test)
}
trim1_rmse = data.frame(trim1_knn,k_grid)


ggplot(data = trim1_rmse, aes(x = k_grid, y = trim1_knn))+
  geom_point()+
  geom_line()


trim2_split = initial_split(trim2, prop=0.8) 
trim2_train = training(trim2_split)
trim2_test = testing(trim2_split)

trim2_rmse = foreach(k = k_grid, .combine='rbind') %do% {
  model = knnreg(price ~ mileage, k=k, data = trim2_train, use.all=FALSE)
  errs = rmse(model,trim2_test)
  c(k=k, err = mean(errs))
} %>% as.data.frame

min(trim1_rmse$errs)






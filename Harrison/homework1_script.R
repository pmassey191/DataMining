library(tidyverse)
library(mosaic)
library(ggplot2)
library(rsample)
library(caret)
library(modelr)
library(parallel)
library(foreach)

# Problem 1
ABIA <- read.csv("~/School/University of Texas-Austin/Classes/Data Mining/Data/ABIA.csv")
View(ABIA)

# What is the best day of the week to fly to minimize delays
# Does this depend on airline/destination/into or out of AUS


ABIA_In = ABIA %>%
  filter(Dest == 'AUS')%>%
  group_by(DayOfWeek)%>%
  summarize(mdelay = mean(ArrDelay, na.rm=TRUE))

ggplot(ABIA_In)+
  geom_col(aes(x=DayOfWeek, y=mdelay))


ABIA_Out = ABIA %>%
  filter(Origin == 'AUS')%>%
  group_by(DayOfWeek)%>%
  summarize(mddelay = mean(DepDelay, na.rm=TRUE))

ggplot(ABIA_Out)+
  geom_col(aes(x=DayOfWeek, y=mddelay))


# Problem 2
billboard <- read.csv("~/School/University of Texas-Austin/Classes/Data Mining/Data/billboard.csv")
View(billboard)

# Part A
# Table of top 10 most popular songs since 1958, 
# measured by total number of weeks that a song
# has spent on th charts
# Table should be 10x3 with performer, song, and count


top10 = billboard %>%
  group_by(performer,song)%>%
  summarize(count = n())%>%
  arrange(desc(count))%>%
  head(10)


# Part B
# run foreach to cycle through years, each year use distinct(song_id)
# to return number of unique songs, store and plot values

unique = billboard %>%
  group_by(year)%>%
  distinct(song_id)%>%
  summarize(count = n())%>%
  filter(year != 1958, year != 2021)

ggplot(unique)+
  geom_line(aes(x=year,y=count))

# Part C
plus10 = billboard %>%
  filter(weeks_on_chart >= 10)%>%
  distinct(performer,song)%>%
  group_by(performer)%>%
  summarize(count = n())%>%
  filter(count >= 30)

ggplot(plus10, aes(count,fct_reorder(performer,count)))+
  geom_col()


# Problem 3
olympics <- read.csv("~/School/University of Texas-Austin/Classes/Data Mining/Data/olympics_top20.csv")
View(olympics)


# A) What is the 95th percentile of heights for female
# competitors across all sports?
# 187

olympics_A = olympics %>%
  filter(sex=='F',sport == 'Athletics') %>%
  select(id,sex,height)%>%
  distinct()
  
height95 = quantile(olympics_A$height,probs=.95)

# B) Which single women's event had the greatest variability of 
# height, measured by standard deviation?
# Answer: Women's Rowing Coxed Fours

# group by event, calculate standard deviations of height, max value

olympics_B = olympics %>%
  filter(sex=='F')%>%
  group_by(event)%>%
  summarize(var = sd(height))%>%
  arrange(desc(var))%>%
  head(1)

# Part C
# How has the average age of Olympic swimmers changed over
# time? Is the trend different for male and female?

olympics_C = olympics %>%
  filter(sport == 'Swimming')%>%
  group_by(year,sex)%>%
  summarize(avgage = mean(age))

ggplot(olympics_C)+
  geom_line(aes(x=year,y=avgage,color=sex))


# Problem 4
sclass <- read.csv("~/School/University of Texas-Austin/Classes/Data Mining/Data/sclass.csv")
View(sclass)

sclass_clean = sclass %>%
  select(trim, mileage, price)%>%
  filter(trim=='65 AMG' | trim=='350')

sclass_350 = sclass_clean%>%
  filter(trim=='350')

sclass350_split = initial_split(sclass_350, prop = 0.8)
sclass350_train = training(sclass350_split)
sclass350_test = testing(sclass350_split)

lm1 = lm(price ~ mileage, data=sclass350_train)
lm2 = lm(price ~ poly(mileage, 2), data=sclass350_train)

linear_bench = rmse(lm1, sclass350_test)
quad_bench = rmse(lm2, sclass350_test)

knn_opts = foreach(i = 2:100, .combine='rbind') %do% {
  err = rmse(knnreg(price ~ mileage, data=sclass350_train, k=i),sclass350_test)
  }%>% as.data.frame()

knn_opts = data.frame(knn_opts,2:100)

knn_opts = knn_opts%>%
  mutate(RMSE = V1, k = X2.100)%>%
  select(RMSE,k)

ggplot(knn_opts)+
  geom_line(aes(y=RMSE,x=k))+
  geom_hline(aes(yintercept=quad_bench))+
  geom_hline(aes(yintercept=linear_bench))



knn350_20 <- knnreg(price ~ mileage, data=sclass350_train, k=50)

sclass_350_test = sclass350_test %>%
  mutate(price_pred = predict(knn350_20, sclass350_test))

ggplot(data = sclass_350_test) + 
  geom_point(mapping = aes(x = mileage, y = price), alpha=0.2) + 
  geom_line(aes(x = mileage, y = price_pred), color='red', size=1.5)



sclass_AMG = sclass_clean%>%
  filter(trim=='65 AMG')

sclassAMG_split = initial_split(sclass_AMG, prop = 0.8)
sclassAMG_train = training(sclassAMG_split)
sclassAMG_test = testing(sclassAMG_split)

lm1 = lm(price ~ mileage, data=sclassAMG_train)
lm2 = lm(price ~ poly(mileage, 2), data=sclassAMG_train)

linear_benchAMG = rmse(lm1, sclassAMG_test)
quad_benchAMG = rmse(lm2, sclassAMG_test)


knn_AMG = foreach(i = 2:100, .combine='rbind') %do% {
  err = rmse(knnreg(price ~ mileage, data=sclassAMG_train, k=i),sclassAMG_test)
}%>% as.data.frame()

knn_AMG = data.frame(knn_AMG,2:100)

knn_AMG = knn_AMG%>%
  mutate(RMSE = V1, k = X2.100)%>%
  select(RMSE,k)

ggplot(knn_AMG)+
  geom_line(aes(y=RMSE,x=k))+
  geom_hline(aes(yintercept=quad_benchAMG))+
  geom_hline(aes(yintercept=linear_benchAMG))


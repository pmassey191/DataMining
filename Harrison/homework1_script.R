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

################################################
################## Problem 4 ###################
################################################

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

lm1_350 = lm(price ~ mileage, data=sclass350_train)
lm2_350 = lm(price ~ poly(mileage, 2), data=sclass350_train)

linear_bench_350 = rmse(lm1_350, sclass350_test)
quad_bench_350 = rmse(lm2_350, sclass350_test)

knn_350 = foreach(i = 2:100, .combine='rbind') %do% {
  err = rmse(knnreg(price ~ mileage, data=sclass350_train, k=i),sclass350_test)
  }%>% as.data.frame()

knn_350 = data.frame(knn_350,2:100)

knn_350 = knn_350%>%
  mutate(RMSE = V1, k = X2.100)%>%
  select(RMSE,k)

ggplot(knn_350)+
  theme_classic()+
  geom_line(aes(y=RMSE,x=k,color='dark green'))+
  geom_hline(aes(yintercept=quad_bench_350,color='blue'))+
  geom_hline(aes(yintercept=linear_bench_350,color='red'))+
  labs(title = "350 Trim: RMSE for Different K Values\n", x = "K", y = "RMSE") +
  scale_color_manual(labels = c("Quadratic RMSE","KNN RMSE","Linear RMSE"),
                     values = c('blue', 'dark green','red'))+
  theme(legend.title = element_blank())

optimal_350 = knn_350 %>%
  arrange(RMSE)

optk_350 = as.numeric(optimal_350[1,2])

knn350_optk <- knnreg(price ~ mileage, data=sclass350_train, k=optk_350)

sclass_350_test = sclass350_test %>%
  mutate(price_pred = predict(knn350_optk, sclass350_test))

ggplot(data = sclass_350_test) +
  theme_classic()+
  ggtitle(paste("350 Trim: Line of Fit for K=",optk_350, sep = ""))+
  geom_point(mapping = aes(x = mileage, y = price), alpha=0.2) + 
  geom_line(aes(x = mileage, y = price_pred), color='red', size=1.5)



sclass_AMG = sclass_clean%>%
  filter(trim=='65 AMG')

sclassAMG_split = initial_split(sclass_AMG, prop = 0.8)
sclassAMG_train = training(sclassAMG_split)
sclassAMG_test = testing(sclassAMG_split)

lm1_AMG = lm(price ~ mileage, data=sclassAMG_train)
lm2_AMG = lm(price ~ poly(mileage, 2), data=sclassAMG_train)

linear_bench_AMG = rmse(lm1_AMG, sclassAMG_test)
quad_bench_AMG = rmse(lm2_AMG, sclassAMG_test)

knn_AMG = foreach(i = 2:100, .combine='rbind') %do% {
  err = rmse(knnreg(price ~ mileage, data=sclassAMG_train, k=i),sclassAMG_test)
}%>% as.data.frame()

knn_AMG = data.frame(knn_AMG,2:100)

knn_AMG = knn_AMG%>%
  mutate(RMSE = V1, k = X2.100)%>%
  select(RMSE,k)

ggplot(knn_AMG)+
  theme_classic()+
  geom_line(aes(y=RMSE,x=k,color='dark green'))+
  geom_hline(aes(yintercept=quad_bench_AMG,color='blue'))+
  geom_hline(aes(yintercept=linear_bench_AMG,color='red'))+
  labs(title = "AMG Trim: RMSE for Different K Values\n", x = "K", y = "RMSE") +
  scale_color_manual(labels = c("Quadratic RMSE","KNN RMSE","Linear RMSE"),
                     values = c('blue', 'dark green','red'))+
  theme(legend.title = element_blank())

optimal_AMG = knn_AMG %>%
  arrange(RMSE)

optk_AMG = as.numeric(optimal_AMG[1,2])

knnAMG_optk <- knnreg(price ~ mileage, data=sclassAMG_train, k=optk_AMG)

sclass_AMG_test = sclassAMG_test %>%
  mutate(price_pred = predict(knnAMG_optk, sclassAMG_test))

ggplot(data = sclass_AMG_test) +
  theme_classic()+
  ggtitle(paste("AMG Trim: Line of Fit for K=",optk_AMG, sep = ""))+
  geom_point(mapping = aes(x = mileage, y = price), alpha=0.2) + 
  geom_line(aes(x = mileage, y = price_pred), color='red', size=1.5)

######################################################

sclass_350 = sclass_clean%>%
  filter(trim=='350')

K_folds = 5
k_grid = c(2:30,35,40,45,50,55,60,65,70,80, 90,100)

sclass350_folds = crossv_kfold(sclass_350, k=K_folds)



cv_grid_350 = foreach(k = k_grid, .combine='rbind') %dopar% {
  models = map(sclass350_folds$train, ~ knnreg(price ~ mileage, k=k, data = ., use.all=FALSE))
  errs = map2_dbl(models, sclass350_folds$test, modelr::rmse)
  c(k=k, err = mean(errs), std_err = sd(errs)/sqrt(K_folds))
} %>% as.data.frame

ggplot(cv_grid_350) + 
  geom_point(aes(x=k, y=err))+
  scale_x_log10()+
  geom_errorbar(aes(x=k, ymin = err-std_err, ymax = err+std_err)) +
  labs(title = "350 Trim: RMSE for Different K Values\n", x = "K", y = "RMSE") +
  theme_classic()

opt_350 = cv_grid_350%>%
  arrange(err)

max_err_350 = opt_350[1,2] + opt_350[1,3]
min_k_350 = opt_350[1,1]

opt_350 = opt_350%>%
  filter(k >= min_k_350)%>%
  mutate(diff = max_err_350 - err)%>%
  filter(diff > 0)%>%
  arrange(diff)

optk_350 = opt_350[1,1]

sclass350_split = initial_split(sclass_350, prop = 0.8)
sclass350_train = training(sclass350_split)
sclass350_test = testing(sclass350_split)

knn350_optk <- knnreg(price ~ mileage, data=sclass350_train, k=optk_350)

sclass_350_test = sclass350_test %>%
  mutate(price_pred = predict(knn350_optk, sclass350_test))

ggplot(data = sclass_350_test) +
  theme_classic()+
  ggtitle(paste("350 Trim: Line of Fit for K=",optk_350, sep = ""))+
  geom_point(mapping = aes(x = mileage, y = price), alpha=0.2) + 
  geom_line(aes(x = mileage, y = price_pred), color='red', size=1.5)












sclass_AMG = sclass_clean%>%
  filter(trim=='65 AMG')

sclassAMG_folds = crossv_kfold(sclass_AMG, k=K_folds)

cv_grid_AMG = foreach(k = k_grid, .combine='rbind') %dopar% {
  models = map(sclassAMG_folds$train, ~ knnreg(price ~ mileage, k=k, data = ., use.all=FALSE))
  errs = map2_dbl(models, sclassAMG_folds$test, modelr::rmse)
  c(k=k, err = mean(errs), std_err = sd(errs)/sqrt(K_folds))
} %>% as.data.frame

ggplot(cv_grid_AMG) + 
  geom_point(aes(x=k, y=err))+
  scale_x_log10()+
  geom_errorbar(aes(x=k, ymin = err-std_err, ymax = err+std_err)) +
  labs(title = "AMG Trim: RMSE for Different K Values\n", x = "K", y = "RMSE") +
  theme_classic()

opt_AMG = cv_grid_AMG%>%
  arrange(err)

max_err_AMG = opt_AMG[1,2] + opt_AMG[1,3]
min_k_AMG = opt_AMG[1,1]

opt_AMG = opt_AMG%>%
  filter(k >= min_k_AMG)%>%
  mutate(diff = max_err_AMG - err)%>%
  filter(diff > 0)%>%
  arrange(diff)

optk_AMG = opt_AMG[1,1]

sclassAMG_split = initial_split(sclass_AMG, prop = 0.8)
sclassAMG_train = training(sclassAMG_split)
sclassAMG_test = testing(sclassAMG_split)

knnAMG_optk <- knnreg(price ~ mileage, data=sclassAMG_train, k=optk_AMG)

sclass_AMG_test = sclassAMG_test %>%
  mutate(price_pred = predict(knnAMG_optk, sclassAMG_test))

ggplot(data = sclass_AMG_test) +
  theme_classic()+
  ggtitle(paste("AMG Trim: Line of Fit for K=",optk_AMG, sep = ""))+
  geom_point(mapping = aes(x = mileage, y = price), alpha=0.2) + 
  geom_line(aes(x = mileage, y = price_pred), color='red', size=1.5)


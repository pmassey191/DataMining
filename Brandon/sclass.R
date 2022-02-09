library(tidyverse)
library(ggplot2)
library(rsample)  # for creating train/test splits
library(caret)
library(modelr)
library(parallel)
library(foreach)
library(here)

sclass <- read_csv(here("Data/sclass.csv"))


## Let's take a look at the data

sclass_clean <- sclass %>% 
  select(trim, mileage, price) %>% 
  filter(trim == "350" | trim == "65 AMG")

ggplot(data = sclass_clean) + 
  geom_point(mapping = aes(x = mileage, y = price)) +
  facet_wrap(~ trim)

## Create our datasets and compare to benchmarks

sclass_350<- sclass %>% 
  select(trim, mileage, price) %>% 
  filter(trim == "350")

lm350_1 = lm(price ~ mileage, data=sclass_350)
lm350_2 = lm(price ~ poly(mileage, 2), data=sclass_350)
rmse(lm350_1, sclass_350)
rmse(lm350_2, sclass_350)


sclass_65 <- sclass %>% 
  select(trim, mileage, price) %>% 
  filter(trim == "65 AMG") 

lm65_1 = lm(price ~ mileage, data=sclass_65)
lm65_2 = lm(price ~ poly(mileage, 2), data=sclass_65)
rmse(lm65_1, sclass_65)
rmse(lm65_2, sclass_65)

## Create train / test splits

sclass_350_split =  initial_split(sclass_350, prop=0.8)
sclass_350_train = training(sclass_350_split)
sclass_350_test  = testing(sclass_350_split)

sclass_65_split =  initial_split(sclass_65, prop=0.8)
sclass_65_train = training(sclass_65_split)
sclass_65_test  = testing(sclass_65_split)

## Take a look at K = 20


knn350_20 <- 
  knnreg(price ~ mileage, data=sclass_350_train, k=20)

sclass_350_test = sclass_350_test %>%
  mutate(price_pred = predict(knn350_20, sclass_350_test))

ggplot(data = sclass_350_test) + 
  geom_point(mapping = aes(x = mileage, y = price), alpha=0.2) + 
  geom_line(aes(x = mileage, y = price_pred), color='red', size=1.5)

## Define a series of k values

k_grid = c(1:100)

## Run a loop to determine the RMSE for each value of k.

## For 350 Trim

knn_350 <- foreach(k = k_grid, .combine='rbind') %do% { 
  rmse(knnreg(price ~ mileage, data=sclass_350_train, k=k), sclass_350_test)
  
}


knn350_rmse <- data.frame(knn_350, k_grid)

ggplot(knn350_rmse) +
  geom_line(aes(x = k_grid, y = knn_350)) +
  geom_hline(yintercept = 11526, color = 'red') +
  geom_hline(yintercept = 10176, color = 'blue')


## For 350 Trim

knn_65 <- foreach(k = k_grid, .combine='rbind') %do% { 
  rmse(knnreg(price ~ mileage, data=sclass_65_train, k=k), sclass_65_test)
  
}

knn65_rmse <- data.frame(knn_65, k_grid)

ggplot(knn65_rmse) +
  geom_line(aes(x = k_grid, y = knn_65)) +
  geom_hline(yintercept = 44953, color = 'red') +
  geom_hline(yintercept = 30722, color = 'blue')

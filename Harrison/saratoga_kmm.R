library(tidyverse)
library(ggplot2)
library(modelr)
library(rsample)
library(mosaic)
library(foreach)
library(caret)

data(SaratogaHouses)

glimpse(SaratogaHouses)

####
# Compare out-of-sample predictive performance
####

# Split into training and testing sets
saratoga_split = initial_split(SaratogaHouses, prop = 0.8)
saratoga_train = training(saratoga_split)
saratoga_test = testing(saratoga_split)

# baseline medium model with 11 main effects
lm_medium = lm(price ~ lotSize + age + livingArea + pctCollege + bedrooms + 
                 fireplaces + bathrooms + rooms + heating + fuel + centralAir, data=saratoga_train)
rmse(lm_medium, saratoga_test)

lm_better = lm(price ~ . - pctCollege - sewer - newConstruction, data=saratoga_train)
rmse(lm_better, saratoga_test)

##### 
# Attempting to replicate JS version feature matrices
#####

xtrain = model.matrix(~ . - 1, data=saratoga_train)
xtest = model.matrix(~ . - 1, data=saratoga_test)
ytrain = saratoga_train$price
ytrain = saratoga_test$price

# rescale
scale_train = apply(xtrain, 2, sd)
xtilde_train = scale(xtrain, scale = scale_train) %>% 
  as.data.frame() %>% 
  rename(heatinghot_air = "heatinghot air") %>% 
  rename(heatinghot_water_steam = "heatinghot water/steam")
xtilde_test = scale(xtest, scale = scale_train) %>% 
  as.data.frame() %>% 
  rename(heatinghot_air = "heatinghot air") %>% 
  rename(heatinghot_water_steam = "heatinghot water/steam")

head(xtrain, 2)
head(xtilde_train)

K_folds = 5
k_grid = c(2:30,35,40,45,50,55,60,65,70,80, 90,100)

#####
## Testing without scaling
#####


saratoga_folds = crossv_kfold(SaratogaHouses, k=K_folds)

cv_grid = foreach(k = k_grid, .combine='rbind') %dopar% {
  models = map(saratoga_folds$train, ~ knnreg(price ~ lotSize + age + livingArea + pctCollege + bedrooms + 
                                                fireplaces + bathrooms + rooms + heating + fuel + centralAir, k=k, data = ., use.all=FALSE))
  errs = map2_dbl(models, saratoga_folds$test, modelr::rmse)
  c(k=k, err = mean(errs), std_err = sd(errs)/sqrt(K_folds))
} %>% as.data.frame

# Plotting our RMSE averages versus K
ggplot(cv_grid) + 
  geom_point(aes(x=k, y=err))+
  scale_x_log10()+
  geom_errorbar(aes(x=k, ymin = err-std_err, ymax = err+std_err)) +
  labs(title = "350 Trim: RMSE for Different K Values\n", x = "K", y = "RMSE") +
  theme_classic()

#####
# Scaling based on all data
#####

saratoga_matrix = model.matrix(~ . - 1, data=SaratogaHouses)
saratoga_scaled <- scale(saratoga_matrix, center = FALSE, scale = apply(saratoga_matrix, 2, sd)) %>% 
  as.data.frame() %>%
  mutate(price = price*sd(saratoga_matrix[,1]))%>%
  rename(heatinghot_air = "heatinghot air") %>% 
  rename(heatinghot_water_steam = "heatinghot water/steam")

saratoga_folds2 = crossv_kfold(saratoga_scaled, k=K_folds)

for (i in K_folds) {
  train[1,i] = saratoga_folds2$train$'[1,i]' %>%  
    as.data.frame() 
}

i = 1
train = saratoga_folds2[1,i] %>%  
  as.data.frame() 

train = saratoga_folds2$train$'1' %>%  
  as.data.frame() 

cv_grid2 = foreach(k = k_grid, .combine='rbind') %dopar% {
  models = map(saratoga_folds2$train, ~ knnreg(price ~ lotSize + age + livingArea + pctCollege + bedrooms + 
                                                fireplaces + bathrooms + rooms + heatinghot_air + heatinghot_water_steam, k=k, data = ., use.all=FALSE))
  errs = map2_dbl(models, saratoga_folds2$test, modelr::rmse)
  c(k=k, err = mean(errs), std_err = sd(errs)/sqrt(K_folds))
} %>% as.data.frame

ggplot(cv_grid2) + 
  geom_point(aes(x=k, y=err))+
  scale_x_log10()+
  geom_errorbar(aes(x=k, ymin = err-std_err, ymax = err+std_err)) +
  labs(title = "350 Trim: RMSE for Different K Values\n", x = "K", y = "RMSE") +
  theme_classic()

# Plotting our RMSE averages versus K
ggplot(cv_grid) + 
  geom_point(aes(x=k, y=err))+
  scale_x_log10()+
  geom_errorbar(aes(x=k, ymin = err-std_err, ymax = err+std_err)) +
  labs(title = "350 Trim: RMSE for Different K Values\n", x = "K", y = "RMSE") +
  theme_classic()


####
# Attempts to divide by train/test split over k-fold follows
####

saratoga_folds = crossv_kfold(SaratogaHouses, k=K_folds)

train1 = saratoga_folds$train$'1' %>%  
  as.data.frame() 

xtrain1 = model.matrix(~ . - 1, data=train1)  

scale_train1 = apply(xtrain1, 2, sd)

xtilde_train1 = scale(xtrain1, scale = scale_train1) %>% 
  as.data.frame() %>% 
  rename(heatinghot_air = "heatinghot air") %>% 
  rename(heatinghot_water_steam = "heatinghot water/steam")



# feature matrices
xtrain = model.matrix(~ . - 1, data=saratoga_train)
xtest = model.matrix(~ . - 1, data=saratoga_test)
ytrain = saratoga_train$price
ytrain = saratoga_test$price

# rescale
scale_train = apply(xtrain, 2, sd)
xtilde_train = scale(xtrain, scale = scale_train) %>% 
  as.data.frame() %>% 
  rename(heatinghot_air = "heatinghot air") %>% 
  rename(heatinghot_water_steam = "heatinghot water/steam")
xtilde_test = scale(xtest, scale = scale_train) %>% 
  as.data.frame() %>% 
  rename(heatinghot_air = "heatinghot air") %>% 
  rename(heatinghot_water_steam = "heatinghot water/steam")

cv_grid = foreach(k = k_grid, .combine='rbind') %dopar% {
  models = map(sclass350_folds$train, ~ knnreg(price ~ mileage, k=k, data = ., use.all=FALSE))
  errs = map2_dbl(models, sclass350_folds$test, modelr::rmse)
  c(k=k, err = mean(errs), std_err = sd(errs)/sqrt(K_folds))
} %>% as.data.frame

# Plotting our RMSE averages versus K
ggplot(cv_grid_350) + 
  geom_point(aes(x=k, y=err))+
  scale_x_log10()+
  geom_errorbar(aes(x=k, ymin = err-std_err, ymax = err+std_err)) +
  labs(title = "350 Trim: RMSE for Different K Values\n", x = "K", y = "RMSE") +
  theme_classic()




# Scaling train data
K_folds = 5

foreach (i = 1:K_folds) %do% {
  nam <- paste("train_", i, sep = "")
  dat = as.data.frame(saratoga_folds$train[i])
  clean_matrix = model.matrix(~ . - 1, data=dat)
  thing <- scale(clean_matrix, center = FALSE, scale = apply(clean_matrix, 2, sd)) %>% 
    as.data.frame()
  thing = thing %>%
    mutate(price = clean_matrix[,1])
  assign(nam, thing)
}


# Scaling Test data
foreach (i = 1:K_folds) %do% {
  nam <- paste("test_", i, sep = "")
  dat = as.data.frame(saratoga_folds$test[i])
  clean_matrix = model.matrix(~ . - 1, data=dat)
  thing <- scale(clean_matrix, center = FALSE, scale = apply(clean_matrix, 2, sd)) %>% 
    as.data.frame()
  thing = thing %>%
    rename_with(~gsub('X'[i],'',.x))%>%
    mutate(price = clean_matrix[,1])
  assign(nam, thing)
}


testing1 = saratoga_folds$train$'1' %>%  
  as.data.frame() 

testing1_matrix = model.matrix(~ . - 1, data=testing1)
testing1_scaled <- scale(testing1_matrix, center = FALSE, scale = apply(testing1_matrix, 2, sd)) %>% 
  as.data.frame() %>%
  mutate(price = price*sd(testing1_matrix[,1]))

fuck_this = train_1 %>%
  select(!X1.price)%>%
  rename_with(~gsub('X1.','', .x))%>%
  relocate(price)


knn(price ~ X[i].lotSize)


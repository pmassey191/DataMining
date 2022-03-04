library(tidyverse)
library(ggplot2)
library(modelr)
library(rsample)
library(mosaic)
library(foreach)
library(caret)
library(assert)

## Define our K values and scale the data in each train/test split based only on the data in each corresponding split.

data(SaratogaHouses)

K_folds = 5
k_grid = c(2:100)
saratoga_folds = crossv_kfold(SaratogaHouses, k=K_folds)

## need to calculate scale by sd of training set and apply to both

# now rescale:
# scale_train = apply(Xtrain, 2, sd)  # calculate std dev for each column
# Xtilde_train = scale(Xtrain, scale = scale_train)
# Xtilde_test = scale(Xtest, scale = scale_train)  # use the training set scales!

training <- foreach (i = 1:K_folds) %do% {
  nam <- paste("train_", i, sep = "")
  dat = as.data.frame(saratoga_folds$train[i])
  clean_matrix = model.matrix(~ . - 1, data=dat)
  thing <- scale(clean_matrix, center = FALSE, scale = apply(clean_matrix, 2, sd)) %>% 
    as.data.frame()
  thing = thing %>%
    mutate(house_price = clean_matrix[,1])
  names(thing)[1:20] <- substring(names(thing)[1:20],4)
  names(thing)<-str_replace_all(names(thing), c(" " = "." , "/" = "." ))
  assign(nam, thing)
}

testing <- foreach (i = 1:K_folds) %do% {
  nam <- paste("test_", i, sep = "")
  dat = as.data.frame(saratoga_folds$test[i])
  clean_matrix = model.matrix(~ . - 1, data=dat)
  if (sd(clean_matrix[,18]) == 0) {
    clean_matrix[,-18] = scale(clean_matrix[,-18], center = FALSE, scale = TRUE)
    clean_matrix[,18] = 0
  } 
  else { 
    clean_matrix = scale(clean_matrix, center = FALSE, scale = TRUE)
  }
  thing = as.data.frame(clean_matrix)
  thing = thing %>%
    mutate(house_price = clean_matrix[,1])
  names(thing)[1:20] <- substring(names(thing)[1:20],4)
  names(thing)<-str_replace_all(names(thing), c(" " = "." , "/" = "." ))
  assign(nam, thing)
}


#apply(clean_matrix, 2, sd)

assert(sd(test_1$waterfrontNo) != 0)
assert(sd(test_2$waterfrontNo) != 0)
assert(sd(test_3$waterfrontNo) != 0)
assert(sd(test_4$waterfrontNo) != 0)
assert(sd(test_5$waterfrontNo) != 0)
assert(sd(test_6$waterfrontNo) != 0)
assert(sd(test_7$waterfrontNo) != 0)
assert(sd(test_8$waterfrontNo) != 0)
assert(sd(test_9$waterfrontNo) != 0)


## Get our cross-validation grid and plot of K values to find optimal K.  

cv_grid = foreach(k = k_grid, .combine='rbind') %dopar% {
  models = map(training, ~ knnreg(house_price ~ lotSize + age +landValue + livingArea + bedrooms + 
                                    fireplaces + bathrooms + rooms+ heatinghot.water.steam
                                  + heatingelectric + fuelelectric + centralAirNo + fueloil, k=k, data = ., use.all=FALSE))
  errs = map2_dbl(models, testing, modelr::rmse)
  c(k=k, err = mean(errs), std_err = sd(errs)/sqrt(K_folds))
} %>% as.data.frame

ggplot(cv_grid) + 
  geom_point(aes(x=k, y=err))+
#  scale_x_log10()+
  geom_errorbar(aes(x=k, ymin = err-std_err, ymax = err+std_err)) +
  labs(title = "RMSE for Different K Values\n", x = "K", y = "RMSE") +
  theme_minimal()

# This provides us with the 1 standard error allowance and isolates the associated K value


opt_k = cv_grid%>%
  arrange(err)

max_err = opt_k[1,2] + opt_k[1,3]
min_k = opt_k[1,1]
opt_k = opt_k%>%
  filter(k >= min_k)%>%
  mutate(diff = max_err - err)%>%
  filter(diff > 0)%>%
  arrange(diff)

optk_final = opt_k[1,1]

optk_final

## Take a look at an example of RSME values

lm_better = lm(house_price ~  lotSize + age +landValue + livingArea + bedrooms + 
                     fireplaces + bathrooms + rooms + heatinghot.water.steam
                     + heatingelectric + fuelelectric + waterfrontNo + centralAirNo + fueloil +
                 waterfrontNo * landValue, data=train_1)
rmse(lm_better, test_1)

knn_optk <- knnreg(house_price ~ lotSize + age +landValue + livingArea + bedrooms + 
                     fireplaces + bathrooms + rooms + heatinghot.water.steam
                   + heatingelectric + fuelelectric + centralAirNo + fueloil, data=train_1, k=optk_final)
rmse(knn_optk, test_1)

knn_optk <- knnreg(house_price ~ lotSize + age +landValue + livingArea + bedrooms + 
                     fireplaces + bathrooms + rooms + heatinghot.water.steam
                   + heatingelectric + fuelelectric + centralAirNo + fueloil, data=train_1, k=avg_k)
rmse(knn_optk, test_1)


### medium RMSEs on average

lm_medium = lm(house_price ~ lotSize + age + livingArea + pctCollege + bedrooms + 
                 fireplaces + bathrooms + rooms + heatinghot.air + heatinghot.water.steam + fueloil + 
                 fuelelectric + centralAirNo, data=train_1)
rmse_med_1 <- rmse(lm_medium, test_1)

lm_medium = lm(house_price ~ lotSize + age + livingArea + pctCollege + bedrooms + 
                 fireplaces + bathrooms + rooms + heatinghot.air + heatinghot.water.steam + fueloil + 
                 fuelelectric + centralAirNo, data=train_2)
rmse_med_2 <- rmse(lm_medium, test_2)

lm_medium = lm(house_price ~ lotSize + age + livingArea + pctCollege + bedrooms + 
                 fireplaces + bathrooms + rooms + heatinghot.air + heatinghot.water.steam + fueloil + 
                 fuelelectric + centralAirNo, data=train_3)
rmse_med_3 <- rmse(lm_medium, test_3)

lm_medium = lm(house_price ~ lotSize + age + livingArea + pctCollege + bedrooms + 
                 fireplaces + bathrooms + rooms + heatinghot.air + heatinghot.water.steam + fueloil + 
                 fuelelectric + centralAirNo, data=train_4)
rmse_med_4 <- rmse(lm_medium, test_4)

lm_medium = lm(house_price ~ lotSize + age + livingArea + pctCollege + bedrooms + 
                 fireplaces + bathrooms + rooms + heatinghot.air + heatinghot.water.steam + fueloil + 
                 fuelelectric + centralAirNo, data=train_5)
rmse_med_5 <- rmse(lm_medium, test_5)

rmse_med <- as.data.frame(c(rmse_med_1, rmse_med_2, rmse_med_3, rmse_med_4, rmse_med_5))
rmse_med
avg_rmse_med = (rmse_med_1 + rmse_med_2 + rmse_med_3 + rmse_med_4 + rmse_med_5)/5
avg_rmse_med

### better RMSEs

lm_better = lm(house_price ~  lotSize + age +landValue + livingArea + bedrooms + 
                 fireplaces + bathrooms + rooms + heatinghot.water.steam
               + heatingelectric + fuelelectric + waterfrontNo + centralAirNo + fueloil +
                 waterfrontNo * landValue, data=train_1)
rmse_bet_1 <- rmse(lm_better, test_1)

lm_better = lm(house_price ~  lotSize + age +landValue + livingArea + bedrooms + 
                 fireplaces + bathrooms + rooms + heatinghot.water.steam
               + heatingelectric + fuelelectric + waterfrontNo + centralAirNo + fueloil +
                 waterfrontNo * landValue, data=train_2)
rmse_bet_2 <- rmse(lm_better, test_2)

lm_better = lm(house_price ~  lotSize + age +landValue + livingArea + bedrooms + 
                 fireplaces + bathrooms + rooms + heatinghot.water.steam
               + heatingelectric + fuelelectric + waterfrontNo + centralAirNo + fueloil +
                 waterfrontNo * landValue, data=train_3)
rmse_bet_3 <- rmse(lm_better, test_3)

lm_better = lm(house_price ~  lotSize + age +landValue + livingArea + bedrooms + 
                 fireplaces + bathrooms + rooms + heatinghot.water.steam
               + heatingelectric + fuelelectric + waterfrontNo + centralAirNo + fueloil +
                 waterfrontNo * landValue, data=train_4)
rmse_bet_4 <- rmse(lm_better, test_4)

lm_better = lm(house_price ~  lotSize + age +landValue + livingArea + bedrooms + 
                 fireplaces + bathrooms + rooms + heatinghot.water.steam
               + heatingelectric + fuelelectric + waterfrontNo + centralAirNo + fueloil +
                 waterfrontNo * landValue, data=train_5)
rmse_bet_5 <- rmse(lm_better, test_5)

rmse_bet <- as.data.frame(c(rmse_bet_1, rmse_bet_2, rmse_bet_3, rmse_bet_4, rmse_bet_5))
rmse_bet
avg_rmse_bet = (rmse_bet_1 + rmse_bet_2 + rmse_bet_3 + rmse_bet_4 + rmse_bet_5)/5
avg_rmse_bet

### KNN RMSEs

knn_optk <- knnreg(house_price ~ lotSize + age +landValue + livingArea + bedrooms + 
                     fireplaces + bathrooms + rooms + heatinghot.water.steam
                   + heatingelectric + fuelelectric + centralAirNo + fueloil, data=train_1, k=optk_final)
rmse_knn_1 <- rmse(knn_optk, test_1)

knn_optk <- knnreg(house_price ~ lotSize + age +landValue + livingArea + bedrooms + 
                     fireplaces + bathrooms + rooms + heatinghot.water.steam
                   + heatingelectric + fuelelectric + centralAirNo + fueloil, data=train_2, k=optk_final)
rmse_knn_2 <- rmse(knn_optk, test_2)

knn_optk <- knnreg(house_price ~ lotSize + age +landValue + livingArea + bedrooms + 
                     fireplaces + bathrooms + rooms + heatinghot.water.steam
                   + heatingelectric + fuelelectric + centralAirNo + fueloil, data=train_3, k=optk_final)
rmse_knn_3 <- rmse(knn_optk, test_3)

knn_optk <- knnreg(house_price ~ lotSize + age +landValue + livingArea + bedrooms + 
                     fireplaces + bathrooms + rooms + heatinghot.water.steam
                   + heatingelectric + fuelelectric + centralAirNo + fueloil, data=train_4, k=optk_final)
rmse_knn_4 <- rmse(knn_optk, test_4)

knn_optk <- knnreg(house_price ~ lotSize + age +landValue + livingArea + bedrooms + 
                     fireplaces + bathrooms + rooms + heatinghot.water.steam
                   + heatingelectric + fuelelectric + centralAirNo + fueloil, data=train_5, k=optk_final)
rmse_knn_5 <- rmse(knn_optk, test_5)

rmse_knn <- as.data.frame(c(rmse_knn_1, rmse_knn_2, rmse_knn_3, rmse_knn_4, rmse_knn_5))
rmse_knn
avg_rmse_knn = (rmse_knn_1 + rmse_knn_2 + rmse_knn_3 + rmse_knn_4 + rmse_knn_5)/5
avg_rmse_knn

### Comparing

avg_rmse_med
avg_rmse_bet
avg_rmse_knn


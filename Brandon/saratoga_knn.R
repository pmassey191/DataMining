library(tidyverse)
library(ggplot2)
library(modelr)
library(rsample)
library(mosaic)
library(foreach)
library(caret)

data(SaratogaHouses)

K_folds = 5
k_grid = c(2:30,35,40,45,50,55,60,65,70,80, 90,100)
saratoga_folds = crossv_kfold(SaratogaHouses, k=K_folds)

training <- foreach (i = 1:K_folds) %do% {
  nam <- paste("train_", i, sep = "")
  dat = as.data.frame(saratoga_folds$train[i])
  clean_matrix = model.matrix(~ . - 1, data=dat)
  thing <- scale(clean_matrix, center = FALSE, scale = apply(clean_matrix, 2, sd)) %>% 
    as.data.frame()
  thing = thing %>%
    mutate(house_price = clean_matrix[,1])
  names(thing)[1:20] <- substring(names(thing)[1:20],4)
  names(thing)<-str_replace_all(names(thing), c(" " = "." , "/" = "" ))
  assign(nam, thing)
}


testing <- foreach (i = 1:K_folds) %do% {
  nam <- paste("test_", i, sep = "")
  dat = as.data.frame(saratoga_folds$test[i])
  clean_matrix = model.matrix(~ . - 1, data=dat)
  thing <- scale(clean_matrix, center = FALSE, scale = apply(clean_matrix, 2, sd)) %>% 
    as.data.frame()
  thing = thing %>%
    mutate(house_price = clean_matrix[,1])
  names(thing)[1:20] <- substring(names(thing)[1:20],4)
  names(thing)<-str_replace_all(names(thing), c(" " = "" , "/" = "" ))
  assign(nam, thing)
}

cv_grid = foreach(k = k_grid, .combine='rbind') %dopar% {
  models = map(training, ~ knnreg(house_price ~ lotSize + age + livingArea + pctCollege + bedrooms +
                                                fireplaces + bathrooms + rooms +
                                    waterfrontNo + newConstructionNo + centralAirNo, k=k, data = ., use.all=FALSE))
  errs = map2_dbl(models, testing, modelr::rmse)
  c(k=k, err = mean(errs), std_err = sd(errs)/sqrt(K_folds))
} %>% as.data.frame

ggplot(cv_grid) + 
  geom_point(aes(x=k, y=err))+
  scale_x_log10()+
  geom_errorbar(aes(x=k, ymin = err-std_err, ymax = err+std_err)) +
  labs(title = "RMSE for Different K Values\n", x = "K", y = "RMSE") +
  theme_classic()

opt_k = cv_grid%>%
  arrange(err)

# This provides us with the 1 standard error allowance and isolates the associated K value
max_err = opt_k[1,2] + opt_k[1,3]
min_k = opt_k[1,1]
opt_k

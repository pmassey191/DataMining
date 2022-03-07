library(tidyverse)
library(ggplot2)
library(naivebayes)
library(modelr)
library(rsample)
library(foreach)
library(mosaic)
library(gamlr)
library(fastDummies)


###########################################################
######################## Problem 1 ########################
###########################################################
capmetro_UT <- read.csv("~/School/University of Texas-Austin/Classes/Data Mining/Data/capmetro_UT.csv")

# Recode the categorical variables in sensible, rather than alphabetical, order
capmetro_UT = mutate(capmetro_UT,
                     day_of_week = factor(day_of_week,
                                          levels=c("Mon", "Tue", "Wed","Thu", "Fri", "Sat", "Sun")),
                     month = factor(month,
                                    levels=c("Sep", "Oct","Nov")))

fpanel = capmetro_UT %>%
  group_by(hour_of_day,day_of_week,month)%>%
  summarize(avg_board = mean(boarding))

ggplot(fpanel)+
  geom_line(aes(x=hour_of_day,y=avg_board,color=month),size=1.2)+
  facet_wrap(~day_of_week)+
  theme_minimal()
  

ggplot(capmetro_UT)+
  geom_point(aes(x=temperature,y=boarding,color=weekend),size=.5)+
  facet_wrap(~hour_of_day)





###########################################################
######################## Problem 2 ########################
###########################################################
data(SaratogaHouses)

saratoga_split = initial_split(SaratogaHouses, prop = 0.8)
saratoga_train = training(saratoga_split)
saratoga_test = testing(saratoga_split)

# Build linear model that out-performs

bench = lm(price ~ . - pctCollege - sewer - waterfront - landValue - newConstruction, data=saratoga_train)
rmse(bench, saratoga_test)

comp = lm(price ~ . - pctCollege - newConstruction + age*age + lotSize*waterfront,data=saratoga_train)

rmse(comp,saratoga_test)-rmse(bench,saratoga_test)

# Scaling features
house_scale = SaratogaHouses %>%
  mutate(dum_air = ifelse(centralAir == 'Yes',1,0),
         dum_water = ifelse(waterfront == 'Yes',1,0),
         dum_new_cons = ifelse(newConstruction == 'Yes',1,0))%>%
  select(!c(newConstruction,waterfront,centralAir,sewer,fuel,heating))%>%
  mutate(across(!price,scale))

house_scale_split = initial_split(house_scale, prop = 0.8)
house_scale_train = training(house_scale_split)
house_scale_test = testing(house_scale_split)


knn_K5 = caret::knn3(price ~ . - pctCollege - dum_new_cons, data=house_scale_train, subset = ifelse(),k=5)
knn_K25 = caret::knn3(price ~ . - pctCollege - dum_new_cons, data=house_scale_train, k=25)

rmse(knn_K25, data=house_scale_test)-rmse(knn_K5,data=house_scale_test)
###########################################################
######################## Problem 3 ########################
###########################################################

german_credit <- read.csv("~/School/University of Texas-Austin/Classes/Data Mining/Data/german_credit.csv")

prob_default = german_credit%>% 
  group_by(history) %>% 
  summarize(prob = mean(Default))

ggplot(prob_default)+
  geom_col(aes(x=history,y=prob),color='dark green',fill='dark green')+
  theme_minimal()+
  ggtitle("Probability of Default \n by Credit History")+
  ylab("Probability")+
  xlab("History")

german_split = initial_split(german_credit, prop = 0.8)
german_train = training(german_split)
german_test = testing(german_split)


logit_credit = glm(Default ~ (duration + amount + installment + age + 
                     history + purpose + foreign)^2, data=german_train,
                   family='binomial')

# Confusion Matrix
phat_logit_credit = predict(logit_credit,german_test,
                            type='response')
yhat_logit_credit = ifelse(phat_logit_credit >0.5 , 1 , 0)
confusion_logit = table(y = german_test$Default ,
                        yhat = yhat_logit_credit)

###########################################################
######################## Problem 4 ########################
###########################################################

hotels_dev <- read.csv("~/School/University of Texas-Austin/Classes/Data Mining/Data/hotels_dev.csv")
hotels_val <- read.csv("~/School/University of Texas-Austin/Classes/Data Mining/Data/hotels_val.csv")

hotel_split = initial_split(hotels_dev, prop=.8)
hotel_train = training(hotel_split)
hotel_test = testing(hotel_split)

lm1 = lm(children ~ market_segment+adults+customer_type+is_repeated_guest, data=hotel_train)
lm2 = lm(children ~ . - arrival_date, data=hotel_train)


hotelx = model.matrix(children ~ .-1-arrival_date, data=hotels_dev) # do -1 to drop intercept!
hotely = hotels_dev$children

# Note: there's also a "sparse.model.matrix"
# here our matrix isn't sparse.
# but sparse.model.matrix is a good way of doing things if you have factors.

# fit a single lasso
hotellasso = gamlr(hotelx, hotely, family="binomial")
plot(hotellasso) # the path plot!

# AIC selected coef
# note: AICc = AIC with small-sample correction.  See ?AICc
AICc(hotellasso)  # the AIC values for all values of lambda
plot(hotellasso$lambda, AICc(hotellasso))
plot(log(hotellasso$lambda), AICc(hotellasso))

# the coefficients at the AIC-optimizing value
# note the sparsity
scbeta = coef(hotellasso) 

# optimal lambda
log(hotellasso$lambda[which.min(AICc(hotellasso))])
sum(scbeta!=0) # chooses 30 (+intercept) @ log(lambda) = -4.5

# Now without the AIC approximation:
# cross validated lasso (`verb` just prints progress)
# this takes a little longer, but still so fast compared to stepwise
sccvl = cv.gamlr(hotelx, hotely, nfold=10, family="binomial", verb=TRUE, select='1se')

# plot the out-of-sample deviance as a function of log lambda
# Q: what are the bars associated with each dot? 
plot(sccvl, bty="n")

## CV min deviance selection
scb.min = coef(sccvl, select="min")
log(sccvl$lambda.min)
sum(scb.min!=0) # note: this is random!  because of the CV randomness

## CV 1se selection (the default)
scb.1se = coef(sccvl)
log(sccvl$lambda.1se)
sum(scb.1se!=0) ## usually selects all zeros (just the intercept)

## comparing AICc and the CV error
# note that AIC is a pretty good estimate of out-of-sample deviance
# for values of lambda near the optimum
# outside that range: much worse  
plot(sccvl, bty="n", ylim=c(0, 1))
lines(log(sclasso$lambda),AICc(sclasso)/n, col="green", lwd=2)
legend("top", fill=c("blue","green"),
       legend=c("CV","AICc"), bty="n")





hotel_tiny = model.matrix(children~.+1-arrival_date, data=hotel_test)
dim(hotel_tiny)
a = as.data.frame(hotel_tiny)%>%
  mutate(children = hotel_test$children)%>%
  as.matrix()
da_fuck = predict(hotellasso, a, type='response')





phat_test_lm1 = predict(lm1, hotel_test, type='response')
phat_test_lm2 = predict(lm2, hotel_test, type='response')
thresh_grid = seq(1, 0, by=-0.005)
roc_curve_hotel = foreach(thresh = thresh_grid, .combine='rbind') %do% {
  yhat_test_lm1 = ifelse(phat_test_lm1 >= thresh, 1, 0)
  yhat_test_lm2 = ifelse(phat_test_lm2 >= thresh, 1, 0)
  # FPR, TPR for linear model
  confusion_out_lm1 = table(y = hotel_test$children, yhat = yhat_test_lm1)
  confusion_out_lm2 = table(y = hotel_test$children, yhat = yhat_test_lm2)
  out_lm1 = data.frame(model = "lm1",
                       TPR = ifelse(sum(yhat_test_lm1) ==0, 0, confusion_out_lm1[2,2]/sum(hotel_test$children==1)),
                       FPR = ifelse(sum(yhat_test_lm1) == 0, 0,confusion_out_lm1[1,2]/sum(hotel_test$children==0)))
  out_lm2 = data.frame(model = "lm2",
                       TPR = ifelse(sum(yhat_test_lm2)==0, 0,confusion_out_lm2[2,2]/sum(hotel_test$children==1)),
                       FPR = ifelse(sum(yhat_test_lm2)==0,0,confusion_out_lm2[1,2]/sum(hotel_test$children==0)))
  
  rbind(out_lm1, out_lm2)
} %>% as.data.frame()
ggplot(roc_curve_hotel) + 
  geom_line(aes(x=FPR, y=TPR, color=model)) + 
  labs(title="ROC curves: linear vs. logit models") +
  theme_bw(base_size = 10)


thresh=.5

yhat_test_lm1 = ifelse(phat_test_lm1 >= thresh, 1, 0)
yhat_test_lm2 = ifelse(phat_test_lm2 >= thresh, 1, 0)
# FPR, TPR for linear model
confusion_out_lm1 = table(y = hotel_test$children, yhat = yhat_test_lm1)
confusion_out_lm2 = table(y = hotel_test$children, yhat = yhat_test_lm2)
out_lm1 = data.frame(model = "lm1",
                     TPR = ifelse(sum(yhat_test_lm1) ==0, 0, confusion_out_lm1[2,2]/sum(hotel_test$children==1)),
                     FPR = ifelse(sum(yhat_test_lm1) == 0, 0,confusion_out_lm1[1,2]/sum(hotel_test$children==0)))
out_lm2 = data.frame(model = "lm2",
                     TPR = ifelse(sum(yhat_test_lm2)==0, 0,confusion_out_lm2[2,2]/sum(hotel_test$children==1)),
                     FPR = ifelse(sum(yhat_test_lm2)==0,0,confusion_out_lm2[1,2]/sum(hotel_test$children==0)))

rbind(out_lm1, out_lm2)

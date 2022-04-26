library(tidyverse)
library(mosaic)
library(rpart)
library(rpart.plot)
library(rsample)
library(modelr)
library(randomForest)
library(gbm)
library(foreach)
library(gamlr)
library(caret)
library(LICORS)



############################################################
################### Clustering and PCA #####################
############################################################

wine <- read.csv("~/School/University of Texas-Austin/Classes/Data Mining/Data/wine.csv")


### Clustering for color
# Center and scale the data
X = wine[,-c(1,13)]
X = scale(X, center=TRUE, scale=TRUE)

# Extract the centers and scales from the rescaled data (which are named attributes)
mu = attr(X,"scaled:center")
sigma = attr(X,"scaled:scale")

# K-means++
clust_kplus = kmeanspp(X, k=2, nstart=25)

clust_kplus$center[1,]*sigma + mu
clust_kplus$center[2,]*sigma + mu

summary(factor(clust_kplus$cluster))

table(wine$color,factor(clust_kplus$cluster))

ggplot(wine)+
  geom_point(aes(x=residual.sugar, y=total.sulfur.dioxide, color = factor(clust_kplus$cluster)))

ggplot(wine)+
  geom_point(aes(x=residual.sugar,y=total.sulfur.dioxide,color=color))


clust_kplus$withinss
sum(clust_kplus$withinss)
clust_kplus$tot.withinss
clust_kplus$betweenss


##### Clustering for Quality
Y = wine[,-c(1,13)]
Y = scale(Y, center=TRUE, scale=TRUE)

# Extract the centers and scales from the rescaled data (which are named attributes)
mu = attr(Y,"scaled:center")
sigma = attr(Y,"scaled:scale")

# K-means++
clust_kplus = kmeanspp(Y, k=3, nstart=25)

clust_kplus$center[1,]*sigma + mu
clust_kplus$center[2,]*sigma + mu


summary(factor(clust_kplus$cluster))

qual_count = wine %>%
  group_by(quality)%>%
  summarize(count =n())

table(wine$quality,factor(clust_kplus$cluster))

ggplot(wine)+
  geom_point(aes(x=residual.sugar, y=total.sulfur.dioxide, color = factor(clust_kplus$cluster)))

ggplot(wine)+
  geom_point(aes(x=fixed.acidity,y=total.sulfur.dioxide,color=quality))


clust_kplus$withinss
sum(clust_kplus$withinss)
clust_kplus$tot.withinss
clust_kplus$betweenss





##### PCA approach

wine = wine %>%
  rownames_to_column('wine_id')

wine$wine_id = as.numeric(wine$wine_id)

pc_wine = prcomp(wine[,-c(1,2,13)], rank=6, scale=TRUE)

summary(pc_wine)

outcome = as.data.frame(pc_wine$x)

pc_wine$rotation

ggplot(data)+
  geom_point(aes(x=color,y=PC1))

outcome = outcome %>%
  rownames_to_column('wine_id')

data = merge(wine, outcome, by = 'wine_id')

data = data %>%
  select(!wine_id)
  
ggplot(data) + 
  geom_col(aes(x=reorder(color, PC2), y=PC2)) + 
  coord_flip()

ggplot(data)+
  geom_point(aes(x=PC1,y=PC2,color=color))





data = data %>%
  mutate(indicator = ifelse(color == 'red',1,0))

lm1 = glm(indicator ~ PC1 + PC2 + PC3 + PC4+ PC5 + PC6 + PC7 + PC8, data = data, family = 'binomial')

y_hat = predict(lm1, data, type = 'response')

y_hat_1 = ifelse(y_hat >= .5, 1, 0)

y_hat_1 = as.factor(y_hat_1)
data$indicator = as.factor(data$indicator)
x = data$indicator

confusion_mat = confusionMatrix(y_hat_1,x)

data$indicator = as.factor(data$indicator)

confusion_mat$table

data = data %>%
  mutate(indicator = ifelse(color == 'red',1,0))
  
data = data[,c(2,3,4,5,6,7,8,9,10,11,12,25)]

lm2 = glm(indicator ~ ., data = data, family = 'binomial')

y_hat = predict(lm2, data, type = 'response')

y_hat_1 = ifelse(y_hat >= .5, 1, 0)

y_hat_1 = as.factor(y_hat_1)
data$indicator = as.factor(data$indicator)
x = data$indicator

confusion_mat = confusionMatrix(y_hat_1,x)

data$indicator = as.factor(data$indicator)

confusion_mat$table


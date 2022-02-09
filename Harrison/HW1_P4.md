\`\`\`{r, echo=FALSE} sclass\_clean = sclass %&gt;% select(trim,
mileage, price)%&gt;% filter(trim==‘65 AMG’ | trim==‘350’)

sclass\_350 = sclass\_clean%&gt;% filter(trim==‘350’)

sclass350\_split = initial\_split(sclass\_350, prop = 0.8)
sclass350\_train = training(sclass350\_split) sclass350\_test =
testing(sclass350\_split)

lm1 = lm(price ~ mileage, data=sclass350\_train) lm2 = lm(price ~
poly(mileage, 2), data=sclass350\_train)

linear\_bench = rmse(lm1, sclass350\_test) quad\_bench = rmse(lm2,
sclass350\_test)

knn\_opts = foreach(i = 2:100, .combine=‘rbind’) %do% { err =
rmse(knnreg(price ~ mileage, data=sclass350\_train,
k=i),sclass350\_test) }%&gt;% as.data.frame()

knn\_opts = data.frame(knn\_opts,2:100)

knn\_opts = knn\_opts%&gt;% mutate(RMSE = V1, k = X2.100)%&gt;%
select(RMSE,k)

ggplot(knn\_opts)+ geom\_line(aes(y=RMSE,x=k))+
geom\_hline(aes(yintercept=quad\_bench))+
geom\_hline(aes(yintercept=linear\_bench)) \`\`\`

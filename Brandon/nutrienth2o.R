df <- read.csv(here("data/social_marketing.csv"))
df <- select(df, -X)

# some summary statistics

summary(df)
sort(colSums(df))
avg_user <- 
  as.data.frame(sort(colMeans(df)))
avg_user <- avg_user %>% 
  rownames_to_column("tweet_cat") %>% 
  rename("avg_tweets" = "sort(colMeans(df))")


ggplot(avg_user) + 
  geom_col(aes(x = reorder(tweet_cat, -avg_tweets), y = avg_tweets)) + 
  coord_flip() +
  ylab("Average Tweets Per User") +
  xlab("Tweet Type")

# a heatmap visualization with sorting by hierarchical clustering
ggcorrplot::ggcorrplot(cor(df), hc.order = TRUE)

## Since clustering creates mutually exclusiving groups, it's probably better for us to consider PCA


pca1 = prcomp(df, scale=TRUE) 
summary(pca)

#calculate total variance explained by each principal component
var_explained = pca1$sdev^2 / sum(pca1$sdev^2)

#create scree plot
qplot(c(1:36), var_explained) + 
  geom_line() + 
  xlab("Principal Component") + 
  ylab("Variance Explained") +
  ggtitle("Variance Explained by PC") +
  ylim(0, .25)

# It doesn't look like we gain much after 5 or 6--after 6 it drops below 5% of explanation

pca = prcomp(df, scale=TRUE, rank=10)

head(round(pca$rotation[,1:10],2)) 

# create a tidy summary of the loadings
loadings = pca$rotation %>%
  as.data.frame() %>%
  rownames_to_column('tweet')

# This looks like the spam/adult PC
loadings %>%
  select(tweet, PC1) %>%
  arrange(desc(PC1))

# Let's call this the influencer - cooking, photos, fashing, shopping
loadings %>%
  select(tweet, PC2) %>%
  arrange(desc(PC2))

# The wellness nut
loadings %>%
  select(tweet, PC3) %>%
  arrange(desc(PC3))

# The college demographic - school, sports and video games
loadings %>%
  select(tweet, PC4) %>%
  arrange(desc(PC4))

# The arts, film and crafts group
loadings %>%
  select(tweet, PC7) %>%
  arrange(desc(PC7))

# The college demographic - school, sports and video games
loadings %>%
  select(tweet, PC10) %>%
  arrange(desc(PC10))



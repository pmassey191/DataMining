# Homework 4

Patrick Massey, Harrison Snell, Brandon Williams

## Problem 1 - Wine Clustering and PCA

## Problem 2 - NutrientH2O

When considering marketing to the NutrientH2O Twitter followers, there
are several natural groups that emerge using unsupervised learning
techniques. These groups will help NutrientH20 coordinate a marketing
campaign to specific follower demographics. Before conducting principle
component analysis (PCA), let’s take a look at the overall trends of the
tweets of the Twitter followers.

![](Homework4_files/figure-markdown_strict/unnamed-chunk-3-1.png)

As we might have predicted, the average user generally tweets about
general, uncategorized “chatter” and some photo sharing. Nevertheless,
we see some high counts in health and nutrition, cooking, politics,
sports, and travel. Are there natural groupings of followers into
categories? Consider the correlation matrix of tweet type organized by
hierarchical clustering:

![](Homework4_files/figure-markdown_strict/pressure-1.png)

Some patterns emerge. Disregarding the spam/adult categories (unless
NutrientH2O is considering a significant rebrand), there are clear
groupings around: \* beauty, cooking, and fashion \* health, nutrition,
and fitness \* family, school, religion, and parenting \* gaming,
sports, and university

Since clustering is naturally mutually exclusive and Twitter users can
have multiple interests simultaneously, we choose to present a PCA on
the follower base to see if these categorical patterns continue to
emerge based on the components of the Tweets. An initial PCA reveals how
much variance is explained by each principle component. We see the
variance dropping off after 5 components, and certainly after 10 we are
gaining smaller and smaller amounts of variance.

![](Homework4_files/figure-markdown_strict/unnamed-chunk-4-1.png)

Running a PCA with 10 principle components gives us some pretty clear
group characteristics. Let’s look at the loadings for some of the
components. The first principle component is once again the adult/spam
group, so let’s look at the high loadings for PC2. We can call this the
“influencer” group: high in cooking, fashion, shopping, and beauty.
Considering the overall popularity of these types of tweets among
NutrientH2O followers, this would be an effective demographic to market
to.

    ##           tweet       PC2
    ## 1       cooking 0.3142880
    ## 2 photo_sharing 0.3030776
    ## 3       fashion 0.2797997
    ## 4      shopping 0.2098528
    ## 5        beauty 0.2086099
    ## 6       chatter 0.1972255

PC3 represents the wellness demographic–people interested in health,
nutrition, personal fitness, and cooking. Given NutrientH2O’s brand
name, this is a natural group to target in any social media marketing.

    ##              tweet       PC3
    ## 1 health_nutrition 0.2255148
    ## 2 personal_fitness 0.2173747
    ## 3          cooking 0.1944997
    ## 4           beauty 0.1507105
    ## 5         outdoors 0.1403903
    ## 6          fashion 0.1387695

Finally, PC4 shows a younger demographic, those interested in video
games, sports, and college/university. The insight here for the brand is
to target this market segment with branding aimed at youth and
college-aged consumers.

    ##            tweet       PC4
    ## 1    college_uni 0.2555873
    ## 2  online_gaming 0.2207630
    ## 3 sports_playing 0.1756699
    ## 4  photo_sharing 0.1514910
    ## 5         beauty 0.1469076
    ## 6        fashion 0.1379828

The other principle components begin to show less clear market segments,
but some interesting ones still emerge. Consider PC7, which has high
loadings in art, film, and crafts, or PC10, which seems to have a high
interest in dating.

    ##                  PC1  PC2   PC3   PC4   PC5   PC6   PC7   PC8   PC9  PC10
    ## chatter        -0.13 0.20 -0.07  0.11 -0.19  0.46 -0.11  0.07 -0.02  0.11
    ## current_events -0.10 0.06 -0.05  0.03 -0.06  0.14  0.04 -0.05 -0.02 -0.11
    ## travel         -0.12 0.04 -0.42 -0.15 -0.01 -0.16  0.09  0.31  0.02 -0.11
    ## photo_sharing  -0.18 0.30  0.01  0.15 -0.23  0.21 -0.13  0.02  0.02 -0.13
    ## uncategorized  -0.09 0.15  0.03  0.02  0.06 -0.04  0.19 -0.05 -0.05  0.27
    ## tv_film        -0.10 0.08 -0.09  0.09  0.21  0.06  0.50 -0.22  0.13 -0.10

Principle component analysis reveals some clear “ingredients” for each
demographic, highlighting their interests, and giving valuable insight
to the NutrientH2O marketing team to orient their strategy.

## Problem 3 - Market Basket

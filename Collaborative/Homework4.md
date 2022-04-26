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

PC3 represents the wellness demographic–people interested in health,
nutrition, personal fitness, and cooking. Given NutrientH2O’s brand
name, this is a natural group to target in any social media marketing.

Finally, PC4 shows a younger demographic, those interested in video
games, sports, and college/university. The insight here for the brand is
to target this market segment with branding aimed at youth and
college-aged consumers.

The other principle components begin to show less clear market segments,
but some interesting ones still emerge. Consider PC7, which has high
loadings in art, film, and crafts, or PC10, which seems to have a high
interest in dating.

Principle component analysis reveals some clear “ingredients” for each
demographic, highlighting their interests, and giving valuable insight
to the NutrientH2O marketing team to orient their strategy.

## Problem 3 - Market Basket

Here’s my graph.

    knitr::opts_chunk$set(echo = FALSE)

    library(tidyverse)

    ## -- Attaching packages --------------------------------------- tidyverse 1.3.1 --

    ## v ggplot2 3.3.5     v purrr   0.3.4
    ## v tibble  3.1.6     v dplyr   1.0.7
    ## v tidyr   1.1.4     v stringr 1.4.0
    ## v readr   2.1.1     v forcats 0.5.1

    ## -- Conflicts ------------------------------------------ tidyverse_conflicts() --
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

    library(mosaic)

    ## Registered S3 method overwritten by 'mosaic':
    ##   method                           from   
    ##   fortify.SpatialPolygonsDataFrame ggplot2

    ## 
    ## The 'mosaic' package masks several functions from core packages in order to add 
    ## additional features.  The original behavior of these functions should not be affected by this.

    ## 
    ## Attaching package: 'mosaic'

    ## The following object is masked from 'package:Matrix':
    ## 
    ##     mean

    ## The following objects are masked from 'package:dplyr':
    ## 
    ##     count, do, tally

    ## The following object is masked from 'package:purrr':
    ## 
    ##     cross

    ## The following object is masked from 'package:ggplot2':
    ## 
    ##     stat

    ## The following objects are masked from 'package:stats':
    ## 
    ##     binom.test, cor, cor.test, cov, fivenum, IQR, median, prop.test,
    ##     quantile, sd, t.test, var

    ## The following objects are masked from 'package:base':
    ## 
    ##     max, mean, min, prod, range, sample, sum

    library(airportr)
    library(dplyr)
    library(usmap)
    library(maptools)

    ## Loading required package: sp

    ## Checking rgeos availability: FALSE
    ## Please note that 'maptools' will be retired by the end of 2023,
    ## plan transition at your earliest convenience;
    ## some functionality will be moved to 'sp'.
    ##      Note: when rgeos is not available, polygon geometry     computations in maptools depend on gpclib,
    ##      which has a restricted licence. It is disabled by default;
    ##      to enable gpclib, type gpclibPermit()

    library(ggplot2)
    library(rgdal)

    ## Please note that rgdal will be retired by the end of 2023,
    ## plan transition to sf/stars/terra functions using GDAL and PROJ
    ## at your earliest convenience.
    ## 
    ## rgdal: version: 1.5-28, (SVN revision 1158)
    ## Geospatial Data Abstraction Library extensions to R successfully loaded
    ## Loaded GDAL runtime: GDAL 3.2.1, released 2020/12/29
    ## Path to GDAL shared files: C:/Users/bjwil/OneDrive/Documents/R/win-library/4.1/rgdal/gdal
    ## GDAL binary built with GEOS: TRUE 
    ## Loaded PROJ runtime: Rel. 7.2.1, January 1st, 2021, [PJ_VERSION: 721]
    ## Path to PROJ shared files: C:/Users/bjwil/OneDrive/Documents/R/win-library/4.1/rgdal/proj
    ## PROJ CDN enabled: FALSE
    ## Linking to sp version:1.4-6
    ## To mute warnings of possible GDAL/OSR exportToProj4() degradation,
    ## use options("rgdal_show_exportToProj4_warnings"="none") before loading sp or rgdal.
    ## Overwritten PROJ_LIB was C:/Users/bjwil/OneDrive/Documents/R/win-library/4.1/rgdal/proj

    ## 
    ## Attaching package: 'rgdal'

    ## The following object is masked from 'package:mosaic':
    ## 
    ##     project

    library(viridis)

    ## Loading required package: viridisLite

    library(here)

    ## here() starts at C:/Users/bjwil/OneDrive/Documents/GitHub/DataMining

    library(colorspace)

    ABIA <- read.csv(here("Data/ABIA.csv"))

    ## Let's take a look at what average delays look like for flights out of Austin 

    ABIA_stats = ABIA %>% 
      filter(Origin == 'AUS') %>% 
      group_by(Dest) %>% 
      summarize(count = n(),
                mean_arr_delay = mean(ArrDelay, na.rm=TRUE)) %>% 
      filter(count > 499)

    worstdelays <- ggplot(ABIA_stats) +
      geom_col(aes(x = mean_arr_delay, fct_reorder(Dest, mean_arr_delay), fill = mean_arr_delay), show.legend = FALSE) +
      scale_fill_continuous_sequential(palette = "Heat"
                                        )  +
      theme_classic() +
      labs(title = "Worst Arrival Delays by Airport",
           subtitle = "Arriving from Austin (At Least 500 Flights)",
           x = "Average Flight Delay",
           y = "Destination") +
      geom_vline(aes(xintercept=5.5546)) +
      geom_text(mapping=aes(x=5.5546, y=5, label="Group Average"), size=4, angle=90, vjust=-.3, hjust=.3)

## Including Plots

You can also embed plots, for example:

## Including Plots

You can also embed plots, for example:

![](Airport_files/figure-markdown_strict/pressure-1.png)

Note that the `echo = FALSE` parameter was added to the code chunk to
prevent printing of the R code that generated the plot.

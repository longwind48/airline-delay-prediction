---
title: "R Notebook"
output:
  html_document:
    keep_md: yes
  pdf_document: default
---

This is an [R Markdown](http://rmarkdown.rstudio.com) Notebook. When you execute code within the notebook, the results appear beneath the code. 

Try executing this chunk by clicking the *Run* button within the chunk or by placing your cursor inside it and pressing *Ctrl+Shift+Enter*. 

This markdown file is a summary of a final project 




```r
head(dataForAnalysisOfCausesOfDelay)
```

```
##    MONTH DAY_OF_MONTH DAY_OF_WEEK    FL_DATE AIRLINE_ID CARRIER TAIL_NUM
## 1      4           19           3 2017-04-19      19790      DL   N355NB
## 2      5            9           2 2017-05-09      19790      DL   N905DE
## 4     11            5           7 2017-11-05      19930      AS   N224AK
## 5      3            5           7 2017-03-05      19393      WN   N8321D
## 6     11            3           5 2017-11-03      20304      OO   N103SY
## 10     1            2           1 2017-01-02      20409      B6   N903JB
##    FL_NUM ORIGIN_AIRPORT_ID DEST_AIRPORT_ID CRS_DEP_TIME CRS_ARR_TIME
## 1    2050             13495           12953         1259         1659
## 2    2541             11423           10397         1130         1438
## 4     414             14747           14057         2310         2356
## 5    2875             14679           15016         1035         1605
## 6    5342             11292           10800         1130         1311
## 10     54             14027           12478         2025         2259
##    ARR_DELAY ARR_DEL15 CANCELLED CANCELLATION_CODE DIVERTED
## 1          0         0         0                          0
## 2        -17         0         0                          0
## 4         41         1         0                          0
## 5        -23         0         0                          0
## 6         10         0         0                          0
## 10        47         1         0                          0
##    CRS_ELAPSED_TIME FLIGHTS DISTANCE DISTANCE_GROUP CARRIER_DELAY
## 1               180       1     1183              5            NA
## 2               128       1      743              3            NA
## 4                46       1      129              1            22
## 5               210       1     1557              7            NA
## 6               161       1      850              4            NA
## 10              154       1     1028              5            25
##    WEATHER_DELAY NAS_DELAY SECURITY_DELAY LATE_AIRCRAFT_DELAY
## 1             NA        NA             NA                  NA
## 2             NA        NA             NA                  NA
## 4              0        19              0                   0
## 5             NA        NA             NA                  NA
## 6             NA        NA             NA                  NA
## 10             0        22              0                   0
##           DELAY_GROUPS CRS_DEP_TIME_MINS CRS_ARR_TIME_MINS
## 1             no_delay               779              1019
## 2             no_delay               690               878
## 4  delay.31.to.45.mins              1390              1436
## 5             no_delay               635               965
## 6   delay.1.to.15.mins               690               791
## 10 delay.46.to.60.mins              1225              1379
##    CRS_DEP_TIME_MINS_SQUARED CRS_ARR_TIME_MINS_SQUARED DEP_TIME_BINS
## 1                     606841                   1038361 X1200.to.1259
## 2                     476100                    770884 X1100.to.1159
## 4                    1932100                   2062096 X2300.to.2359
## 5                     403225                    931225 X1000.to.1059
## 6                     476100                    625681 X1100.to.1159
## 10                   1500625                   1901641 X2000.to.2059
##    ARR_TIME_BINS ORIGIN_AIRPORT_LAT ORIGIN_AIRPORT_LONG DEST_AIRPORT_LAT
## 1  X1600.to.1659           29.99111           -90.25139         40.77944
## 2  X1400.to.1459           41.53389           -93.65667         33.64083
## 4  X2300.to.2359           47.44722          -122.30556         45.58917
## 5  X1600.to.1659           32.73278          -117.18722         38.74722
## 6  X1300.to.1359           39.77444          -104.87972         34.20000
## 10 X2200.to.2259           26.68222           -80.09417         40.63861
##    DEST_AIRPORT_LONG ORIGIN_AIRPORT_SIZE DEST_AIRPORT_SIZE
## 1          -73.87583               46876             93326
## 2          -84.42722                8173            364655
## 4         -122.59500              137176             62666
## 5          -90.36444               84056             56988
## 6         -118.35778              223165             25129
## 10         -73.77694               24448             94454
##    ORIGIN_AIRPORT_STATE_NAME DEST_AIRPORT_STATE_NAME
## 1                  Louisiana                New York
## 2                       Iowa                 Georgia
## 4                 Washington                  Oregon
## 5                 California                Missouri
## 6                   Colorado              California
## 10                   Florida                New York
##                  ORIGIN_DISPLAY_AIRPORT_NAME
## 1  Louis Armstrong New Orleans International
## 2                       Des Moines Municipal
## 4                      Seattle International
## 5       San Diego International Lindbergh Fl
## 6                    Stapleton International
## 10                  Palm Beach International
##          DEST_DISPLAY_AIRPORT_NAME ORIGIN_DISPLAY_CITY_MARKET_NAME_FULL
## 1                        LaGuardia                      New Orleans, LA
## 2                Atlanta Municipal                       Des Moines, IA
## 4           Portland International                          Seattle, WA
## 5  Lambert-St. Louis International                        San Diego, CA
## 6       Hollywood-Burbank Midpoint                           Denver, CO
## 10   John F. Kennedy International       West Palm Beach/Palm Beach, FL
##       DEST_DISPLAY_CITY_MARKET_NAME_FULL ORIGIN_AIRPORT DEST_AIRPORT
## 1  New York City, NY (Metropolitan Area)            MSY          LGA
## 2        Atlanta, GA (Metropolitan Area)            DSM          ATL
## 4                           Portland, OR            SEA          PDX
## 5                          St. Louis, MO            SAN          STL
## 6    Los Angeles, CA (Metropolitan Area)            DEN          BUR
## 10 New York City, NY (Metropolitan Area)            PBI          JFK
```

![](dataviz_files/figure-html/unnamed-chunk-3-1.png)<!-- -->



Add a new chunk by clicking the *Insert Chunk* button on the toolbar or by pressing *Ctrl+Alt+I*.

When you save the notebook, an HTML file containing the code and output will be saved alongside it (click the *Preview* button or press *Ctrl+Shift+K* to preview the HTML file).

The preview shows you a rendered HTML copy of the contents of the editor. Consequently, unlike *Knit*, *Preview* does not run any R code chunks. Instead, the output of the chunk when it was last run in the editor is displayed.

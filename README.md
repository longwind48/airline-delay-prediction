#Prediction of Flight Delays

## Based on 2017 United States Department of Transportation Data

##### By: Traci Lim, Yi Luo, Bill Skinner

---

The aim of this project was to use historical data to **develop a model for a flight delay prediction system**, where the aim of the system is to provide flight delay information at the time of booking to help people avoid delayed flights.  The model was developed and then deployed within a system that takes in basic flight details and displays predicted delay information to the user to help compare the likelihood of flight delays for different airlines. 

On top of exploratory data analysis and feature engineering, this project also extensively compared the performance of tree-based models: 

- CART
- C5.0
- Gradient Boosting Machine (Stochastic Gradient Boosting)
- Extreme Gradient Boosting (XGBoost)
- Stacking

This repository contains a snippets of the a 20-page report on the prediction of delays of United States domestic flights. If you are interested in looking at the full report, feel free to [email](longwind48@gmail.com) me.

---

### Methodology

![methodology](methodology.png)

---

### Summary and Interpretation of Results

![flow_chart](summarytable.png)



Regularized logistic regression is a form of logistic regression designed to be less sensitive to overfitting, therefore, it outperforms logistic regression likely because there could be overfitting due to the flexibility of the large number of features created by the one-hot-encoding. It is impressive that the test set accuracy metric is competitive with tree-based boosting algorithm C5.0. While both of them are designed to be robust to overfitting, C5.0 is able to detect the relevancy of features by performing implicit variable selection, as well as capture high-order interactions of the data.

The single tree-based algorithm, CART, was considered because the results could be useful in illustrating the superiority of boosting-based algorithms. C5.0 was added in because of the same reason, i.e. to compare tree-boosting algorithms with gradient-boosting algorithms. The results were reasonably obvious when they were judged based on both overall and balanced accuracy test scores, XGBoost is undeniably the best model among all tree-based algorithms, coming in at 61.3% and 62.5% respectively. Although XGBoost’s scores only differed in the 3rd decimal place from the runner up model, GBM, the running time of XGBoost favourably trumps every algorithm, taking only 20.9 seconds to train. When matched with remarkable gradient boosting algorithms, performance of CART and C5.0 were flat out overtaken, which is coherent given the underlying framework of their limitations. The predictors include some numeric features, which could cause instability in the case of CART, mostly because small changes in the variable could result in a completely different tree structure. C5.0 is very susceptible to overfitting when it picks up data with uncommon characteristics, and as we might expect to find, the ARR_TIME_BINS and DEP_TIM_BINS do have some noise in the early hours.

One of the improvements of XGBoost over GBM is the penalization of complexity, which was not common for additive tree models. The penalization part helps to avoid overfitting, stemming from its ability to control complexity. In a nutshell, XGBoost excels in performance because it uses a more regularized model formalization to control over-fitting, compared to other forms of gradient boosting. Other than being robust enough to support fine tuning and addition of regularization parameters, it also leverages the structure of computer hardware to speed up computing times and facilitate memory usage (Reinstein, 2017).

The best models in terms of overall and balanced accuracy are Stacking with logistic regression, XGBoost and Stacking with regularized logistic regression. For the best model, the balanced accuracy is 0.626. This means that the average of sensitivity and specificity is 62.6%, made up of a sensitivity of 61.1% and a specifiticity of 64.2%. In other words, 61.1% of the on-time flights were correctly classified, and 64.2% of the delayed flights were correctly classified. Since 23% of all 2017 domestic flights were delayed, we would naively expect any particular flight to have a 23% chance of being delayed. Simply put, if our model predicts that a flight will be delayed, there is a 64.2% chance that it will be right, which is 41% higher than the 23% chance that a flight would be delayed by guessing. On the other hand, if our model predicts that a flight is on time, it will only be correct 61.1% of the time, which is 15.9% less than the 77% chance that a flight would be on time by guessing. Since our goal was to provide a model that meaningfully predicts on-time and delayed flights equally well, we are encouraged that we managed to obtain relatively balanced predictions.

While our model is not perfect, we are pleased that it provides an increase from 23% to 61.7% in probability of correctly predicting whether a flight is delayed. Furthermore, our prediction of both on-time and delayed flights is fairly balanced, which helps provide meaningful results. 

### Application of Model

To implement our model, we developed a Flight Delay Prediction System in R that takes in basic information about a prospective flight from the user and then displays delay predictions for each carrier that flew that route in 2017.  Figure 10 shows the inputs and outputs of the system.  For ease of use, some features are generated internally, such as the distance between the airports, the origin airport state, the destination airport state, and the carriers.  In the output, a red bar is shown beside each airline for which the model predicts the flight would be delayed while a green bar is shown beside each airline for which the model predicts the flight would be on-time, as shown in Figure 11.  The length of the bars is an indication of how certain the model is: the longer the bar the more confident the model is that the flight will be delayed.  For 30,000 test flights, the overall accuracy of the model was 62.2% i.e. its prediction of whether flights were delayed or not was correct 62.2% of the time.

Users may also find it useful to know which airlines typically fly the route they are interested in.  Another plot, beside the delay predictions, shows the total number of flights that each airline flew from the origin airport to the destination airport in 2017; only airlines that flew the route are shown.  Of course, airline schedules may change, but this gives the user a pretty good idea of which airlines have been the main carriers on a route.  For example, of the five airlines that flew from Atlanta Georgia to Los Angeles California in 2017, Delta flew by far the most flights.  This makes sense because Atlanta (ATL) and Los Angeles (LAX) are both Delta hubs.

![applicationofmodel1](applicationofmodel1.png)

*Figure 10: Overview of Inputs and Outputs of Flight Delay Prediction System *

![applicationofmodel2](applicationofmodel2.png)

*Figure 11: Output of Flight Delay Prediction System for Flight from Atlanta to Los Angeles departing at 12:50 and arriving at 14:51 on Saturday April 28*

---

### Conclusion

To corroborate the classifier generated in this data mining project, we pitted our best model’s results against a flight delay prediction competition hosted by CrowdAnalytix.com in 2016 (CrowdANALYTIX, 2016). Our best model, XGBoost, when trained on 70,000 flights, achieved an AUC score of 68.1%. Interestingly enough, **this result is competitive with the top submissions in the competition, and would have achieved a rank of 19th out of 664 submissions**, where the winning solution achieved an AUC score of 70.9%. Although the data we used and the data the competition provided came from the same source and included similar features, (BUREAU OF TRANSPORTATION  STATISTICS, 2018), the data used in the competition was from the year 2014 to 2015. Therefore, this comparison can only be taken with a pinch of salt. Nevertheless, it shows that the results of our work are competitive and further improvements could still be made by engineering better features and trying different ensembles or methods.

Although optimising models is an imperative aspect of a data mining task, we also developed a functional implementation of our predictive model.  This guided our choice of features to only those that could be inputted by a user or computed at the time of booking a flight, which could be months in advance.  Using only these limited features, we were able to develop a data mining model trained on 2017 data that is capable of correctly classifying 62.2% of flights.  This model was then integrated into a flight delay system in R that produces plots of predicted delays for the relevant airlines for a flight of interest.  The output plot, which can be generated at the time of booking a flight, enables the user to easily compare which airlines are likely to have flight delays.  Further possibilities exist to enhance the model’s predictive ability, adjust the format of the output, and to deploy the model into more refined flight search tools. 
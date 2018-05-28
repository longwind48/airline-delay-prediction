# us_airline_delay_prediction_

something

### Methodology



![flow_chart](summarytable.png)



We first used univariate and multivariate analysis to examine the dataset, revealing the class imbalance problem. Then, to prepare the data for model building, we created four separate data sets to evaluate the effectiveness of three different resampling approaches to solve the class imbalance problem. To reach the best predicting power, we experimented with several learning methods, and we also normalized numerical variables when appropriate for the method. Considering both the success metrics and running time, we narrowed down to 5 main methods: 

- Logistic Regression
- Linear Discriminant Analysis (LDA)
- Classification and Regression Trees (CART)
- Tree Boosting (C5.0)
- Stacking

The predicting ability of our model has the potential application to improve the efficiency of a social welfare system where the government needs to allocate subsidies to those in the greatest need.    

------

### Summary and Interpretation of Results

The following table shows a list of the well-performing classifiers we evaluated with the best model in each method, or local optimal model, highlighted with a darker colour hue. All running times are for when the code was run on an Intel(R) Core(TM) i7-7700HQ Lenovo laptop, with 16GB of RAM.    

![model_sumary_table]()
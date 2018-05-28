# this analysis is usually based on traindf.unprocessed: 70% of original dataset
univariateAnalysis <- function(data) {
  # Reference: https://www.kaggle.com/notaapple/detailed-exploratory-data-analysis-using-r
  plotHist <- function(data_in, i) {
    data <- data.frame(x=data_in[[i]])
    p <- ggplot(data=data, aes(x=factor(x))) + stat_count() + xlab(colnames(data_in)[i]) + theme_light() + 
      theme(axis.text.x = element_text(angle = 90, hjust =1))
    return (p)
  }
  
  plotDen <- function(data_in, i){
    data <- data.frame(x=data_in[[i]], delay_groups = data_in$DELAY_GROUPS)
    p <- ggplot(data= data) + geom_line(aes(x = x), stat = 'density', size = 1,alpha = 1.0) +
      xlab(paste0((colnames(data_in)[i]), '\n', 'Skewness: ',round(skewness(data_in[[i]], na.rm = TRUE), 2))) + theme_light() 
    return(p)
  }
  
  doPlots <- function(data_in, fun, ii, ncol=3) {
    pp <- list()
    for (i in ii) {
      p <- fun(data_in=data_in, i=i)
      pp <- c(pp, list(p))
    }
    do.call("grid.arrange", c(pp, ncol=ncol))
  }
  
  # x.1 Create Histograms and Kernel density plots for each numerical feature
  doPlots(data, fun = plotDen, ii = 1:3, ncol = 2)
  doPlots(data, fun = plotDen, ii = 8:12, ncol = 2)
  doPlots(data, fun = plotDen, ii = 13:17, ncol = 2)
  doPlots(data, fun = plotHist, ii = 8:9, ncol = 1)
  
  #normality test on ARR_DELAY
  install.packages("nortest")
  library(nortest)
  ad.test(data$ARR_DELAY)
  cvm.test(data$ARR_DELAY)
  
  # x.2 Create barplots for each categorical feature
  doPlots(data, fun = plotHist, ii = 5, ncol = 1)
  doPlots(data, fun = plotHist, ii = 20, ncol = 1)
  
  # x.3 Day_of_month fluctuation
  hist(data$DAY_OF_MONTH, breaks = 30,xlim = c(0,30))
  
  # x.4 Month fluctuation
  hist(data$MONTH, breaks = 12,xlim = c(0,12))
}


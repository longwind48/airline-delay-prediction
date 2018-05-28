# Cleaning Data
clean <- function(data) {
  # Remove rows with missing ARR_DELAY and CRS_ELAPSED_TIME values
  data <- data %>% 
    filter(!is.na(ARR_DELAY)) %>%
    filter(!is.na(DEP_TIME_BINS))  %>%
    filter(!is.na(ARR_TIME_BINS)) %>%
    filter(DIVERTED==0) %>%
    filter(CANCELLED==0)
}

#describe(data)

# Handling missing data
#colSums(sapply(dataset, is.na))
# -> There are 10372 rows with missing ARR_DELAY values.
# -> Action? Since 10372 rows is just 2.3% of the total number of rows, we can remove the rows with missing values

# Visualisation of missing data
# plot_Missing <- function(data_in, title = NULL){
#   temp_df <- as.data.frame(ifelse(is.na(data_in), 0, 1))
#   temp_df <- temp_df[,order(colSums(temp_df))]
#   data_temp <- expand.grid(list(x = 1:nrow(temp_df), y = colnames(temp_df)))
#   data_temp$m <- as.vector(as.matrix(temp_df))
#   data_temp <- data.frame(x = unlist(data_temp$x),
#                           y = unlist(data_temp$y),
#                           m = unlist(data_temp$m))
#   ggplot(data_temp) + geom_tile(aes(x=x, y=y, fill=factor(m))) + scale_fill_manual(values=c("white", "black"),name="Missing\n(0=Yes, 1=No)") + theme_light() + ylab("") + xlab("") + ggtitle(title)
# }


#plot_Missing(dataset[,(colSums(is.na(dataset)) > 0)], title = "Missing Values")
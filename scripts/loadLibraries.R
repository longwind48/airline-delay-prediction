# Load libraries
listOfLibrariesToLoad <- c('dplyr',
                           'Hmisc',
                           'ggplot2',
                           'ggmap',
                           'igraph',
                           'ggplot2',
                           'lattice',
                           'OpenStreetMap',
                           'GoodmanKruskal',
                           'caret',
                           'ROCR',
                           'corrplot',
                           'ggthemes',
                           'tictoc',
                           'MASS',
                           'caTools',
                           'xgboost',
                           'Matrix',
                           'MLmetrics',
                           'doParallel',
                           'bst',
                           'RSNNS',
                           'caret',
                           'caretEnsemble',
                           'ROCR',
                           'timeDate',
                           'gridExtra',
                           'nortest',
                           'DMwR',
                           'C50')


sapply(listOfLibrariesToLoad, require, character = TRUE)

# Function to install missing packages
ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}

ipak(listOfLibrariesToLoad)
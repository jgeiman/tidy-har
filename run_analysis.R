# Scripts to tidy Human Activity Recognition (HAR) data from smartphones.
# Written by Justin Geiman, April 2016

# The principles of tidy data were outlined by Hadley Wickham in the following paper:
#     http://vita.had.co.nz/papers/tidy-data.pdf) 

# The original data set for this analysis is from the 'Human Activity Recognition 
# Using Smartphones Data Set' from the UCI Machine Learning Repository: 
# http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones) 

# See `codebook.md` for description of variables, code usage, and additional details.

library(dplyr)
library(tidyr)

# Download and extract the original data from the zip file
download.data <- function() {
    # create a directory for the data
    if (!file.exists('./data')) {dir.create('./data')}

    # url of the file to download
    file.url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'

    # local file name
    zip.file <- file.path('data', 'UCI-HAR-Dataset.zip')

    if (!file.exists(zip.file)) {
        # download the zip file
        download.file(file.url, destfile = zip.file , method = 'curl')
        # extract the zip file into the data directory
        unzip(zip.file, exdir = './data')
    }

    # return the path to the data files
    data.path <- file.path('data','UCI HAR Dataset')
    data.path
}

# Load all the features from the training & test data sets into a data frame
load.features <- function(data_path){
    # load feature names from features.txt
    col_names <- read.table(file.path(data_path, 'features.txt'))
    col_names <- col_names[,2]
    #col_names <- fixFeatureNames(col_names[,2])
    
    # grep for features names that include mean or std -- keep only these cols
    keep <- grep('mean\\(|std\\(', col_names)

    # load the features from the training dataset    
    train <- read.table(file.path(data_path, 'train', 'X_train.txt'), 
                        col.names = col_names)

    # load the features from the test dataset
    test <- read.table(file.path(data_path, 'test', 'X_test.txt'), 
                       col.names = col_names)
    
    # combine test and training data sets using rbind
    features <- rbind(train, test)
    
    # create a subset of desired columns    
    features <- features[, keep]

    # add sample numbers to maintain row numbers of features
    features$sample <- 1:nrow(features)
    
    # return the combined features dataframe
    features
}

# Load all the activity labels from the training & test data sets into a vector
load.labels <- function(data_path){

    # create a vector of column names
    cols <- c('ActivityID','Activity')

    # load the labels from the training dataset    
    train <- read.table(file.path(data_path, 'train', 'y_train.txt'),
                        col.names = cols[1])
    
    # load the labels from the test dataset 
    test <- read.table(file.path(data_path, 'test', 'y_test.txt'),
                       col.names = cols[1])
    
    # combine test and training data sets using rbind
    labels <- rbind(train, test)
    
    # load the activity labels
    activities <- read.table(file.path(data_path, 'activity_labels.txt'),
                             col.names = cols)
    
    # create a subset of desired columns    
    activities <- merge(labels, activities)
    
    # return the vector of activities
    activities$Activity
}

# Load all the subjects from the training & test data sets into a data frame
load.subjects <- function(data_path) {
    
    # create a vector of column names
    cols <- c('Subjects')
    
        # load the labels from the training dataset    
    train <- read.table(file.path(data_path, 'train', 'subject_train.txt'),
                        col.names = cols)
    
    # load the labels from the test dataset 
    test <- read.table(file.path(data_path, 'test', 'subject_test.txt'),
                       col.names = cols)
    
    # combine test and training data sets using rbind
    subjects <- rbind(train, test)
    
    subjects    
}

# make the provided HAR data set tidy
tidy.har <- function(df) {
    # Steps to make the data set tidy:
    #  1. Use gather to make all the 'feature' columns into rows by moving the column name 
    #     into a new measurement column, and the column value into a value column.
    #  2. Use separate to split the measurement column into three columns
    #     (measurement, statistic, & direction), based on non-alphanumeric characters
    #  3. Use separate again to split the measurement column into two columns
    #     (measurement & domain). domain is indicated by first character.
    #  4. Use spread to combine rows containing the same information other than statistic.
    #     This creates two new columns (mean and std)
    #  5. Substitute the single characters in domain with the full word (time or frequency)
    
    tidy <- df %>%
        gather(measurement, value, -subject,-activity, -sample) %>%
        separate(measurement, into=c('measurement','statistic','direction')) %>%
        separate(measurement, into=c('domain','measurement'), sep=1) %>%
        spread(statistic, value) #%>%
        
    tidy$domain <- gsub('t','TIME', tidy$domain)
    tidy$domain <- gsub('f','FREQUENCY', tidy$domain)
    
    tidy
}

# create a new tidy data set with average values for each variable grouped by 
# subject and activity
subject.averages <- function(df){
    group_means <- df %>%
                    group_by(subject, activity, domain, measurement, direction) %>%
                    summarize(mean = mean(mean), std = mean(std))
    group_means
}

# Perform all steps necessary to create tidy data from the original HAR data set 
runAnalysis <- function(data.path = '') {

    if (data.path == '') {
        # download the original data and unzip
        data.path <- download.data()
    }
    
    # load the necessary data files
    features <- load.features(data.path)
    activities <- load.labels(data.path)
    subjects <- load.subjects(data.path)
    
    # combine the dataframes (by column)
    data <- cbind(subjects, activities, features)
    names(data)[1:2] <- c('subject','activity')

    # create a tidy dataset
    tidy <- tidy.har(data)
    
    # compute averages for each subject and activity
    grouped <- subject.averages(tidy)

    # create a list of the result data frames    
    results <- list(tidy, grouped)
    names(results) <- c('tidy','grouped')

    results    
}

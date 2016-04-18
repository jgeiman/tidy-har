# Code Book for tidy-har
This code book describes the variables, the data, and transformations used to clean up and create a tidy data set for analysis based on the data from the **Human Activity Recognition Using Smartphones Data Set** from the UCI Machine Learning Repository:

<http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones>

## Experiment Summary
*The following is an excerpt provided with the original data:*

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. 

*See README.txt in the original data set for additional information.*

## Variables

The data set output from tidy-har contains the following variables:

 - **subject**: Identifier for each subject in the experiment. Integer with values ranging from 1-30.

 - **activity**: Description of activity performed by subject. Factor with six levels: LAYING, SITTING, STANDING, WALKING, WALKING_DOWNSTAIRS, WALKING_UPSTAIRS

 - **sample**: Identifier for the sample. Integer with values from 1 - 10299.  

 - **domain**: Description of signal domain. Factor with two (2) levels: TIME, FREQUENCY.  
 
 - **measurement**: Sensor measurement. Character string with one of 13 values:
      1. BodyAcc
      2. BodyAccJerk         
      3. BodyAccMag
      4. BodyBodyAccJerkMag 
      5. BodyBodyGyroJerkMag
      6. BodyBodyGyroMag     
      7. BodyGyro
      8. BodyAccJerkMag     
      9. BodyGyroJerk
      10. BodyGyroJerkMag
      11. BodyGyroMag         
      12. GravityAcc         
      13. GravityAccMag

 - **direction**: Axial direction for the signal (if applicable). Factor with three (3) levels: X, Y, Z

 - **mean**: mean value of the sensor signal. Values are normalized and bounded within [-1,1]

 - **std**: standard deviation of the sensor signal. Values are normalized and bounded within [-1,1]

-----

## Code

### Usage
All cleaning and tidying operations are done by the **runAnalysis** function in run_analysis.R. 

To download the original data set and tidy the data, call the **runAnalysis** function  using the following code:

```
# Download data (if it doesn't already exist) and create a tidy data set
results <- runAnalysis() 
```

To skip the download of the original data set, provide the path to the data set to the **runAnalysis** function: 

```
# Create a tidy data set only (no download)
data.path <- file.path('path', 'to', 'data')
results <- runAnalysis(data.path) 
```

-----

The output of the **runAnalysis** function is a list containing two data frames:

 - **tidy**: Data frame containing the tidy data set

 - **grouped**: Data frame containing the tidy data set containing average values of each variable when grouped by subject and activity.

To write the tidy data set to a CSV file named 'tidy-har.csv', use the following code:

```
write.csv(results$tidy, file = "tidy-har.csv", row.names = FALSE)
```

-----

### Function List

The following functions are provided in **run_analysis.R**:

`download.data`: Downloads and extracts the original data from a zip file.

- Arguments: None
- Returns: Path to the downloaded data set

`load.features`: Loads all the features from the training & test data sets into a data frame. 

 - Arguments: data_path - path to original data set
 - Returns: Data frame of features
 - *NOTE: Only loads features related to mean and std of sensor measurements.* 

`load.labels`: Loads all the activity labels from the training & test data sets into a data frame. 

 - Arguments: data_path - path to original data set
 - Returns: Character Vector of activities
 
`load.subjects`: Loads all the subjects from the training & test data sets into a data frame. 

 - Arguments: data_path - path to original data set
 - Returns: Data frame of subject identifiers

`tidy.har`: Makes the HAR data set tidy

 - Arguments: df - Data frame containing HAR data
 - Returns: Tidy data frame
 - Steps taken to make the data set tidy:
    1. Use `gather` to make all the feature columns into rows by moving the column name into a new measurement column, and the column value into a value column.
    2. Use `separate` to split the measurement column into three columns (measurement, statistic, & direction), based on non-alphanumeric characters
    3. Use `separate` again to split the measurement column into two columns (measurement & domain). domain is indicated by first character.
    4. Use `spread` to combine rows containing the same information other than statistic. This creates two new columns (mean and std)
    5. Substitute the single characters in domain with the full word (time or frequency)

`subject.averages`: Creates a new tidy data set with average values for each variable grouped by subject and activity

 - Arguments: df - Data frame containing tidy HAR data
 - Returns: Data frame containing group averages

`runAnalysis`: Performs all steps necessary to create two tidy data sets from the original HAR data set, with and without group averaging by subject and activity. 

 - Arguments: data.path (Optional) - path to existing HAR data set, if exists
 - Returns: List containing two data frames (tidy & grouped) 
 - Steps in analysis:
    1. Download the original HAR data and unzip the files (if needed)
    2. Load the necessary data files into a data frame (un-tidy)
    3. Create a a tidy HAR data set
    4. Create a new tidy HAR data set containing averages for each subject and activity

For additional information on the processing steps taken by each function, comments are provided throughout **run_analysis.R** 

-----

### Dependencies
The following libraries are used by tidy-har:

 - [dplyr](https://cran.r-project.org/web/packages/dplyr/index.html)

 - [tidyr](https://cran.r-project.org/web/packages/tidyr/index.html)
 
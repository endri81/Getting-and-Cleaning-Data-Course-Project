# R script called run_analysis.R that does the following:
# 
# 1. Merges the training and the test sets to create one data set.
#
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
#
# 3. Uses descriptive activity names to name the activities in the data set
# 
# 4. Appropriately labels the data set with descriptive variable names.
#
# 5. From the data set in step 4, creates a second, independent tidy data set 
#    with the average of each variable for each activity and each subject.



# ------------------------------------
## Load required libraries
# tidyverse for creating tidy data
if (!require("tidyverse")) install.packages("tidyverse")
# dataMaid for creating codebook
if (!require("dataMaid")) install.packages("dataMaid")
library(tidyverse)
library(dataMaid)


# Let's start with data download

filename <- "getdata_projectfiles_UCI HAR Dataset.zip"

# Controll for already existing files
# If folder doesn't exist proceed with download
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename, method="curl")
}  

#If folder exists proceed with unzip
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Now we read data frames

# From folder UCI HAR Dataset
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("id","features"))
activities <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))

# From folder UCI HAR Dataset/train
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
Y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "code")
X_train <- read.table('UCI HAR Dataset/train/X_train.txt', col.names = features$features)

# From folder UCI HAR Dataset/test
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
X_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$features)
Y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "code")


# Task 1 Mergin the training and the test sets to create one data set.

# We merge X_train with X_test by rows
Merged_X <- rbind(X_train, X_test)

# We merge Y_train with Y_test by rows
Merged_Y <- rbind(Y_train, Y_test)

# We merge subject_train  with subject_test
Merged_S <- rbind(subject_train, subject_test)
Merged_Data <- cbind(Merged_X, Merged_Y, Merged_S)


## Task 2 Extracts only the measurements on the mean 
## and standard deviation for each measurement.

dat <- Merged_Data %>% select(code, subject,contains("mean"), contains("std"))

# Task 3 Uses descriptive activity names to name the activities in the data set

# Here we recode and convert 'code' column from integer to factor
dat$code <- factor(dat$code, labels=c("Walking","Walking Upstairs", 
"Walking Downstairs", "Sitting", "Standing", "Laying"))


# Task 4 Appropriately labels the data set with descriptive variable names.
names(dat)<-gsub("^t", "time", names(dat))
names(dat)<-gsub("^f", "frequency", names(dat))
names(dat)<-gsub("Acc", "Accelerometer", names(dat))
names(dat)<-gsub("Gyro", "Gyroscope", names(dat))
names(dat)<-gsub("Mag", "Magnitude", names(dat))
names(dat)<-gsub("BodyBody", "Body", names(dat))

# Task 5. From the data set in step 4, creates a second, independent tidy data set 
#    with the average of each variable for each activity and each subject.

FinalTidyData <- aggregate(. ~subject + code, dat, mean)
FinalTidyData <- FinalTidyData[order(FinalTidyData$subject,FinalTidyData$code),]
write.table(FinalTidyData, file = "finaltidydata.txt",row.name=FALSE)


## Finally we create codebook
makeCodebook(FinalTidyData)


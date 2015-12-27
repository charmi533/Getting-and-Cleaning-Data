#Basic assumption : The zip file (https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) is downloaded and extracted in the R Home Directory

#Loading libraries
library(data.table)
library(dplyr)

#Read Supporting Metadata
featureNames <- read.table("UCI HAR Dataset/features.txt")
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE)

#Format train data
#The data is split up into subject, activity and features

#Read train data
subjectTrn <- read.table("UCI HAR Dataset/train/subject_train.txt", header = FALSE)
activityTrn <- read.table("UCI HAR Dataset/train/y_train.txt", header = FALSE)
featuresTrn <- read.table("UCI HAR Dataset/train/X_train.txt", header = FALSE)

#Read test data
subjectTst <- read.table("UCI HAR Dataset/test/subject_test.txt", header = FALSE)
activityTst <- read.table("UCI HAR Dataset/test/y_test.txt", header = FALSE)
featuresTst <- read.table("UCI HAR Dataset/test/X_test.txt", header = FALSE)


#Part1 - Merge the training and the test sets to create one data set
subject <- rbind(subjectTrn, subjectTst)
activity <- rbind(activityTrn, activityTst)
features <- rbind(featuresTrn, featuresTst)

#Name the column names from the features file in variable featureNames
colnames(features) <- t(featureNames[2])

#Add activity and subject as a column to features
colnames(activity) <- "Activity"
colnames(subject) <- "Subject"
Data <- cbind(features,activity,subject)

#Part2 - Extracts only the measurements on the mean and standard deviation for each measurement
featureNames <- featureNames[grep("(mean|std)\\(", featureNames[,2]),]
mean_and_std <- Data[,featureNames[,1]]
extractData <- cbind(mean_and_std, Data$Activity, Data$Subject)
colnames(extractData)[67] <- "Activity"
colnames(extractData)[68] <- "Subject"

#Part3 - Uses descriptive activity names to name the activities in the data set

#Set activity variable as character
extractData$Activity <- as.character(extractData$Activity)
for (i in 1:6){
  extractData$Activity[extractData$Activity == i] <- as.character(activityLabels[i,2])
}
#Set the activity variable in the data as a factor
extractData$Activity <- as.factor(extractData$Activity)

#Part4 - Appropriately labels the data set with descriptive variable names

#Acc can be replaced with Accelerometer
#Gyro can be replaced with Gyroscope
#BodyBody can be replaced with Body
#Mag can be replaced with Magnitude
#Character 'f' can be replaced with Frequency
#Character 't' can be replaced with Time

names(extractData)<-gsub("Acc", "Accelerometer", names(extractData))
names(extractData)<-gsub("Gyro", "Gyroscope", names(extractData))
names(extractData)<-gsub("BodyBody", "Body", names(extractData))
names(extractData)<-gsub("Mag", "Magnitude", names(extractData))
names(extractData)<-gsub("^t", "Time", names(extractData))
names(extractData)<-gsub("^f", "Frequency", names(extractData))
names(extractData)<-gsub("tBody", "TimeBody", names(extractData))
names(extractData)<-gsub("-mean()", "Mean", names(extractData), ignore.case = TRUE)
names(extractData)<-gsub("-std()", "STD", names(extractData), ignore.case = TRUE)
names(extractData)<-gsub("-freq()", "Frequency", names(extractData), ignore.case = TRUE)
names(extractData)<-gsub("angle", "Angle", names(extractData))
names(extractData)<-gsub("gravity", "Gravity", names(extractData))

#Part5 - From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject
extractData$Subject <- as.factor(extractData$Subject)
extractData <- data.table(extractData)

tidyData <- tidyData[order(tidyData$Subject,tidyData$Activity),]

#Write tidy data to the file
write.table(tidyData, file = "Tidy.txt", row.names = FALSE)

tidyData <- aggregate(. ~Subject + Activity, extractData, mean)
## CODEBOOK for run_analysis.R:
## Description of the original data (per the README document from the UCI HAR Dataset):
The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers were selected for generating the training data and 30% the test data. 
The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain. See 'features_info.txt' for more details. 
## For each record it is provided:
======================================
- Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
- Triaxial Angular velocity from the gyroscope. 
- A 561-feature vector with time and frequency domain variables. 
- Its activity label. 
- An identifier of the subject who carried out the experiment.

## The dataset includes the following files and variables of interest:
- 'features_info.txt': Shows information about the variables used on the feature vector.
- 'features.txt': List of all features.
- 'activity_labels.txt': Links the class labels with their activity name.
- 'train/X_train.txt': Training set.
- 'train/y_train.txt': Training labels.
- 'test/X_test.txt': Test set.
- 'test/y_test.txt': Test labels.

## Descriptions of the variables of interest:
1. 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 
2. 'train/Inertial Signals/total_acc_x_train.txt': The acceleration signal from the smartphone accelerometer X axis in standard gravity units 'g'. Every row shows a 128 element vector. The same description applies for the 'total_acc_x_train.txt' and 'total_acc_z_train.txt' files for the Y and Z axis. 
3. 'train/Inertial Signals/body_acc_x_train.txt': The body acceleration signal obtained by subtracting the gravity from the total acceleration. 
4. 'train/Inertial Signals/body_gyro_x_train.txt': The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second.
5. 'activity_labels.txt': Links the class labels with their activity name.
6. 'features_info.txt': Shows information about the variables used on the feature vector.
7. 'features.txt': List of all features.

##DATA SET COMPILATION

##1 - Merge the training and test sets to create one set.

Create the directory, if it doesn't already exists.
Download the file from the website.
Unzip the file and list the files.
Organize the data into usable information
datapath <- file.path("./getdata" , "UCI HAR Dataset")
files<-list.files(datapath, recursive=TRUE)
files

Read the files into the variables of interest.

Y_Test  	SubjectTrain	X_Test  
Y_Train	SubjectTest	X_Train 

RBind the similar rows together. 
Y_Value <- rbind(Y_Test, Y_Train)
SubjectValues <- rbind(SubjectTrain, SubjectTest)
X_Value <- rbind(X_Test, X_Train)

Create the variable names for the new data table.
names(Y_Value) <- c("Activity")
names(SubjectValues) <- c("Subject")
FeatureNames <- read.table(file.path(datapath, "features.txt"),head=FALSE)
names(X_Value) <- FeatureNames[,2]

Merge (or bind) the columns to create a new data set labeled All_Data

combine <- cbind(SubjectValues, Y_Value)
All_Data <- cbind(combine, X_Value)

##2 - Extract only the measurments on the mean and sd for each measurement.

Extract only the mean and SD for each measurement using grep.
subset1 <- FeatureNames[,2][grep("mean\\(\\)|std\\(\\)", FeatureNames$V2)]

Further subsetting required for Subject and Activity.
subset2 <-c("Subject", "Activity", as.character(subset1))
Data<-subset(All_Data, select=subset2)

##3 - Uses descriptive activity names to name the activities in the data set.

Create a table that adds the descriptive names.
labels  <- read.table(file.path(datapath, "activity_labels.txt"),header = FALSE)
names(labels) <- c("Activity", "Activity_Name")
Data <- merge(Data, labels, by="Activity", all.x=TRUE)

##4 - Appropriately label the data set with descriptive variable names.

Label the variables with the appropriate names.
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

##5 - Creating a Tidy Data Set.

Create a second independent tidy data set with the average of each variable 
for each activity and each subject.
library(plyr)
finaldata <- aggregate(. ~Subject + Activity_Name, Data, mean)
finaldata <- finaldata[order(finaldata$Subject, finaldata$Activity_Name), ]
write.table(finaldata, file = "./tidydata.txt", row.names=FALSE, quote = FALSE)

##Final output should be a table with 180 observations and 69 variables.


#1 - Merge the training and test sets to create one set.

#Create the directory, if it doesn't already exists.

if(!file.exists("./getdata")){
            dir.create("./getdata")}

#Download the file from the website.

urlfile<- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(urlfile, destfile = "./getdata.zip")

# Unzip the file and list the files.

unzip("getdata.zip", list=TRUE)

# to organize the data into usable information
datapath <- file.path("./getdata" , "UCI HAR Dataset")
files<-list.files(datapath, recursive=TRUE)
files

# Read the files into the variables of interest.

Y_Test  <- read.table(file.path(datapath, "test" , "Y_test.txt" ),header = FALSE)
Y_Train <- read.table(file.path(datapath, "train", "Y_train.txt"),header = FALSE)

SubjectTrain <- read.table(file.path(datapath, "train", "subject_train.txt"),header = FALSE)
SubjectTest  <- read.table(file.path(datapath, "test" , "subject_test.txt"),header = FALSE)

X_Test  <- read.table(file.path(datapath, "test" , "X_test.txt" ),header = FALSE)
X_Train <- read.table(file.path(datapath, "train", "X_train.txt"),header = FALSE)

# RBind the similar rows together. 

Y_Value <- rbind(Y_Test, Y_Train)
SubjectValues <- rbind(SubjectTrain, SubjectTest)
X_Value <- rbind(X_Test, X_Train)

# Create the variable names for the new data table.
names(Y_Value) <- c("Activity")
names(SubjectValues) <- c("Subject")
FeatureNames <- read.table(file.path(datapath, "features.txt"),head=FALSE)
names(X_Value) <- FeatureNames[,2]

# Merge (or bind) the columes to create a new data set labeled All_Data

combine <- cbind(SubjectValues, Y_Value)
All_Data <- cbind(combine, X_Value)

#2 - Extract only the measurments on the mean and sd for each measurement.

# Extract only the mean and SD for each measurement using grep.
subset1 <- FeatureNames[,2][grep("mean\\(\\)|std\\(\\)", FeatureNames$V2)]

# Further subsetting required for Subject and Activity.
subset2 <-c("Subject", "Activity", as.character(subset1))
Data<-subset(All_Data, select=subset2)

#3 - Uses descriptive activity names to name the activities in the data set.

# Create a table that adds the descriptive names..
labels <- read.table(file.path(datapath, "activity_labels.txt"),header = FALSE)
names(labels) <- c("Activity", "Activity_Name")
Data <- merge(Data, labels, by="Activity", all.x=TRUE)

#4 - Appropriately label the data set with descriptive variable names.

# Label the variables with the appropriae names.
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

#5 - Creating a Tidy Data Set.

# Create a second independent tidy data set with the average of each variable 
# for each activity and each subject.
library(plyr)
finaldata <- aggregate(. ~Subject + Activity_Name, Data, mean)
finaldata <- finaldata[order(finaldata$Subject, finaldata$Activity_Name), ]
write.table(finaldata, file = "./tidydata.txt", row.names=FALSE, quote = FALSE)




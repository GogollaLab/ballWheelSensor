library(plyr) #conditional replacement of values, revaluing
library(reticulate) #interface with Python to run the data cleaning script





#SET CORRECT PATH TO cleanBallData_r1.py below before first use and save, only needed once. CRUCIAL
#ensure to use forward slashes in all paths! (/) 
pathTo_cleanBallData_r1_py = "C:/Users/nd.../cleanBallData_r1.py"


acqFreq <- 62.5 #acquisition frequency of the ball sensor; DEFAULT IS 62.5, keep if mouse polling was NOT manually changed in Linux/RPi
binsPerSecond <- 10 #define the desired number of bins per second



#in RStudio use Session/Set Working Directory/Choose Directory... to set the working directory to
#location of your unprocessed mouse sensor .txt files.
#in VSCode (or command line or similar) use the setwd("path") command before running the script 
#with "path" replaced with the path to the folder containing unprocessed mouse sensor .txt files


#run the whole script! pressing "run" in RStudio will ONLY run the current line by default!
#you can select whole file by pressing ctrl+A and run the selection by pressing ctrl+enter






ballSensorProcess <- function(filename) {
  data <- read.table(paste0("cl/", filename))
  
  
  
  
  
  
  
  #for direction and velocity only the 3,4,5,6 positions are relevant, that is columns V4, V5, V6, V7
  data <- data[,-(2:3)] #remove V2, V3
  data <- data[,-(6:7)] #remove V7, V8
  
  colnames(data) <- c("time", "LRvel", "LR", "UDvel", "UD")
  
  #remove all rows containing any wrong value - corrupted recording
  test1 <- table(data$UD)
  lenTest1 <- length(test1)
  test1names <- dimnames(test1)
  
  #if more than 2 values (0, 255) in data, remove all rows with those vals
  if(lenTest1 > 2){
    for(i in 2:(lenTest1 - 1)){
      temp1 <- as.numeric(test1names[[1]][[i]])
      
      wrong1 <- subset(data, UD == temp1)
      wrong2 <- as.numeric(row.names(wrong1))
      
      data <- data[-c(wrong2),]
      
      rownames(data) <- seq(length=nrow(data)) #reset row names (numbers) 
      
    }
  }
  
  test1 <- table(data$LR)
  lenTest1 <- length(test1)
  test1names <- dimnames(test1)
  
  #if more than 2 values (0, 255) in data, remove all rows with those vals
  if(lenTest1 > 2){
    for(i in 2:(lenTest1 - 1)){
      temp1 <- as.numeric(test1names[[1]][[i]])
      
      wrong1 <- subset(data, LR == temp1)
      wrong2 <- as.numeric(row.names(wrong1))
      
      data <- data[-c(wrong2),]
      
      rownames(data) <- seq(length=nrow(data)) #reset row names (numbers) 
      
    }
  }
  
  rownames(data) <- seq(length=nrow(data)) #reset row names (numbers) 
  
  #inspiration from: http://stackoverflow.com/questions/8214303/conditional-replacement-of-values-in-a-data-frame
  data$LRvel[data$LR == 255] <- mapvalues(data$LRvel[data$LR == 255], rev(1:255), c(1:255), warn_missing = FALSE)
  data$UDvel[data$UD == 255] <- mapvalues(data$UDvel[data$UD == 255], rev(1:255), c(1:255), warn_missing = FALSE)
  
  data1 <- data
  
  #transfort LR, UD values into more meaningful factors
  data1$LR <- as.factor(data1$LR)
  data1$UD <- as.factor(data1$UD)
  
  
  data1$LR <- revalue(data1$LR, c("255" = "L", "0" = "R"), warn_missing = FALSE)
  data1$UD <- revalue(data1$UD, c("255" = "U", "0" = "D"), warn_missing = FALSE)
  
  
  data1$dir <- paste0(data1$LR, data1$UD)
  data1$dir <- as.factor(data1$dir)
  
  #separate data by the axes - LR and UD are on the same axes, just moving in a differnt direction
  #instead always starting from 0, make negative vals for the opposite direction
  # U + / D - 
  # R + / L -
  data1$LRvel[data1$LR == "L"] <- data1$LRvel[data1$LR == "L"] * (-1)
  data1$UDvel[data1$UD == "D"] <- data1$UDvel[data1$UD == "D"] * (-1)
  
  #the vector of movement is the hypotenuse in a right-angled triangle with catheti of a and b (UDvel and LRvel for each timepoint)
  data1$hypo <- sqrt((data1$LRvel)^2 + (data1$UDvel)^2)
  
  #plot(data1$time, data1$hypo, type = "l")
  
  
  
  #binning
  binVar <- NULL
  timeStep <- 1/binsPerSecond
  for(i in seq(0, floor(max(data1$time)), timeStep)){
    bin1 <- subset(data1, time > i & time < (i + timeStep))
    mean1 <- sum(bin1$hypo)/(acqFreq/binsPerSecond)
    
    binVar$time[(i * binsPerSecond) + 1] <- i
    binVar$mean[(i * binsPerSecond) + 1] <- mean1
  }
  
  binVar <- data.frame(binVar)
  
  
  
  
  
  
  #write to file
  noExtFilename <- tools::file_path_sans_ext(filename) #remove extension from the filename
  noExtFilename <- substr(noExtFilename, 1, nchar(noExtFilename) - 3) #remove "_cl" from final filename
  outputFilename <- paste0("processed/", noExtFilename, "__binned_", binsPerSecond, "Hz")
  outputFilename <- paste(outputFilename, "txt", sep = ".")
  
  write.table(binVar, outputFilename, sep="\t", row.names = F, col.names = T)
}










dir.create("processed")

py_run_file(pathTo_cleanBallData_r1_py) 

files <- list.files("cl", pattern = "*.txt")

for(i in 1:length(files)){
  filename <- files[i]
  ballSensorProcess(filename)
}
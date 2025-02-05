############
# Author: Hermina
# Date: 19 Oct 23 (created version 3-1 to analyze OD only data)
# some functions for getting the data into R from the default H1 txt export format and other useful things to do on the data
############

# to do:
###########
# o extract the temperature data as a function of the time of day

require(tidyverse) # for tidy data & plotting
require(lubridate) # for time

# read the txt file and parse it into a data.frame
# this function is to be used with OD data only!
extract_OD_df <- function(filename) {
  lines <- readLines(filename) # get the entire file
  lines <- lines[-which(lines == "")] # remove the empty lines
  
  # get the starting time of the experiment from within the metadata that appears before the OD
  lines_metadata <- lines[(1:which(lines == "OD 600:600"))] # this is the lines of metadata
  start_time <- unlist(strsplit( lines_metadata[grepl("^Time", lines_metadata)], "\t"))[2] # find the line that starts with Time, string split it on tab, keep only the 2nd value
  
  # get the OD data
  lines <- lines[-(1:which(lines == "OD 600:600"))] # remove the experimental procedure details before the first read
  if(any(lines == "Blank OD 600:600")) { # check if there's baselined data included from the Gen5 output
    lines <- lines[-(which(lines == "Blank OD 600:600"):length(lines))] # remove any blank baselined OD data found at the end of the file
  }
  lines <- lines[!grepl("^0:00:00", lines)] # remove any empty data at the end
  # convert lines into a data.frame with the data
  df <- scan(text=lines, sep="\t", what=character(), quiet=TRUE) %>%
                matrix(., nrow=length(lines), ncol=96+2, byrow=TRUE) %>%
                      as.data.frame(stringsAsFactors=FALSE)
  df[1,2] <- "Temp" # replace this weird value with "Temp" because that's what it should be
  colnames(df) <- df[1,] # use the first row of df as the column names
  df <- df[-1,] # remove the first row of df because it is now redundant
  
  # return the values of interest
  return(list(start_time, df))
  # clear the workspace
  rm(lines, lines_metadata, start_time, df)
}

# reads and parses the text file into a dataframe of tidy data for point estimates over time, calling on relevant functions as necessary
# this function is to be used with OD data only!
get_OD_data <- function(filename) # name of txt file containing growth curve data goes here
{
  # load the data from the .txt file as a data.frame
  data_list <- extract_OD_df(filename)
  data_starttime <- data_list[[1]] # unpack the start time from the list
  data_df <- data_list[[2]] # unpack the data.frame of the data from the list
  
  # make a data.frame for the temperature data as a function of the time of day
  # CHECK OUT THIS RESOURCE FOR WORKING WITH DATES AND TIMES: https://r4ds.had.co.nz/dates-and-times.html
  
  # convert the time from hours:minutes:seconds into total hours
  data_df$Time <- sapply(data_df$Time,
                         function(x) as.numeric(hms(x))/(60*60))
  # now we can easily convert the whole data.frame to numeric
  data_df[] <- lapply(data_df, as.numeric)
  # convert Temp into the mean temperature across the run
  data_df$Temp <- round(mean(data_df$Temp), digits=2)
  # reshape the data to long format
  data_df <- pivot_longer(data_df, cols=!c("Time", "Temp"), names_to="Well", values_to="OD")
  
  return(data_df) # NEED TO RETURN THE TEMPERATURE DATAFRAME AS WELL!!
  
  # cleanup
  rm(data_list, data_starttime, data_df)
}

# a function to load OD data into a data.frame with temperature treatment as factor
get_ODdata_block <- function(blockID, # unique identifier for this block of experiments
                             filename_1,
                             filename_2="" # second file is optional
                             # by default filename_1 will be called plate 1 and filename_2 will be called plate 2
                      )
{
  # check inputs
  stopifnot(is.character(blockID))
  stopifnot(file.exists(filename_1))

  # open the first file and get the OD data from inside of it
  plate1 <- get_OD_data(filename_1)
  plate1$block <- blockID # annotate with the blockID and plate number
  plate1$plate <- 1
  
  # if there's a second file, load it and combine the 2 plates
  if(file.exists(filename_2)){
    # open the second file and  get the OD data from inside of it
    plate2 <- get_OD_data(filename_2)
    plate2$block <- blockID # annotate with the blockID and plate number
    plate2$plate <- 2 
    # combine the two plates in the block into a single data.frame
    the_data <- (rbind(plate1, plate2))
  }
  # if there's no second file, rename plate1 as the_data
  if(!file.exists(filename_2)){
    print(paste("Only loading 1 file for block", blockID))
    the_data <- plate1
  }

  # TO DO: extract the temperature data as a function of the time of day

  # replace the temperature data over time with a simple temperature treatment
    # get the mean temperature rounded to the nearest integer for each plate
  temp_Temp <- the_data %>% group_by(plate) %>% summarise(round(mean(Temp), digits=0)) %>% as.data.frame()
    # replace the data over time with the mean temperature of that plate
  for(i in 1:nrow(temp_Temp)){
    the_data$Temp[which(the_data$plate %in% temp_Temp[i,1])] <- temp_Temp[i,2]
  }
  # change temperature to a factor
  the_data$Temp <- as.factor(the_data$Temp)

  # return the data
  return(the_data)
}

# a function to annotate the dilution growth curves data
  # two layout options:
    # "checkerboard" is 2 samples, each with 3 replicates, laid out in a checkerboard pattern
    # "12columns" is 12 samples, each with 1 replicate, laid out in columns
    # "3x4columnes" is 4 samples, each with 3 replicates, laid out in columns
    # for both these default options, the top and bottom row (i.e., A & H) are all blank wells
  # the data is assumed to have a dilution series from 10^-1 to 10^-6
annotate_data <- function(the_data, layout=c("checkerboard", "12columns"), samples) {
  # check function inputs
  stopifnot(is.data.frame(the_data))
  layout <- match.arg(layout)
  stopifnot(is.character(samples))
  
  # specify the dilution series
  dilutions <- 10^(-1:-6)
    # for future versions of the code this can be made into an input

  # specify the checkerboard layout
  if(layout == "checkerboard"){
    # checkerboard can only have 2 samples
    stopifnot(length(samples)==2)
    # make a data frame with the checkerboard annotation
    annotation.df <- data.frame(Well = paste0(rep(LETTERS[1:8], each=12), rep(1:12, times=8)),
                                Sample = c(rep("BLK", 12),
                                           rep(c(rep(samples, times=6), rep(rev(samples), times=6)), times=3),
                                           rep("BLK", 12)),
                                Replicate = c(rep(NA, 12),
                                              rep(1:3, each=24),
                                              rep(NA, 12)),
                                Dilution = c(rep(NA, 12),
                                             rep(rep(c(dilutions, rev(dilutions)), each=2), times=3),
                                             rep(NA, 12)))
  }

  # specify the 12 columns layout
  if(layout == "12columns"){
    # 12columns can only have 12 samples
    stopifnot(length(samples)==12)
    # make a data frame with the 12columns annotation
    annotation.df <- data.frame(Well = paste0(rep(LETTERS[1:8], each=12), rep(1:12, times=8)),
                                Sample = c(rep("BLK", 12),
                                           rep(samples, times=6),
                                           rep("BLK", 12)),
                                Replicate = c(rep(NA, 12),
                                              rep(1, 72),
                                              rep(NA, 12)),
                                Dilution = c(rep(NA, 12),
                                             rep(dilutions, each=12),
                                             rep(NA, 12)))
  }

  # change Sample and Dilution to factors
  annotation.df$Sample <- as.factor(annotation.df$Sample)
  annotation.df$Dilution <- as.factor(annotation.df$Dilution)

  # return the annotated data
  return(inner_join(the_data, annotation.df, by="Well"))
}

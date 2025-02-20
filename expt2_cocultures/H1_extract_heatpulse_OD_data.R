############
# Author: Hermina
# Date: 28 Oct 24
#
# functions to parse OD raw data into R. These functions were modified from H1_extract_data_fun_v3-1.R
#
# input: 1 or more .txt raw OD data files exported from the BioTek Gen5 software
# output: parses the files into a long data.frame in R. Also adds some annotation to the wells
#
# extract_OD_df actually deals with the file. get_OD_annotated is a wrapper for the former workhorse function.
############

require(tidyverse) # for tidy data & plotting
require(lubridate) # for converting hours:minutes:seconds into minutes

# read the txt file and parse it into a data.frame
# this function is to be used with OD data only!
extract_OD_df <- function(filename) {
  # check input
  stopifnot(file.exists(filename))

  # read the file
  lines <- readLines(filename) # get the entire file
  lines <- lines[-which(lines == "")] # remove the empty lines
  # remove the experimental procedure details before the first read
  while(any(lines == "End Kinetic\t"))
      suppressWarnings(lines <- lines[-(1:which(lines == "End Kinetic\t"))])
  # remove any empty data at the end
  lines <- lines[!grepl("^0:00:00", lines)]

  rows <- setNames(c(NA, NA), c("ambient", "heat")) # initialize for storage
  # get the row number for ambient data
  if(any(lines == "OD 600:600")) { # ambient data identifier
    rows[1] <- which(lines == "OD 600:600")
  }
  # get the row number for heat data
  if(any(lines == "OD 600 heat:600")) { # heat data identifier
    rows[2] <- which(lines == "OD 600 heat:600")
  }
  rows <- na.omit(rows) # remove any NA values

  # abort if neither of the above lines are matched
  stopifnot(is.numeric(rows))

  # when the data is just at one temperature, we can readily parse it into a data.frame
  if(length(rows) == 1){
    df <- scan(text=lines[-rows], sep="\t", what=character(), quiet=TRUE) %>%
            matrix(., nrow=length(lines)-1, ncol=96+2, byrow=TRUE) %>%
              as.data.frame(stringsAsFactors=FALSE)
    # convert the first column from hours:minutes:seconds format simply into hours
    df$V1 <- sapply(df$V1,
                    function(x) as.numeric(hms(x))/(60*60))
  }

  # when the data is at two temperatures
  if(length(rows) == 2){
    rows <- sort(rows) # make sure 1st element is the earliest row
    # parse in the earliest time points
    df <- scan(text=lines[2:(rows[2]-1)], sep="\t", what=character(), quiet=TRUE) %>%
            matrix(., nrow=length(2:(rows[2]-1)), ncol=96+2, byrow=TRUE) %>%
              as.data.frame(stringsAsFactors=FALSE)
    # convert time to simple hours format
    df$V1 <- sapply(df$V1,
                    function(x) as.numeric(hms(x))/(60*60))

    # then parse in the next time points
    df2 <- scan(text=lines[(rows[2]+1):length(lines)], sep="\t", what=character(), quiet=TRUE) %>%
            matrix(., nrow=length((rows[2]+1):length(lines)), ncol=96+2, byrow=TRUE) %>%
              as.data.frame(stringsAsFactors=FALSE)
    # convert time to simple hours format
    df2$V1 <- sapply(df2$V1,
                    function(x) as.numeric(hms(x))/(60*60))

    # adjust the time of df2 to indicate that it happened subsequent to df
    df2$V1 <- df2$V1 + max(df$V1)

    # combine df and df2 into a single data.frame
    df <- rbind(df, df2)
    rm(df2) 
  }
  
  # rename the columns to correspond with the wells
  colnames(df) <- c("Time.hrs", "Temp.C", paste0(rep(LETTERS[1:8], each=12), rep(1:12)))
  df[] <- lapply(df, as.numeric) # convert the whole data.frame to numeric

  # reshape the data to long format
  df <- pivot_longer(df, cols=!c("Time.hrs", "Temp.C"), names_to="Well", values_to="OD")
  
  # return the values of interest
  return(df)
  # clear the workspace
  rm(lines, rows, df)
}

# a function that extracts the data along with the uniqID and Day from the filenames
# this is a wrapper for extract_OD_df
get_ODdata_serialbatch <- function(folder, # filepath folder with txt files from 1 time-series
                                   incubator, # must be either "Epoch" OR "H1"
                                   Date, # expected in the form YY-MM-DD
                                   heat) # must be one of 0, 6, 12, 24, or 48
{
  # check inputs
  stopifnot(file.exists(folder))
  stopifnot(is.character(incubator))
  stopifnot(incubator %in% c("H1", "Epoch"))
  stopifnot(is.numeric(heat))
  stopifnot(heat %in% c(0, 6, 12, 24, 48))

# the lines below got changed when the folder names got changed for the git repo
  # get the date from the folder name
  #informal_date <- str_split_i(folder, "/", 2)
  # convert the format of the date using a lookup table
  #dateLookUp <- data.frame(informal = c("2July24", "8July24", "5Aug24", "19Aug24"),
  #                         YYMMDD = c("24-07-02", "24-07-08", "24-08-05", "24-08-19"))
  # change the format of the date to YY-MM-DD
  #Date <- informal_date
  #Date[] <- dateLookUp$YYMMDD[match(informal_date, dateLookUp$informal)]

  # identify the text files
  files_v <- list.files(folder)
  files_v <- files_v[endsWith(files_v, ".txt")]

  # get the data from each text file by looping
  output.df <- data.frame()
  for(filename in files_v){
    # get the day from the filename
    Day <- substr(filename, 4, 4)

    # get the data from the file using the whole filepath
    data.df <- extract_OD_df(paste(folder, filename, sep="/"))

    # add Date, Day, and Incubator annotation
    output.df <- rbind(output.df,
                       data.frame(Date=Date, Day=Day, Incubator=incubator, Heat=heat,
                                  data.df))
  }

  # uniqID is just the Date, Incubator, and Well mashed together
  output.df <- output.df %>% unite(uniqID, c(Date, Incubator, Well), sep=" ", remove=FALSE) %>%
                  rename(OD_well=Well)
  # format columns to match annotation
  output.df$Day <- as.integer(output.df$Day)

  return(output.df)
  rm(informal_date, dateLookUp, Date, files_v, output.df, filename, Day, data.df)
}

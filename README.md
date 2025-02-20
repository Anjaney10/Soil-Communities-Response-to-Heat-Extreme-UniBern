# Xtreme_heat

# 1. Project title & abstract

Long exposure to extreme heat magnifies the decoupling between bacterial resistance and recovery.

Abstract coming soon.

# 2. Project description

This GitHub repository was created to facilitate the reproducibility of the scientific article listed above.

The pre-print manuscript will be available ... shortly.

The complete protocols, data, and analysis for the manuscript can be found here. The raw flow cytometry data can be found at ???this_link??? ... available shortly.

# 3. File structure

As detailed in the manuscript, the project is broken up into two experiments that are creatively called "Experiment I" and "Experiment II". This repository is laid out in the same way, with each experiment's main folder (prefixed "expt") containing dedicated subfolders for "protocols", "data", and any "old_files". The finalized code for the analysis and the manuscript figures are in the main experiment folders (along with any intermediate files outputted by the analysis scripts). The finalized code for the analysis is written in a notebook format and then typeset. The figures from the main text are outputted by these scripts in png format; the figures from the supplement can be found in the typeset notebooks.

The main folder for Experiment I is called "expt1_traits". The finalized analysis is found in the R Notebook called "thermal_performance_traits", which is available both as an RStudio file and a typeset html file (this html file contains figures for the supplement). As stated above, this main folder contains intermediate files outputted by the script: the png files for Figure 2 of the main text and intermediate data stored in an RData file. The "data" subfolder contains txt files with the OD data for the growth curves, one xlsx file with the plate reader calibration data, and two xlsx files with the CFU data. The "old_files" subfolder contains a more complete calibration of the microplate spectrophotometers (in the subsubfolder "calibration") and a preliminary analysis of the growth rate estimates as well as Anjaney Pandey's final presentation at the end of his internship (in the subfolder "TTD").

[ZACH: please update the paragraph below as appropriate to describe your code and data]
The main folder for Experiment II is called "expt2_cocultures". The finalized analyses are found in 2 R Notebooks called "main_expt--flow_cytometry_analysis" and "main_expt--OD_analysis". The 2 R Notebooks files with the prefix "main_expt--" are dependent on one another because they each create csv files with intermediate data that is used by the other (e.g., indicating well annotation, extinction, and contamination) ... this is annoying when running each of those scripts independently but if you just download the entire repository you should be fine. The main folder contains the png files for Figures 3-5 of the main text. The data for the serial transfer experiment contains csv files with the flow cytometry cell counts from FCS Express, xlsx files with the flow cytometry well volume from Attune, and txt files with the OD data; this data is found in subsubfolders with prefix "serial_transf--" and the date of each timeseries.

Finally, there is a main folder called "writing". Here you can find docx files as well as image files.

# 4. Credits for repository

For Experiment I: the growth curve protocol was co-written by Anjaney Pandey (AP) & Ana-Hermina Ghenu (AHG), the growth curve data was gathered by AP as supervised by AHG, the growth curve data was analyzed by AHG with input from AP. The CFU protocol, data, and analysis was done by AHG.

For Experiment II: the serial transfer protocol and data was done by AHG with help from Anine Wyser, and then analyzed by AHG. The protocol, data, and analysis of the spent media experiments was done by Zachary Bailey. 

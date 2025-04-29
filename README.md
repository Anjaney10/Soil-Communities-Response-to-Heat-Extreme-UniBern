# Xtreme_heat

# 1. Project title & abstract

## Title:

Longer heat pulses disrupt bacterial communities by decoupling resistance from recovery.

## Abstract:

Abstract coming soon.

# 2. Project description

This GitHub repository was created to facilitate the reproducibility of the scientific article listed above. As this article may currently be under double annonymous peer review, we have not yet included the pre-print link here.

The complete protocols, data, and analysis for the manuscript can be found here. The raw flow cytometry data for each of the 5 heat pulse durations can be found at these anonymous review links: https://figshare.com/s/d81c927071951ba776e7, https://figshare.com/s/4fbdd4550e7a16752044, https://figshare.com/s/183d7cb990b1e2ab76a8, https://figshare.com/s/cb37922b5ebabc628642,https://figshare.com/s/fd044109578f5c582c81

# 3. File structure

As detailed in the manuscript, the project is broken up into two experiments that are creatively called "Experiment I" and "Experiment II". This repository is laid out in the same way, with each experiment's main folder (prefixed "expt") containing dedicated subfolders for "protocols", "data", and any "old_files". The finalized code for the analysis and the manuscript figures are in the main experiment folders (along with any intermediate files outputted by the analysis scripts). The finalized code for the analysis is written in a notebook format (".Rmd" file extension) and then typeset (".html" file extension). The figures from the main text are outputted by these scripts in png format; the figures from the supplement can be found in the typeset notebooks.

## Experiment I

The main folder for Experiment I is called "expt1_traits". The finalized analysis is found in the R Notebook called "thermal_performance_traits". Its typeset html file contains figures that are found in the supplement. As stated above, this main folder contains intermediate files outputted by the script: the png files for Figure 2 of the main text and intermediate data stored in an RData file. The "./data" subfolder contains txt files with the OD data for the growth curves, one xlsx file with the plate reader calibration data, and two xlsx files with the CFU data. The "./old_files" subfolder contains a more complete calibration of the microplate spectrophotometers (in the subsubfolder "./old_files/calibration") and a preliminary analysis of the growth rate estimates as well as Anjaney Pandey's final presentation at the end of his internship (in the subfolder "./old_files/TTD").

## Experiment II

The main folder for Experiment II is called "expt2_cocultures". The finalized analyses are found in 2 R Notebooks called "main_expt--flow_cytometry_analysis" and "main_expt--OD_analysis". The raw data is found in the subfolder "./raw_data", intermediate data produced by the R Notebooks is in the subfolder "./intermediate_data", and png figures for Figures 3-5 of the main text are produced by the R Notebooks into the subfolder "./figures".

The 2 R Notebooks files with the prefix "main_expt--" are dependent on one another because they each create csv or RData files with intermediate data that is used by the other (e.g., indicating well annotation, extinction, and contamination). This is slightly annoying when running each of those scripts independently as you will need to run "main_expt--flow_cytometry_analysis.Rmd" first (it will run about 1/4 of the way before failing), then run "main_expt--OD_analysis.Rmd" (this will run completely without any issues), and finally you will be able to run "main_expt--flow_cytometry_analysis.Rmd" without any issues. But, if you simply download the entire git repository, you should be fine.

The subfolder "./raw_data" contains several subsubfolders that are prefixed with "serial_transf--" followed by a date (i.e., corresponding to the starting date of that experiment). This is the data for the serial transfer experiment: csv files with the flow cytometry cell counts from FCS Express, xlsx files with the flow cytometry well volume from Attune, and txt files with the OD data.

Note that the data and analysis of the supernatant experiments is not (yet?) available.

## Writing folder

Finally, there is a main folder called "writing". Here you can find docx files for drafts of the main text and supplement, as well as image files where multipanel figures were combined into their final format for the main text. The main text was written and revised in a shared folder on Overleaf.

# 4. Credits for repository

[Temporarily removed for peer review]

# wirxLab 
A collection of software and functions. Please update this file when you rename or add functions! Download GitHub for Desktop, clone this repository, and add the folder to your MATLAB path. After making edits to the code, remember to commit changes and push changes to origin/master!


**fastsmooth.m** Smoothens spiky signal by taking averages across points.

**shotData.m** Extract or calculate important parameter values for a shot.

**shotImaging.m** Extracts imaga data from PPD and ICCD cameras.

**tightfig.m** Reduces white space in figures.

## CCD Imaging

**img_raw2jpg.m** Reads .b16 files exported from PCO CamWare and saves .jpg image.

**img_raw2tiff.m** Reads .b16 files exported from PCO CamWare and saves .tiff image.

**pcoCamware.py** Script to operate Dicam ICCD Cameras with PCO software.

**readB16.m** Reads .b16 raw image data (recommended)

**readB16.py** Reads .b16 raw image file and plots image.

**showB16.m** Reads and show .b16 raw image data.



## Modelling

**puffPressure.m** Estimates pressure of half-cylinder-shaped gas cloud around electrodes.

**ArcadePlot.m** Creates image of arcade

**Bfield2.m** 

**Bfield_calc.mat** Data needed to input to Bfield functions

**Bfield_main.m**

**Blines.m**

**Btrace.m**


## PPD Imaging
**PPD2vel.m** Extracts event velocity from time-distance maps.

**PPD_view.fig** GUI window for PPD_view.m

**PPD_view.m** Program to view intensity maps for both PPDs. Requires PPD_view.fig

**PPDvelDistribution.m** Compiles all velocities from .mat files in a folder to study the distribution.


## Spectrometer

**MorkenSpectrometer.py** Operates Arduino in spectrometer to control grating position.

**calibrate.m** Analysis emission image of discharge lamps to get calibration factors.

**Density.m** Extracts CCD images of HBeta line to calculate electron density n_e.

**Temp.m** Calculate temperature based on emission spectra. Calibration images needed.

**fwhm2Ne.m** [Archived] Calculate n_e (electron density) from FWHM of spectra.

**spectraFWHM.m** [Archived] Calculate FWHM based on emission spectra

Note: emission spectra images point to specific file paths, need to change that.

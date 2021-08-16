--------------------------------------------------------------------------
Odor temporal dynamics control for calcium imaging
Author: Luis Hernandez Nunez
Questions: luishernandeznunez@fas.harvard.edu
--------------------------------------------------------------------------

1. NARX model

The NARX and linear models can be found in the file Olfactometer_sysiden.sid

This extension corresponds to the MATLAB Systems Identification Toolbox.

To open it, in MATLAB 2016 or later, type in the command line >> systemIdentification.

Once the Systems Identification window opens, select File>Open and then choose Olfactometer_sysiden.sid. The first loaded model is the linear one and the second one is the NARX model. They can be exported to the workspace and then used to compute model outputs to any input.


2. Odor control virtual instruments

The LabVIEW software needed to run the olfactometer is in the folder Olfactometer_for_Microscopy. The main VI is Odor_control_m.vi and it calls all the other sub-VIs. Most of the sub-VIs were also part of the control software of Gershow et al 2012 (Nature Methods) and are re-utilized here.

A movie of Or42a neural response to a sine wave is in the movie Or42a_Sine_Wave_response.mp4

3. Data analysis

3.1 Pre-Processing and Motion correction

Functional volumetric calcium imaging was conducted with a spinning disk confocal micrscope and data saved in .nd2 format.

To extract data and format it for motion correction we used the matlab script Format_data_and_motion_correction.m. As described in the Methods and Materials of the paper, motion correction is conducted with the package MOCO. Example movies of the antennal lobe (AL) before and after motion correction are provided in this folder under the names AL_wo_MC.mp4 and AL_w_MC.mp4

3.2 Calcium imaging analysis

The motion corrected movies are then processed using CNMF techniques as described in the Methods and Materials of the paper, using the Paninski lab toolbox for CNMF demixing, denoising, and deconvolving. The Script that implement these code using functions from the toolbox is in Calcium_data_analysis.m

--------------------------------------------------------------------------
Odor temporal dynamics control for behavior
Author: Luis Hernandez Nunez
Questions: luishernandeznunez@fas.harvard.edu
--------------------------------------------------------------------------

1. Odor control virtual instruments

The LabVIEW software needed to run the olfactometer is in the folder Olfactometer_for_Behavior. 
The main VI is Odor_control_b.vi and it calls all the other sub-VIs. Most of the sub-VIs were 
also part of the control software of Gershow et al 2012 (Nature Methods) and are re-utilized here.

2. Data analysis

2.1 Pre-Processing 

Functional volumetric calcium imaging was conducted with a spinning disk confocal micrscope and data saved in .nd2 format.

To extract data and format it for motion correction we used the matlab script Format_data_and_motion_correction.m. As described in the Methods and Materials of the paper, motion correction is conducted with the package MOCO. Example movies of the antennal lobe (AL) before and after motion correction are provided in this folder under the names AL_wo_MC.mp4 and AL_w_MC.mp4

2.2  Turn rates and run rates

The motion corrected movies are then processed using CNMF techniques as described in the Methods and Materials of the paper, using the Paninski lab toolbox for CNMF demixing, denoising, and deconvolving. The Script that implement these code using functions from the toolbox is in Calcium_data_analysis.m

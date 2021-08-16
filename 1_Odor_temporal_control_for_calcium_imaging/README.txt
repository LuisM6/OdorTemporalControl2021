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

The LabVIEW software needed to run the olfactometer is in the folder Olfactometer_for_Microscopy. The main VI is Odor_control_m.vi and it calls all the other sub-VIs. Most of the sub-VIs were also part of the control software of Gershow et al 2012 (Nature Methods).


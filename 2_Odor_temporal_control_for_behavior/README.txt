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

2.1 Data Processing 

The behavioral traces are processed in MATLAB using functions from MAGAT Analyzer. The script Process_behavior_data.m was used to this step.

2.2  Turn rates and run rates

The analysis of behavioral state transitions, turn rates, run rates, speed and other parameters was conducted with the Analyze_behavioral_dynamics.m script.

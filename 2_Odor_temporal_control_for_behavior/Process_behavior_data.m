%% Behavior data processing used in Hernandez-Nunez et al 2021 Olfaction Methods Paper
% This script cleans tracks, finishes the inference of head tail 
% orientation and segments tracks
% Author: Luis Hernandez Nunez
% Questions: luishernandeznunez@fas.harvard.edu
clear all; close all; clc;clear all; close all; clc;
%% Input arguments
Expt = 'Odor1';
Type=  'Or13a@UAS-orco_delta_orco';
%% LOAD FILE(S)
current_dir    =   pwd;
output_dir      =   ['\\LABNAS100\Luis\Chemotaxis_Project\Behavior_Movies\Chemotaxis_2019\',Type,'\',Expt,'\All_outputs'];
if (~exist('eset','var'))
    eset=ExperimentSet.fromFiles();
end
%% CLEAN THE TRACKS
existsAndDefault('cleanEset', 'true');
if (cleanEset)
    ecl = ESetCleaner;
    ecl.minHTValid = 0.75;
    ecl.minDist = 15;
    ecl.minSpeed = 0.25;
    ecl.minPts = 100;
    ecl.clean(eset);
    cleanEset = false;
end
%% FIX HEAD-TAIL ORIENTATION 
existsAndDefault('fixht','true');
if (fixht)
    eset.executeTrackFunction('fixHTOrientation');
    fixht = false;
end 
%% SET SEGMENTATION SPEED
existsAndDefault('autosetspeeds', true);
if (autosetspeeds)
    eset.executeTrackFunction('setSegmentSpeeds');
    autosetspeeds = false;
end
%% SEGMENT THE TRACKS
existsAndDefault('segment', true);
if (segment)
    eset.executeTrackFunction('segmentTrack');
    segment = false; 
end
%% Save experiment
cd(output_dir);
toMatFiles(eset,[Expt,'Sinusoidal_temporal_waveform']);
cd(current_dir);
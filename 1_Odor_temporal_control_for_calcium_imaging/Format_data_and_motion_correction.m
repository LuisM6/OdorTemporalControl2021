%% Fromatting data for motion correction script used in Hernandez-Nunez et al 2021 Olfaction Methods Paper
% Author: Luis Hernandez Nunez
% Questions: luishernandeznunez@fas.harvard.edu
clear all; close all; clc;
%% Experiment information
Type_of_experiment      =                    'Physiology_Odor_Responses';
Genotype                =                    'orco_Gal4_UAS_GC6m';
number_of_neurons       =                    21;                                
Date                    =                    '20180922';
Type_of_stimulus        =                    'Low_baseline_sw_ramps';                               
output_dir              =                    ['\\LABNAS100\Luis\2018\',Type_of_experiment,'\_Results\',Genotype,'\',Date,'\',Type_of_stimulus];
digits_of_steps         =                    3;
custom_time_bounds      =                    0;
c_time_b                =                   [17521*0.05 20320*0.05]+800*0.05;                     % [0 5920*0.05 5120*0.05 10720*0.05 9921*0.05 12720*0.05 12720*0.05 18320*0.05 17521*0.05 20320*0.05]  20321*0.05 50621*0.05
use_limits              =                    1;
use_median_as_template  =                    1;
use_custom_frame_as_template =               0;
custom_frame            =                    46;
opt_x_lims              =                    [249 337];
opt_y_lims              =                    [318 405];
mkdir(output_dir);
%% Load data
curr_dir = pwd;
global image_times;
[filename,pathname]  = uigetfile({'*.nd2'});                                       % Ask the user to select the nd2 files (movies of Elements) 
fname = [pathname filename];                                                       % Merge location of the file and itsname   
if(use_limits==1)
    data=bfopen(fname,opt_x_lims(1),opt_y_lims(1),opt_x_lims(2)-opt_x_lims(1),opt_y_lims(2)-opt_y_lims(1));     
else
    data=bfopen(fname);                                                            % Open the nd2 file in the variable 'data'
end
%% Format data
imagelist=data{1,1};                                                        % Recovers the image stack
[x_dim, y_dim]=size(imagelist{1,1});                                        % Recovers the size (Number of Z sections * Number of time steps ,  2 ( 1 contains the image, 2 the location and info of the image))
image_inf = data{1}{1,2};                                                   % Store image information including time step and Z section
num_t =str2num(image_inf(end+1-digits_of_steps:end)) ;                      % Get number of time steps
if(isempty(num_t))
    num_t = str2num(image_inf(end-1:end)) ;
end
istart=1;
iend=num_t;
% Get number of Z stacks
z_start = strfind(image_inf, 'Z=1/');                                               
z_end   = strfind(image_inf, '; T=1/');
if isempty(z_start)
    num_z = 1;
else
    num_z = str2double(image_inf(z_start+4 : z_end-1));
end
zplane = 1:num_z;
% Project image in xy
img_stack_maxintensity = zeros(x_dim, y_dim,num_t);
for i=1:num_t    
     img_stack=zeros(x_dim,y_dim,length(zplane));                    
     for j=1:length(zplane)            
                if isempty(z_start)
                    img_stack(:,:,j)=imagelist{i, 1};
                else
                    img_stack(:,:,j)=imagelist{(i-1)*num_z+zplane(j),1};
                end      
    end
    img_stack_maxintensity(:,:,i) = max(img_stack,[],3);
end
%% Obtain the time of each image projection

total_bins= 1;
time_bin = 1;

metadata = data{2};
image_times = zeros(num_t,1);
if(total_bins>1)
    for i=1+floor((time_bin-1)*iend/total_bins):floor(time_bin*iend/total_bins)
        index = i*num_z - 1;
        image_times(i) = metadata.get(['timestamp ' num2str(index)]);
    end   
else
    for i=1:num_t
        index = i*num_z - 1;
        image_times(i) = metadata.get(['timestamp ' num2str(index)]);
    end
end
%% Save data for movement cancellation
cd(output_dir)
if(use_limits==1)
    temp_mat = uint16(img_stack_maxintensity(:,:,1+floor((time_bin-1)*iend/total_bins):floor(time_bin*iend/total_bins)));
    x_dim = length(opt_x_lims(1):opt_x_lims(2)); 
    y_dim = length(opt_y_lims(1):opt_y_lims(2));
else
    temp_mat = uint16(img_stack_maxintensity(:,:,1+floor((time_bin-1)*iend/total_bins):floor(time_bin*iend/total_bins)));
end
if(custom_time_bounds==1)
    temp_mat = temp_mat(:,:,(image_times>c_time_b(1) & image_times<=c_time_b(2)));
    image_times = image_times((image_times>c_time_b(1) & image_times<=c_time_b(2)));
    num_t = size(temp_mat,3);
end
outputFileName = [filename(1:end-4),'_xy_stack.tif'];
% Save stack
for K=1:length(temp_mat(1, 1, :))
   imwrite(temp_mat(:, :, K), outputFileName, 'WriteMode', 'append',  'Compression','none');
end
% Save template
outputFileName = [filename(1:end-4),'_xy_template.tif'];
if(use_median_as_template==1)
    imwrite(temp_mat(:, :, round(size(temp_mat,3)/2)), outputFileName, 'WriteMode', 'append',  'Compression','none');
elseif (use_custom_frame_as_template ==1)
    imwrite(temp_mat(:, :, custom_frame), outputFileName, 'WriteMode', 'append',  'Compression','none');
else
    imwrite(temp_mat(:, :, 1), outputFileName, 'WriteMode', 'append',  'Compression','none');
end
if(total_bins>1)
    num_t = length(1+floor((time_bin-1)*iend/total_bins):floor(time_bin*iend/total_bins));
end
cd(curr_dir)
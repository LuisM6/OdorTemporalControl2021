%% Calcium imaging analysis used in Hernandez-Nunez et al 2021 Olfaction Methods Paper
% With the motion correction script variables, use CNMF to obtain neural responses
% Author: Luis Hernandez Nunez
% Questions: luishernandeznunez@fas.harvard.edu
clear all; close all; clc;
%% Optional load just a subset of the movement corrected movie to process faster
load_subset = 1; %flag for loading data subset or full dataset
if(load_subset)
    cd(output_dir)
    use_limits_2 = 1;
    opt_y_lims_2 = [23 91];
    opt_x_lims_2 = [21 93];
    if(use_limits_2==1)
        x_dim = length(opt_x_lims_2(1):opt_x_lims_2(2)); 
        y_dim = length(opt_y_lims_2(1):opt_y_lims_2(2));
        for K=1:length(temp_mat(1, 1, :))
            temp = imread([output_dir, '\', filename(1:end-4),'_wmc.tif'],K);
            temp = temp(opt_x_lims_2(1):opt_x_lims_2(2),opt_y_lims_2(1):opt_y_lims_2(2));
            imwrite(temp,[output_dir, '\', filename(1:end-4),'_wmc_2.tif'], 'WriteMode', 'append',  'Compression','none');
        end
    end
    cd(curr_dir)
end
%% Analyze using CNMF from Paninski lab for demixing and deconvolving calcium imaging data
cd('Paninski')
addpath(genpath('utilities'));
if(use_limits_2==1)
    inputFileName   = [output_dir, '\', filename(1:end-4),'_wmc_2.tif'];
else
    inputFileName   = [output_dir, '\', filename(1:end-4),'_wmc.tif'];
    x_dim=x_dim-1;
    y_dim=y_dim-1;
end
% Alternatively, to acces an older file
inputFileName = [output_dir, '\PL1ol_S1_L102_wmc_2.tif'];
x_dim = 68;
y_dim = 66;

Y                       = bigread2(inputFileName,istart,iend);  % input file, start_frame and end_frame
Y                       = Y - min(Y(:)); 
if ~isa(Y,'single');  Y = single(Y);  end                       % convert to single
d                       = x_dim*y_dim;                          % total number of pixels

% Select Parameters for analysis
K               = number_of_neurons;
tau             = 10; %4;                                     % std of gaussian kernel (size of neuron)
p               = 2;                                          % order of autoregressive system (p = 0 no dynamics, p=1 just decay, p = 2, both rise and decay)
merge_thr       = 0.98;                                       % merging threshold

options = CNMFSetParms(...                      
    'd1',x_dim,'d2',y_dim,...                   % dimensions of datasets
    'search_method','ellipse','dist',3,...      % search locations when updating spatial components
    'deconv_method','constrained_foopsi',...    % activity deconvolution method
    'temporal_iter',2,...                       % number of block-coordinate descent steps 
    'fudge_factor',0.98,...                     % bias correction for AR coefficients
    'merge_thr',merge_thr,...                   % merging threshold
    'gSig',tau...
    );
options.ind = 1:number_of_neurons;
[P,Y] = preprocess_data(Y,p);

% fast initialization of spatial components using greedyROI and HALS

[Ain,Cin,bin,fin,center] = initialize_components(Y,K,tau,options,P);  % initialize

% display centers of found components
Cn =  reshape(P.sn,x_dim,y_dim); %correlation_image(Y); %max(Y,[],3); %std(Y,[],3); % image statistic (only for display purposes)
figure;imagesc(Cn);
    axis equal; axis tight; hold all;
    scatter(center(:,2),center(:,1),'mo');
    title('Center of ROIs found from initialization algorithm');
    drawnow;

% manually refine components (optional)
refine_components = true;               % flag for manual refinement
if refine_components
    [Ain,Cin,center] = manually_refine_components(Y,Ain,Cin,center,Cn,tau,options);
end

% update spatial components
Yr = reshape(Y,d,num_t);
%clear Y;
[A,b,Cin] = update_spatial_components(Yr,Cin,fin,Ain,P,options);

% update temporal components
P.p = 0;    % set AR temporarily to zero for speed
[C,f,P,S] = update_temporal_components(Yr,A,b,Cin,fin,P,options);

% merge found components
[Am,Cm,K_m,merged_ROIs,P,Sm] = merge_components(Yr,A,b,C,f,P,S,options);

display_merging = 1; % flag for displaying merging example
if and(display_merging, ~isempty(merged_ROIs))
    for i=1:length(merged_ROIs)
        ln = length(merged_ROIs{i});
        f2=figure(1+i);
            set(gcf,'color','white'); hold on;
            set(gcf,'Position',[300,300,(ln+2)*300,300]);
            for j = 1:ln
                subplot(1,ln+2,j); imagesc(reshape(A(:,merged_ROIs{i}(j)),x_dim,y_dim)); 
                title(sprintf('Component %i',merged_ROIs{i}(j)),'fontsize',16,'fontweight','bold'); axis equal; axis tight;
            end
            subplot(1,ln+2,ln+1); imagesc(reshape(Am(:,K_m-length(merged_ROIs)+i),x_dim,y_dim));
                title('Merged Component','fontsize',16,'fontweight','bold');axis equal; axis tight; 
            subplot(1,ln+2,ln+2);
            plot(1:num_t,(diag(max(C(merged_ROIs{i},:),[],2))\C(merged_ROIs{i},:))'); 
            hold all; plot(1:num_t,Cm(K_m-length(merged_ROIs)+i,:)/max(Cm(K_m-length(merged_ROIs)+i,:)),'--k')
            title('Temporal Components','fontsize',16,'fontweight','bold')
            drawnow;
        saveas(f2,[output_dir,'\',filename(1:end-4),'_merged_components_',num2str(i)],'fig')
        saveas(f2,[output_dir,'\',filename(1:end-4),'_merged_components_',num2str(i)],'tiff')
        saveas(f2,[output_dir,'\',filename(1:end-4),'_merged_components_',num2str(i)],'pdf')
    end
end

% repeat
P.p = p;    % restore AR value
[A2,b2,Cm] = update_spatial_components(Yr,Cm,f,Am,P,options);
[C2,f2,P,S2] = update_temporal_components(Yr,A2,b2,Cm,f,P,options);

%% Make figures and save data
[A_or,C_or,S_or,P] = order_ROIs(A2,C2,S2,P);                % order components
K_m = size(C_or,1);
[C_df,~] = extract_DF_F(Yr,[A_or,b2],[C_or;f2],K_m+1);      % extract DF/F values (optional)
contour_threshold = 0.95;                                   % amount of energy used for each component to construct contour plot

fig3=figure(2+length(merged_ROIs));
set(gcf,'color','white'); hold on;
[Coor,json_file] = plot_contours(A_or,reshape(P.sn,x_dim,y_dim),options,1);           % contour plot of spatial footprints
%savejson('jmesh',json_file,[output_dir,'\',filename(1:end-4),'_components']);        % optional save json file with component coordinates (requires matlab json library)
set(gca,'YDir','reverse')
title('Analyzed Components')
set(gca,'FontSize',14)
saveas(fig3,[output_dir,'\',filename(1:end-4),'_final_components'],'fig')
saveas(fig3,[output_dir,'\',filename(1:end-4),'_final_components'],'tiff')
saveas(fig3,[output_dir,'\',filename(1:end-4),'_final_components'],'pdf')

display components
fig4 = figure(4);
set(gcf,'color','white'); hold on;
plot_components_GUI(Yr,A_or,C_or,b2,f2,Cn,options)

% Compute responses of each component
[Response, Filtered_Resp, C_filt, Y_r_output, Delta_f]= compute_responses(Yr,A_or,C_or,b2,f2,Cn,options);

% decide which variables to keep, for example Cin,C,C2,C_df,C_or and image_times
save([output_dir,'\',filename(1:end-4),'_analyzed_data.mat'],'C','C2','C_df','C_or','Cn','image_times','A_or','b2','f2','Cn','options','Yr',...
    'Response', 'Filtered_Resp', 'C_filt','Y_r_output', 'Delta_f');

fig4 = figure(3+length(merged_ROIs));
set(gcf,'color','white'); hold on;
legendInfo = cell(size(C_df,1),1);
for i=1:size(Response,1)
    plot(image_times,Response(i,:),'LineWidth',2.5)
    legendInfo{i} = ['#' num2str(i)];
end
xlabel('time(s)')
ylabel('f/\Deltaf')
title('Raw data')
legend(legendInfo)
set(gca,'FontSize',14)
saveas(fig4,[output_dir,'\',filename(1:end-4),'_responses'],'fig')
saveas(fig4,[output_dir,'\',filename(1:end-4),'_responses'],'tiff')
saveas(fig4,[output_dir,'\',filename(1:end-4),'_responses'],'pdf')

fig5 = figure(4+length(merged_ROIs));
set(gcf,'color','white'); hold on;
legendInfo2 = cell(size(C_df,1),1);
for i=[20 25 15 32]%1:size(Response,1)
    plot(image_times,Filtered_Resp(i,:),'LineWidth',2.5)
    legendInfo2{i} = ['#' num2str(i)];
end
xlabel('time(s)')
ylabel('F/\deltaf')
title('Filtered data')
legend(legendInfo)
set(gca,'FontSize',14)
saveas(fig5,[output_dir,'\',filename(1:end-4),'_filtered_responses'],'fig')
saveas(fig5,[output_dir,'\',filename(1:end-4),'_filtered_responses'],'tiff')
saveas(fig5,[output_dir,'\',filename(1:end-4),'_filtered_responses'],'pdf')

cd(curr_dir);

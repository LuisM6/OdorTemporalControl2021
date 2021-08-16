%% Behavior data analysis used in Hernandez-Nunez et al 2021 Olfaction Methods Paper
% This script computes the turn and run rate for a periodic signal
% presented to larvae
% Author: Luis Hernandez Nunez
% Questions: luishernandeznunez@fas.harvard.edu
clear all; close all; clc;clear all; close all; clc;
%% Input arguments
Genotype            = 'w1118';                         %  Ir68a_SineW1_60s_15
Date                = '20190710';               
Type_of_stimulus    = 'Periodic_Activation';        %  Periodic signal = Periodic_Activation  White noise = Random_Activation
Type_of_experiment  = 'Acetal_high';                %  Phototaxis_Yellow Phototaxis_Violet Phototaxis_White Thermotaxis Thermotaxis_with_optogenetics Chemotaxis Chemotaxis_with_optogenetics
Stimulus_period     = 96;                           %   in number of frames
Movie_duration      = 4800;                         %   in number of frames
Frame_rate          = 4;                            %   in Hz
SlidingWindow       = 8;                            %   in number of frames 
Number_of_movies    = 3;                        
%% LOAD additional files
data_dir          =     ['\\LABNAS100\Luis\_Final\Olfaction_methods_paper\Behavior_Fig4\',Type_of_experiment,'\',Genotype,'\',Type_of_stimulus];
fig_dir           =     ['\\LABNAS100\Luis\_Final\Olfaction_methods_paper\Behavior_Fig4\',Type_of_experiment,'\_Results\',Genotype,'\',Type_of_stimulus];
curr_dir          =     pwd;
cd(data_dir);
eset              =     ExperimentSet.fromMatFiles([Genotype,'_',Type_of_stimulus],'all',true);
cd(curr_dir);
%% Compute time traces of relevant behaviors
larvae_running      =   cell(length(eset.expt),1);              % Total amount of larvae running
larvae_turning      =   cell(length(eset.expt),1);              % Total amount of larvae turning
larvae_pausing      =   cell(length(eset.expt),1);              % Total amount of larvae pausing (stop with no change in direction)
larvae_r_to_t       =   cell(length(eset.expt),1);              % Larvae run to turn
larvae_t_to_r       =   cell(length(eset.expt),1);              % Larvae turn to run
larvae_r_to_p       =   cell(length(eset.expt),1);              % Larvae run to pause
larvae_p_to_r       =   cell(length(eset.expt),1);              % Larvae pause to run
% Other general data extraction
speed_per_track     =   cell(length(eset.expt),1);              % speed in pixels in each track
state_per_track     =   cell(length(eset.expt),1);              % 1 for running 2 for turning 3 for pausing
% Still need to write code to indentify
larvae_hs_rejection =   cell(length(eset.expt),1);              % Larvae rejecting a head sweep
larvae_run_backwards=   cell(length(eset.expt),1);              % Number of larvae crawling backwards (not as part of a turn)  
larvae_hunching     =   cell(length(eset.expt),1);              % Contraction during a pause or a turn (before initiating head sweeping larvae may hunch)
larvae_C_bending    =   cell(length(eset.expt),1);              % Larvae doing a C bend

for i=1:length(eset.expt)
   larvae_running{i}        =   zeros(1,Movie_duration+5);
   larvae_turning{i}        =   zeros(1,Movie_duration+5);
   larvae_pausing{i}        =   zeros(1,Movie_duration+5);
   larvae_r_to_t{i}         =   zeros(1,Movie_duration+5);
   larvae_t_to_r{i}         =   zeros(1,Movie_duration+5);
   larvae_r_to_p{i}         =   zeros(1,Movie_duration+5);
   larvae_p_to_r{i}         =   zeros(1,Movie_duration+5);
   % Other general data extraction
   speed_per_track{i}     =   NaN(length(eset.expt(i).track),Movie_duration+5);             
   state_per_track{i}     =   NaN(length(eset.expt(i).track),Movie_duration+5);             
   % Still need to write code to indentify  
   larvae_run_backwards{i}  =   zeros(1,Movie_duration+5);   
   larvae_hs_rejection{i}   =   zeros(1,Movie_duration+5);
   larvae_hunching{i}       =   zeros(1,Movie_duration+5);
   larvae_C_bending{i}      =   zeros(1,Movie_duration+5);
   
   for k=1:length(eset.expt(i).track)
       delay=0;
       for j=1:length(eset.expt(i).track(k).reorientation)
           if(eset.expt(i).track(k).startFrame+eset.expt(i).track(k).reorientation(j).endInd<=Movie_duration) 
            if(max(diff(eset.expt(i).elapsedTime(eset.expt(i).track(k).startFrame+eset.expt(i).track(k).run(j).startInd:eset.expt(i).track(k).startFrame+eset.expt(i).track(k).reorientation(j).endInd)))<=0.26)
                if (eset.expt(i).track(k).reorientation(j).numHS>0)
                    larvae_r_to_t{i}(int16(eset.expt(i).track(k).startFrame)+int16(eset.expt(i).track(k).reorientation(j).startInd)-round(delay))=larvae_r_to_t{i}(int16(eset.expt(i).track(k).startFrame)+int16(eset.expt(i).track(k).reorientation(j).startInd)-round(delay))+1;
                    larvae_turning{i}(int16(eset.expt(i).track(k).startFrame)+int16(eset.expt(i).track(k).reorientation(j).inds)-round(delay))= larvae_turning{i}(int16(eset.expt(i).track(k).startFrame)+int16(eset.expt(i).track(k).reorientation(j).inds)-round(delay))+1;    
                    state_per_track{i}(k,int16(eset.expt(i).track(k).startFrame)+int16(eset.expt(i).track(k).reorientation(j).inds)-round(delay)) =   2;
                    speed_per_track{i}(k,eset.expt(i).track(k).startFrame+int16(eset.expt(i).track(k).reorientation(j).inds)-round(delay)) =   eset.expt(i).track(k).dq.speed(int16(eset.expt(i).track(k).reorientation(j).inds));
                else
                    larvae_r_to_p{i}(int16(eset.expt(i).track(k).startFrame)+int16(eset.expt(i).track(k).reorientation(j).startInd)-round(delay))=larvae_r_to_p{i}(int16(eset.expt(i).track(k).startFrame)+int16(eset.expt(i).track(k).reorientation(j).startInd)-round(delay))+1;
                    larvae_pausing{i}(int16(eset.expt(i).track(k).startFrame)+int16(eset.expt(i).track(k).reorientation(j).inds)-round(delay))= larvae_pausing{i}(int16(eset.expt(i).track(k).startFrame)+int16(eset.expt(i).track(k).reorientation(j).inds)-round(delay))+1;
                    state_per_track{i}(k,int16(eset.expt(i).track(k).startFrame)+int16(eset.expt(i).track(k).reorientation(j).inds)-round(delay)) =   3;
                    speed_per_track{i}(k,eset.expt(i).track(k).startFrame+int16(eset.expt(i).track(k).reorientation(j).inds)-round(delay)) =   eset.expt(i).track(k).dq.speed(int16(eset.expt(i).track(k).reorientation(j).inds));
                end
            else
                    delay = delay+sum(diff(eset.expt(i).elapsedTime(eset.expt(i).track(k).startFrame+eset.expt(i).track(k).run(j).startInd:eset.expt(i).track(k).startFrame+eset.expt(i).track(k).reorientation(j).endInd))-0.25)*4;
            end
           end
       end 
       delay=0;
       for j=1:length(eset.expt(i).track(k).run)          
            if(eset.expt(i).track(k).startFrame+eset.expt(i).track(k).run(j).endInd<=Movie_duration) 
              if(j<2)
                if(max(diff(eset.expt(i).elapsedTime(eset.expt(i).track(k).startFrame+eset.expt(i).track(k).run(j).startInd:min(Movie_duration,eset.expt(i).track(k).startFrame+max(int16(eset.expt(i).track(k).run(j).inds))))))<=0.26)
                    if(isempty(eset.expt(i).track(k).run(j).prevReorientation)==0)
                        larvae_running{i}(int16(eset.expt(i).track(k).startFrame)+int16(eset.expt(i).track(k).run(j).inds)-round(delay))= larvae_running{i}(int16(eset.expt(i).track(k).startFrame)+int16(eset.expt(i).track(k).run(j).inds)-round(delay))+1;
                        state_per_track{i}(k,int16(eset.expt(i).track(k).startFrame)+int16(eset.expt(i).track(k).run(j).inds)-round(delay)) =   1;
                        speed_per_track{i}(k,eset.expt(i).track(k).startFrame+int16(eset.expt(i).track(k).run(j).inds)-round(delay)) =   eset.expt(i).track(k).dq.speed(int16(eset.expt(i).track(k).run(j).inds));
                    end
                elseif (Movie_duration>eset.expt(i).track(k).startFrame+max(int16(eset.expt(i).track(k).run(j).inds)))
                        delay = delay+round(sum(diff(eset.expt(i).elapsedTime(eset.expt(i).track(k).startFrame+int16(eset.expt(i).track(k).run(j).inds)))-0.25)*4);
                end
              else
                if(max(diff(eset.expt(i).elapsedTime(eset.expt(i).track(k).startFrame+eset.expt(i).track(k).reorientation(j-1).startInd:eset.expt(i).track(k).startFrame+eset.expt(i).track(k).run(j).endInd)))<=0.26)
                    if(isempty(eset.expt(i).track(k).run(j).prevReorientation)==0)
                        larvae_running{i}(int16(eset.expt(i).track(k).startFrame)+int16(eset.expt(i).track(k).run(j).inds)-round(delay))= larvae_running{i}(int16(eset.expt(i).track(k).startFrame)+int16(eset.expt(i).track(k).run(j).inds)-round(delay))+1;
                        state_per_track{i}(k,int16(eset.expt(i).track(k).startFrame)+int16(eset.expt(i).track(k).run(j).inds)-round(delay)) =   1;
                        speed_per_track{i}(k,eset.expt(i).track(k).startFrame+int16(eset.expt(i).track(k).run(j).inds)-round(delay)) =   eset.expt(i).track(k).dq.speed(int16(eset.expt(i).track(k).run(j).inds));
                        if(eset.expt(i).track(k).run(j).prevReorientation.numHS>0)
                            larvae_t_to_r{i}(int16(eset.expt(i).track(k).startFrame)+int16(eset.expt(i).track(k).run(j).startInd)-round(delay))=larvae_t_to_r{i}(int16(eset.expt(i).track(k).startFrame)+int16(eset.expt(i).track(k).run(j).startInd)-round(delay))+1;
                        else
                            larvae_p_to_r{i}(int16(eset.expt(i).track(k).startFrame)+int16(eset.expt(i).track(k).run(j).startInd)-round(delay))=larvae_p_to_r{i}(int16(eset.expt(i).track(k).startFrame)+int16(eset.expt(i).track(k).run(j).startInd)-round(delay))+1;
                        end
                    end
                else
                        delay = delay+sum(diff(eset.expt(i).elapsedTime(eset.expt(i).track(k).startFrame+eset.expt(i).track(k).reorientation(j-1).startInd:eset.expt(i).track(k).startFrame+eset.expt(i).track(k).run(j).endInd))-0.25)*4;
                end          
              end
            end         
       end   
   end   
end 
%% Synchronize periodic signals
initial_indexes = cell(length(eset.expt),1);
for i=1:length(eset.expt)
   initial_indexes{i} = Stimulus_period/4*(1:4:(Movie_duration/Stimulus_period-1)*4);   % -10 is the correction for Ir21a missalignment
end
%% Compute probability rates
total_larvae_running        =   zeros(1,Stimulus_period);
total_larvae_turning        =   zeros(1,Stimulus_period);
total_larvae_pausing        =   zeros(1,Stimulus_period);
total_larvae_r_to_t         =   zeros(1,Stimulus_period);
total_larvae_t_to_r         =   zeros(1,Stimulus_period);
total_larvae_r_to_p         =   zeros(1,Stimulus_period);
total_larvae_p_to_r         =   zeros(1,Stimulus_period);

total_speed_per_track = [];
total_state_per_track = [];  

for  i=1:length(eset.expt)
   for j=2:length(initial_indexes{i})         
        total_larvae_r_to_t  = total_larvae_r_to_t+larvae_r_to_t{i}(initial_indexes{i}(j):initial_indexes{i}(j)+Stimulus_period-1);
        total_larvae_t_to_r  = total_larvae_t_to_r+larvae_t_to_r{i}(initial_indexes{i}(j):initial_indexes{i}(j)+Stimulus_period-1);
        total_larvae_r_to_p  = total_larvae_r_to_p+larvae_r_to_p{i}(initial_indexes{i}(j):initial_indexes{i}(j)+Stimulus_period-1);
        total_larvae_p_to_r  = total_larvae_p_to_r+larvae_p_to_r{i}(initial_indexes{i}(j):initial_indexes{i}(j)+Stimulus_period-1);
        total_larvae_turning = total_larvae_turning+larvae_turning{i}(initial_indexes{i}(j)-1:initial_indexes{i}(j)+Stimulus_period-2);   
        total_larvae_running = total_larvae_running+larvae_running{i}(initial_indexes{i}(j)-1:initial_indexes{i}(j)+Stimulus_period-2);  
        total_larvae_pausing = total_larvae_pausing+larvae_pausing{i}(initial_indexes{i}(j)-1:initial_indexes{i}(j)+Stimulus_period-2);  
        total_speed_per_track = [total_speed_per_track; speed_per_track{i}(:,initial_indexes{i}(j)-1:initial_indexes{i}(j)+Stimulus_period-2)];
        total_state_per_track = [total_state_per_track; state_per_track{i}(:,initial_indexes{i}(j)-1:initial_indexes{i}(j)+Stimulus_period-2)];
   end
end
% Compute mean speed during runs
speed_during_runs = total_speed_per_track; speed_during_runs(total_state_per_track~=1) = NaN;
mean_speed_during_runs = nanmean(speed_during_runs);
SEM_speed_during_runs = nanstd(speed_during_runs)./sqrt(total_larvae_running);
% Compute mean speed independent of larvae state
mean_speed = nanmean(total_speed_per_track);
SEM_speed = nanstd(total_speed_per_track)./sqrt(total_larvae_running+total_larvae_turning+total_larvae_pausing);
% Compute the probability of switching from running to turning and turning
% to running
P_R_to_T    = total_larvae_r_to_t./(total_larvae_running+total_larvae_turning+total_larvae_pausing);                        % Run to Turn
P_T_to_R    = total_larvae_t_to_r./(total_larvae_turning+total_larvae_running+total_larvae_pausing);                        % Turn to Run
P_R_to_P    = total_larvae_r_to_p./(total_larvae_running+total_larvae_turning+total_larvae_pausing);                        % Run to Pause
P_P_to_R    = total_larvae_p_to_r./(total_larvae_turning+total_larvae_running+total_larvae_pausing);                        % Pause to Run
P_R_to_PorT = (total_larvae_r_to_t+total_larvae_r_to_p)./(total_larvae_running+total_larvae_turning+total_larvae_pausing);  % Run to Pause or Turn
P_PorT_to_R = (total_larvae_t_to_r+total_larvae_p_to_r)./(total_larvae_running+total_larvae_turning+total_larvae_pausing);  % Pause or Turn to Run
P_R_to_T_gR = total_larvae_r_to_t./total_larvae_running;                                                                    % Run to Turn given that you are running
P_T_to_R_gT = total_larvae_t_to_r./total_larvae_turning;                                                                    % Turn to Run given that you are turning
P_R_to_TP_gR = (total_larvae_r_to_t+total_larvae_r_to_p)./(total_larvae_running);
P_TP_to_R_gTP = (total_larvae_t_to_r+total_larvae_p_to_r)./(total_larvae_turning+total_larvae_pausing);

%% Make Figures
mkdir(fig_dir)
cd(fig_dir)
time_points = (1/Frame_rate)/2:(1/Frame_rate):(Stimulus_period/Frame_rate)-(1/Frame_rate)/2;

f5=figure(5);
set(gcf,'color','white')
hold on
shadedErrorBar(time_points,mean_speed_during_runs*0.6,SEM_speed_during_runs*0.6,'c',0);   % 0.6 is the conversion factor from pixel/s to cm/min in the optogenetics setup
set(gca,'FontSize',14)
xlabel('Time(s)')
ylabel('Speed during runs (cm/min)')
saveas(f5,'Running_Speed','fig');
saveas(f5,'Running_Speed','pdf');
saveas(f5,'Running_Speed','jpg');

f6=figure(6);
set(gcf,'color','white')
hold on
shadedErrorBar(time_points,mean_speed*0.6,SEM_speed*0.6,'g',0);                         % 0.6 is the conversion factor from pixel/s to cm/min in the optogenetics setup
set(gca,'FontSize',14)
xlabel('Time(s)')
ylabel('Speed (cm/min)')
saveas(f6,'Speed','fig');
saveas(f6,'Speed','pdf');
saveas(f6,'Speed','jpg');

f7=figure(7);
set(gcf,'color','white')
hold on
plot(time_points,P_R_to_T_gR*Frame_rate,'b','LineWidth',3);
set(gca,'FontSize',14)
xlabel('Time(s)')
ylabel('R->T | R (Hz)')
saveas(f7,'Run_to_Turn_gR','fig');
saveas(f7,'Run_to_Turn_gR','pdf');
saveas(f7,'Run_to_Turn_gR','jpg');

f8=figure(8);
set(gcf,'color','white')
hold on
plot(time_points,P_T_to_R_gT*Frame_rate,'g','LineWidth',3);
set(gca,'FontSize',14)
xlabel('Time(s)')
ylabel('T->R | T (Hz)')
saveas(f8,'Turn_to_Run_gT','fig');
saveas(f8,'Turn_to_Run_gT','pdf');
saveas(f8,'Turn_to_Run_gT','jpg');

cd(curr_dir)


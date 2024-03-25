function part2_bugsplat_maps_angles_rescrap_rev6(app,rev_folder,folder_names,sim_number,reliability,string_prop_model,grid_spacing,array_reliability_check,tf_calc_rx_angle,tf_recalculate,tf_tropo_cut,tf_server_status,array_bs_eirp_reductions,array_mitigation,tf_rescrap_pathloss)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Function:
cell_status_filename=strcat('cell_',string_prop_model,'_',num2str(sim_number),'_contour_angles_status.mat')
label_single_filename=strcat(string_prop_model,'_',num2str(sim_number),'_contour_angles_status')
location_table=table([1:1:length(folder_names)]',folder_names)


%%%%%%%%%%Need a list because going through 470 folders takes 17 minutes
[cell_status]=initialize_or_load_generic_status_rev1(app,folder_names,cell_status_filename);
if tf_recalculate==1
    cell_status(:,2)=num2cell(0);
end
zero_idx=find(cell2mat(cell_status(:,2))==0);
cell_status

if ~isempty(zero_idx)==1
    temp_folder_names=folder_names(zero_idx)
    num_folders=length(temp_folder_names);

    %%%%%%%%Pick a random folder and go to the folder to do the sim
    disp_progress(app,strcat('Mapping the Required Pathloss . . .'))
    reset(RandStream.getGlobalStream,sum(100*clock))  %%%%%%Set the Random Seed to the clock because all compiled apps start with the same random seed.

    [tf_ml_toolbox]=check_ml_toolbox(app);
    if tf_ml_toolbox==1
        array_rand_folder_idx=randsample(num_folders,num_folders,false);
    else
        array_rand_folder_idx=randperm(num_folders);
    end

    temp_folder_names(array_rand_folder_idx)
    disp_randfolder(app,num2str(array_rand_folder_idx'))

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [multi_hWaitbar,multi_hWaitbarMsgQueue]= ParForWaitbarCreateMH_time('Multi-Folder Mapping: ',num_folders);    %%%%%%% Create ParFor Waitbar

    for folder_idx=1:1:num_folders
        %%%server_status_rev1(app)
        server_status_rev2(app,tf_server_status)
        %%%%%%%%Before going to the sim folder, check one last time if we
        %%%%%%%%need to go to it, since another server may have already
        %%%%%%%%checked.


        %%%%%%%Load
        [cell_status]=initialize_or_load_generic_status_rev1(app,folder_names,cell_status_filename);
        if tf_recalculate==1
            cell_status(:,2)=num2cell(0);
        end
        sim_folder=temp_folder_names{array_rand_folder_idx(folder_idx)};
        temp_cell_idx=find(strcmp(cell_status(:,1),sim_folder)==1);

        if cell_status{temp_cell_idx,2}==0
            %%%%%%%%%%Calculate
            retry_cd=1;
            while(retry_cd==1)
                try
                    cd(rev_folder)
                    pause(0.1);
                    retry_cd=0;
                catch
                    retry_cd=1;
                    pause(0.1)
                end
            end

            retry_cd=1;
            while(retry_cd==1)
                try
                    sim_folder=temp_folder_names{array_rand_folder_idx(folder_idx)};
                    cd(sim_folder)
                    pause(0.1);
                    retry_cd=0;
                catch
                    retry_cd=1;
                    pause(0.1)
                end
            end

            disp_multifolder(app,sim_folder)
            data_label1=sim_folder;

            %%%%%%Check for the tf_complete_ITM file
            complete_filename=strcat(data_label1,'_',label_single_filename,'.mat'); %%%This is a marker for me
            [var_exist]=persistent_var_exist_with_corruption(app,complete_filename);
            if tf_recalculate==1
                var_exist=0
            end

            if var_exist==2
                retry_cd=1;
                while(retry_cd==1)
                    try
                        cd(rev_folder)
                        pause(0.1);
                        retry_cd=0;
                    catch
                        retry_cd=1;
                        pause(0.1)
                    end
                end

                %%%%%%%%Update the Cell
                [cell_status]=update_generic_status_cell_rev1(app,folder_names,sim_folder,cell_status_filename);
            else


                %%%%%Persistent Load the other variables
                disp_progress(app,strcat('Mapping: Loading Sim Data  . . .'))
                retry_load=1;
                while(retry_load==1)
                    try
                        load(strcat(data_label1,'_base_polygon.mat'),'base_polygon')
                        temp_data=base_polygon;
                        clear base_polygon;
                        base_polygon=temp_data;
                        clear temp_data;

                        load(strcat(data_label1,'_base_protection_pts.mat'),'base_protection_pts')
                        temp_data=base_protection_pts;
                        clear base_protection_pts;
                        base_protection_pts=temp_data;
                        clear temp_data;

                        load(strcat(data_label1,'_required_pathloss.mat'),'required_pathloss')
                        temp_data=required_pathloss;
                        clear required_pathloss;
                        required_pathloss=temp_data;
                        clear temp_data;

                        load(strcat(data_label1,'_sim_array_list_bs.mat'),'sim_array_list_bs')
                        temp_data=sim_array_list_bs;
                        clear sim_array_list_bs;
                        sim_array_list_bs=temp_data;
                        clear temp_data;
                        % % %      %%%%array_list_bs  %%%%%%%1) Lat, 2)Lon, 3)BS height, 4)BS EIRP 5) Nick Unique ID for each sector, 6)NLCD: R==1/S==2/U==3, 7) Azimuth 8)BS EIRP Mitigation


                        load(strcat(data_label1,'_radar_threshold.mat'),'radar_threshold')
                        temp_data=radar_threshold;
                        clear radar_threshold;
                        radar_threshold=temp_data;
                        clear temp_data;

                        if tf_calc_rx_angle==1 %%%%%%%Only need to load if we are doing the angles
                            %%%load(strcat(data_label1,'_array_ant_gain_vertical.mat'),'array_ant_gain_vertical')
                            load(strcat(data_label1,'_min_rx_ant_elevation.mat'),'min_rx_ant_elevation')
                            load(strcat(data_label1,'_pathloss_minus_rx_ant.mat'),'pathloss_minus_rx_ant')
                            load(strcat(data_label1,'_receiver_threshold.mat'),'receiver_threshold')
                            load(strcat(data_label1,'_multi_array_ant_gain_vertical.mat'),'multi_array_ant_gain_vertical')
                        end
                       
                        %%%%%%%%%%%%%%%%%%%%%These are typically only used in Aggregate Calculations
                        %%%load(strcat(data_label1,'_min_ant_loss.mat'),'min_ant_loss')
                        %%%load(strcat(data_label1,'_radar_beamwidth.mat'),'radar_beamwidth')


                        %%%%%%%%1-5 is the antenna gain for each protection point, and #6 is the elevation degree
                         retry_load=0;
                    catch
                        retry_load=1;
                        pause(0.1)
                    end
                end


                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%Load all the ITM pathloss data and TIREM angles

                %%%%%%Load all the pathloss data
                tic;
                [array_full_pl_data,full_prop_mode_data]=load_full_pathloss_info_multi_rel_rev3(app,data_label1,string_prop_model,grid_spacing,tf_rescrap_pathloss,base_protection_pts,sim_array_list_bs,sim_number,tf_tropo_cut,reliability);
                toc;

                %%%%%%%%array_full_pl_data=NaN(num_grid_pts,num_pts,num_rels);
                %%array_full_pl_data(:,point_idx,rel_idx)=pathloss(:,rel_idx);
                %%%num_rels=length(reliability)

         
                
                if tf_calc_rx_angle==1 %%%%%%Load the TIREM angles
                    %%%%%%%Load the Rx and Tx Angles
                    %%%%[array_full_pl_data,full_prop_mode_data,full_rx_angle_data]=load_full_pathloss_info_rev1(app,data_label1,'TIREM',grid_spacing,tf_rescrap_pathloss,base_protection_pts,sim_array_list_bs,sim_number,tf_tropo_cut);
                    [~,~,full_rx_angle_data,full_tx_angle_data]=load_full_pathloss_info_angles_rev4(app,data_label1,'TIREM',grid_spacing,tf_rescrap_pathloss,base_protection_pts,sim_array_list_bs,sim_number,tf_tropo_cut);
                    size(full_rx_angle_data)
                    size(full_tx_angle_data)
                    max(max(full_tx_angle_data))
                    max(max(full_rx_angle_data))

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 'use multi_array_ant_gain_vertical instead'
                    double_ant_gain_degrees=vertcat(flipud(-1*multi_array_ant_gain_vertical(:,end)),multi_array_ant_gain_vertical(:,end));
                    double_multi_ant_gain_dB=vertcat(flipud(multi_array_ant_gain_vertical(:,[1:end-1])),multi_array_ant_gain_vertical(:,[1:end-1]));
                    shift_double_ant_gain_degrees=double_ant_gain_degrees+min_rx_ant_elevation;

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Find the Off-Axis antenna gain based on the angle.
                    [num_tx_pts,num_rx_pts]=size(full_rx_angle_data)
                    full_rx_ant_gain=NaN(num_tx_pts,num_rx_pts);
                    for i=1:1:num_rx_pts
                        [idx_nn]=knnsearch(shift_double_ant_gain_degrees(:,1),full_rx_angle_data(:,i),'k',1); %%%Find Nearest Neighbor
                        full_rx_ant_gain(:,i)=double_multi_ant_gain_dB(idx_nn,i);
                    end

                    %%%%%%%%%%%%%%%%Calculate the Max Power Received
                    if length(array_bs_eirp_reductions)>1
                        'Need to check the size of array_bs_eirp_reductions and the dimensions of the output below'
                        pause;
                    end

                    full_pwr_rx_dBm=array_bs_eirp_reductions+full_rx_ant_gain-array_full_pl_data;
                    [max_pwr_rx_dBm,max_pwr_idx]=max(full_pwr_rx_dBm,[],2);

                    if length(reliability)>1
                        size(max_pwr_rx_dBm)
                        max_pwr_rx_dBm=squeeze(max_pwr_rx_dBm);
                        size(max_pwr_rx_dBm)

                    else
                        'Need to check sizes'
                        size(max_pwr_rx_dBm)
                        size(full_pwr_rx_dBm)
                        pause;

                    end
                    [num_grid_pts,~]=size(sim_array_list_bs);

                    %%%%%%%%%Convert to Margin Here: Number of Points x Number of Propagation Reliabilitities
                    array_margin_dB=max_pwr_rx_dBm-receiver_threshold;
                    size(array_margin_dB)

                    min(array_margin_dB)
                    max(array_margin_dB)

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%This is the data to plot 
                    num_rels=length(reliability);
                    min_rx_angle_data=NaN(num_tx_pts,1);
                    min_rx_ant_gain=NaN(num_tx_pts,1);
                    min_pl_data=NaN(num_tx_pts,num_rels);
                    min_prop_data=NaN(num_tx_pts,1);
                    for i=1:1:num_tx_pts
                        min_rx_angle_data(i)=full_rx_angle_data(i,max_pwr_idx(i));
                        min_rx_ant_gain(i)=full_rx_ant_gain(i,max_pwr_idx(i));
                        min_prop_data(i)=full_prop_mode_data(i,max_pwr_idx(i));
                        for rel_idx=1:1:num_rels
                            min_pl_data(i,rel_idx)=array_full_pl_data(i,max_pwr_idx(i),rel_idx);
                        end
                    end

                    %%%%%%%%%%%%%Can also plot the power received for each
                    %%%%%%%%%%%%%reliability will need to update the
                    %%%%%%%%%%%%%function
                    %plot_power_received_heatmap_rev1(app,sim_array_list_bs,max_pwr_rx_dBm,data_label1,string_prop_model,grid_spacing,base_protection_pts)

                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Rx Angle Heat Map 


%                 %%%%%%%%%%%%%%%%Rx Launch Angle  Heat Map
%                 mode_color_set_angles=plasma(100);
%                 f1=figure;
%                 AxesH = axes;
%                 hold on;
%                 scatter(sim_array_list_bs(1,2),sim_array_list_bs(1,1),10,max(edges),'filled');
%                 scatter(sim_array_list_bs(1,2),sim_array_list_bs(1,1),10,min(edges),'filled');
%                 scatter(sim_array_list_bs(:,2),sim_array_list_bs(:,1),10,min_rx_angle_data,'filled');
%                 plot(base_protection_pts(:,2),base_protection_pts(:,1),'xr','LineWidth',3,'DisplayName','Federal System')
%                 %plot(base_protection_pts(:,2),base_protection_pts(:,1),'ob','LineWidth',3,'DisplayName','Federal System')
%                 cbh = colorbar;
%                 ylabel(cbh, 'Elevation Angle [Degrees]')
%                 colormap(f1,mode_color_set_angles)
%                 grid on;
%                 xlabel('Longitude')
%                 ylabel('Latitude')
%                 title({strcat('Received Elevation Angle')})
%                 plot_google_map('maptype','terrain','APIKey','AIzaSyCgnWnM3NMYbWe7N4svoOXE7B2jwIv28F8') %%%Google's API key made by nick.matlab.error@gmail.com
%                 pause(0.1)
%                 filename1=strcat('Launch_Angles','_',data_label1,'_',string_prop_model,'_',num2str(grid_spacing),'km.png');
%                 saveas(gcf,char(filename1))
%                 pause(0.1);
%                 close(f1)


%                 %%%%%%%%%%%%%%%%Rx Antenna Gain Heat Map
%                 floor(min(min_rx_ant_gain))
%                 ceil(max(min_rx_ant_gain))
%                 f1=figure;
%                 AxesH = axes;
%                 hold on;
%                 scatter(sim_array_list_bs(1,2),sim_array_list_bs(1,1),10,floor(min(min_rx_ant_gain)),'filled');
%                 scatter(sim_array_list_bs(1,2),sim_array_list_bs(1,1),10,ceil(max(min_rx_ant_gain)),'filled');
%                 scatter(sim_array_list_bs(:,2),sim_array_list_bs(:,1),10,min_rx_ant_gain,'filled');
%                 plot(base_protection_pts(:,2),base_protection_pts(:,1),'xr','LineWidth',3,'DisplayName','Federal System')
%                 %plot(base_protection_pts(:,2),base_protection_pts(:,1),'ob','LineWidth',3,'DisplayName','Federal System')
%                 cbh = colorbar;
%                 ylabel(cbh, 'Antenna Gain [dBi]')
%                 colormap(f1,mode_color_set_angles)
%                 grid on;
%                 xlabel('Longitude')
%                 ylabel('Latitude')
%                 title({strcat('Receiver Antena Gain')})
%                 plot_google_map('maptype','terrain','APIKey','AIzaSyCgnWnM3NMYbWe7N4svoOXE7B2jwIv28F8') %%%Google's API key made by nick.matlab.error@gmail.com
%                 pause(0.1)
%                 filename1=strcat('Rx_Ant_Gain_Heatmap','_',data_label1,'_',string_prop_model,'_',num2str(grid_spacing),'km.png');
%                 saveas(gcf,char(filename1))
%                 pause(0.1);
%                 close(f1)


%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%These are the angles that are used.
%                 edges=floor(min(min_rx_angle_data)):0.5:ceil(max(min_rx_angle_data))
%                 f1=figure;
%                 AxesH = axes;
%                 hold on;
%                 histogram(min_rx_angle_data,edges,'Normalization','probability')
%                 grid on;
%                 xlabel('Launch Angle [Degrees]')
%                 ylabel('Probability of Occurrence')
%                 title({strcat('Rx Launch Angle')})
%                 filename1=strcat('Launch_Angles_Histogram','_',data_label1,'_',string_prop_model,'.png');
%                 saveas(gcf,char(filename1))
%                 pause(0.1);
%                 close(f1)

% %                 %%%%%%%%%%%%%%%%%%%%%%%%%%%These are the angles that are used.
% %                 edges=floor(min(min_rx_angle_data)):0.5:ceil(max(min_rx_angle_data))
% %                 f1=figure;
% %                 AxesH = axes;
% %                 hold on;
% %                 histogram(min_rx_angle_data,edges,'Normalization','probability')
% %                 grid on;
% %                 xlabel('Vertical Receive Angle [Degrees]')
% %                 ylabel('Probability of Occurrence')
% %                 title({strcat('Histogram')})
% %                 filename1=strcat('Launch2_Angles_Histogram','_',data_label1,'_',string_prop_model,'.png');
% %                 saveas(gcf,char(filename1))
% %                 pause(0.1);
% %                 %close(f1)

                else
                    'Need to put the data in a form so the plot functions can handle angles and non angles::: array_margin_dB'
                    'run a NSF RA example through'
                    pause;


                end


                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Pathloss Heat Map for each Reliability
                plot_pathloss_heatmat_reli_rev2(app,array_reliability_check,min_pl_data,data_label1,string_prop_model,grid_spacing,sim_array_list_bs,base_protection_pts)
                plot_prop_mechanism_heatmap_rev1(app,data_label1,string_prop_model,grid_spacing,sim_array_list_bs,min_prop_data,base_protection_pts)

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Find/Plot the Coordination Zones for each reliability
                file_name_cell_bound_miti=strcat('cell_bound_',string_prop_model,'_',num2str(sim_number),'_',data_label1,'.mat');
                

                num_miti=length(array_mitigation);
                num_rels=length(array_reliability_check);
                cell_bound_miti=cell(num_miti,5,num_rels); 
                %%%%1)Mitigation, 
                % %%2) Max knn dist, 
                % %%3)Convex Bound, 
                % %%4)Max Interference dB, 
                % %%%5)Prop Reliability
                for rel_idx=1:1:num_rels
                    for miti_idx=1:1:num_miti
                        miti_dB=array_mitigation(miti_idx);
                        temp_rel=array_reliability_check(rel_idx);
                        temp_margin=array_margin_dB(:,rel_idx)-miti_dB;

                        idx_keep=find(temp_margin>=0);
                        if ~isempty(idx_keep)
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Calculate the coordination zone
                            [max_knn_dist,convex_bound,max_int_dB]=plot_zone_miti_reli_rev2(app,temp_margin,sim_array_list_bs,base_protection_pts,data_label1,string_prop_model,temp_rel,grid_spacing,miti_dB);
                            cell_bound_miti{miti_idx,1,rel_idx}=miti_dB;
                            cell_bound_miti{miti_idx,2,rel_idx}=max_knn_dist;
                            cell_bound_miti{miti_idx,3,rel_idx}=convex_bound;
                            cell_bound_miti{miti_idx,4,rel_idx}=max_int_dB;
                            cell_bound_miti{miti_idx,5,rel_idx}=temp_rel;
                        end
                    end
                    %%%%%%%%%%%%%Plot the multi-zones, for each Reliability
                    temp_zones=cell_bound_miti(:,:,rel_idx);
                    plot_multi_zones_reli_rev3(app,temp_zones,base_protection_pts,data_label1,string_prop_model,temp_rel,grid_spacing)
                end

                cell_bound_miti


                %%%%%%%%%%Save
                retry_save=1;
                while(retry_save==1)
                    try
                        save(file_name_cell_bound_miti,'cell_bound_miti')
                        pause(0.1);
                        retry_save=0;
                    catch
                        retry_save=1;
                        pause(0.1)
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%Save
                retry_save=1;
                while(retry_save==1)
                    try
                        comp_list=NaN(1);
                        save(complete_filename,'comp_list')
                        pause(0.1);
                        retry_save=0;
                    catch
                        retry_save=1;
                        pause(0.1)
                    end
                end

                retry_cd=1;
                while(retry_cd==1)
                    try
                        cd(rev_folder)
                        pause(0.1);
                        retry_cd=0;
                    catch
                        retry_cd=1;
                        pause(0.1)
                    end
                end
                [cell_status]=update_generic_status_cell_rev1(app,folder_names,sim_folder,cell_status_filename)
                %%%server_status_rev1(app)
                server_status_rev2(app,tf_server_status)
            end
        end
        multi_hWaitbarMsgQueue.send(0);
    end
    delete(multi_hWaitbarMsgQueue);
    close(multi_hWaitbar);
end
%%%%server_status_rev1(app)
server_status_rev2(app,tf_server_status)

end
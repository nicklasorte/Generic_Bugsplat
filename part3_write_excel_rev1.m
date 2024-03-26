function part3_write_excel_rev1(app,rev_folder,folder_names,sim_number,reliability,string_prop_model,grid_spacing,tf_recalculate,tf_tropo_cut)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Function:
cell_status_filename=strcat('cell_',string_prop_model,'_',num2str(sim_number),'_excel_output_status.mat')
label_single_filename=strcat(string_prop_model,'_',num2str(sim_number),'_excel_output_status')
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
    disp_progress(app,strcat('Excel Output . . .'))
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
    [multi_hWaitbar,multi_hWaitbarMsgQueue]= ParForWaitbarCreateMH_time('Multi-Folder Excel: ',num_folders);    %%%%%%% Create ParFor Waitbar

    for folder_idx=1:1:num_folders
        server_status_rev1(app)
        %%%%%%%%Before going to the sim folder, check one last time if we
        %%%%%%%%need to go to it, since another server may have already
        %%%%%%%%checked.


        %%%%%%%Load
        [cell_status]=initialize_or_load_generic_status_rev1(app,folder_names,cell_status_filename);
        if tf_recalculate==1
            cell_status(:,2)=num2cell(0);
        end
        %%%%sim_folder='NRQZ'
        %sim_folder='OwensValleyCA_VLBA'
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
                    %%%%%sim_folder='NRQZ'
                    %sim_folder='OwensValleyCA_VLBA'
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

% %                         load(strcat(data_label1,'_radar_threshold.mat'),'radar_threshold')
% %                         temp_data=radar_threshold;
% %                         clear radar_threshold;
% %                         radar_threshold=temp_data;
% %                         clear temp_data;

                        retry_load=0;
                    catch
                        retry_load=1;
                        pause(0.1)
                    end
                end



                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                num_rel=length(reliability)
                if num_rel>1
                    'Need to update this below'
                    pause;
                end

                 %%%Export the pathloss data, 1 sheet for each point
                [num_sim_pts,~]=size(base_protection_pts)
                [num_tx,~]=size(sim_array_list_bs);
                zero_miti_pathloss=required_pathloss(1);
                for point_idx=1:1:num_sim_pts

                    %%%%%%Load all the pathloss data
                     %%%%%%%%%'Load all the point pathloss calculations'
                        %%%%%%Persistent Load
                        file_name_pathloss=strcat(string_prop_model,'_pathloss_',num2str(point_idx),'_',num2str(sim_number),'_',data_label1,'.mat');
                        retry_load=1;
                        while(retry_load==1)
                            try
                                load(file_name_pathloss,'pathloss')
                                retry_load=0;
                            catch
                                retry_load=1;
                                'Having trouble loading pathloss . . .'
                                pause(1)
                            end
                        end

                    temp_sim_pt=base_protection_pts(point_idx,:);
                    off_idx=find(zero_miti_pathloss>pathloss);

                    %%%%temp_pl_data(off_idx)

                    %%%%%%%%%%Make a table: 
                        % %%%%%%%%1) Uni_Id
                        % %%%%%%%%2) BS_Latitude_DD 
                        % %%%%%%%%3) BS_Longitude_DD 
                        % %%%%%%%%4) BS_Height_m 
                        % %%%%%%%%5) Fed_Latitude_DD 
                        % %%%%%%%%6) Fed_Longitude_DD
                        % %%%%%%%%7) Fed_Height_m
                        % %%%%%%%%8) BS_EIRP_dBm
                        %%%%%%%%%%9) Path_Loss_dB
                        %%%%%%%%%%10) Inside Coordination Zone

                        array_excel_data=horzcat(sim_array_list_bs(:,5),sim_array_list_bs(:,[1,2,3]),temp_sim_pt.*ones(num_tx,1),sim_array_list_bs(:,[4]),pathloss);
                        array_excel_data(off_idx,end+1)=1;  %%%%%%%%%%%Inside the coordination Zone

% % %                         array_excel_data([1:10],:)
% % %                         array_excel_data(off_idx,:)
% % %                         size(array_excel_data)

                        table_excel_data=array2table(array_excel_data);
                        table_excel_data.Properties.VariableNames={'Uni_Id' 'BS_Latitude_DD' 'BS_Longitude_DD' 'BS_Height_m' 'Fed_Latitude_DD' 'Fed_Longitude_DD' 'Fed_Height_m' 'BS_EIRP_dBm' 'Path_Loss_dB' 'TF_Inside_Zone'};
                        disp_progress(app,strcat('Writing Excel File . . . '))
                        tic;
                        writetable(table_excel_data,strcat(data_label1,'_Point',num2str(point_idx),'_',string_prop_model,'.xlsx'));
                        toc;  %%%%%%A few seconds
                    
                end

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
                server_status_rev1(app)
            end
        end
        multi_hWaitbarMsgQueue.send(0);
    end
    delete(multi_hWaitbarMsgQueue);
    close(multi_hWaitbar);
end
server_status_rev1(app)

end
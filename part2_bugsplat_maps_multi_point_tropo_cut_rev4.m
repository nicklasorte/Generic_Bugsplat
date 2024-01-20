function part2_bugsplat_maps_multi_point_tropo_cut_rev4(app,rev_folder,folder_names,sim_number,string_prop_model,grid_spacing,tf_recalculate,tf_tropo_cut,array_mitigation)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Function:
cell_status_filename=strcat('cell_',string_prop_model,'_',num2str(sim_number),'_tropo_contour_status.mat')
label_single_filename=strcat(string_prop_model,'_',num2str(sim_number),'_tropo_contour_status')
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
        server_status_rev1(app)
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

                        retry_load=0;
                    catch
                        retry_load=1;
                        pause(0.1)
                    end
                end


                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                [array_full_pl_data,full_prop_mode_data,~]=load_full_pathloss_info_rev1(app,data_label1,string_prop_model,grid_spacing,tf_recalculate,base_protection_pts,sim_array_list_bs,sim_number,tf_tropo_cut);

                [min_full_pl_data,min_pl_idx]=min(array_full_pl_data,[],2);
                [num_grid_pts,~]=size(sim_array_list_bs);
                min_prop_data=NaN(num_grid_pts,1);
                for i=1:1:num_grid_pts
                    min_prop_data(i)=full_prop_mode_data(i,min_pl_idx(i));
                end


                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%Propagation Mechanism Heat Map: ITM      'plot the tropo/diff/Los map next'  %%%min_prop_data
                %plot_prop_mechanism_heatmap_rev1(app,data_label1,string_prop_model,grid_spacing,sim_array_list_bs,min_prop_data,base_protection_pts)


                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Calculate the Coordination Zones
                num_miti=length(array_mitigation);

                %%%%%%Check for cell_miti_data
                filename_cell_miti_data=strcat(data_label1,'_cell_miti_data_',string_prop_model,'_',num2str(num_miti),'_',num2str(grid_spacing),'km.mat');
                [var_exist_cell_miti_data]=persistent_var_exist_with_corruption(app,filename_cell_miti_data);
                if tf_recalculate==1
                    var_exist_cell_miti_data=0;
                end
                if var_exist_cell_miti_data==2
                    retry_load=1;
                    while(retry_load==1)
                        try
                            load(filename_cell_miti_data,'cell_miti_data')
                            pause(0.1)
                            retry_load=0;
                        catch
                            retry_load=1;
                            pause(1)
                        end
                    end
                    pause(0.1)
                else

                    [cell_miti_data]=calculate_and_plot_pathloss_coordination_rev1(app,data_label1,array_mitigation,required_pathloss,min_full_pl_data,base_protection_pts,sim_array_list_bs,grid_spacing,string_prop_model);

                    retry_save=1;
                    while(retry_save==1)
                        try
                            save(filename_cell_miti_data,'cell_miti_data')
                            pause(0.1)
                            retry_save=0;
                        catch
                            retry_save=1;
                            pause(1)
                        end
                    end
                    pause(0.1)
                end

        
  
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Plot the multiple circles
                plot_multi_zones_rev2(app,cell_miti_data,base_protection_pts,data_label1,string_prop_model,grid_spacing)

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
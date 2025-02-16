function part4_census_pop_impact_rev6(app,rev_folder,folder_names,sim_number,string_prop_model,grid_spacing,tf_recalculate,array_mitigation,tf_server_status)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Function:
cell_status_filename=strcat('cell_',string_prop_model,'_',num2str(sim_number),'_pop_impact_status.mat')
label_single_filename=strcat(string_prop_model,'_',num2str(sim_number),'_pop_impact_status')
location_table=table([1:1:length(folder_names)]',folder_names)
server_status_rev2(app,tf_server_status)


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

    retry_load=1;
    while(retry_load==1)
        try
            load('Cascade_new_full_census_2010.mat','new_full_census_2010')%%%%%%%Geo Id, Center Lat, Center Lon,  NLCD (1-4), Population
            retry_load=0;
        catch
            retry_load=1;
            pause(0.1)
        end
    end

    %%%%%%%%Pick a random folder and go to the folder to do the sim
    disp_progress(app,strcat('Finding Pop Impact . . .'))
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
    [multi_hWaitbar,multi_hWaitbarMsgQueue]= ParForWaitbarCreateMH_time('Multi-Folder Pop: ',num_folders);    %%%%%%% Create ParFor Waitbar

    for folder_idx=1:1:num_folders
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

            %%%%%%Check for the tf_complete file
            complete_filename=strcat(data_label1,'_',label_single_filename,'.mat'); %%%This is a marker for me
            [var_exist]=persistent_var_exist_with_corruption(app,complete_filename);
            if tf_recalculate==1
                var_exist=0;
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

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Load the data.
                num_miti=length(array_mitigation);

                %%%%%%Check for cell_miti_data
                 file_name_cell_bound_miti=strcat('cell_bound_',string_prop_model,'_',num2str(sim_number),'_',data_label1,'.mat');
                             
                [var_exist_cell_miti_data]=persistent_var_exist_with_corruption(app,file_name_cell_bound_miti);
                if var_exist_cell_miti_data==2
                    retry_load=1;
                    while(retry_load==1)
                        try
                            load(file_name_cell_bound_miti,'cell_bound_miti')
                            %%%%1)Mitigation,
                            % %%2) Max knn dist,
                            % %%3)Convex Bound,
                            % %%4)Max Interference dB,
                            % %%%5)Prop Reliability
                        
                            pause(0.1)
                            retry_load=0;
                        catch
                            retry_load=1;
                            pause(1)
                        end
                    end
                    pause(0.1)
                else
                     disp_progress(app,strcat('Error: No cell_bound_miti . . .'))
                    pause;
                end

         
                cell_bound_miti=cell_bound_miti(~cellfun(@isempty,cell_bound_miti(:,1)),:,1)
                %%%%%'Only keep the first reliability'

                size(cell_bound_miti)
                [num_rows,~]=size(cell_bound_miti);
                cell_contour_pop=cell(num_rows,2); %%%%%1) GeoId, 2) Total Pop

                mid_lat=new_full_census_2010(:,2);
                mid_lon=new_full_census_2010(:,3);
                census_latlon=horzcat(mid_lat,mid_lon);
                census_pop=new_full_census_2010(:,5);
                census_geoid=new_full_census_2010(:,1);
          
                %%%%%%%%%%%For Each contour
                tic;
                for row_idx=1:1:num_rows
                    temp_contour_latlon=cell_bound_miti{row_idx,3};
                    [inside_idx]=find_points_inside_contour_two_step(app,temp_contour_latlon,census_latlon);
                    
                    if ~isempty(inside_idx)
                        cell_contour_pop{row_idx,1}=census_geoid(inside_idx);
                        cell_contour_pop{row_idx,2}=sum(census_pop(inside_idx));

                        % % % figure;
                        % % % hold on;
                        % % % plot(temp_contour_latlon(:,2),temp_contour_latlon(:,1),'-r')
                        % % % plot(census_latlon(inside_idx,2),census_latlon(inside_idx,1),'xb')
                        % % % grid on;
                        % % % plot_google_map('maptype','terrain','APIKey','AIzaSyCgnWnM3NMYbWe7N4svoOXE7B2jwIv28F8') %%%Google's API key made by nick.matlab.error@gmail.com
                        % % % pause(0.1)
                    else
                        cell_contour_pop{row_idx,2}=0;
                    end
                end
                toc;
                cell_miti_contour_pop=horzcat(cell_bound_miti,cell_contour_pop)
                size(cell_bound_miti)
                size(cell_miti_contour_pop)
                


                %%%%%%Check for cell_miti_data
                filename_cell_contour_pop=strcat(data_label1,'_cell_miti_contour_pop_',string_prop_model,'_',num2str(num_miti),'_',num2str(grid_spacing),'km.mat');

                retry_save=1;
                while(retry_save==1)
                    try
                        save(filename_cell_contour_pop,'cell_miti_contour_pop')
                        pause(0.1)
                        retry_save=0;
                    catch
                        retry_save=1;
                        pause(1)
                    end
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
                [cell_status]=update_generic_status_cell_rev1(app,folder_names,sim_folder,cell_status_filename);
                server_status_rev2(app,tf_server_status)
            end
        end
        multi_hWaitbarMsgQueue.send(0);
    end
    delete(multi_hWaitbarMsgQueue);
    close(multi_hWaitbar);
end
server_status_rev2(app,tf_server_status)
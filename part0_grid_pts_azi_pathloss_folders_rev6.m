function part0_grid_pts_azi_pathloss_folders_rev6(app,sim_number,tx_height_m,bs_eirp_reductions,grid_spacing,rev_folder,tf_server_status,cell_sim_data,array_dist_pl,sim_scale_factor,tf_clutter)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Function:
server_status_rev2(app,tf_server_status)
cell_status_filename=strcat('cell_',num2str(sim_number),'_grid_points_status.mat')
label_single_filename=strcat('file_',num2str(sim_number),'_grid_points_status')
checkout_filename=strcat('TF_checkout',num2str(sim_number),'_grid_points_status.mat')


%%%%%%%%%%%%%Need to feed in the the folder names we need
data_label_idx=find(matches(cell_sim_data(1,:),'data_label1'));
create_folder_names=cell_sim_data(2:end,data_label_idx);

tf_update_cell_status=0;
sim_folder='';  %%%%%Empty sim_folder to not update.
[cell_status]=checkout_cell_status_rev1(app,checkout_filename,cell_status_filename,sim_folder,create_folder_names,tf_update_cell_status);

%%%[cell_status]=initialize_or_load_generic_status_expand_rev3(app,cell_status_filename,create_folder_names);
zero_idx=find(cell2mat(cell_status(:,2))==0);
size(create_folder_names)
size(cell_status)
size(zero_idx)


% % % %%%%%%%%%%Need a list because going through 470 folders takes 17 minutes
% % % %[cell_status]=initialize_or_load_generic_status_rev1(app,folder_names,cell_status_filename);
% % % [cell_status,folder_names]=initialize_or_load_generic_status_expand_rev2(app,rev_folder,cell_status_filename);
% % % zero_idx=find(cell2mat(cell_status(:,2))==0);
% % % cell_status


if ~isempty(zero_idx)==1
    temp_folder_names=create_folder_names(zero_idx);
    num_folders=length(temp_folder_names);

    %%%%%%%%Pick a random folder and go to the folder to do the sim
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
    [multi_hWaitbar,multi_hWaitbarMsgQueue]= ParForWaitbarCreateMH_time('Multi-Folder Grid Points: ',num_folders);    %%%%%%% Create ParFor Waitbar
    for folder_idx=1:1:num_folders
        disp_TextArea_PastText(app,strcat('Part0 Grid Points:',num2str(num_folders-folder_idx)))
        %%%%%%%%Before going to the sim folder, check one last time if we
        %%%%%%%%need to go to it, since another server may have already
        %%%%%%%%checked.
        %%%%%%%%%%%%%%%%%%%%%%This might be killing us with this cell_status check. 

         %%%%%%%%%%%%%%Check cell_status
        tf_update_cell_status=0;
        sim_folder='';
        [cell_status]=checkout_cell_status_rev1(app,checkout_filename,cell_status_filename,sim_folder,create_folder_names,tf_update_cell_status);

        sim_folder=temp_folder_names{array_rand_folder_idx(folder_idx)};
        temp_cell_idx=find(strcmp(cell_status(:,1),sim_folder)==1);

        % % %%%%%%%Load
        % % [cell_status]=initialize_or_load_generic_status_while_rev4_debug(app,create_folder_names,cell_status_filename);  
        % % sim_folder=temp_folder_names{array_rand_folder_idx(folder_idx)};
        % % temp_cell_idx=find(strcmp(cell_status(:,1),sim_folder)==1);

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

            %%%%%%Check to see if we need to make a new folder
            [~,folder_names,~]=check_rev_folders(app,rev_folder);
            folder_row_idx=find(matches(folder_names,sim_folder));
            if isempty(folder_row_idx)
                %%%%%'Create the folder'
                status=0;
                while status==0
                    [status,msg,msgID]=mkdir(sim_folder);
                end
            end

            %%%%%%%%%%%%%%Go to the folder
            retry_cd=1;
            while(retry_cd==1)
                try
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
                %%%%%%%%Update the cell_status
                %%%%[cell_status]=update_generic_status_cell_rev1(app,folder_names,sim_folder,cell_status_filename);
                %[~]=update_generic_status_cell_rev1_debug(app,create_folder_names,sim_folder,cell_status_filename); 

                %%%%%%%%Update the cell_status
                tf_update_cell_status=1;
                tic;
                [~]=checkout_cell_status_rev1(app,checkout_filename,cell_status_filename,sim_folder,create_folder_names,tf_update_cell_status);
                toc;
            else
                data_row_idx=find(matches(cell_sim_data(:,1),sim_folder));
                if isempty(data_row_idx)
                    disp_progress(app,strcat('Pause Error: Data is not there in the cell_sim_data. . . '))
                    pause;
                end
                temp_single_cell_sim_data=cell_sim_data(data_row_idx,:);
                data_header=cell_sim_data(1,:)';


                %%%%%%%%%%Check for data, at least save it.               
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                pp_pt_idx=find(matches(data_header,'base_protection_pts'))
                base_protection_pts=temp_single_cell_sim_data{pp_pt_idx}
                filename_base_protection_pts=strcat(data_label1,'_base_protection_pts.mat');
                [var_exist_pp_pts]=persistent_var_exist_with_corruption(app,filename_base_protection_pts);
                if var_exist_pp_pts~=2
                    retry_save=1;
                    while(retry_save==1)
                        try
                            save(filename_base_protection_pts,'base_protection_pts')
                            pause(0.1);
                            retry_save=0;
                        catch
                            retry_save=1;
                            pause(0.1)
                        end
                    end
                end

                poly_idx=find(matches(data_header,'base_polygon'))
                base_polygon=temp_single_cell_sim_data{poly_idx};
                filename_base_polygon=strcat(data_label1,'_base_polygon.mat');
                [var_exist_base_poly]=persistent_var_exist_with_corruption(app,filename_base_polygon);
                if var_exist_base_poly~=2
                    retry_save=1;
                    while(retry_save==1)
                        try
                            save(filename_base_polygon,'base_polygon')
                            pause(0.1);
                            retry_save=0;
                        catch
                            retry_save=1;
                            pause(0.1)
                        end
                    end
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%Step 0. Calculate the pathloss as a function of azimuth
                min_azi_idx=find(matches(data_header,'min_azimuth'))
                min_azimuth=temp_single_cell_sim_data{min_azi_idx};

                max_azi_idx=find(matches(data_header,'max_azimuth'))
                max_azimuth=temp_single_cell_sim_data{max_azi_idx};

                ant_bw_idx=find(matches(data_header,'ant_hor_beamwidth'))
                ant_beamwidth=temp_single_cell_sim_data{ant_bw_idx};

                min_ant_idx=find(matches(data_header,'min_ant_loss'))
                min_ant_loss=temp_single_cell_sim_data{min_ant_idx};%     % % 12) Main to side gain:

                re_path_idx=find(matches(data_header,'required_pathloss'))
                required_pathloss=temp_single_cell_sim_data{re_path_idx};
                [azi_required_pathloss]=create_save_load_azi_required_pathloss_rev2(app,data_label1,ant_beamwidth,min_ant_loss,min_azimuth,max_azimuth,required_pathloss,array_dist_pl,sim_scale_factor);
                [wider_keyhole]=create_save_load_wider_keyhole_rev2(app,data_label1,azi_required_pathloss,tf_clutter,min_azimuth,max_azimuth,ant_beamwidth,array_dist_pl,sim_scale_factor);


                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%STEP 1: Create a buffer around the base
                disp_TextArea_PastText(app,strcat('Part0: base_buffer_azi_multi_rev4: Line 183'))
                [base_buffer]=base_buffer_azi_multi_rev4(app,wider_keyhole,data_label1,base_protection_pts);
                disp_TextArea_PastText(app,strcat('Part0: base_buffer_azi_multi_rev4: Line 185'))

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Step 2: Generate Grid Points
                buffer_km=ceil(max(wider_keyhole(:,3)));
                [grid_points]=wrapper_grid_points_rev2_outside_USA(app,data_label1,buffer_km,grid_spacing,base_buffer,base_polygon,tx_height_m);

                [num_tx,~]=size(grid_points)
                sim_array_list_bs=horzcat(grid_points,NaN(num_tx,2));
                sim_array_list_bs(:,4)=bs_eirp_reductions;
                sim_array_list_bs(:,5)=1:1:num_tx;

                % % %      %%%%array_list_bs  %%%%%%%1) Lat, 2)Lon, 3)BS height, 4)BS EIRP Adjusted 5) Nick Unique ID for each sector, 6)NLCD: R==1/S==2/U==3, 7) Azimuth 8)BS EIRP Mitigation


                if grid_spacing>=10
                    % f10=figure;
                    % AxesH = axes;
                    % hold on;
                    % scatter(grid_points(:,2),grid_points(:,1),10,'r','filled','DisplayName','Grid Points')
                    % plot(base_protection_pts(:,2),base_protection_pts(:,1),'xk','LineWidth',3,'DisplayName','Federal System')
                    % plot(base_buffer(:,2),base_buffer(:,1),'-b','LineWidth',3,'DisplayName','Simulation Area')
                    % grid on;
                    % legend
                    % xlabel('Longitude')
                    % ylabel('Latitude')
                    % plot_google_map('maptype','terrain','APIKey','AIzaSyCgnWnM3NMYbWe7N4svoOXE7B2jwIv28F8') %%%Google's API key made by nick.matlab.error@gmail.com
                    % pause(0.1)
                    % filename1=strcat('Sim_Area_Grid','_',data_label1,'_',num2str(grid_spacing),'km.png');
                    % saveas(gcf,char(filename1))
                    % pause(0.1);
                    % close(f10)

                    f10=figure;
                    geoscatter(grid_points(:,1),grid_points(:,2),5,'r','filled','DisplayName','Grid Points')
                    hold on;
                    geoplot(base_protection_pts(:,1),base_protection_pts(:,2),'xk','LineWidth',3,'DisplayName','Federal System')
                    geoplot(base_buffer(:,1),base_buffer(:,2),'-b','LineWidth',3,'DisplayName','Simulation Area')
                    grid on;
                    legend
                    title('Sim Area')
                    geobasemap landcover
                    pause(2)
                    filename1=strcat('Sim_Area_Grid','_',data_label1,'_',num2str(grid_spacing),'km.png');
                    saveas(gcf,char(filename1))
                    pause(0.1);
                    close(f10)                    
                end
         
                retry_save=1;
                while(retry_save==1)
                    try
                        save(strcat(data_label1,'_sim_array_list_bs.mat'),'sim_array_list_bs')
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
                %%%%%%%%Update the cell_status
                %%%%[cell_status]=update_generic_status_cell_rev1(app,folder_names,sim_folder,cell_status_filename);
                %%%[~]=update_generic_status_cell_rev1_debug(app,create_folder_names,sim_folder,cell_status_filename); 
                 %%%%%%%%Update the cell_status
                tf_update_cell_status=1;
                tic;
                [~]=checkout_cell_status_rev1(app,checkout_filename,cell_status_filename,sim_folder,create_folder_names,tf_update_cell_status);
                toc;
                server_status_rev2(app,tf_server_status)
            end
        end
        multi_hWaitbarMsgQueue.send(0);
    end
    delete(multi_hWaitbarMsgQueue);
    close(multi_hWaitbar);


    %%%%%%%%%%If we make it here, just mark all the cell_status as complete
    finish_cell_status_rev1(app,rev_folder,cell_status_filename)
end
server_status_rev2(app,tf_server_status)




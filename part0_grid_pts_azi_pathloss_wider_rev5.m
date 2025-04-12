function part0_grid_pts_azi_pathloss_wider_rev5(app,sim_number,folder_names,tx_height_m,bs_eirp_reductions,grid_spacing,rev_folder,tf_server_status)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Function:
server_status_rev2(app,tf_server_status)
cell_status_filename=strcat('cell_',num2str(sim_number),'_grid_points_status.mat')
label_single_filename=strcat('file_',num2str(sim_number),'_grid_points_status')
%location_table=table([1:1:length(folder_names)]',folder_names)

%%%%%%%%%%Need a list because going through 470 folders takes 17 minutes
%[cell_status]=initialize_or_load_generic_status_rev1(app,folder_names,cell_status_filename);
[cell_status,folder_names]=initialize_or_load_generic_status_expand_rev2(app,rev_folder,cell_status_filename);
zero_idx=find(cell2mat(cell_status(:,2))==0);
cell_status


if ~isempty(zero_idx)==1
    temp_folder_names=folder_names(zero_idx)
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
        %%%%%%%%Before going to the sim folder, check one last time if we
        %%%%%%%%need to go to it, since another server may have already
        %%%%%%%%checked.

        %%%%%%%Load
        [cell_status]=initialize_or_load_generic_status_rev1(app,folder_names,cell_status_filename);
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
            data_label1=sim_folder

            %%%%%%Check for the tf_complete_ITM file
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
                %%%%%%%%Update the Cell
                [cell_status]=update_generic_status_cell_rev1(app,folder_names,sim_folder,cell_status_filename);
            else
                disp_progress(app,strcat('Loading Sim Data: Grid Points . . . '))
                %%%%%Persistent Load the other variables
                retry_load=1;
                while(retry_load==1)
                    try
                        % load(strcat(data_label1,'_min_ant_loss.mat'),'min_ant_loss')
                        % temp_data=min_ant_loss;
                        % clear min_ant_loss;
                        % min_ant_loss=temp_data;
                        % clear temp_data;

                        % % % load(strcat(data_label1,'_required_pathloss.mat'),'required_pathloss')
                        % % % temp_data=required_pathloss;
                        % % % clear required_pathloss;
                        % % % required_pathloss=temp_data;
                        % % % clear temp_data;

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

                        % load(strcat(data_label1,'_min_azimuth.mat'),'min_azimuth')
                        % temp_data=min_azimuth;
                        % clear min_azimuth;
                        % min_azimuth=temp_data;
                        % clear temp_data;

                        % load(strcat(data_label1,'_max_azimuth.mat'),'max_azimuth')
                        % temp_data=max_azimuth;
                        % clear max_azimuth;
                        % max_azimuth=temp_data;
                        % clear temp_data;

                        % load(strcat(data_label1,'_ant_beamwidth.mat'),'ant_beamwidth')
                        % temp_data=ant_beamwidth;
                        % clear ant_beamwidth;
                        % ant_beamwidth=temp_data;
                        % clear temp_data;

                        % load(strcat(data_label1,'_rx_height_m.mat'),'rx_height_m')
                        % temp_data=rx_height_m;
                        % clear rx_height_m;
                        % rx_height_m=temp_data;
                        % clear temp_data;

                        % load(strcat(data_label1,'_azi_required_pathloss.mat'),'azi_required_pathloss')
                        % temp_data=azi_required_pathloss;
                        % clear azi_required_pathloss;
                        % azi_required_pathloss=temp_data;
                        % clear temp_data;

                        load(strcat(data_label1,'_wider_keyhole.mat'),'wider_keyhole')
                        temp_data=wider_keyhole;
                        clear wider_keyhole;
                        wider_keyhole=temp_data;
                        clear temp_data;

                        retry_load=0;
                    catch
                        retry_load=1;
                        pause(0.1)
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%Step 0. Calculate the pathloss as a function of azimuth
                %%%%%%%%%Make this a function: azi_required_pathloss
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%STEP 1: Create a buffer around the base
                %[base_buffer]=base_buffer_azi_rev3(app,wider_keyhole,data_label1,base_protection_pts);
                [base_buffer]=base_buffer_azi_multi_rev4(app,wider_keyhole,data_label1,base_protection_pts);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Step 2: Generate Grid Points
               % buffer_km=ceil(max(azi_required_pathloss(:,3)));
                buffer_km=ceil(max(wider_keyhole(:,3)));
                
                [grid_points]=wrapper_grid_points_rev2_outside_USA(app,data_label1,buffer_km,grid_spacing,base_buffer,base_polygon,tx_height_m);

                [num_tx,~]=size(grid_points)
                sim_array_list_bs=horzcat(grid_points,NaN(num_tx,2));
                sim_array_list_bs(:,4)=bs_eirp_reductions;
                sim_array_list_bs(:,5)=1:1:num_tx;

                % % %      %%%%array_list_bs  %%%%%%%1) Lat, 2)Lon, 3)BS height, 4)BS EIRP Adjusted 5) Nick Unique ID for each sector, 6)NLCD: R==1/S==2/U==3, 7) Azimuth 8)BS EIRP Mitigation


                if grid_spacing==10
                    f10=figure;
                    AxesH = axes;
                    hold on;
                    scatter(grid_points(:,2),grid_points(:,1),10,'r','filled','DisplayName','Grid Points')
                    plot(base_protection_pts(:,2),base_protection_pts(:,1),'xk','LineWidth',3,'DisplayName','Federal System')
                    plot(base_buffer(:,2),base_buffer(:,1),'-b','LineWidth',3,'DisplayName','Simulation Area')
                    grid on;
                    legend
                    xlabel('Longitude')
                    ylabel('Latitude')
                    plot_google_map('maptype','terrain','APIKey','AIzaSyCgnWnM3NMYbWe7N4svoOXE7B2jwIv28F8') %%%Google's API key made by nick.matlab.error@gmail.com
                    pause(0.1)
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
                [cell_status]=update_generic_status_cell_rev1(app,folder_names,sim_folder,cell_status_filename);
                server_status_rev2(app,tf_server_status)
            end
        end
        multi_hWaitbarMsgQueue.send(0);
    end
    delete(multi_hWaitbarMsgQueue);
    close(multi_hWaitbar);
    server_status_rev2(app,tf_server_status)
end



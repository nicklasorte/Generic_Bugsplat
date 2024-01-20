function part0_grid_pts_rev2_outside_US(app,sim_number,folder_names,sim_radius_km,bs_height,array_bs_eirp_reductions,grid_spacing,rev_folder)

disp_progress(app,strcat('Part0: Grid Points: Line 3 . . .'))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Function:
cell_status_filename=strcat('cell_',num2str(sim_number),'_grid_points_status.mat')
label_single_filename=strcat('file_',num2str(sim_number),'_grid_points_status')
location_table=table([1:1:length(folder_names)]',folder_names)

%%%%%%%%%%Need a list because going through 470 folders takes 17 minutes
[cell_status]=initialize_or_load_generic_status_rev1(app,folder_names,cell_status_filename);
zero_idx=find(cell2mat(cell_status(:,2))==0);
cell_status


if ~isempty(zero_idx)==1
    temp_folder_names=folder_names(zero_idx)
    num_folders=length(temp_folder_names);

    disp_progress(app,strcat('Part0: Grid Points: Line 19 . . .'))
    %%%%%%%%Pick a random folder and go to the folder to do the sim
    reset(RandStream.getGlobalStream,sum(100*clock))  %%%%%%Set the Random Seed to the clock because all compiled apps start with the same random seed.
    disp_progress(app,strcat('Part0: Grid Points: Line 22 . . .'))
    [tf_ml_toolbox]=check_ml_toolbox(app);
    if tf_ml_toolbox==1
        array_rand_folder_idx=randsample(num_folders,num_folders,false);
    else
        array_rand_folder_idx=randperm(num_folders);
    end
    disp_progress(app,strcat('Part0: Grid Points: Line 29 . . .'))
    temp_folder_names(array_rand_folder_idx)
    disp_randfolder(app,num2str(array_rand_folder_idx'))
    disp_progress(app,strcat('Part0: Grid Points: Line 32 . . .'))
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [multi_hWaitbar,multi_hWaitbarMsgQueue]= ParForWaitbarCreateMH_time('Multi-Folder Grid Points: ',num_folders);    %%%%%%% Create ParFor Waitbar
    disp_progress(app,strcat('Part0: Grid Points: Line 35 . . .'))
    for folder_idx=1:1:num_folders
        %%%%%%%%Before going to the sim folder, check one last time if we
        %%%%%%%%need to go to it, since another server may have already
        %%%%%%%%checked.


        disp_progress(app,strcat('Part0: Grid Points: Line 42 . . .'))
        %%%%%%%Load
        [cell_status]=initialize_or_load_generic_status_rev1(app,folder_names,cell_status_filename);
        sim_folder=temp_folder_names{array_rand_folder_idx(folder_idx)};
        temp_cell_idx=find(strcmp(cell_status(:,1),sim_folder)==1);

        if cell_status{temp_cell_idx,2}==0
            disp_progress(app,strcat('Part0: Grid Points: Line 49 . . .'))
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

            disp_progress(app,strcat('Part0: Grid Points: Line 79:',data_label1))

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
                disp_progress(app,strcat('Part0: Grid Points: Line 96:',data_label1))
                %%%%%%%%Update the Cell
                [cell_status]=update_generic_status_cell_rev1(app,folder_names,sim_folder,cell_status_filename);
            else

                %%%%%%%%Calculate Path Loss
                %%%%%%%%%%%%%%%%CBSD Neighborhood Search Parameters
                %%%%%Persistent Load the other variables
                disp_progress(app,strcat('Part0 Grid Points: Loading Sim Data: Line 104  . . .'))
                retry_load=1;
                while(retry_load==1)
                    try
                        %%%%disp_progress(app,strcat('Loading Sim Data . . . '))
                        load(strcat(data_label1,'_base_polygon.mat'),'base_polygon')
                        temp_data=base_polygon;
                        clear base_polygon;
                        base_polygon=temp_data;
                        clear temp_data;

                        retry_load=0;
                    catch
                        retry_load=1;
                        pause(0.1)
                    end
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%Calculate the Grid Points

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%STEP 1: Create a buffer around the base
                [base_buffer]=base_buffer_rev1(app,data_label1,sim_radius_km,base_polygon);

                f1=figure;
                AxesH = axes;
                hold on;
                plot(base_polygon(:,2),base_polygon(:,1),'ok','Linewidth',3)
                plot(base_buffer(:,2),base_buffer(:,1),'-b','Linewidth',3)
                grid on;
                plot_google_map('maptype','terrain','APIKey','AIzaSyCgnWnM3NMYbWe7N4svoOXE7B2jwIv28F8') %%%Google's API key made by nick.matlab.error@gmail.com
                filename1=strcat('Sim_Area_',data_label1,'.png');
                pause(0.1)
                saveas(gcf,char(filename1))
                pause(0.1);
                close(f1)

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Step 2: Generate Grid Points
                %%%%%%%%%%%%[grid_points]=wrapper_grid_points_rev1(app,data_label1,sim_radius_km,grid_spacing,base_buffer,base_polygon,bs_height);
                [grid_points]=wrapper_grid_points_rev2_outside_USA(app,data_label1,sim_radius_km,grid_spacing,base_buffer,base_polygon,bs_height);

                [num_tx,~]=size(grid_points)
                sim_array_list_bs=grid_points;
                sim_array_list_bs(:,4)=array_bs_eirp_reductions;
                sim_array_list_bs(:,5)=1:1:num_tx;

                % % %      %%%%array_list_bs  %%%%%%%1) Lat, 2)Lon, 3)BS height, 4)BS EIRP Adjusted 5) Nick Unique ID for each sector, 6)NLCD: R==1/S==2/U==3, 7) Azimuth 8)BS EIRP Mitigation

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
                server_status_rev1(app)
            end
        end
        multi_hWaitbarMsgQueue.send(0);
    end
    delete(multi_hWaitbarMsgQueue);
    close(multi_hWaitbar);
end

end
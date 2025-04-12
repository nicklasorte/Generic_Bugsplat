function step0_create_folders_rev1(app,rev_folder,tf_server_status,cell_sim_data,sim_number,array_dist_pl,sim_scale_factor,tf_clutter)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Function:Pre-Step0
server_status_rev2(app,tf_server_status)
cell_status_filename=strcat('cell_',num2str(sim_number),'_create_folders_status.mat')
label_single_filename=strcat('file_',num2str(sim_number),'_create_folders_status')


%%%%%%%%%%%%%Need to feed in the the folder names we need
data_label_idx=find(matches(cell_sim_data(1,:),'data_label1'));
create_folder_names=cell_sim_data(2:end,data_label_idx)
[cell_status]=initialize_or_load_generic_status_expand_rev3(app,cell_status_filename,create_folder_names);
zero_idx=find(cell2mat(cell_status(:,2))==0);
cell_status
size(zero_idx)


if ~isempty(zero_idx)==1
    temp_folder_names=cell_status(zero_idx,1)
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
    [multi_hWaitbar,multi_hWaitbarMsgQueue]= ParForWaitbarCreateMH_time('Create Folders: ',num_folders);    %%%%%%% Create ParFor Waitbar
    for folder_idx=1:1:num_folders
        %%%%%%%%Before going to the sim folder, check one last time if we
        %%%%%%%%need to go to it, since another server may have already checked.
        disp_TextArea_PastText(app,strcat('Step0: Line 39: Before initialize_or_load_generic_status_rev1')) %%%%%%%%%Error seems to also occur right here. %%%%%%%%Too many servers trying to update this one file. No need to check it at this point?
        [cell_status]=initialize_or_load_generic_status_while_rev4_debug(app,create_folder_names,cell_status_filename);  %%%%%%[cell_status]=initialize_or_load_generic_status_rev1_debug(app,create_folder_names,cell_status_filename);  %%%%[cell_status]=initialize_or_load_generic_status_rev1(app,create_folder_names,cell_status_filename);
        disp_TextArea_PastText(app,strcat('Step0: Line 41: After initialize_or_load_generic_status_rev1'))
        sim_folder=temp_folder_names{array_rand_folder_idx(folder_idx)};
        temp_cell_idx=find(strcmp(cell_status(:,1),sim_folder)==1)  
        disp_TextArea_PastText(app,strcat('Step0: Line 43:',num2str(temp_cell_idx)))
        if cell_status{temp_cell_idx,2}==0 %%%%%%%%%%%This is where the error is occuring, probably with "temp_cell_idx", we needed to have a unique name in the cell_sim_data
            disp_TextArea_PastText(app,strcat('Step0: Line 46: Going into RevFolder'))
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
            disp_TextArea_PastText(app,strcat('Step0: Line 58: Going into check_rev_folders'))
            [~,folder_names,~]=check_rev_folders(app,rev_folder);

            %%%%%%Check to see if we need to make a new folder
            sim_folder=temp_folder_names{array_rand_folder_idx(folder_idx)}
            folder_row_idx=find(matches(folder_names,sim_folder))
            disp_TextArea_PastText(app,strcat('Step0: Line 64:folder_row_idx:',num2str(folder_row_idx)))
            if isempty(folder_row_idx)
                %%%%%'Create the folder'
                status=0;
                while status==0
                    [status,msg,msgID]=mkdir(sim_folder);
                    disp_TextArea_PastText(app,strcat('Step0: Line 70: Folder Status:',num2str(status)))
                end
            end
            disp_TextArea_PastText(app,strcat('Step0: Line 73: Going into sim_folder'))
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
            data_label1=sim_folder
            disp_TextArea_PastText(app,strcat('Step0: Line 87: Checking for complete_filename'))
            complete_filename=strcat(data_label1,'_',label_single_filename,'.mat'); %%%This is a marker for me             %%%%%%Check for the tf_complete_ITM file
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
                disp_TextArea_PastText(app,strcat('Step0: Line 102: Before initialize_or_load_generic_status_rev1'))
                [~]=update_generic_status_cell_rev1_debug(app,create_folder_names,sim_folder,cell_status_filename); %%%%[~]=update_generic_status_cell_rev1(app,create_folder_names,sim_folder,cell_status_filename);
                disp_TextArea_PastText(app,strcat('Step0: Line 104: Before initialize_or_load_generic_status_rev1'))
            else
                disp_TextArea_PastText(app,strcat('Step0: Line 106: Saving the data'))
                data_row_idx=find(matches(cell_sim_data(:,1),sim_folder));
                if isempty(data_row_idx)
                      disp_progress(app,strcat('Error: Data is not there . . . '))
                      pause;
                end
                temp_single_cell_sim_data=cell_sim_data(data_row_idx,:);

                %    %%%%%%%%Calculate the pathloss as a function of azimuth
                min_azimuth=temp_single_cell_sim_data{7};
                max_azimuth=temp_single_cell_sim_data{8};
                ant_beamwidth=temp_single_cell_sim_data{6};
                min_ant_loss=temp_single_cell_sim_data{12};%     % % 12) Main to side gain:
                required_pathloss=temp_single_cell_sim_data{15};

                disp_TextArea_PastText(app,strcat('Step0: Line 121: Before calc_azi_pathloss_rev1'))
                [azi_required_pathloss]=calc_azi_pathloss_rev1(app,ant_beamwidth,min_ant_loss,min_azimuth,max_azimuth,required_pathloss,array_dist_pl,sim_scale_factor);
                disp_TextArea_PastText(app,strcat('Step0: Line 123: After calc_azi_pathloss_rev1'))
                %%%%%%%%%%Save
                retry_save=1;
                while(retry_save==1)
                    try
                        %     %%%%%%%%%%%azi_required_pathloss
                        %%%%%%%%%1)Azimuth Degrees, 2) Pathloss, 3) Distance km for base_buffer
                        save(strcat(data_label1,'_azi_required_pathloss.mat'),'azi_required_pathloss')
                        pause(0.1);
                        retry_save=0;
                    catch
                        retry_save=1;
                        pause(0.1)
                    end
                end
                %%%%%%%%Make the wider_keyhole
                disp_TextArea_PastText(app,strcat('Step0: Line 139: Before create_wider_keyhole_rev1'))
                [wider_keyhole]=create_wider_keyhole_rev1(app,azi_required_pathloss,tf_clutter,min_azimuth,max_azimuth,ant_beamwidth,array_dist_pl,sim_scale_factor);
                disp_TextArea_PastText(app,strcat('Step0: Line 141: Before create_wider_keyhole_rev1'))
                retry_save=1;
                while(retry_save==1)
                    try
                        save(strcat(data_label1,'_wider_keyhole.mat'),'wider_keyhole')
                        pause(0.1);
                        retry_save=0;
                    catch
                        retry_save=1;
                        pause(0.1)
                    end
                end

                base_protection_pts=temp_single_cell_sim_data{16};
                retry_save=1;
                while(retry_save==1)
                    try
                        save(strcat(data_label1,'_base_protection_pts.mat'),'base_protection_pts')
                        pause(0.1);
                        retry_save=0;
                    catch
                        retry_save=1;
                        pause(0.1)
                    end
                end

                base_polygon=temp_single_cell_sim_data{17};
                retry_save=1;
                while(retry_save==1)
                    try
                        save(strcat(data_label1,'_base_polygon.mat'),'base_polygon')
                        pause(0.1);
                        retry_save=0;
                    catch
                        retry_save=1;
                        pause(0.1)
                    end
                end

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
                disp_TextArea_PastText(app,strcat('Step0: Line 205: Before update_generic_status_cell_rev1')) %%%%%%%Error also occuring after this point
                [~]=update_generic_status_cell_rev1_debug(app,create_folder_names,sim_folder,cell_status_filename); %%%%[~]=update_generic_status_cell_rev1(app,create_folder_names,sim_folder,cell_status_filename);
                server_status_rev2(app,tf_server_status)
                disp_TextArea_PastText(app,strcat('Step0: Line 208: After server_status_rev2'))
            end          
        end
        multi_hWaitbarMsgQueue.send(0);
    end
    delete(multi_hWaitbarMsgQueue);
    close(multi_hWaitbar);
    server_status_rev2(app,tf_server_status)
end

end
function part0_grid_pts_azi_pathloss_folders_rev10_custant(app,sim_number,tx_height_m,bs_eirp_reductions,grid_spacing,rev_folder,tf_server_status,cell_sim_data,array_dist_pl,sim_scale_factor,tf_clutter,FreqMHz)



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
disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 19'))

%%%[cell_status]=initialize_or_load_generic_status_expand_rev3(app,cell_status_filename,create_folder_names);
zero_idx=find(cell2mat(cell_status(:,2))==0);
size(create_folder_names)
size(cell_status)
size(zero_idx)
disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 26'))

if ~isempty(zero_idx)==1
    disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 29'))
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
    disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 43'))
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [multi_hWaitbar,multi_hWaitbarMsgQueue]= ParForWaitbarCreateMH_time('Multi-Folder Grid Points: ',num_folders);    %%%%%%% Create ParFor Waitbar
    for folder_idx=1:1:num_folders
        disp_TextArea_PastText(app,strcat('Part0 Grid Points:',num2str(num_folders-folder_idx)))
        disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 48'))
        %%%%%%%%Before going to the sim folder, check one last time if we
        %%%%%%%%need to go to it, since another server may have already
        %%%%%%%%checked.
        %%%%%%%%%%%%%%%%%%%%%%This might be killing us with this cell_status check.

        %%%%%%%%%%%%%%Check cell_status
        tf_update_cell_status=0;
        sim_folder='';
        [cell_status]=checkout_cell_status_rev1(app,checkout_filename,cell_status_filename,sim_folder,create_folder_names,tf_update_cell_status);
        disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 58'))

        sim_folder=temp_folder_names{array_rand_folder_idx(folder_idx)};
        temp_cell_idx=find(strcmp(cell_status(:,1),sim_folder)==1);

        if cell_status{temp_cell_idx,2}==0
            disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 64'))
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
            disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 77'))

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
            disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 89'))

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
            disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 103'))

            disp_multifolder(app,sim_folder)
            data_label1=sim_folder;

            %%%%%%Check for the tf_complete file
            complete_filename=strcat(data_label1,'_',label_single_filename,'.mat'); %%%This is a marker for me
            [var_exist]=persistent_var_exist_with_corruption(app,complete_filename);
            disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 111'))
            if var_exist==2
                disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 113'))
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

                disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 126'))
                %%%%%%%%Update the cell_status
                tf_update_cell_status=1;
                tic;
                [~]=checkout_cell_status_rev1(app,checkout_filename,cell_status_filename,sim_folder,create_folder_names,tf_update_cell_status);
                toc;
                disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 132'))
            else
                disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 134'))
                data_row_idx=find(matches(cell_sim_data(:,1),sim_folder));
                if isempty(data_row_idx)
                    disp_progress(app,strcat('Pause Error: Data is not there in the cell_sim_data. . . '))
                    pause;
                end
                temp_single_cell_sim_data=cell_sim_data(data_row_idx,:);
                data_header=cell_sim_data(1,:)';
                disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 142'))


                %%%%%%%%%%Check for data, at least save it.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                pp_pt_idx=find(matches(data_header,'base_protection_pts'))
                base_protection_pts=temp_single_cell_sim_data{pp_pt_idx}
                filename_base_protection_pts=strcat(data_label1,'_base_protection_pts.mat');
                [var_exist_pp_pts]=persistent_var_exist_with_corruption(app,filename_base_protection_pts);
                disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 151'))
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
                disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 165'))

                poly_idx=find(matches(data_header,'base_polygon'))
                base_polygon=temp_single_cell_sim_data{poly_idx};
                filename_base_polygon=strcat(data_label1,'_base_polygon.mat');
                [var_exist_base_poly]=persistent_var_exist_with_corruption(app,filename_base_polygon);
                disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 171'))
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
                disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 185'))

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

                tf_cust_ant_idx=find(matches(data_header,'TF_Custom_Ant_Pattern'));
                tf_custom_ant_pat=temp_single_cell_sim_data{tf_cust_ant_idx};

                disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 207'))
                if tf_custom_ant_pat==1
                    disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 209'))
                    col_ant_pat_str_idx=find(matches(data_header,'Antenna_Pattern_Str'));
                    temp_str_ant_pattern=temp_single_cell_sim_data{col_ant_pat_str_idx};
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Antenna Pattern
                    if matches(temp_str_ant_pattern,'itu_antenna_f1245')
                        disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 214'))
                        %%%%%%%%%%%%ITU-R F.1245
                        col_ant_gain_idx=find(matches(data_header,'rx_ant_gain_mb'));
                        Gmax_dBi=temp_single_cell_sim_data{col_ant_gain_idx};
             
                        phi_deg = 0:0.1:180;
                        D_m=1.8;  %%%%%%%%Just a placeholder
                        [G_dBi]=calc_antenna_f1245_rev1(app,phi_deg,Gmax_dBi,D_m,FreqMHz);
                        radar_ant_array=horzcat(phi_deg',G_dBi');
                        %custom_antenna_pattern=horzcat(phi_deg',G_dBi');
                        if Gmax_dBi<max(G_dBi)
                            disp_TextArea_PastText(app,strcat('Error: Part0 Grid Points: Line 225, GdBi>Gmax'))
                            pause;
                        end


                        neg_ant_array=flipud(radar_ant_array([2:end],:));
                        neg_ant_array(:,1)=-1*neg_ant_array(:,1);
                        mod_neg_ant_array=neg_ant_array;
                        mod_neg_ant_array(:,1)=mod(neg_ant_array(:,1),360);
                        temp_ant=vertcat(radar_ant_array,mod_neg_ant_array);
                        [~,uni_idx]= unique(temp_ant(:,1), 'stable');

                        temp_custom_antenna_pattern=temp_ant(uni_idx,:);

                        %%%%%%%%%Need to shift by gs_azimuth
                        col_gs_azimuth_idx=find(matches(data_header,'gs_azimuth'));
                        gs_azimuth=temp_single_cell_sim_data{col_gs_azimuth_idx};
                        nn_azi_idx=nearestpoint_app(app,gs_azimuth,temp_custom_antenna_pattern(:,1));

                        custom_antenna_pattern=temp_custom_antenna_pattern;
                        custom_antenna_pattern(:,2)=circshift(temp_custom_antenna_pattern(:,2),nn_azi_idx);
                        % figure;
                        % hold on
                        % plot(radar_ant_array(:,1),radar_ant_array(:,2),'-ok')
                        % plot(mod_neg_ant_array(:,1),mod_neg_ant_array(:,2),'-sr')
                        % plot(custom_antenna_pattern(:,1),custom_antenna_pattern(:,2),'-g')

                        %%%%%%%%%%%%%%Plot and Save
                        fig1=figure;
                        hold on;
                        plot(phi_deg,G_dBi,'-b')
                        xlabel('Elevation [Degree]')
                        ylabel('Antenna Gain')
                        grid on;
                        title({strcat(data_label1,': itu antennaf1245')})
                        filename1=strcat(data_label1,'_itu_antenna_f1245.png');
                        retry_save=1;
                        while(retry_save==1)
                            try
                                saveas(gcf,char(filename1))
                                pause(0.1);
                                retry_save=0;
                            catch
                                retry_save=1;
                                pause(0.1)
                            end
                        end
                        pause(0.1)
                        close(fig1)


                        %%%%%%%%%%%%%%Plot and Save
                        fig1=figure;
                        hold on;
                        plot(custom_antenna_pattern(:,1),custom_antenna_pattern(:,2),'-b')
                        xlabel('Azimuth [Degree]')
                        ylabel('Antenna Gain')
                        grid on;
                        filename1=strcat(data_label1,'_custom_ant_gain.png');
                        retry_save=1;
                        while(retry_save==1)
                            try
                                saveas(gcf,char(filename1))
                                pause(0.1);
                                retry_save=0;
                            catch
                                retry_save=1;
                                pause(0.1)
                            end
                        end
                        pause(0.1)
                        close(fig1)

                        %
                        % figure;
                        % hold on;
                        % plot(phi_deg,G_dBi);
                        % xlabel('Off-axis angle \phi (degrees)');
                        % ylabel('Gain G(\phi) (dBi)');
                        % grid on;
                        disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 299'))
                    else
                        disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 301, PAUSE: Need to do another custom pattern'))
                        pause;
                    end
                    disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 304'))

                    retry_save=1;
                    while(retry_save==1)
                        try
                            save(strcat(data_label1,'_custom_antenna_pattern.mat'),'custom_antenna_pattern')
                            retry_save=0;
                        catch
                            retry_save=1;
                            pause(1)
                        end
                    end
                    disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 316'))
                end

                if tf_custom_ant_pat==0
                    disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 310'))
                    %%%%%%%%%%Add Radar Antenna Pattern: Offset from 0 degrees and loss in dB
                    array_azi=0:1:360;
                    if ant_beamwidth==360
                        custom_antenna_pattern=array_azi';
                        ant_gain_idx=find(matches(data_header,'rx_ant_gain_mb'));
                        ant_gain=temp_single_cell_sim_data{ant_gain_idx}
                        custom_antenna_pattern(:,2)=ant_gain;
                    else
                        %%%%%%%%%%%Note, this is not STATGAIN
                        [radar_ant_array]=horizontal_antenna_loss_app(app,ant_beamwidth,min_ant_loss);
                        neg_ant_array=flipud(radar_ant_array([2:end],:));
                        neg_ant_array(:,1)=-1*neg_ant_array(:,1);
                        mod_neg_ant_array=neg_ant_array;
                        mod_neg_ant_array(:,1)=mod(neg_ant_array(:,1),360);

                        min_neg_azi=min(mod_neg_ant_array(:,1));
                        neg_nn1_idx=nearestpoint_app(app,min_neg_azi,array_azi,'previous'); %%%%Use this one
                        %%%%neg_nn2_idx=nearestpoint_app(app,min_neg_azi,array_azi,'next');
                        %%%%horzcat(min_neg_azi,array_azi(neg_nn1_idx),array_azi(neg_nn2_idx))

                        max_pos_azi=max(radar_ant_array(:,1));
                        pos_nn1_idx=nearestpoint_app(app,max_pos_azi,array_azi,'next'); %%%%Use this one
                        %%%%%%horzcat(max_pos_azi,array_azi(pos_nn1_idx))

                        if neg_nn1_idx<pos_nn1_idx
                            'Error on the non-custom ant pattern'
                            pause;
                        end
                        middle_piece=array_azi([pos_nn1_idx:1:neg_nn1_idx])';
                        middle_piece(:,2)=-1*min_ant_loss;
                        custom_antenna_pattern=vertcat(radar_ant_array,middle_piece,mod_neg_ant_array);
                    end
                    %%%%%%%%%%%%%%Plot and Save
                    fig1=figure;
                    hold on;
                    plot(custom_antenna_pattern(:,1),custom_antenna_pattern(:,2),'-b')
                    xlabel('Azimuth [Degree]')
                    ylabel('Antenna Gain')
                    grid on;
                    filename1=strcat(data_label1,'_custom_ant_gain.png');
                    retry_save=1;
                    while(retry_save==1)
                        try
                            saveas(gcf,char(filename1))
                            pause(0.1);
                            retry_save=0;
                        catch
                            retry_save=1;
                            pause(0.1)
                        end
                    end
                    pause(0.1)
                    close(fig1)
                    retry_save=1;
                    while(retry_save==1)
                        try
                            save(strcat(data_label1,'_custom_antenna_pattern.mat'),'custom_antenna_pattern')
                            retry_save=0;
                        catch
                            retry_save=1;
                            pause(1)
                        end
                    end

                    % 'Use the old ways'
                    % 'or just make a custom_antenna_pattern and feed it into the algorithm below'
                    % pause;
                    % % [azi_required_pathloss]=create_save_load_azi_required_pathloss_rev2(app,data_label1,ant_beamwidth,min_ant_loss,min_azimuth,max_azimuth,required_pathloss,array_dist_pl,sim_scale_factor);
                    % % [wider_keyhole]=create_save_load_wider_keyhole_rev2(app,data_label1,azi_required_pathloss,tf_clutter,min_azimuth,max_azimuth,ant_beamwidth,array_dist_pl,sim_scale_factor);
                end
                disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 327'))

                %%%%%%%%%%%%%%%%%%
                %'rx_ant_gain is in required pathloss, so need to normalize custom_antenna_pattern'
                %'the custom ant pattern is already shifted'
                %custom_antenna_pattern
                max_ant_gain=max(custom_antenna_pattern(:,2))
                norm_custom_antenna_pattern=custom_antenna_pattern;
                norm_custom_antenna_pattern(:,2)=custom_antenna_pattern(:,2)-max_ant_gain;

                % figure;
                % hold on;
                % plot(norm_custom_antenna_pattern(:,1),norm_custom_antenna_pattern(:,2),'-b')
                % grid on;
                % pause(0.1)


                %%%%%%%%%%%%%%Calculate the required pathloss for each azimuth step
                %%%%%%For 0-360 Degrees
                azi_required_pathloss=norm_custom_antenna_pattern;
                azi_required_pathloss(:,2)=required_pathloss+norm_custom_antenna_pattern(:,2);
                % norm_custom_antenna_pattern
                % required_pathloss
                % 'check'
                % pause;

                % figure;
                % hold on;
                % plot(azi_required_pathloss(:,1),azi_required_pathloss(:,2),'-b')
                % grid on;


                %%%%%%%%%%Check to see if we have enough distance
                disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 354'))
                if max(array_dist_pl(:,2))<max(azi_required_pathloss)
                    disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 356: PAUSE: Need longer ITM Area Distance km'))
                    pause;
                end
                disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 359')) %%%%%%%%Error after this point.

                % % figure;
                % % hold on;
                % % plot(array_dist_pl(:,1),array_dist_pl(:,2),'-k')
                % % grid on;

                %%%%%%%%Find the distance for each azimuth and take it times the scalling factor, then create a polygon
                nn_idx=nearestpoint_app(app,azi_required_pathloss(:,2),array_dist_pl(:,2),'next');
                disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 360'))

                % figure;
                % hold on;
                % plot(azi_required_pathloss(:,1),azi_required_pathloss(:,2),'-ok')
                % grid on;

                %size(azi_required_pathloss)
                %size(nn_idx)
                % nn_idx
                % sim_scale_factor
                % azi_required_pathloss
                azi_required_pathloss(:,3)=array_dist_pl(nn_idx,1)*sim_scale_factor;
                disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 361'))

                filename_azi_pathloss=strcat(data_label1,'_azi_required_pathloss.mat');
                retry_save=1;
                while(retry_save==1)
                    disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 362'))
                    try
                        %     %%%%%%%%%%%azi_required_pathloss
                        %%%%%%%%%1)Azimuth Degrees, 2) Pathloss, 3) Distance km for base_buffer
                        save(filename_azi_pathloss,'azi_required_pathloss')
                        pause(0.1);
                        retry_save=0;
                        disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 363'))
                    catch
                        retry_save=1;
                        pause(0.1)
                        disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 364'))
                    end
                    disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 365'))
                end
                 disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 386'))


                %%%For the custom antenna, don't downsample.
                %%%%%%%Just set the wider_keyhole=azi_required_pathloss;
                wider_keyhole=azi_required_pathloss;

                filename_wider_keyhole=strcat(data_label1,'_wider_keyhole.mat');
                retry_save=1;
                while(retry_save==1)
                    try
                        save(filename_wider_keyhole,'wider_keyhole')
                        pause(0.1);
                        retry_save=0;
                    catch
                        retry_save=1;
                        pause(0.1)
                    end
                end
                 disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 405'))

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%STEP 1: Create a buffer around the base
                disp_TextArea_PastText(app,strcat('Part0: base_buffer_azi_multi_rev4: Line 410'))
                [base_buffer]=base_buffer_azi_multi_rev4(app,wider_keyhole,data_label1,base_protection_pts);
                disp_TextArea_PastText(app,strcat('Part0: base_buffer_azi_multi_rev4: Line 412'))

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Step 2: Generate Grid Points
                buffer_km=ceil(max(wider_keyhole(:,3)));
                disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 416'))
                [grid_points]=wrapper_grid_points_rev2_outside_USA(app,data_label1,buffer_km,grid_spacing,base_buffer,base_polygon,tx_height_m);
                disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 418'))

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
                disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 461'))

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
                disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 473'))

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
                disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 489'))

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
                disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 502'))
                %%%%%%%%Update the cell_status
                %%%%[cell_status]=update_generic_status_cell_rev1(app,folder_names,sim_folder,cell_status_filename);
                %%%[~]=update_generic_status_cell_rev1_debug(app,create_folder_names,sim_folder,cell_status_filename);
                %%%%%%%%Update the cell_status
                tf_update_cell_status=1;
                tic;
                [~]=checkout_cell_status_rev1(app,checkout_filename,cell_status_filename,sim_folder,create_folder_names,tf_update_cell_status);
                toc;
                disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 511'))
                server_status_rev2(app,tf_server_status)
                disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 513'))
            end
            disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 515'))
        end
        multi_hWaitbarMsgQueue.send(0);
        disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 518'))
    end
    disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 520'))
    try
        delete(multi_hWaitbarMsgQueue);
    end
    disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 524'))
    try
        close(multi_hWaitbar);
    end
    disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 528'))

    %%%%%%%%%%If we make it here, just mark all the cell_status as complete
    finish_cell_status_rev1(app,rev_folder,cell_status_filename)
    disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 532'))
end
disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 534'))
server_status_rev2(app,tf_server_status)
disp_TextArea_PastText(app,strcat('Part0 Grid Points: Line 536'))
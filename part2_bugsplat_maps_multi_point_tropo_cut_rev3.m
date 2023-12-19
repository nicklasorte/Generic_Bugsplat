function part2_bugsplat_maps_multi_point_tropo_cut_rev3(app,rev_folder,folder_names,sim_number,reliability,string_prop_model,grid_spacing,array_reliability_check,tf_recalculate,tf_tropo_cut)


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

                        load(strcat(data_label1,'_radar_height.mat'),'radar_height')
                        temp_data=radar_height;
                        clear radar_height;
                        radar_height=temp_data;
                        clear temp_data;

                        load(strcat(data_label1,'_radar_threshold.mat'),'radar_threshold')
                        temp_data=radar_threshold;
                        clear radar_threshold;
                        radar_threshold=temp_data;
                        clear temp_data;

                        retry_load=0;
                    catch
                        retry_load=1;
                        pause(0.1)
                    end
                end



                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                num_rel=length(reliability)
             
                %%%%%%Check for cell_pathloss_data
                filename_min_full_pl_data=strcat(data_label1,'_min_full_pl_data_',num2str(num_rel),'_',num2str(grid_spacing),'km.mat');
                [var_exist_min_full_pl_data]=persistent_var_exist_with_corruption(app,filename_min_full_pl_data);

                filename_min_full_prop_mode_data=strcat(data_label1,'_min_full_prop_mode_data_',num2str(num_rel),'_',num2str(grid_spacing),'km.mat');
                [var_exist_min_full_prop_mode_data]=persistent_var_exist_with_corruption(app,filename_min_full_prop_mode_data);
                if tf_recalculate==1
                    var_exist_min_full_pl_data=0;
                end

                if var_exist_min_full_pl_data==2 && var_exist_min_full_prop_mode_data==2
                    retry_load=1;
                    while(retry_load==1)
                        try
                            load(filename_min_full_pl_data,'min_full_pl_data')
                            load(filename_min_full_prop_mode_data,'min_full_prop_mode_data')
                            pause(0.1)
                            retry_load=0;
                        catch
                            retry_load=1;
                            pause(1)
                        end
                    end
                    pause(0.1)
                else
                    [num_pts,~]=size(base_protection_pts);
                    [num_grid_pts,~]=size(sim_array_list_bs);
                    full_array_prop_mode=NaN(num_grid_pts,num_pts);
                    for point_idx=1:1:num_pts
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
                                pause(1)
                            end
                        end

                        file_name_prop_mode=strcat(string_prop_model,'_prop_mode_',num2str(point_idx),'_',num2str(sim_number),'_',data_label1,'.mat');
                        retry_load=1;
                        while(retry_load==1)
                            try

                                load(file_name_prop_mode,'prop_mode')
                                retry_load=0;
                            catch
                                retry_load=1;
                                pause(1)
                            end
                        end


                        %%%%%%%%%%Clean up the prop_mode
                        if strcmp(string_prop_model,'TIREM')
                            num_cells=length(prop_mode);
                            cell_prop_mode=cell(num_cells,1);
                            for prop_idx=1:1:num_cells
                                temp_structure=prop_mode{prop_idx};
                                cell_prop_mode{prop_idx}=temp_structure.PropagationMode;
                                'Need to merge Tirem prop string to ITM prop numbers, find los_idx, diff_idx, and tropo_idx'
                                pause;

% % %                                 if strcmp(string_prop_model,'TIREM')
% % %                                     unique(sort_cell_prop_mode)
% % %                                     los_idx=find(contains(sort_cell_prop_mode,'LOS'));
% % %                                     dif_idx=find(contains(sort_cell_prop_mode,'DIF'));
% % %                                     tro_idx=find(contains(sort_cell_prop_mode,'TRO'));
% % %                                 end
                            end
                        end


                        if strcmp(string_prop_model,'ITM')
                            los_idx=find(prop_mode==0);
                            dif1_idx=find(prop_mode==4);
                            dif2_idx=find(prop_mode==5);
                            dif3_idx=find(prop_mode==8);
                            dif4_idx=find(prop_mode==9);
                            diff_idx=unique(vertcat(dif1_idx,dif2_idx,dif3_idx,dif4_idx));
                            trop1_idx=find(prop_mode==6);
                            trop2_idx=find(prop_mode==10);
                            tropo_idx=unique(vertcat(trop1_idx,trop2_idx));
                        end

% % % %                         if strcmp(string_prop_model,'ITM')
% % % %                             num_cells=length(prop_mode);
% % % %                             cell_prop_mode=cell(num_cells,1);
% % % %                             for prop_idx=1:1:num_cells
% % % %                                 num_prop_mode=prop_mode(prop_idx);
% % % %                                 if num_prop_mode==0
% % % %                                     temp_prop_mode='LOS';
% % % %                                 elseif num_prop_mode==4
% % % %                                     temp_prop_mode='Single Horizon';
% % % %                                 elseif num_prop_mode==5
% % % %                                     temp_prop_mode='Difraction Double Horizon';
% % % %                                 elseif num_prop_mode==8
% % % %                                     temp_prop_mode='Double Horizon';
% % % %                                 elseif num_prop_mode==9
% % % %                                     temp_prop_mode='Difraction Single Horizon';
% % % %                                 elseif num_prop_mode==6
% % % %                                     temp_prop_mode='Troposcatter Single Horizon';
% % % %                                 elseif num_prop_mode==10
% % % %                                     temp_prop_mode='Troposcatter Double Horizon';
% % % %                                 elseif num_prop_mode==333
% % % %                                     temp_prop_mode='Error';
% % % %                                 else
% % % %                                     'Undefined Propagation Mode'
% % % %                                     pause;
% % % %                                 end
% % % %                                 cell_prop_mode{prop_idx}=temp_prop_mode;
% % % %                             end
% % % %                         end

                       if length(prop_mode)~=(length(los_idx)+length(diff_idx)+length(tropo_idx))
                           'Error: Check prop_mode lengths'
                           pause;
                       end

                       %%%%%%%%Now change to 
                       % % %  Mode of propagation
                       % % % 1 = Line of Sight
                       % % % 2 = Diffraction
                       % % % 3 = Troposcatter

                       array_prop_mode=NaN(size(prop_mode));
                       array_prop_mode(los_idx)=1;
                       array_prop_mode(diff_idx)=2;
                       array_prop_mode(tropo_idx)=3;

                       full_array_prop_mode(:,point_idx)=array_prop_mode;

                       if tf_tropo_cut==1
                            %%%%%% 'If it is tropo, we ignore the pathloss value'
                            pathloss(tropo_idx,:)=NaN(1);
                       end

                       %%%%%%%%%Find the Minimum Path Loss for each grid point and reliability
                       if point_idx==1
                           min_full_pl_data=pathloss;
                           min_full_prop_mode_data=array_prop_mode;
                       else
                           min_full_pl_data=min(min_full_pl_data,pathloss,"omitnan");
                           min_full_prop_mode_data=min(min_full_prop_mode_data,array_prop_mode);
                       end
                  
                    end

                    size(min_full_pl_data)
                    nan_pl_idx=find(isnan(min_full_pl_data(:,1)));
                    size(nan_pl_idx)

                    tropo_mode_idx=find(min_full_prop_mode_data==3);
                    size(tropo_mode_idx)


% % %                     for row_idx=1:1:num_grid_pts
% % %                          tf_row_prop=min_full_prop_mode_data(row_idx)==full_array_prop_mode(row_idx,:);
% % % 
% % %                          if any(tf_row_prop==0)
% % %                              full_array_prop_mode(row_idx,:)
% % %                              min_full_prop_mode_data(row_idx)
% % %                              'check'
% % %                              pause;
% % %                          end
% % %                     end

                    %%%'Min min_full_pl_data '
                    retry_save=1;
                    while(retry_save==1)
                        try
                            save(filename_min_full_pl_data,'min_full_pl_data')
                            save(filename_min_full_prop_mode_data,'min_full_prop_mode_data')
                            pause(0.1)
                            retry_save=0;
                        catch
                            retry_save=1;
                            pause(1)
                        end
                    end
                    pause(0.1)
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


                %%%%%%%%%%Make the troposcatter contour from min_full_prop_mode_data with the 3 colors of propagation mechanism
                temp_prop_grid_pts=sim_array_list_bs(:,[1,2]);

                merge_los_idx=find(min_full_prop_mode_data==1);
                merge_diff_idx=find(min_full_prop_mode_data==2);
                merge_tropo_idx=find(min_full_prop_mode_data==3);

                non_tropo_idx=unique(vertcat(merge_los_idx,merge_diff_idx));
                non_tropo_prop_grid_pts=temp_prop_grid_pts(non_tropo_idx,:);

                %%%%%Convex hull the points
                non_tropo_k_idx=boundary(non_tropo_prop_grid_pts(:,2),non_tropo_prop_grid_pts(:,1),0);
                non_tropo_convex_bound=non_tropo_prop_grid_pts(non_tropo_k_idx,:);

                %%%%%%%%%%%%%%%%Propagation Mechanism Heat Map
                mode_color_set=plasma(3);

                f1=figure;
                AxesH = axes;
                hold on;
                
                scatter(temp_prop_grid_pts(merge_tropo_idx,2),temp_prop_grid_pts(merge_tropo_idx,1),10,min_full_prop_mode_data(merge_tropo_idx),'filled');
                scatter(temp_prop_grid_pts(merge_diff_idx,2),temp_prop_grid_pts(merge_diff_idx,1),10,min_full_prop_mode_data(merge_diff_idx),'filled');
                scatter(temp_prop_grid_pts(merge_los_idx,2),temp_prop_grid_pts(merge_los_idx,1),10,min_full_prop_mode_data(merge_los_idx),'filled');
                %h2=plot(non_tropo_convex_bound(:,2),non_tropo_convex_bound(:,1),'-g','LineWidth',2,'DisplayName','Troposcatter Bound');

                [num_base_pts,~]=size(base_polygon);
                if num_base_pts==1
                    plot(base_polygon(:,2),base_polygon(:,1),'ok','LineWidth',3)
                else
                    plot(base_polygon(:,2),base_polygon(:,1),'-k','LineWidth',2)
                end
                plot(base_protection_pts(:,2),base_protection_pts(:,1),'xr','LineWidth',3,'DisplayName','Federal System')

                cbh = colorbar;
                ylabel(cbh, 'Prop Mode')
                colormap(f1,mode_color_set)
                cbh.Ticks = linspace(min(min_full_prop_mode_data),max(min_full_prop_mode_data), 7); 
                cbh.TickLabels ={'','LOS','','DIFF','','TROPO',''};
                grid on;
                %legend([h2])
                xlabel('Longitude')
                ylabel('Latitude')
                title({strcat(data_label1),strcat('Propagation Mechanism')})
                plot_google_map('maptype','terrain','APIKey','AIzaSyCgnWnM3NMYbWe7N4svoOXE7B2jwIv28F8') %%%Google's API key made by nick.matlab.error@gmail.com
                pause(0.1)
                filename1=strcat('Prop_mode_Bound','_',data_label1,'_',num2str(grid_spacing),'km.png');
                saveas(gcf,char(filename1))
                pause(0.1);
                close(f1)

                %%%%%%%%%Find the Minimum Path Loss for each grid point
                size(min_full_pl_data)

                %%%%%%Find the idx for the points less  than required_pathloss
                num_rel_check=length(array_reliability_check);
                num_pathloss=length(required_pathloss);
                num_threshold=length(radar_threshold);


                if num_pathloss~=num_threshold
                    disp_progress(app,strcat('Mapping: The num_pathloss and num_threshold is different, need to check why or fill in the logic  . . .'))
                    pause;
                end

                %%%%%%Check for cell_pathloss_data
                filename_cell_rel_idx=strcat(data_label1,'_cell_rel_idx_',num2str(num_rel_check),'_',num2str(num_pathloss),'_',num2str(grid_spacing),'km.mat');
                [var_exist_cell_rel_idx]=persistent_var_exist_with_corruption(app,filename_cell_rel_idx);
                 if tf_recalculate==1
                    var_exist_cell_rel_idx=0;
                end
                if var_exist_cell_rel_idx==2
                    retry_load=1;
                    while(retry_load==1)
                        try
                            load(filename_cell_rel_idx,'cell_rel_idx')
                            pause(0.1)
                            retry_load=0;
                        catch
                            retry_load=1;
                            pause(1)
                        end
                    end
                    pause(0.1)
                else

                    %%%%%%%%%1) Keep idx points
                    %%%%%%%%%2) Keep grid points
                    %%%%%%%%4) Keep Margin Over

                    cell_rel_idx=cell(num_rel_check,num_pathloss,5);

                    %%%%%%%%%1)temp_reliability
                    %%%%%%%%%2) temp_pathloss
                     %%%%%%%%3) max_knn_dist
                      %%%%%%%4) Convex Hull
                      %%%%5) Radar Threshold

                    for rel_check_idx=1:1:num_rel_check
                        temp_reliability=array_reliability_check(rel_check_idx)
                        rel_idx=find(temp_reliability==reliability)

                        for path_idx=1:1:num_pathloss
                            temp_pathloss=required_pathloss(path_idx)
                            temp_threshold=radar_threshold(path_idx)

                            temp_margin=temp_pathloss-min_full_pl_data(:,rel_idx);
                            idx_keep=find(temp_margin>0);

                            temp_nan_idx=find(isnan(min_full_pl_data(:,rel_idx)));
                            size(temp_nan_idx)
                            if ~isempty(intersect(idx_keep,temp_nan_idx))
                                'Check for Overlapping idx-keep and nan_idx'
                                pause;
                            end

                         
                            if ~isempty(idx_keep)
                                length(idx_keep)
                                keep_margin=temp_margin(idx_keep);


                                %%%%%%%%Find the max distance as a check
                                temp_grid_pts=sim_array_list_bs(idx_keep,[1,2]);
                                [idx_knn]=knnsearch(base_protection_pts,temp_grid_pts,'k',1); %%%Find Nearest Neighbor
                                base_knn_array=base_protection_pts(idx_knn,:);
                                knn_dist_bound=deg2km(distance(base_knn_array(:,1),base_knn_array(:,2),temp_grid_pts(:,1),temp_grid_pts(:,2)));%%%%Calculate Distance
                                max_knn_dist=ceil(max(knn_dist_bound))

                                %%%%%
                                if ~isempty(temp_grid_pts)==1
                                    all_coordination_pts=vertcat(temp_grid_pts,base_protection_pts);
                                else
                                    all_coordination_pts=vertcat(base_protection_pts);
                                end


                                %%%%%Convex hull the points
                                bound_idx=boundary(all_coordination_pts(:,2),all_coordination_pts(:,1),0);
                                pathloss_convex_bound=all_coordination_pts(bound_idx,:);

                                cell_rel_idx{rel_check_idx,path_idx,1}=temp_reliability;
                                cell_rel_idx{rel_check_idx,path_idx,2}=temp_pathloss;
                                cell_rel_idx{rel_check_idx,path_idx,3}=max_knn_dist;
                                cell_rel_idx{rel_check_idx,path_idx,4}=pathloss_convex_bound;
                                cell_rel_idx{rel_check_idx,path_idx,5}=temp_threshold;


                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Set the Color Map
                                round_dbm_data=round(keep_margin);
                                min(round_dbm_data)
                                max(round_dbm_data)

                                non_inf_idx=find(~isinf(round_dbm_data));
                                non_inf_round_dbm_data=round_dbm_data(non_inf_idx);
                                non_inf_keep_grid_pts=temp_grid_pts(non_inf_idx,:);
                                min(non_inf_round_dbm_data)
                                max(non_inf_round_dbm_data)

                                if ~isempty(non_inf_keep_grid_pts)==1

                                    [sort_non_inf_round_dbm_data,sort_idx]=sort(non_inf_round_dbm_data,'ascend');
                                    sort_non_inf_keep_grid_pts=non_inf_keep_grid_pts(sort_idx,:);

                                    dbm2_range=max(non_inf_round_dbm_data)-min(horzcat(min(non_inf_round_dbm_data),0));
                                    color_set=plasma(dbm2_range);

                                    %%%%%%%%%%%%%%%%Original Linear Heat Map Color set
                                    f1=figure;
                                    AxesH = axes;
                                    hold on;
                                    scatter(sort_non_inf_keep_grid_pts(:,2),sort_non_inf_keep_grid_pts(:,1),10,sort_non_inf_round_dbm_data,'filled');
                                    [num_base_pts,~]=size(base_polygon);
                                    if num_base_pts==1
                                        plot(base_polygon(:,2),base_polygon(:,1),'ok','LineWidth',3)
                                    else
                                        plot(base_polygon(:,2),base_polygon(:,1),'-k','LineWidth',2)
                                    end
                                    plot(base_protection_pts(:,2),base_protection_pts(:,1),'ob','LineWidth',3,'DisplayName','Federal System')
                                    h2=plot(pathloss_convex_bound(:,2),pathloss_convex_bound(:,1),'-r','LineWidth',2,'DisplayName','Coordination Zone');
                                    h = colorbar;
                                    ylabel(h, 'Margin [dB]')
                                    colormap(f1,color_set)
                                    grid on;
                                    legend([h2])
                                    xlabel('Longitude')
                                    ylabel('Latitude')
                                    title({strcat(data_label1),strcat('Path Loss Reliability:',num2str(temp_reliability),'%'),strcat('Pathloss:',num2str(temp_pathloss),'dB:',num2str(max_knn_dist),'km')})
                                    plot_google_map('maptype','terrain','APIKey','AIzaSyCgnWnM3NMYbWe7N4svoOXE7B2jwIv28F8') %%%Google's API key made by nick.matlab.error@gmail.com
                                    pause(0.1)
                                    filename1=strcat('No_UA_Bound','_',data_label1,'_',num2str(temp_reliability),'_',num2str(grid_spacing),'km_',num2str(temp_pathloss),'dB.png');
                                    saveas(gcf,char(filename1))
                                    pause(0.1);
                                    close(f1)
                                end
                            end
                        end
                    end
                    cell_rel_idx=squeeze(cell_rel_idx)
                    retry_save=1;
                    while(retry_save==1)
                        try
                            save(filename_cell_rel_idx,'cell_rel_idx')
                            pause(0.1)
                            retry_save=0;
                        catch
                            retry_save=1;
                            pause(1)
                        end
                    end
                    pause(0.1)

                end


                [num_circles,~]=size(cell_rel_idx)
                   num_rel_check=length(array_reliability_check);
                num_pathloss=length(required_pathloss);
                num_threshold=length(radar_threshold);

                if num_rel_check==1 && num_pathloss==1 && num_threshold==1
                    num_circles=1
                end


                %color_set3=flipud(plasma(num_circles+1));
                color_set3=plasma(num_circles);
                f1=figure;
                AxesH = axes;
                hold on;
                
                [num_base_pts,~]=size(base_polygon);
                if num_base_pts==1
                    plot(base_polygon(:,2),base_polygon(:,1),'xk','LineWidth',3,'DisplayName','Federal System')
                else
                    plot(base_polygon(:,2),base_polygon(:,1),'-k','LineWidth',2,'DisplayName','Federal System')
                end
                plot(base_protection_pts(:,2),base_protection_pts(:,1),'ob','LineWidth',3,'DisplayName','Federal System')
                
                if num_circles>1
                    for i=num_circles:-1:1
                        %for i=1:1:num_circles
                        temp_bound=cell_rel_idx{i,4};
                        if ~isempty(temp_bound)
                            temp_reliability=cell_rel_idx{i,1};
                            temp_pathloss=cell_rel_idx{i,2};
                            temp_dist_km=cell_rel_idx{i,3};
                            temp_threshold=cell_rel_idx{i,5};
                            plot(temp_bound(:,2),temp_bound(:,1),'-','Color',color_set3(i,:),'LineWidth',3,'DisplayName',strcat(num2str(temp_dist_km),'km:',num2str(temp_threshold),'dBm/100MHz:',num2str(temp_reliability),'%'))
                        end
                    end
                elseif num_circles==1
                    temp_bound=cell_rel_idx{4};
                    if ~isempty(temp_bound)
                        temp_reliability=cell_rel_idx{1};
                        temp_pathloss=cell_rel_idx{2};
                        temp_dist_km=cell_rel_idx{3};
                        temp_threshold=cell_rel_idx{5};
                        plot(temp_bound(:,2),temp_bound(:,1),'-','Color',color_set3,'LineWidth',3,'DisplayName',strcat(num2str(temp_dist_km),'km:',num2str(temp_threshold),'dBm/100MHz:',num2str(temp_reliability),'%'))
                    end
                end
              
                title({strcat(data_label1)})
                grid on;
                %legend
                if num_circles>1
                    legend('Location','eastoutside')
                end
                xlabel('Longitude')
                ylabel('Latitude')
                plot_google_map('maptype','terrain','APIKey','AIzaSyCgnWnM3NMYbWe7N4svoOXE7B2jwIv28F8') %%%Google's API key made by nick.matlab.error@gmail.com
                pause(0.1)
                filename1=strcat('Multi_Circles','_',data_label1,'_',num2str(grid_spacing),'km.png');
                saveas(gcf,char(filename1))
                pause(0.1);
                close(f1)

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
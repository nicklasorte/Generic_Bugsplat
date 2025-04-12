function part2_bugsplat_maps_azimuth_radial_multi_pop_geoplot_rev13(app,rev_folder,reliability,string_prop_model,grid_spacing,array_reliability_check,tf_calc_rx_angle,tf_recalculate,tf_tropo_cut,tf_server_status,array_mitigation,tf_rescrap_pathloss)


[sim_number,folder_names,~]=check_rev_folders(app,rev_folder);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Function:
cell_status_filename=strcat('cell_',string_prop_model,'_',num2str(sim_number),'_contour_pop_status.mat')
label_single_filename=strcat(string_prop_model,'_',num2str(sim_number),'_contour_pop_status')
checkout_filename=strcat('TF_checkout_',string_prop_model,'_',num2str(sim_number),'_contour_pop_status.mat')
%location_table=table([1:1:length(folder_names)]',folder_names)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Check for the Number of Folders to Sim


%%%%%%%%%%Need a list because going through 470 folders takes 17 minutes
tf_update_cell_status=0;
sim_folder='';  %%%%%Empty sim_folder to not update.
[cell_status]=checkout_cell_status_rev1(app,checkout_filename,cell_status_filename,sim_folder,folder_names,tf_update_cell_status);


if tf_recalculate==1
    cell_status(:,2)=num2cell(0);
    %%%%%Save the Cell
    retry_save=1;
    while(retry_save==1)
        try
            save(cell_status_filename,'cell_status')
            retry_save=0;
        catch
            retry_save=1;
            pause(2)
        end
    end

end
zero_idx=find(cell2mat(cell_status(:,2))==0);
cell_status

if ~isempty(zero_idx)==1
    temp_folder_names=folder_names(zero_idx)
    num_folders=length(temp_folder_names);

    %%%%%%%%Pick a random folder and go to the folder to do the sim
    disp_progress(app,strcat('Mapping . . .'))
    reset(RandStream.getGlobalStream,sum(100*clock))  %%%%%%Set the Random Seed to the clock because all compiled apps start with the same random seed.

    [tf_ml_toolbox]=check_ml_toolbox(app);
    if tf_ml_toolbox==1
        array_rand_folder_idx=randsample(num_folders,num_folders,false);
    else
        array_rand_folder_idx=randperm(num_folders);
    end

    temp_folder_names(array_rand_folder_idx)
    disp_randfolder(app,num2str(array_rand_folder_idx'))

    %%%%%%%%%%%%%%%%%%%%%%%%Load the Census Pop Data
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

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [multi_hWaitbar,multi_hWaitbarMsgQueue]= ParForWaitbarCreateMH_time('Multi-Folder Mapping: ',num_folders);    %%%%%%% Create ParFor Waitbar

    for folder_idx=1:1:num_folders
        disp_TextArea_PastText(app,strcat('Part2 Maps:',num2str(num_folders-folder_idx)))

               %%%%%%%%%%%%%%Check cell_status
        tf_update_cell_status=0;
        sim_folder='';
        [cell_status]=checkout_cell_status_rev1(app,checkout_filename,cell_status_filename,sim_folder,folder_names,tf_update_cell_status);

        sim_folder=temp_folder_names{array_rand_folder_idx(folder_idx)};
        temp_cell_idx=find(strcmp(cell_status(:,1),sim_folder)==1);
        cell_status{temp_cell_idx,2}

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
                %[~]=update_generic_status_cell_rev1(app,folder_names,sim_folder,cell_status_filename);
                 %%%%%%%%Update the cell_status
                tf_update_cell_status=1;
                tic;
                [~]=checkout_cell_status_rev1(app,checkout_filename,cell_status_filename,sim_folder,folder_names,tf_update_cell_status);
                toc;
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

                        load(strcat(data_label1,'_azi_required_pathloss.mat'),'azi_required_pathloss')
                        temp_data=azi_required_pathloss;
                        clear azi_required_pathloss;
                        azi_required_pathloss=temp_data;
                        clear temp_data;

                        load(strcat(data_label1,'_wider_keyhole.mat'),'wider_keyhole')
                        temp_data=wider_keyhole;
                        clear wider_keyhole;
                        wider_keyhole=temp_data;
                        clear temp_data;

                        % % % if tf_calc_rx_angle==0
                        % % %     load(strcat(data_label1,'_required_pathloss.mat'),'required_pathloss')
                        % % %     temp_data=required_pathloss;
                        % % %     clear required_pathloss;
                        % % %     required_pathloss=temp_data;
                        % % %     clear temp_data;
                        % % % end

                        load(strcat(data_label1,'_sim_array_list_bs.mat'),'sim_array_list_bs')
                        temp_data=sim_array_list_bs;
                        clear sim_array_list_bs;
                        sim_array_list_bs=temp_data;
                        clear temp_data;
                        % % %      %%%%array_list_bs  %%%%%%%1) Lat, 2)Lon, 3)BS height, 4)BS EIRP 5) Nick Unique ID for each sector, 6)NLCD: R==1/S==2/U==3, 7) Azimuth 8)BS EIRP Mitigation

                        if tf_calc_rx_angle==1 %%%%%%%Only need to load if we are doing the angles
                            'pause at tf_calc_rx_angle'
                            pause;
                            %%%load(strcat(data_label1,'_array_ant_gain_vertical.mat'),'array_ant_gain_vertical')
                            load(strcat(data_label1,'_min_rx_ant_elevation.mat'),'min_rx_ant_elevation')
                            %load(strcat(data_label1,'_pathloss_minus_rx_ant.mat'),'pathloss_minus_rx_ant')
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
                %%%[base_buffer]=base_buffer_azi_rev3(app,azi_required_pathloss,data_label1,base_protection_pts);
                %%%[base_buffer]=base_buffer_azi_rev3(app,wider_keyhole,data_label1,base_protection_pts);
                 [base_buffer]=base_buffer_azi_multi_rev4(app,wider_keyhole,data_label1,base_protection_pts);

                %%%%%%Load all the ITM pathloss data and TIREM angles

                %%%%%%Load all the pathloss data
                tic;
                [array_full_pl_data,full_prop_mode_data]=load_full_pathloss_info_multi_rel_rev3(app,data_label1,string_prop_model,grid_spacing,tf_rescrap_pathloss,base_protection_pts,sim_array_list_bs,sim_number,tf_tropo_cut,reliability);
                toc;

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Calculate Each Base Station Azimuth
                [num_pp_pts,~]=size(base_protection_pts)
                [num_grid_pts,~]=size(sim_array_list_bs)
                multi_array_margin_dB=NaN(num_grid_pts,num_pp_pts);
                for point_idx=1:1:num_pp_pts
                    sim_pt=base_protection_pts(point_idx,:);
                    bs_azimuth=azimuth(sim_pt(1),sim_pt(2),sim_array_list_bs(:,1),sim_array_list_bs(:,2));
                    zero_azi_idx=find(bs_azimuth==360);
                    bs_azimuth(zero_azi_idx)=0;
                    min(bs_azimuth)
                    max(bs_azimuth)
                    % % % % azimuth(35,-120,35,-121)
                    % % % % azimuth(35,-120,34,-120)

                    %%%%%%%%%Now see if the pathloss is greater than the
                    %%%%%%%%%required pathloss for that azimuth.
                    nn_azi_idx=nearestpoint_app(app,bs_azimuth,azi_required_pathloss(:,1));
                    size(azi_required_pathloss)
                    size(bs_azimuth)
                    size(nn_azi_idx)
                    bs_required_pathloss=azi_required_pathloss(nn_azi_idx,2);
                    size(bs_required_pathloss)

                    if length(array_reliability_check)>1
                        array_reliability_check
                        'Need to insert logic for this multiple array_reliability_check'
                        pause
                    end
                    multi_array_margin_dB(:,point_idx)=bs_required_pathloss-array_full_pl_data(:,point_idx);
                end
                [array_margin_dB,max_idx]=max(multi_array_margin_dB,[],2);
                min_prop_data=full_prop_mode_data(max_idx);
                min(min_prop_data)
                max(min_prop_data)


                num_rel_check=length(array_reliability_check)
                num_rels=length(reliability)
                if num_rel_check==1 && num_pp_pts==1
                    min_pl_data=array_full_pl_data;
                    min_prop_data=full_prop_mode_data;
                elseif num_rels==1
                    [min_pl_data,min_idx]=min(array_full_pl_data(:,:,1),[],2);
                    %min_prop_data=full_prop_mode_data(min_idx);
                else
                    'Need to check rels'
                    pause;
                end



                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Pathloss Heat Map for each Reliability
                %%%%%plot_pathloss_heatmat_reli_rev2(app,array_reliability_check,min_pl_data,data_label1,string_prop_model,grid_spacing,sim_array_list_bs,base_protection_pts)
                %%%%%plot_prop_mechanism_heatmap_rev1(app,data_label1,string_prop_model,grid_spacing,sim_array_list_bs,min_prop_data,base_protection_pts)
                plot_pathloss_heatmat_reli_geoplot_rev3(app,array_reliability_check,min_pl_data,data_label1,string_prop_model,grid_spacing,sim_array_list_bs,base_protection_pts)
                plot_prop_mechanism_heatmap_geoplot_rev2(app,data_label1,string_prop_model,grid_spacing,sim_array_list_bs,min_prop_data,base_protection_pts)

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Find/Plot the Coordination Zones for each reliability
                file_name_cell_bound_miti=strcat('cell_bound_',string_prop_model,'_',num2str(sim_number),'_',data_label1,'.mat');


                num_miti=length(array_mitigation)
                num_rels=length(array_reliability_check);
                cell_bound_miti=cell(num_miti,6,num_rels);
                %%%%1)Mitigation,
                % %%2) Max knn dist,
                % %%3)Convex Bound,
                % %%4)Max Interference dB,
                % %%%5)Prop Reliability
                %%%%%6)Radial Bound
                for rel_idx=1:1:num_rels
                    for miti_idx=1:1:num_miti
                        miti_dB=array_mitigation(miti_idx);
                        temp_rel=array_reliability_check(rel_idx);
                        temp_margin=array_margin_dB(:,rel_idx)-miti_dB;
                        temp_multi_pt_margin=multi_array_margin_dB-miti_dB;

                        % % %
                        idx_keep=find(temp_margin>=0);
                        if ~isempty(idx_keep)
                            %%%%%%%%[max_knn_dist,convex_bound,max_int_dB,radial_bound]=plot_zone_miti_reli_radial_multi_rev4(app,temp_margin,sim_array_list_bs,base_protection_pts,data_label1,string_prop_model,temp_rel,grid_spacing,miti_dB,temp_multi_pt_margin);
                            [max_knn_dist,convex_bound,max_int_dB,radial_bound]=plot_zone_miti_reli_radial_multi_geoplot_rev5(app,temp_margin,sim_array_list_bs,base_protection_pts,data_label1,string_prop_model,temp_rel,grid_spacing,miti_dB,temp_multi_pt_margin);

                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Calculate the coordination zone[ Convex Hull]
                            %[max_knn_dist,convex_bound,max_int_dB]=plot_zone_miti_reli_rev2(app,temp_margin,sim_array_list_bs,base_protection_pts,data_label1,string_prop_model,temp_rel,grid_spacing,miti_dB);
                            cell_bound_miti{miti_idx,1,rel_idx}=miti_dB;
                            cell_bound_miti{miti_idx,2,rel_idx}=max_knn_dist;
                            cell_bound_miti{miti_idx,3,rel_idx}=convex_bound;
                            cell_bound_miti{miti_idx,4,rel_idx}=max_int_dB;
                            cell_bound_miti{miti_idx,5,rel_idx}=temp_rel;
                            cell_bound_miti{miti_idx,6,rel_idx}=radial_bound;
                        end
                    end

                    %%%%%%%%%%%%%Plot the multi-zones, for each Reliability
                    temp_zones=cell_bound_miti(:,:,rel_idx);
                    %%%%%%%%%plot_multi_zones_reli_rev3(app,temp_zones,base_protection_pts,data_label1,string_prop_model,temp_rel,grid_spacing)  %%%%%%ConvexHull
                     plot_multi_zones_reli_geoplot_rev4(app,temp_zones,base_protection_pts,data_label1,string_prop_model,temp_rel,grid_spacing)
                    %%%%%%%%%plot_multi_radial_zones_reli_rev4(app,temp_zones,base_protection_pts,data_label1,string_prop_model,temp_rel,grid_spacing)%%%%%%%Concave
                     plot_multi_radial_zones_reli_geoplot_rev5(app,temp_zones,base_protection_pts,data_label1,string_prop_model,temp_rel,grid_spacing)
                end


                %%%%%%%%Take the maximum radial_bound and compare it to the
                %%%%%%%%wider_keyhole/base_buffer
                larger_radial_bound=cell_bound_miti{1,6,1};
                radial_poly=polyshape(larger_radial_bound(:,2),larger_radial_bound(:,1));
                radial_geopoly=geopolyshape(larger_radial_bound(:,1),larger_radial_bound(:,2));


                %%%%%%%%%%%%%Take the 90th Percentile of it
                check_keyhole=wider_keyhole;
                check_keyhole(:,3)=wider_keyhole(:,3)*0.9;

                [check_buffer]=geo_buffer_azi_rev1(app,base_protection_pts,check_keyhole);
                check_poly=polyshape(check_buffer(:,2),check_buffer(:,1));
                check_geopoly=geopolyshape(check_buffer(:,1),check_buffer(:,2));
                outlier_poly = subtract(radial_poly,check_poly);
                if ~isempty(outlier_poly)
                    vertices=outlier_poly.Vertices;
                    x_coords = vertices(:, 1); % x-coordinates
                    y_coords = vertices(:, 2); % y-coordinates
                    outlier_geopoly=geopolyshape(y_coords,x_coords);
                    %%%%%%%%%Then that means me have a overflow
                    f2 = figure;
                    geoplot(radial_geopoly)
                    hold on;
                    geoplot(check_geopoly)
                    geoplot(outlier_geopoly,'LineWidth',3)
                    geoplot(base_buffer(:,1),base_buffer(:,2),'-k')
                    geoplot(larger_radial_bound(:,1),larger_radial_bound(:,2),'-r')
                    grid on;
                    geobasemap streets-light%landcover
                    f2.Position = [100 100 1200 900];
                    pause(1)
                    filename1=strcat('Insufficient_Buffer_',data_label1,'_',string_prop_model,'.png');
                    saveas(gcf,char(filename1))
                    pause(0.1);
                    close(f2)
                end
    
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


                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Pop Impact
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
                    temp_contour_latlon=cell_bound_miti{row_idx,6};
                    [inside_idx]=find_points_inside_contour_two_step(app,temp_contour_latlon,census_latlon);
                    
                    if ~isempty(inside_idx)
                        cell_contour_pop{row_idx,1}=census_geoid(inside_idx);
                        cell_contour_pop{row_idx,2}=sum(census_pop(inside_idx));
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
                %[~]=update_generic_status_cell_rev1(app,folder_names,sim_folder,cell_status_filename);
                 %%%%%%%%Update the cell_status
                tf_update_cell_status=1;
                tic;
                [~]=checkout_cell_status_rev1(app,checkout_filename,cell_status_filename,sim_folder,folder_names,tf_update_cell_status);
                toc;
                %%%server_status_rev1(app)
                server_status_rev2(app,tf_server_status)
            end
        end
        multi_hWaitbarMsgQueue.send(0);
    end
    delete(multi_hWaitbarMsgQueue);
    close(multi_hWaitbar);
    finish_cell_status_rev1(app,rev_folder,cell_status_filename)
end
server_status_rev2(app,tf_server_status)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%End of Part 2
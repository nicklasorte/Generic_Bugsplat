function part2_plot_dsn_eess_rev1(app,rev_folder,string_prop_model,tf_recalculate,tf_server_status,cell_sim_data_excel,impact_levels,tf_repull_excel,tf_plot_bugsplat,tf_plot_multi_con)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Function:
[sim_number,folder_names,~]=check_rev_folders(app,rev_folder)
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
    mid_lat=new_full_census_2010(:,2);
    mid_lon=new_full_census_2010(:,3);
    census_latlon=horzcat(mid_lat,mid_lon);
    census_pop=new_full_census_2010(:,5);
    census_geoid=new_full_census_2010(:,1);

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

                 %%%%%%%%Update the cell_status
                tf_update_cell_status=1;
                tic;
                [~]=checkout_cell_status_rev1(app,checkout_filename,cell_status_filename,sim_folder,folder_names,tf_update_cell_status);
                toc;
            else

                %%%%%%%%%%%%%Need to find the base_protection_pts
                match_row_idx=find(contains(cell_sim_data_excel(:,1),sim_folder));
                base_protection_pts=cell2mat(cell_sim_data_excel(match_row_idx,[3,4]))
                if isempty(base_protection_pts)
                    'Error: Empty base_protection_pts'
                    pause;
                end

    

                %%%%%%%Need to find the min_contour_dBm
                [num_rows_type,~]=size(impact_levels);
                type_idx=NaN(num_rows_type,1);
                for i=1:1:num_rows_type
                    temp_idx=find(contains(sim_folder,impact_levels{i,1}));
                    if ~isempty(temp_idx)
                        type_idx(i)=i;
                    end
                end
                type_idx=type_idx(~isnan(type_idx));
                array_contour_dBm=impact_levels{type_idx,2}

            
                %%%%%%Load the Data
                %%%%%%%%%%%%%%%%Pull all the excel data in a single folder (This will be
                %%%%%%%%%%%%%%%%scaled to when we have multiple folders, one folder for each location.)
                [cell_folder_data]=pull_dsn_excel_data_rev2(app,tf_repull_excel,sim_folder)

                %%%%%%%%%Merge the data
                cell_file3=cellfun(@(x) strsplit(x, '%'), cell_folder_data(:,2), 'UniformOutput', false);
                cell_str_per=vertcat(cell_file3{:});
                array_per_num=cellfun(@str2num,cell_str_per(:,1));
                uni_per=unique(array_per_num);
                uni_str_per=unique(cell_folder_data(:,2));
                num_per=length(uni_str_per);
                cell_merge_data=cell(num_per,5);  %%4) Convex, 5)Concave

                num_miti=length(array_contour_dBm)
                cell_bound_miti=cell(num_miti,10,num_per);
                %%%%1)Mitigation,
                % %%2) Max knn dist,
                % %%3)Convex Bound,
                % %%4)Max Interference dB,
                % %%%5)Prop Reliability
                %%%%%6)Radial Bound
                %%%%%7)Convex GeoId, 
                %%%%%8)Convex Total Pop
                %%%%%9)Concave GeoId, 
                %%%%%10)Concave Total Pop
                %'Need to put it in this format.'


                for per_idx=1:1:num_per
                    match_row_idx=find(matches(cell_folder_data(:,2),uni_str_per{per_idx}));

                    temp_cell_data=cell_folder_data(match_row_idx,4);
                    array_latlonpwr=vertcat(temp_cell_data{:});
                    size(array_latlonpwr)

                    above_idx=find(array_latlonpwr(:,3)>=(min(array_contour_dBm)-50));
                    array_latlonpwr=array_latlonpwr(above_idx,:);
                    cell_merge_data{per_idx,1}=array_latlonpwr;
                    cell_merge_data{per_idx,2}=cell_folder_data{match_row_idx(1),2};

                    if tf_plot_bugsplat==1
                        %%%%%%%%%%Make the bugsplat plot for all data.
                        filename_bugsplat=strcat('Power_BugSplat_',sim_folder,'_',cell_merge_data{per_idx,2},'.png')
                        title_str=strcat(sim_folder,':',cell_merge_data{per_idx,2},'%')
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Map the Power
                        map_bugsplat_rev1(app,array_latlonpwr,filename_bugsplat,title_str)
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    end

                    num_contours=length(array_contour_dBm);
                    temp_latlon_data=array_latlonpwr;
                    cell_multi_convex=cell(num_contours,2);  %%%%%%Convex
                    cell_multi_concave=cell(num_contours,2);  %%%%%%Concave
                    for con_idx=1:1:num_contours
                        above_idx=find(temp_latlon_data(:,3)>=array_contour_dBm(con_idx));
                        if ~isempty(above_idx)
                            temp_latlon_data=temp_latlon_data(above_idx,:);
                            max_int_dB=max(temp_latlon_data(:,3)); %%%%%Worthless data
                            %%%%%Convex hull the points
                            bound_idx=boundary(temp_latlon_data(:,2),temp_latlon_data(:,1),0);
                            convex_bound=temp_latlon_data(bound_idx,[1,2]);
                            cell_multi_convex{con_idx,1}=array_contour_dBm(con_idx);
                            cell_multi_convex{con_idx,2}=convex_bound;
                     

                            %%%%%%%%Find the max_knn_dist
                            [idx_knn]=knnsearch(base_protection_pts(:,[1,2]),convex_bound,'k',1); %%%Find Nearest Neighbor
                            base_knn_array=base_protection_pts(idx_knn,[1,2]);
                            knn_dist_bound=deg2km(distance(base_knn_array(:,1),base_knn_array(:,2),convex_bound(:,1),convex_bound(:,2)));%%%%Calculate Distance
                            max_knn_dist=ceil(max(knn_dist_bound));


                            %%%%%%%%%%%%%%%%Concave
                            %%%%%%Bin for each 1 degree step
                            [num_pp_pts,~]=size(base_protection_pts)
                            if num_pp_pts>1
                                sim_pt=horzcat(meanm(base_protection_pts(:,1),base_protection_pts(:,2)));
                            else
                                sim_pt=base_protection_pts;
                            end
                            min_dist_km=1;
                            [radial_bound]=radial_bound_rev2(app,sim_pt,temp_latlon_data(:,[1,2]),min_dist_km);
                            cell_multi_concave{con_idx,1}=array_contour_dBm(con_idx);
                            cell_multi_concave{con_idx,2}=radial_bound;

                            if con_idx==1
                                cell_merge_data{per_idx,3}=convex_bound;
                                cell_merge_data{per_idx,4}=radial_bound;
                            end

                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            cell_bound_miti{con_idx,1,per_idx}=array_contour_dBm(con_idx);
                            cell_bound_miti{con_idx,2,per_idx}=max_knn_dist;
                            cell_bound_miti{con_idx,3,per_idx}=convex_bound;
                            cell_bound_miti{con_idx,4,per_idx}=max_int_dB;
                            cell_bound_miti{con_idx,5,per_idx}=cell_merge_data{per_idx,2}; %%%%%Might need to change string to a number
                            cell_bound_miti{con_idx,6,per_idx}=radial_bound;

                            %%%%1)Mitigation,
                            % %%2) Max knn dist,
                            % %%3)Convex Bound,
                            % %%4)Max Interference dB,
                            % %%%5)Prop Reliability
                            %%%%%6)Radial Bound
                            %%%%%7)Convex GeoId,
                            %%%%%8)Convex Total Pop
                            %%%%%9)Concave GeoId,
                            %%%%%10)Concave Total Pop

                             %%%%%%%%%For each contounr, find the pop impact
                            [inside_idx]=find_points_inside_contour_two_step(app,convex_bound,census_latlon);
                            if ~isempty(inside_idx)
                                cell_bound_miti{con_idx,7,per_idx}=census_geoid(inside_idx);
                                cell_bound_miti{con_idx,8,per_idx}=sum(census_pop(inside_idx));
                            else
                                cell_bound_miti{con_idx,7,per_idx}=NaN(1,1);
                                cell_bound_miti{con_idx,8,per_idx}=0;
                            end

                             %%%%%%%%%For each contounr, find the pop impact
                            [inside_idx]=find_points_inside_contour_two_step(app,radial_bound,census_latlon);
                            if ~isempty(inside_idx)
                                cell_bound_miti{con_idx,9,per_idx}=census_geoid(inside_idx);
                                cell_bound_miti{con_idx,10,per_idx}=sum(census_pop(inside_idx));
                            else
                                cell_bound_miti{con_idx,9,per_idx}=NaN(1,1);
                                cell_bound_miti{con_idx,10,per_idx}=0;
                            end
                        end
                    end
                    cell_multi_convex=cell_multi_convex(~cellfun('isempty',cell_multi_convex(:,1)),:);
                    cell_multi_concave=cell_multi_concave(~cellfun('isempty',cell_multi_concave(:,1)),:);

                    if tf_plot_multi_con==1
                        filename_bugsplat=strcat('Convex_Multi_Bound_Contours_',sim_folder,'_',cell_folder_data{match_row_idx(1),2},'.png');
                        title_str=strcat('Convex Multi-Contours:',sim_folder,':',cell_folder_data{match_row_idx(1),2});
                        map_multi_contours_rev1(app,cell_multi_convex,title_str,filename_bugsplat)
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                         filename_bugsplat=strcat('Concave_Multi_Bound_Contours_',sim_folder,'_',cell_folder_data{match_row_idx(1),2},'.png');
                        title_str=strcat('Concave Multi-Contours:',sim_folder,':',cell_folder_data{match_row_idx(1),2});
                        map_multi_contours_rev1(app,cell_multi_concave,title_str,filename_bugsplat)
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    end
                end



                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Convex
                %%%%%%%%%%Now we need to make the 50% and 0.01% contour for
                filename_bugsplat=strcat('Convex_Reliability_Contours_',sim_folder,'.png');
                title_str=strcat('Convex Multi-Reliability:',sim_folder);
                [num_con,~]=size(cell_merge_data)
                color_set3=flipud(plasma(num_con));
                f1=figure;
                for row_idx=1:1:num_con
                    temp_bound=cell_merge_data{row_idx,3};  %%%%Convex
                    display_str=cell_merge_data{row_idx,2};
                    if ~isempty(temp_bound)
                        geoplot(temp_bound(:,1),temp_bound(:,2),'-','Color',color_set3(row_idx,:),'LineWidth',3,'DisplayName',display_str)
                        hold on;
                    end
                end
                title({title_str})
                grid on;
                legend
                pause(0.1)
                geobasemap streets-light%landcover
                f1.Position = [100 100 1200 900];
                pause(1)
                saveas(gcf,char(filename_bugsplat))
                pause(0.1);
                close(f1)

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Concave
                %%%%%%%%%%Now we need to make the 50% and 0.01% contour for
                filename_bugsplat=strcat('Concave_Reliability_Contours_',sim_folder,'.png');
                title_str=strcat('Concave Multi-Reliability:',sim_folder);
                [num_con,~]=size(cell_merge_data)
                color_set3=flipud(plasma(num_con));
                f1=figure;
                for row_idx=1:1:num_con
                    temp_bound=cell_merge_data{row_idx,4};  %%%%Concave
                    display_str=cell_merge_data{row_idx,2};
                    if ~isempty(temp_bound)
                        geoplot(temp_bound(:,1),temp_bound(:,2),'-','Color',color_set3(row_idx,:),'LineWidth',3,'DisplayName',display_str)
                        hold on;
                    end
                end
                title({title_str})
                grid on;
                legend
                pause(0.1)
                geobasemap streets-light%landcover
                f1.Position = [100 100 1200 900];
                pause(1)
                saveas(gcf,char(filename_bugsplat))
                pause(0.1);
                close(f1)


                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Find/Plot the Coordination Zones for each reliability
                file_name_cell_bound_miti=strcat('cell_bound_',string_prop_model,'_',num2str(sim_number),'_',data_label1,'.mat');
                %%%%1)Mitigation,
                % %%2) Max knn dist,
                % %%3)Convex Bound,
                % %%4)Max Interference dB,
                % %%%5)Prop Reliability
                %%%%%6)Radial Bound
                %%%%%7)Convex GeoId,
                %%%%%8)Convex Total Pop
                %%%%%9)Concave GeoId,
                %%%%%10)Concave Total Pop
         
    
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
                tf_update_cell_status=1;
                tic;
                [~]=checkout_cell_status_rev1(app,checkout_filename,cell_status_filename,sim_folder,folder_names,tf_update_cell_status);
                toc;
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
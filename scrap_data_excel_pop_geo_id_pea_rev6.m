function scrap_data_excel_pop_geo_id_pea_rev6(app,tf_rescrap_rev_data,sim_number,string_prop_model,grid_spacing,array_mitigation,rev_folder,tf_server_status)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Scrap Data for table.
%tf_rescrap_rev_data=0%1%0
filename_cell_kml_data=strcat('cell_coordination_kml_',string_prop_model,'_',num2str(sim_number),'_',num2str(grid_spacing),'km.mat');
filename_cell_geo_id=strcat('cell_geo_id_',string_prop_model,'_',num2str(sim_number),'_',num2str(grid_spacing),'km.mat');
filename_cell_convex_zone=strcat('cell_convex_zones_',string_prop_model,'_',num2str(sim_number),'_',num2str(grid_spacing),'km.mat');
disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 9'))

if tf_rescrap_rev_data==0
    %'check if all the files are there, if not, then set tf_rescrap_rev_data==0, else load'
    [var_exist1]=persistent_var_exist_with_corruption(app,filename_cell_kml_data);
    [var_exist2]=persistent_var_exist_with_corruption(app,filename_cell_geo_id);
    [var_exist3]=persistent_var_exist_with_corruption(app,filename_cell_convex_zone);

    if var_exist1~=2 || var_exist2~=2 || var_exist3~=2
        tf_rescrap_rev_data=1;
    end
end
disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 21'))


if tf_rescrap_rev_data==1
    server_status_rev2(app,tf_server_status)
    [sim_number,folder_names,num_folders]=check_rev_folders(app,rev_folder);
    %location_table=table([1:1:length(folder_names)]',folder_names)
    array_rand_folder_idx=1:1:num_folders;

    %%%%%%%%%%%%%%%%%%%%Instead of status file, the data with the neighborhood
    %%%%%%%%%%%%%%%%%%%%distance will be the status file
    %%%% 1) Name and 2)Neighborhood Distance 3) Population

    cell_coordination_kml=cell(num_folders,3); %%%%%%%%1) Name ,2) Lat, 3)Lon
    cell_coordination_data=cell(num_folders,1);
    cell_geo_id=cell(num_folders,2); %%%%1)Name, 2)GeoID
    cell_table_0dB_dist_pop=cell(num_folders,1); %%%%Excel with 0dB distance and pop
    cell_table_all_dist=cell(num_folders,1); %%%%Excel with all miti distances
    cell_table_all_pop=cell(num_folders,2); %%%%Excel with all the pop
    cell_convex_zones=cell(num_folders,2); %%%%%%%%%1)Name, 2)Mitigation/ConvexZone
    for folder_idx=1:1:num_folders
        disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 42: folder_idx:',num2str(folder_idx)))
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
                sim_folder=folder_names{array_rand_folder_idx(folder_idx)}
                cd(sim_folder)
                pause(0.1);
                retry_cd=0;
            catch
                retry_cd=1;
                pause(0.1)
            end
        end
        data_label1=sim_folder;
        disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 69:',sim_folder))

        %%%%%Load
        num_miti=length(array_mitigation);
        filename_cell_contour_pop=strcat(data_label1,'_cell_miti_contour_pop_',string_prop_model,'_',num2str(num_miti),'_',num2str(grid_spacing),'km.mat');

        [var_exist_cell_rel_idx]=persistent_var_exist_with_corruption(app,filename_cell_contour_pop);
        if var_exist_cell_rel_idx==2
            disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 77:',sim_folder))

            retry_load=1;
            while(retry_load==1)
                try
                    load(filename_cell_contour_pop,'cell_miti_contour_pop')
                    pause(0.1)
                    retry_load=0;
                catch
                    retry_load=1;
                    pause(1)
                end
            end
            disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 90:',sim_folder))
            %%%%1)Mitigation,
            % %%2) Max knn dist,
            % %%3) Convex Bound,
            % %%4) Max Interference dB,
            % %%%5) Prop Reliability
            %%%%%6) Radial Bound (Concave)
            %%%%%7) GeoId (Concave),
            % %%%8) Total Pop (Concave)


            dual_cell=cell(2,2);
            dual_cell{1,1}=sim_folder;
            dual_cell{1,2}=cell2mat(cell_miti_contour_pop(:,[2])');
            dual_cell{2,1}=sim_folder;
            dual_cell{2,2}=cell2mat(cell_miti_contour_pop(:,[8])');
            %dual_cell

            cell_coordination_data{folder_idx,1}=dual_cell;

            %%%%%Convex
            cell_convex_zones{folder_idx,1}=sim_folder;
            cell_convex_zones{folder_idx,2}=cell_miti_contour_pop(:,[1,3]);

            cell_single_contour=cell(1,3);
            cell_single_contour{1,1}=sim_folder;
            if ~isempty(cell_miti_contour_pop)
                cell_single_contour{1,2}=cell2mat(cell_miti_contour_pop(1,[2])');
                cell_single_contour{1,3}=cell2mat(cell_miti_contour_pop(1,[8])');
            end
            cell_table_0dB_dist_pop{folder_idx,1}=cell_single_contour;

            %%%%%%%%%All Miti Distance
            cell_multi_contour=cell(1,2);
            cell_multi_contour{1,1}=sim_folder;
            cell_multi_contour{1,2}=cell2mat(cell_miti_contour_pop(:,[2])');
            cell_table_all_dist{folder_idx,1}=cell_multi_contour;

            %%%%%%%%%All Miti Population
            cell_table_all_pop{folder_idx,1}=sim_folder;
            cell_table_all_pop{folder_idx,2}=cell2mat(cell_miti_contour_pop(:,[8])');


            %%%%%%%%%%Gather the GEO Id
            cell_geo_id{folder_idx,1}=sim_folder;
            cell_geo_id{folder_idx,2}=cell_miti_contour_pop{1,7};

            %%%%1)Mitigation,
            % %%2) Max knn dist,
            % %%3)Convex Bound,
            % %%4)Max Interference dB,
            % %%%5)Prop Reliability
            %%%%%6)Radial Bound
            %%%%%7) GeoId,
            % %%%8) Total Pop


            %%%%1)Mitigation,
            % %%2) Max knn dist,
            % %%3)Convex Bound,
            % %%4)Max Interference dB,
            % %%%5)Prop Reliability
            %%%%%6) GeoId,
            % %%%7) Total Pop

            cell_coordination_kml{folder_idx,1}=sim_folder;
            if ~isempty(cell_miti_contour_pop)
                temp_latlon=cell_miti_contour_pop{1,6};

                %%%%%Clockwise
                [x_cw, y_cw] = poly2cw(temp_latlon(:,2),temp_latlon(:,1));
                temp_latlon=horzcat(y_cw,x_cw);

                cell_coordination_kml{folder_idx,2}=temp_latlon(:,1);
                cell_coordination_kml{folder_idx,3}=temp_latlon(:,2);
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
    end
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 180'))


    %%%%%Save 1
    %filename_cell_kml_data=strcat('cell_coordination_kml_',string_prop_model,'_',num2str(sim_number),'_',num2str(grid_spacing),'km.mat');
    retry_save=1;
    while(retry_save==1)
        try
            save(filename_cell_kml_data,'cell_coordination_kml')
            pause(0.1)
            retry_save=0;
        catch
            retry_save=1;
            pause(1)
        end
    end
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 196'))

    %%%%%Save 2
    %filename_cell_geo_id=strcat('cell_geo_id_',string_prop_model,'_',num2str(sim_number),'_',num2str(grid_spacing),'km.mat');
    retry_save=1;
    while(retry_save==1)
        try
            save(filename_cell_geo_id,'cell_geo_id')
            pause(0.1)
            retry_save=0;
        catch
            retry_save=1;
            pause(1)
        end
    end
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 211'))

    %%%%%Save 3
    %filename_cell_convex_zone=strcat('cell_convex_zones_',string_prop_model,'_',num2str(sim_number),'_',num2str(grid_spacing),'km.mat');
    retry_save=1;
    while(retry_save==1)
        try
            save(filename_cell_convex_zone,'cell_convex_zones')
            pause(0.1)
            retry_save=0;
        catch
            retry_save=1;
            pause(1)
        end
    end
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 226'))

    %%%%%%%%%%%'Now write an excel table'
    %%%%%%%%All the population for each mitigation.
    table_full_pop_data=cell2table(cell_table_all_pop)
    writetable(table_full_pop_data,strcat('Coordination_All_Pop_',num2str(sim_number),'.xlsx'))
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 232'))

    %if ~isempty(cell2mat(cell_coordination_data))
    table_full_data=cell2table(vertcat(cell_coordination_data{:}))
    writetable(table_full_data,strcat('Coordination_Distances__Pop_',num2str(sim_number),'.xlsx'))
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 237'))
    %end

    %if ~isempty(cell2mat(cell_table1))
    table_data1=cell2table(vertcat(cell_table_0dB_dist_pop{:}))
    writetable(table_data1,strcat('Base_Coordination_Dist_Pop_',num2str(sim_number),'.xlsx'))
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 243'))
    %end

    %if ~isempty(cell2mat(cell_table2))
    table_data2=cell2table(vertcat(cell_table_all_dist{:}))
    writetable(table_data2,strcat('All_Miti_Coordination_Dist_',num2str(sim_number),'.xlsx'))
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 249'))
    %end
    %pause(0.1)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Make the KML file
    %if ~isempty(cell2mat(cell_coordination_kml))
    geos=geoshape(cell_coordination_kml(:,2),cell_coordination_kml(:,3));
    geos.Name=cell_coordination_kml(:,1);
    geos.Geometry='polygon';
    tic;
    filename_kml=strcat('Rev',num2str(sim_number),'.kml')
    kmlwrite(filename_kml, geos, 'Name', geos.Name, 'Description',{},'EdgeColor','r','FaceColor','w','FaceAlpha',0.5,'LineWidth',3);
    toc;
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 262'))
    %end
    server_status_rev2(app,tf_server_status)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 267'))
    % %%%%%%%%%%%%Load the data.
    % retry_load=1;
    % while(retry_load==1)
    %     try
    %         load(filename_cell_kml_data,'cell_coordination_kml')
    %         pause(0.1)
    %         retry_load=0;
    %     catch
    %         retry_load=1;
    %         pause(1)
    %     end
    % end
    % 
    % retry_load=1;
    % while(retry_load==1)
    %     try
    %         load(filename_cell_geo_id,'cell_geo_id')
    %         pause(0.1)
    %         retry_load=0;
    %     catch
    %         retry_load=1;
    %         pause(1)
    %     end
    % end

    retry_load=1;
    while(retry_load==1)
        try
            load(filename_cell_convex_zone,'cell_convex_zones')
            pause(0.1)
            retry_load=0;
        catch
            retry_load=1;
            pause(1)
        end
    end
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 304'))
end
disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 306'))


%%%%%%%%%%%%%%%Test: cell_convex_zones
%tf_rescrap_rev_data=0%1%0%1
% % % % cell_convex_zones=cell(2,2);
% % % % cell_convex_zones{1,1}='Location1';
% % % % cell_convex_zones{2,1}='Location2';
% % % % array_mitigation=0;
% % % % temp_first_cell=cell(1,2);
% % % % temp_first_cell{1,1}=0;
% % % % [temp_lat1,temp_lon1]=scircle1(35,-80,km2deg(400));
% % % % temp_first_cell{1,2}=horzcat(temp_lat1,temp_lon1);
% % % % cell_convex_zones{1,2}=temp_first_cell;
% % % % temp_first_cell=cell(1,2);
% % % % temp_first_cell{1,1}=0;
% % % % [temp_lat2,temp_lon2]=scircle1(35,-85,km2deg(400));
% % % % temp_first_cell{1,2}=horzcat(temp_lat2,temp_lon2);
% % % % cell_convex_zones{2,2}=temp_first_cell;
% % % % cell_convex_zones
% % % % 
% % % % figure;
% % % % hold on;
% % % % plot(temp_lon2,temp_lat2,'-k')
% % % % plot(temp_lon1,temp_lat1,'-r')
% % % % grid on;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%'Another stage of if we rescrap then we calculate, else load'

filename_cell_poly_merge=strcat('cell_poly_merge_',string_prop_model,'_',num2str(sim_number),'_',num2str(grid_spacing),'km.mat');
filename_cell_ind_poly=strcat('cell_ind_poly_',string_prop_model,'_',num2str(sim_number),'_',num2str(grid_spacing),'km.mat');
filename_cell_overlap_poly=strcat('cell_overlap_poly_',string_prop_model,'_',num2str(sim_number),'_',num2str(grid_spacing),'km.mat');
filename_cell_xor_poly=strcat('cell_xor_poly_',string_prop_model,'_',num2str(sim_number),'_',num2str(grid_spacing),'km.mat');
filename_cell_census_poly=strcat('cell_census_poly_',string_prop_model,'_',num2str(sim_number),'_',num2str(grid_spacing),'km.mat');
filename_cell_pea_hist_poly=strcat('cell_pea_hist_poly_',string_prop_model,'_',num2str(sim_number),'_',num2str(grid_spacing),'km.mat');
server_status_rev2(app,tf_server_status)
disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 345'))
if tf_rescrap_rev_data==0
    %'check if all the files are there, if not, then set tf_rescrap_rev_data==0, else load'
    [var_exist4]=persistent_var_exist_with_corruption(app,filename_cell_poly_merge);
    [var_exist5]=persistent_var_exist_with_corruption(app,filename_cell_ind_poly);
    [var_exist6]=persistent_var_exist_with_corruption(app,filename_cell_overlap_poly);
    [var_exist7]=persistent_var_exist_with_corruption(app,filename_cell_xor_poly);
    [var_exist8]=persistent_var_exist_with_corruption(app,filename_cell_census_poly);
    [var_exist9]=persistent_var_exist_with_corruption(app,filename_cell_pea_hist_poly);

    if var_exist4~=2 || var_exist5~=2 || var_exist6~=2 || var_exist7~=2  || var_exist8~=2 || var_exist9~=2
        tf_rescrap_rev_data=1;
    end
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 358'))
end
disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 360'))

if tf_rescrap_rev_data==1
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 363'))
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Polylmerge the cell_convex_zones for each mitigation level
    [cell_poly_merge,cell_ind_poly,cell_overlap_poly,cell_xor_poly]=polymerge_multi_miti_rev1(app,cell_convex_zones,array_mitigation);
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 366'))

    %%%%%Save
    %filename_cell_poly_merge=strcat('cell_poly_merge_',string_prop_model,'_',num2str(sim_number),'_',num2str(grid_spacing),'km.mat');
    retry_save=1;
    while(retry_save==1)
        try
            save(filename_cell_poly_merge,'cell_poly_merge')
            pause(0.1)
            retry_save=0;
        catch
            retry_save=1;
            pause(1)
        end
    end
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 381'))

    %%%%%Save
    %filename_cell_ind_poly=strcat('cell_ind_poly_',string_prop_model,'_',num2str(sim_number),'_',num2str(grid_spacing),'km.mat');
    retry_save=1;
    while(retry_save==1)
        try
            save(filename_cell_ind_poly,'cell_ind_poly')
            pause(0.1)
            retry_save=0;
        catch
            retry_save=1;
            pause(1)
        end
    end
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 396'))

    %%%%%Save
    %filename_cell_overlap_poly=strcat('cell_overlap_poly_',string_prop_model,'_',num2str(sim_number),'_',num2str(grid_spacing),'km.mat');
    retry_save=1;
    while(retry_save==1)
        try
            save(filename_cell_overlap_poly,'cell_overlap_poly')
            pause(0.1)
            retry_save=0;
        catch
            retry_save=1;
            pause(1)
        end
    end
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 411'))

    %%%%%Save
    %filename_cell_xor_poly=strcat('cell_xor_poly_',string_prop_model,'_',num2str(sim_number),'_',num2str(grid_spacing),'km.mat');
    retry_save=1;
    while(retry_save==1)
        try
            save(filename_cell_xor_poly,'cell_xor_poly')
            pause(0.1)
            retry_save=0;
        catch
            retry_save=1;
            pause(1)
        end
    end
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 426'))

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Plot the Overlapping Coordination Zones
    tf_plot_overlap=1%0%1%0%1%0%1%0
    if tf_plot_overlap==1
        plot_nationwide_single_overlap_rev1(app,sim_number,cell_poly_merge,cell_overlap_poly)
    end
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 433'))

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%(This is the figure Nationwide7.)
    %%%%'Next step, plot the poly merge with the layers and a color bar on the right'
    tf_plot_nat=1%0%1%0
    if tf_plot_nat==1
        plot_nationwide_poly_miti_rev1(app,sim_number,cell_poly_merge,array_mitigation)
    end
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 441'))

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%'Census tract impact of overlap and XOR coordination zones'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [cell_census_poly]=census_xor_poly_miti_rev1(app,array_mitigation,cell_xor_poly,cell_overlap_poly);
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 447'))

    %%%%%Save
    %filename_cell_census_poly=strcat('cell_census_poly_',string_prop_model,'_',num2str(sim_number),'_',num2str(grid_spacing),'km.mat');
    retry_save=1;
    while(retry_save==1)
        try
            save(filename_cell_census_poly,'cell_census_poly')
            pause(0.1)
            retry_save=0;
        catch
            retry_save=1;
            pause(1)
        end
    end
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 462'))

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%PEA Table of overlap and XOR coordination zones'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [cell_pea_hist_poly]=pea_impact_overlap_xor_rev1(app,array_mitigation,cell_census_poly);
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 469'))
    %%%%%Save
    %filename_cell_pea_hist_poly=strcat('cell_pea_hist_poly_',string_prop_model,'_',num2str(sim_number),'_',num2str(grid_spacing),'km.mat');
    retry_save=1;
    while(retry_save==1)
        try
            save(filename_cell_pea_hist_poly,'cell_pea_hist_poly')
            pause(0.1)
            retry_save=0;
        catch
            retry_save=1;
            pause(1)
        end
    end
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 483'))

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%NationWide PEA map with the Overlapping
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tf_plot_nat_pea=1%0%1%0
    if tf_plot_nat_pea==1
        plot_pea_overlap_rev1(app,cell_poly_merge,cell_overlap_poly,cell_pea_hist_poly,array_mitigation)
    end
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 492'))

    %%%%%%%Just all Rows (This is the table in Section 4)
    retry_load=1;
    while(retry_load==1)
        try
            load('cell_pea_census_data.mat','cell_pea_census_data')
            pause(0.1)
            retry_load=0;
        catch
            retry_load=1;
            pause(1)
        end
    end
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 506'))

    %load('cell_pea_census_data.mat','cell_pea_census_data')
    %%%%%1)PEA Name, 2)PEA Num, 3)PEA {Lat/Lon}, 4)PEA Pop, 5)PEA Centroid, 6)Census {Geo ID}, 7)Census{Population}, 8)Census{NLCD}, 9)Census Centroid

    miti_idx=1
    temp_dB_miti=array_mitigation(miti_idx)
    temp_cell_pea_hist_poly=squeeze(cell_pea_hist_poly(miti_idx,:,:));
    full_cell_pea_data=horzcat(cell_pea_census_data(:,[1,2,4]),temp_cell_pea_hist_poly(:,[4,5,6]));
    table_pea=cell2table(full_cell_pea_data);
    table_pea.Properties.VariableNames={'PEA_Name' 'PEA_Number' 'PEA_Population' 'XOR_Percentage' 'Overlap_Percentage' 'Available_Percentage'}
    retry_save=1;
    while(retry_save==1)
        try
            writetable(table_pea,strcat('PEA_',num2str(temp_dB_miti),'dB_Poly_',num2str(sim_number),'.xlsx'));
            pause(0.1)
            retry_save=0;
        catch
            retry_save=1;
            pause(1)
        end
    end
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 528'))
else
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 530'))
    % %%%%%%%%% 'Load poly'
    % retry_load=1;
    % while(retry_load==1)
    %     try
    %         load(filename_cell_poly_merge,'cell_poly_merge')
    %         pause(0.1)
    %         retry_load=0;
    %     catch
    %         retry_load=1;
    %         pause(1)
    %     end
    % end
    % retry_load=1;
    % while(retry_load==1)
    %     try
    %         load(filename_cell_ind_poly,'cell_ind_poly')
    %         pause(0.1)
    %         retry_load=0;
    %     catch
    %         retry_load=1;
    %         pause(1)
    %     end
    % end
    % retry_load=1;
    % while(retry_load==1)
    %     try
    %         load(filename_cell_overlap_poly,'cell_overlap_poly')
    %         pause(0.1)
    %         retry_load=0;
    %     catch
    %         retry_load=1;
    %         pause(1)
    %     end
    % end
    % retry_load=1;
    % while(retry_load==1)
    %     try
    %         load(filename_cell_xor_poly,'cell_xor_poly')
    %         pause(0.1)
    %         retry_load=0;
    %     catch
    %         retry_load=1;
    %         pause(1)
    %     end
    % end
    % retry_load=1;
    % while(retry_load==1)
    %     try
    %         load(filename_cell_census_poly,'cell_census_poly')
    %         pause(0.1)
    %         retry_load=0;
    %     catch
    %         retry_load=1;
    %         pause(1)
    %     end
    % end
    % retry_load=1;
    % while(retry_load==1)
    %     try
    %         load(filename_cell_pea_hist_poly,'cell_pea_hist_poly')
    %         pause(0.1)
    %         retry_load=0;
    %     catch
    %         retry_load=1;
    %         pause(1)
    %     end
    % end
end
server_status_rev2(app,tf_server_status)
disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 600'))
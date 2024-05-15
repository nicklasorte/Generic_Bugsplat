function scrap_data_excel_pop_rev3(app,folder_names,string_prop_model,grid_spacing,array_mitigation,rev_folder,sim_number)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Scrap Data for table.
location_table=table([1:1:length(folder_names)]',folder_names)


%%%%%%%%%%%%%%%%%%%%Instead of status file, the data with the neighborhood
%%%%%%%%%%%%%%%%%%%%distance will be the status file
%%%% 1) Name and 2)Neighborhood Distance 3) Population


[num_folders,~]=size(folder_names);
array_rand_folder_idx=1:1:num_folders;

cell_coordination_kml=cell(num_folders,3); %%%%%%%%1) Name ,2) Lat, 3)Lon
cell_coordination_data=cell(num_folders,1); 
cell_table1=cell(num_folders,1); %%%%Excel with 0dB distance and pop
cell_table2=cell(num_folders,1); %%%%Excel with all miti distances
for folder_idx=1:1:num_folders
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


    %%%%%Load
    num_miti=length(array_mitigation);
    filename_cell_contour_pop=strcat(data_label1,'_cell_miti_contour_pop_',string_prop_model,'_',num2str(num_miti),'_',num2str(grid_spacing),'km.mat');

    [var_exist_cell_rel_idx]=persistent_var_exist_with_corruption(app,filename_cell_contour_pop);
    if var_exist_cell_rel_idx==2

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
        cell_miti_contour_pop

        %%%%%Find the idx
        %temp_cell_idx=find(strcmp(cell_coordination_data(:,1),sim_folder)==1);

        dual_cell=cell(2,2);
        dual_cell{1,1}=sim_folder;
        dual_cell{1,2}=cell2mat(cell_miti_contour_pop(:,[2])');
        dual_cell{2,1}=sim_folder;
        dual_cell{2,2}=cell2mat(cell_miti_contour_pop(:,[7])');
        dual_cell

        cell_coordination_data{folder_idx,1}=dual_cell;

        cell_single_contour=cell(1,3);
        cell_single_contour{1,1}=sim_folder;
        if ~isempty(cell_miti_contour_pop)
            cell_single_contour{1,2}=cell2mat(cell_miti_contour_pop(1,[2])');
            cell_single_contour{1,3}=cell2mat(cell_miti_contour_pop(1,[7])');
        end
        cell_table1{folder_idx,1}=cell_single_contour;

        %%%%%%%%%All Miti Distance
        cell_multi_contour=cell(1,2);
        cell_multi_contour{1,1}=sim_folder;
        cell_multi_contour{1,2}=cell2mat(cell_miti_contour_pop(:,[2])');
        cell_table2{folder_idx,1}=cell_multi_contour;


        %%%%1)Mitigation,
        % %%2) Max knn dist,
        % %%3)Convex Bound,
        % %%4)Max Interference dB,
        % %%%5)Prop Reliability
        %%%%%6) GeoId,
        % %%%7) Total Pop


        cell_coordination_kml{folder_idx,1}=sim_folder;
        if ~isempty(cell_miti_contour_pop)
            temp_latlon=cell_miti_contour_pop{1,3};

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


%%%%%%%%%%%'Now write an excel table'
%if ~isempty(cell2mat(cell_coordination_data))
    table_full_data=cell2table(vertcat(cell_coordination_data{:}));
    writetable(table_full_data,strcat('Coordination_Distances__Pop_',num2str(sim_number),'.xlsx'))
%end
cell_table1
%if ~isempty(cell2mat(cell_table1))
    table_data1=cell2table(vertcat(cell_table1{:}))
    writetable(table_data1,strcat('Base_Coordination_Dist_Pop_',num2str(sim_number),'.xlsx'))
%end
cell_table2
%if ~isempty(cell2mat(cell_table2))
    table_data2=cell2table(vertcat(cell_table2{:}))
    writetable(table_data2,strcat('All_Miti_Coordination_Dist_',num2str(sim_number),'.xlsx'))
%end
pause(0.1)


cell_coordination_kml
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Make the KML file
%if ~isempty(cell2mat(cell_coordination_kml))
    geos=geoshape(cell_coordination_kml(:,2),cell_coordination_kml(:,3));
    geos.Name=cell_coordination_kml(:,1);
    geos.Geometry='polygon';
    tic;
    filename_kml=strcat('Rev',num2str(sim_number),'.kml')
    kmlwrite(filename_kml, geos, 'Name', geos.Name, 'Description',{},'EdgeColor','r','FaceColor','w','FaceAlpha',0.5,'LineWidth',3);
    toc;
%end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



end




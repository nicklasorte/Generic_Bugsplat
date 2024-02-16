function scrap_data_excel_pop_rev2(app,folder_names,string_prop_model,grid_spacing,array_mitigation,rev_folder,sim_number)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Scrap Data for table.
location_table=table([1:1:length(folder_names)]',folder_names)


%%%%%%%%%%%%%%%%%%%%Instead of status file, the data with the neighborhood
%%%%%%%%%%%%%%%%%%%%distance will be the status file
%%%% 1) Name and 2)Neighborhood Distance 3) Population


[num_folders,~]=size(folder_names);
array_rand_folder_idx=1:1:num_folders;

cell_coordination_kml=cell(num_folders,3); %%%%%%%%1) Name ,2) Lat, 3)Lon
cell_coordination_data=cell(num_folders,1); 
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
        dual_cell{1,2}=cell2mat(cell_miti_contour_pop(:,[3])');
        dual_cell{2,1}=sim_folder;
        dual_cell{2,2}=cell2mat(cell_miti_contour_pop(:,[6])');

        cell_coordination_data{folder_idx,1}=dual_cell;

                %%%%%%%%%1)Mitigation
        %%%%%%%%%2) required_pathloss
        %%%%%%%%3) max_knn_dist
        %%%%%%%4) Convex Hull

        cell_coordination_kml{folder_idx,1}=sim_folder;
        temp_latlon=cell_miti_contour_pop{1,4};

        %%%%%Clockwise
        [x_cw, y_cw] = poly2cw(temp_latlon(:,2),temp_latlon(:,1));
        temp_latlon=horzcat(y_cw,x_cw);

        cell_coordination_kml{folder_idx,2}=temp_latlon(:,1);
        cell_coordination_kml{folder_idx,3}=temp_latlon(:,2);

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

table_data=cell2table(vertcat(cell_coordination_data{:}))
writetable(table_data,strcat('Coordination_Distances__Pop_',num2str(sim_number),'.xlsx'));
pause(0.1)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Make the KML file
geos=geoshape(cell_coordination_kml(:,2),cell_coordination_kml(:,3));
geos.Name=cell_coordination_kml(:,1);
geos.Geometry='polygon';
tic;
filename_kml=strcat('Rev',num2str(sim_number),'.kml')
kmlwrite(filename_kml, geos, 'Name', geos.Name, 'Description',{},'EdgeColor','r','FaceColor','w','FaceAlpha',0.5,'LineWidth',3);
toc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




function part5_kml_file_rev1(app,folder_names,rev_folder,string_prop_model,sim_number)


'Pull all the cells and create a kml'



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Function:
location_table=table([1:1:length(folder_names)]',folder_names)
 num_folders=length(folder_names);

 %%%%%%%%%%
 cell_cell_kml_data=cell(num_folders,1); %%%%%%%Need to Have 1)Name with Mitigation 2) Lat, 3)Lon
 cell_point_kml_data=cell(num_folders,3); %%%%%%%Need to Have 1)Name  2) Lat, 3)Lon
 for folder_idx=1:1:num_folders

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
             sim_folder=folder_names{folder_idx};
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

     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Load the data.
     load(strcat(data_label1,'_base_polygon.mat'),'base_polygon')

     cell_point_kml_data{folder_idx,1}=data_label1;
     cell_point_kml_data{folder_idx,2}=base_polygon(:,1);
     cell_point_kml_data{folder_idx,3}=base_polygon(:,2);

     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Find/Plot the Coordination Zones for each reliability
     file_name_cell_bound_miti=strcat('cell_bound_',string_prop_model,'_',num2str(sim_number),'_',data_label1,'.mat');

     [var_exist_cell_miti_data]=persistent_var_exist_with_corruption(app,file_name_cell_bound_miti);
     if var_exist_cell_miti_data==2
         retry_load=1;
         while(retry_load==1)
             try
                 load(file_name_cell_bound_miti,'cell_bound_miti')
                 %%%%1)Mitigation,
                 % %%2) Max knn dist,
                 % %%3)Convex Bound,
                 % %%4)Max Interference dB,
                 % %%%5)Prop Reliability

                 pause(0.1)
                 retry_load=0;
             catch
                 retry_load=1;
                 pause(1)
             end
         end
         pause(0.1)
     else
         'Error: No cell_bound_miti'
         pause;
     end

     %%%'Only keep the first reliability'
     cell_bound_miti=cell_bound_miti(~cellfun(@isempty,cell_bound_miti(:,1)),:,1)
     [num_rows,~]=size(cell_bound_miti)


    %%%%%%%%%%%For Each contour
     temp_cell_kml=cell(num_rows,3); %%%1) Name, 2) Lat, 3)Lon
     for row_idx=1:1:num_rows
         temp_contour=cell_bound_miti{row_idx,3};
         %%%%%%%%%%Clockwise
         [cw_lon,cw_lat] = poly2cw(temp_contour(:,2),temp_contour(:,1));

         if ~isempty(cw_lon) && ~isempty(cw_lat)
             temp_cell_kml{row_idx,1}=strcat(data_label1,'_',num2str(cell_bound_miti{row_idx,1}),'dB');
             temp_cell_kml{row_idx,2}=cw_lat;
             temp_cell_kml{row_idx,3}=cw_lon;
         end
     end
     cell_cell_kml_data{folder_idx,1}=temp_cell_kml;

         
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

 cell_kml_data=vertcat(cell_cell_kml_data{:})


 %%%%%%Remove empty rows
cell_kml_data=cell_kml_data(~cellfun(@isempty,cell_kml_data(:,1)),:)

 %%%%%%%%%%%%%Save to a kml file
 tic;
 cell_lat=cell_kml_data(:,2);
 cell_lon=cell_kml_data(:,3);
 geos=geoshape(cell_lat,cell_lon);
 geos.Name=cell_kml_data(:,1);
 geos.Geometry='polygon';
 filename = strcat('REV',num2str(sim_number),'_polygon.kml');
 kmlwrite(filename, geos, 'Name', geos.Name, 'Description',{},'EdgeColor','b','FaceColor','b','FaceAlpha',0.25,'LineWidth',2);

cell_lat_point=cell_point_kml_data(:,2);
cell_lon_point=cell_point_kml_data(:,3);
geos=geoshape(cell_lat_point,cell_lon_point);
geos.Name=cell_point_kml_data(:,1);
geos.Geometry='point';
filename = strcat('REV',num2str(sim_number),'_points.kml');
kmlwrite(filename, geos, 'Name', geos.Name, 'Description',{},'EdgeColor','r','FaceColor','r','FaceAlpha',0.25,'LineWidth',2);
toc;

end

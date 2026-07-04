function [cell_folder_data]=pull_dsn_excel_data_rev3(app,tf_repull_excel,sim_folder)

folder_info=dir%(sim_folder);
x3=length(folder_info);
file_name=cell(x3,1);
for i=1:1:x3
    file_name{i}=folder_info(i).name;
end
xlsx_idx=find(endsWith(file_name,'.xlsx')==1); %%%%%%%%Search the folder for the .xlsx file name
cell_xlsx_file=file_name(xlsx_idx);
cell_split_file=cellfun(@(x) strsplit(x, '.xlsx'), cell_xlsx_file, 'UniformOutput', false);
cell_split_file=vertcat(cell_split_file{:});
cell_excel_file=cell_split_file(:,1);

%cell_file2=cellfun(@(x) strsplit(x, 'Signal Strength_'), cell_excel_file, 'UniformOutput', false);
cell_file2=cellfun(@(x) strsplit(x, '_'), cell_excel_file, 'UniformOutput', false);
cell_file_data=horzcat(vertcat(cell_file2{:}),cell_xlsx_file)
[num_files,~]=size(cell_file_data)

cell_filename_str=strcat('cell_folder_data_',num2str(num_files),'.mat')
[var_exist]=persistent_var_exist_with_corruption(app,cell_filename_str);
if tf_repull_excel==1
    var_exist=0;
end

if var_exist==2
    tic;
    load(cell_filename_str,'cell_folder_data')
    toc;
else
    %%%%%%Now we need to run through all of them
    cell_multi_data=cell(num_files,1);  %%%%%%%%%Full Data
    for file_idx=1:1:num_files
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Pull in this excel file for inputs:
        excel_filename_data=cell_file_data{file_idx,3}
        mat_filename_str=strcat(cell_file_data{file_idx,1},'_',cell_file_data{file_idx,2},'.mat')
        [cell_data]=load_full_excel_rev1(app,mat_filename_str,excel_filename_data,tf_repull_excel);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%Now make a contour with that data.
        cell_header=cell_data(1,:)
        col_lat_idx=find(contains(cell_header,'Latitude'))
        col_lon_idx=find(contains(cell_header,'Longitude'))
        col_dBm_idx=find(contains(cell_header,'dBm'))
        if isempty(col_dBm_idx) || isempty(col_lon_idx) || isempty(col_lat_idx)
            'empty col_dBm_idx check'
            pause;
        end
        %cell_data([2:end],[col_lat_idx,col_lon_idx,col_dBm_idx])
        size(cell_data)
        cell_data(1:10,:)
        temp_array=cell2mat(cell_data([2:end],[col_lat_idx,col_lon_idx,col_dBm_idx]));
        cell_multi_data{file_idx,1}=temp_array;
    end

    cell_folder_data=horzcat(cell_file_data,cell_multi_data);

    tic;
    save(cell_filename_str,'cell_folder_data')
    toc;
end


end
function [array_data]=load_fss_data_rev1(app,cell_filename_str,tf_repull_excel,excel_filename,in_threshold)


%%%%%%%%%%%%%%%%%%%%%%%%%
[var_exist]=persistent_var_exist_with_corruption(app,cell_filename_str);
if tf_repull_excel==1
    var_exist=0;
end

if var_exist==2
    tic;
    load(cell_filename_str,'array_data')
    toc;
else

    tic;
    cell_raw_data=readcell(excel_filename);
    toc; %%%%%%%%%

    cell_header=cell_raw_data(1,:);
    col_lat_idx=find(matches(cell_header,'Latitude'))
    col_lon_idx=find(matches(cell_header,'Longitude'))
    col_IN_idx=find(contains(cell_header, 'I/N'))

    if length(col_IN_idx)>1
          in_data=max(cell2mat(cell_raw_data([2:end],[col_IN_idx])),[],2);
    else
         in_data=cell2mat(cell_raw_data([2:end],[col_IN_idx]));
    end
    temp_data=horzcat(cell2mat(cell_raw_data([2:end],[col_lat_idx,col_lon_idx])),in_data);
    keep_idx=find(temp_data(:,3)>=in_threshold);
    array_data=temp_data(keep_idx,:);
    size(temp_data)
    size(array_data)

    tic;
    save(cell_filename_str,'array_data')
    toc;
end

end
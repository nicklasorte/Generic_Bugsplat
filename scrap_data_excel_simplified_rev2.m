function scrap_data_excel_simplified_rev2(app,sim_number,folder_names,grid_spacing)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Scrap Data for table.
location_table=table([1:1:length(folder_names)]',folder_names)

%%%%%%%%%%%%%%%%%%%%Instead of status file, the data with the neighborhood
%%%%%%%%%%%%%%%%%%%%distance will be the status file
%%%% 1) Name and 2)0/1 3)Neighborhood Distnace 4)Move List Size 5)All Binary Data

[num_folders,~]=size(folder_names);
array_rand_folder_idx=1:1:num_folders;

cell_coordination_data=cell(num_folders,2);
cell_coordination_data(:,1)=folder_names;
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

    num_miti=length(array_mitigation);

    %%%%%%Check for cell_miti_data
    filename_cell_miti_data=strcat(data_label1,'_cell_miti_data_',string_prop_model,'_',num2str(num_miti),'_',num2str(grid_spacing),'km.mat');
    [var_exist_cell_miti_data]=persistent_var_exist_with_corruption(app,filename_cell_miti_data);
    if tf_recalculate==1
        var_exist_cell_miti_data=0;
    end
    if var_exist_cell_miti_data==2
        retry_load=1;
        while(retry_load==1)
            try
                load(filename_cell_miti_data,'cell_miti_data')
                pause(0.1)
                retry_load=0;
            catch
                retry_load=1;
                pause(1)
            end
        end
        pause(0.1)

        %%%%%%%%%1)Mitigation
        %%%%%%%%%2) required_pathloss
        %%%%%%%%3) max_knn_dist
        %%%%%%%4) Convex Hull

        temp_cell_idx=find(strcmp(cell_coordination_data(:,1),sim_folder)==1);
        cell_coordination_data{temp_cell_idx,2}=cell2mat(cell_miti_data(:,3)');

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

cell_coordination_data

%%%%%%%%%%%'Now write an excel table'
table_nsf_data=cell2table(cell_coordination_data)
writetable(table_nsf_data,strcat('Coordination_data_',num2str(sim_number),'.xlsx'));
pause(0.1)
end
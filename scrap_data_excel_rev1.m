function scrap_data_excel_rev1(app,sim_number,folder_names,reliability,array_reliability_check,grid_spacing)


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

    %%%%%Persistent Load the other variables
    disp_progress(app,strcat('Mapping: Loading Sim Data  . . .'))
    retry_load=1;
    while(retry_load==1)
        try

            load(strcat(data_label1,'_required_pathloss.mat'),'required_pathloss')
            temp_data=required_pathloss;
            clear required_pathloss;
            required_pathloss=temp_data;
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

    %%%%%%Check for cell_pathloss_data
    num_rel=length(reliability)

    num_rel_check=length(array_reliability_check);
    num_pathloss=length(required_pathloss);
    num_threshold=length(radar_threshold);

    %%%%filename_cell_rel_idx=strcat(data_label1,'_cell_rel_idx_',num2str(num_rel),'_',num2str(grid_spacing),'km.mat');
    filename_cell_rel_idx=strcat(data_label1,'_cell_rel_idx_',num2str(num_rel_check),'_',num2str(num_pathloss),'_',num2str(grid_spacing),'km.mat');

    [var_exist_cell_rel_idx]=persistent_var_exist_with_corruption(app,filename_cell_rel_idx);
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

        %%%%                     cell_rel_idx=cell(num_rel_check,num_pathloss,4);
        %%%%%%%%%1)temp_reliability
        %%%%%%%%%2) temp_pathloss
        %%%%%%%%3) max_knn_dist
        %%%%%%%4) Convex Hull

        %%%%%%%Update the Cell
         %%%%%Find the idx
        temp_cell_idx=find(strcmp(cell_coordination_data(:,1),sim_folder)==1);

        if num_rel_check==1 && num_pathloss==1 && num_threshold==1
            cell_coordination_data{temp_cell_idx,2}=cell2mat(cell_rel_idx(3)');
        else
            cell_coordination_data{temp_cell_idx,2}=cell2mat(cell_rel_idx(:,3)');
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

cell_coordination_data


%%%%%%%%%%%'Now write an excel table'
table_data=cell2table(cell_coordination_data)
writetable(table_data,strcat('Coordination_Distances_',num2str(sim_number),'.xlsx'));
pause(0.1)

end
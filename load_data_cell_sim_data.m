function [cell_sim_data]=load_data_cell_sim_data(app)

retry_load=1;
while(retry_load==1)
    try
        disp_progress(app,strcat('Loading Sim Data: cell_sim_data . . . '))
        load('cell_sim_data.mat','cell_sim_data')
        temp_data=cell_sim_data;
        clear cell_sim_data;
        cell_sim_data=temp_data;
        clear temp_data;

        retry_load=0;
    catch
        retry_load=1
        pause(0.1)
    end
end
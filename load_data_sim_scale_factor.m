function [sim_scale_factor]=load_data_sim_scale_factor(app)

retry_load=1;
while(retry_load==1)
    try
        disp_progress(app,strcat('Loading Sim Data: sim_scale_factor . . . '))
        load('sim_scale_factor.mat','sim_scale_factor')
        temp_data=sim_scale_factor;
        clear sim_scale_factor;
        sim_scale_factor=temp_data;
        clear temp_data;

        retry_load=0;
    catch
        retry_load=1
        pause(0.1)
    end
end
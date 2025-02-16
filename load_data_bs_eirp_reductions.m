function [bs_eirp_reductions]=load_data_bs_eirp_reductions(app)


retry_load=1;
while(retry_load==1)
    try
        disp_progress(app,strcat('Loading Sim Data: bs_eirp_reductions . . . '))
        
        load('bs_eirp_reductions.mat','bs_eirp_reductions')
        temp_data=bs_eirp_reductions;
        clear bs_eirp_reductions;
        bs_eirp_reductions=temp_data;
        clear temp_data;
        retry_load=0;
    catch
        retry_load=1
        pause(0.1)
    end
end
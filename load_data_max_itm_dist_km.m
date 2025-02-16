function [max_itm_dist_km]=load_data_max_itm_dist_km(app)


retry_load=1;
while(retry_load==1)
    try
        disp_progress(app,strcat('Loading Sim Data: max_itm_dist_km . . . '))
        
        load('max_itm_dist_km.mat','max_itm_dist_km')
        temp_data=max_itm_dist_km;
        clear max_itm_dist_km;
        max_itm_dist_km=temp_data;
        clear temp_data;
        retry_load=0;
    catch
        retry_load=1
        pause(0.1)
    end
end
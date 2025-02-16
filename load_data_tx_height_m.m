function [tx_height_m]=load_data_tx_height_m(app)


retry_load=1;
while(retry_load==1)
    try
        disp_progress(app,strcat('Loading Sim Data: tx_height_m . . . '))
        
        load('tx_height_m.mat','tx_height_m')
        temp_data=tx_height_m;
        clear tx_height_m;
        tx_height_m=temp_data;
        clear temp_data;
        retry_load=0;
    catch
        retry_load=1
        pause(0.1)
    end
end
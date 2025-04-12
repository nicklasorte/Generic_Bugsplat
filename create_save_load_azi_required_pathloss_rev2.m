function [azi_required_pathloss]=create_save_load_azi_required_pathloss_rev2(app,data_label1,ant_beamwidth,min_ant_loss,min_azimuth,max_azimuth,required_pathloss,array_dist_pl,sim_scale_factor)

%    %%%%%%%%Calculate the pathloss as a function of azimuth
filename_azi_pathloss=strcat(data_label1,'_azi_required_pathloss.mat');
[var_exist_azi_path]=persistent_var_exist_with_corruption(app,filename_azi_pathloss);
if var_exist_azi_path==2
    %%%%%%%%Load
    retry_load=1;
    while(retry_load==1)
        try
            %     %%%%%%%%%%%azi_required_pathloss
            %%%%%%%%%1)Azimuth Degrees, 2) Pathloss, 3) Distance km for base_buffer
            load(filename_azi_pathloss,'azi_required_pathloss')
            pause(0.1);
            retry_load=0;
        catch
            retry_load=1;
            pause(0.1)
        end
    end
else
    %%%%%%%Calculate it
    [azi_required_pathloss]=calc_azi_pathloss_rev1(app,ant_beamwidth,min_ant_loss,min_azimuth,max_azimuth,required_pathloss,array_dist_pl,sim_scale_factor);

    retry_save=1;
    while(retry_save==1)
        try
            %     %%%%%%%%%%%azi_required_pathloss
            %%%%%%%%%1)Azimuth Degrees, 2) Pathloss, 3) Distance km for base_buffer
            save(filename_azi_pathloss,'azi_required_pathloss')
            pause(0.1);
            retry_save=0;
        catch
            retry_save=1;
            pause(0.1)
        end
    end
end


end
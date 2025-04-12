function [wider_keyhole]=create_save_load_wider_keyhole_rev2(app,data_label1,azi_required_pathloss,tf_clutter,min_azimuth,max_azimuth,ant_beamwidth,array_dist_pl,sim_scale_factor)

filename_wider_keyhole=strcat(data_label1,'_wider_keyhole.mat');
[var_exist_wider]=persistent_var_exist_with_corruption(app,filename_wider_keyhole);
if var_exist_wider==2
    %%%%%%%%Load
    retry_load=1;
    while(retry_load==1)
        try
            load(filename_wider_keyhole,'wider_keyhole')
            pause(0.1);
            retry_load=0;
        catch
            retry_load=1;
            pause(0.1)
        end
    end
else
    %%%%%%%Calculate it
    [wider_keyhole]=create_wider_keyhole_rev1(app,azi_required_pathloss,tf_clutter,min_azimuth,max_azimuth,ant_beamwidth,array_dist_pl,sim_scale_factor);
    retry_save=1;
    while(retry_save==1)
        try
            save(filename_wider_keyhole,'wider_keyhole')
            pause(0.1);
            retry_save=0;
        catch
            retry_save=1;
            pause(0.1)
        end
    end
end
end
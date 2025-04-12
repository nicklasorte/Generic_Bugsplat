function [wider_keyhole]=create_wider_keyhole_rev1(app,azi_required_pathloss,tf_clutter,min_azimuth,max_azimuth,ant_beamwidth,array_dist_pl,sim_scale_factor)

if tf_clutter==1
    clutter_azi_required_pathloss=azi_required_pathloss;
    clutter_azi_required_pathloss(:,2)=clutter_azi_required_pathloss(:,2)-30;
    clutter_nn_idx=nearestpoint_app(app,clutter_azi_required_pathloss(:,2),array_dist_pl(:,2),'next');
    clutter_azi_required_pathloss(:,3)=array_dist_pl(clutter_nn_idx,1)*sim_scale_factor;
    azi_required_pathloss=clutter_azi_required_pathloss;
    under10km_idx=find(azi_required_pathloss(:,3)<10);
    azi_required_pathloss(under10km_idx,3)=10;
end

    wider_keyhole=azi_required_pathloss;
    wider_min_azimuth=floor(min_azimuth-(5*ant_beamwidth));
    wider_max_azimuth=ceil(max_azimuth+(5*ant_beamwidth));
    if wider_min_azimuth<0
        mod_wider_min_azimuth=mod(wider_min_azimuth,360);
        min1_idx=nearestpoint_app(app,mod_wider_min_azimuth,wider_keyhole(:,1));
        max2_idx=nearestpoint_app(app,wider_max_azimuth,wider_keyhole(:,1));
        max_dist=max(wider_keyhole(:,3));
        wider_keyhole([min1_idx:1:end],3)=max_dist;
        wider_keyhole([1:1:max2_idx],3)=max_dist;
    elseif wider_max_azimuth>360
        mod_wider_max_azimuth=mod(wider_max_azimuth,360);
        min1_idx=nearestpoint_app(app,wider_min_azimuth,wider_keyhole(:,1));
        max2_idx=nearestpoint_app(app,mod_wider_max_azimuth,wider_keyhole(:,1));
        max_dist=max(wider_keyhole(:,3));
        wider_keyhole([min1_idx:1:end],3)=max_dist;
        wider_keyhole([1:1:max2_idx],3)=max_dist;
    else
        min1_idx=nearestpoint_app(app,wider_min_azimuth,wider_keyhole(:,1));
        max2_idx=nearestpoint_app(app,wider_max_azimuth,wider_keyhole(:,1));
        max_dist=max(wider_keyhole(:,3));
        wider_keyhole([min1_idx:1:max2_idx],3)=max_dist;
    end

end
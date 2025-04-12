function [max_knn_dist,convex_bound,max_int_dB,radial_bound]=plot_zone_miti_reli_radial_rev3(app,temp_margin,sim_array_list_bs,base_protection_pts,data_label1,string_prop_model,temp_rel,grid_spacing,miti_dB)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Plot Zone Function
temp_nan_idx=find(isnan(temp_margin));
idx_keep=find(temp_margin>=0);
size(temp_nan_idx)
if ~isempty(intersect(idx_keep,temp_nan_idx))
    'Check for Overlapping idx-keep and nan_idx'
    pause;
end


if ~isempty(idx_keep)
    length(idx_keep)
    keep_margin=temp_margin(idx_keep);

    %%%%%%%%Find the max distance as a check
    keep_grid_pts=sim_array_list_bs(idx_keep,[1,2]);
    [idx_knn]=knnsearch(base_protection_pts(:,[1,2]),keep_grid_pts,'k',1); %%%Find Nearest Neighbor
    base_knn_array=base_protection_pts(idx_knn,[1,2]);
    knn_dist_bound=deg2km(distance(base_knn_array(:,1),base_knn_array(:,2),keep_grid_pts(:,1),keep_grid_pts(:,2)));%%%%Calculate Distance
    max_knn_dist=ceil(max(knn_dist_bound))

    %%%%%%%Non-Convexhull Radial Bound
    %%%Find the azimuth from the center to the keep_grid_pts

    %%%%%%Bin for each 1 degree step
    [num_pp_pts,~]=size(base_protection_pts)
    if num_pp_pts>1
        'Need to expand for multiple protection points, specifically the non-convex hull radial'
        pause;
    end
    
    point_idx=1
    sim_pt=base_protection_pts(point_idx,:);
    %[radial_bound]=radial_bound_rev1(app,sim_pt,keep_grid_pts);
    min_dist_km=1;
    [radial_bound]=radial_bound_rev2(app,sim_pt,keep_grid_pts,min_dist_km);

    % f2=figure;
    % AxesH = axes;
    % hold on;
    % h3=plot(radial_bound(:,2),radial_bound(:,1),'-k','LineWidth',3,'DisplayName','Concave Coordination Zone')
    % scatter(keep_grid_pts(:,2),keep_grid_pts(:,1),20,'r','filled');
    % plot(base_protection_pts(:,2),base_protection_pts(:,1),'ob','LineWidth',3,'DisplayName','Federal System')
    % grid on;
    % xlabel('Longitude')
    % ylabel('Latitude')
    % title({strcat('Coordination Distance:',num2str(max_knn_dist),'km')})
    % plot_google_map('maptype','terrain','APIKey','AIzaSyCgnWnM3NMYbWe7N4svoOXE7B2jwIv28F8') %%%Google's API key made by nick.matlab.error@gmail.com
    % pause(0.1)
    % 
    % 'check'
    % pause;


    % % % % floor_grid_pt_azimuth=floor(azimuth(sim_pt(1),sim_pt(2),keep_grid_pts(:,1),keep_grid_pts(:,2)));
    % % % % ceil_grid_pt_azimuth=ceil(azimuth(sim_pt(1),sim_pt(2),keep_grid_pts(:,1),keep_grid_pts(:,2)));
    % % % % grid_pt_dist=ceil(deg2km(distance(sim_pt(1),sim_pt(2),keep_grid_pts(:,1),keep_grid_pts(:,2))));
    % % % %
    % % % % dual_azi_dist=vertcat(horzcat(floor_grid_pt_azimuth,grid_pt_dist),horzcat(ceil_grid_pt_azimuth,grid_pt_dist));
    % % % % %%%%For each uni_azi, find the max distance.
    % % % % [uni_azi,~]=unique(dual_azi_dist(:,1));
    % % % % num_uni_azi=length(uni_azi);
    % % % % dual_max_azi_dist=uni_azi;
    % % % % for i=1:1:num_uni_azi
    % % % %     temp_row_idx=find(dual_azi_dist(:,1)==uni_azi(i));
    % % % %     dual_max_azi_dist(i,2)=max(dual_azi_dist(temp_row_idx,2));
    % % % % end
    % % % %
    % % % % %%%%%%%%Fill in the holes that don't have an azimuth
    % % % %
    % % % % full_azi=[0:1:360]';
    % % % % nn_full_azi_idx=nearestpoint_app(app,full_azi,dual_max_azi_dist(:,1));
    % % % % size(nn_full_azi_idx)
    % % % % size(dual_max_azi_dist)
    % % % % full_dual_max_azi_dist=horzcat(full_azi,dual_max_azi_dist(nn_full_azi_idx,2));
    % % % % [radial_lat,radial_lon] = track1(sim_pt(1),sim_pt(2),full_dual_max_azi_dist(:,1),km2deg(full_dual_max_azi_dist(:,2)),[],'degrees',1);
    % % % % radial_bound=horzcat(radial_lat',radial_lon');



    %%%%%
    if ~isempty(keep_grid_pts)==1
        all_coordination_pts=vertcat(keep_grid_pts,base_protection_pts(:,[1,2]));
    else
        all_coordination_pts=vertcat(base_protection_pts(:,[1,2]));
    end

    %%%%%Convex hull the points
    bound_idx=boundary(all_coordination_pts(:,2),all_coordination_pts(:,1),0);
    convex_bound=all_coordination_pts(bound_idx,:);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Set the Color Map
    round_dbm_data=round(keep_margin);
    min(round_dbm_data)
    max_int_dB=max(round_dbm_data)

    non_inf_idx=find(~isinf(round_dbm_data));
    non_inf_round_dbm_data=round_dbm_data(non_inf_idx);
    non_inf_keep_grid_pts=keep_grid_pts(non_inf_idx,:);
    min(non_inf_round_dbm_data)
    max(non_inf_round_dbm_data)

    if ~isempty(non_inf_keep_grid_pts)==1

        [sort_non_inf_round_dbm_data,sort_idx]=sort(non_inf_round_dbm_data,'ascend');
        sort_non_inf_keep_grid_pts=non_inf_keep_grid_pts(sort_idx,:);

        dbm2_range=max(non_inf_round_dbm_data)-min(horzcat(min(non_inf_round_dbm_data),0));

        dbm2_range
        if dbm2_range>0
            color_set=plasma(dbm2_range);

            %%%%%%%%%%%%%%%%Original Linear Heat Map Color set
            f1=figure;
            AxesH = axes;
            hold on;
            h2=plot(convex_bound(:,2),convex_bound(:,1),'-g','LineWidth',3,'DisplayName','Convex Hull Coordination Zone');
            scatter(sort_non_inf_keep_grid_pts(:,2),sort_non_inf_keep_grid_pts(:,1),10,sort_non_inf_round_dbm_data,'filled');
            plot(base_protection_pts(:,2),base_protection_pts(:,1),'ob','LineWidth',3,'DisplayName','Federal System')
            h = colorbar;
            ylabel(h, 'Margin [dB]')
            h3=plot(radial_bound(:,2),radial_bound(:,1),'-k','LineWidth',3,'DisplayName','Concave Coordination Zone')
            colormap(f1,color_set)
            grid on;
            legend([h2,h3])
            xlabel('Longitude')
            ylabel('Latitude')
            title({strcat('Coordination Distance:',num2str(max_knn_dist),'km')})
            plot_google_map('maptype','terrain','APIKey','AIzaSyCgnWnM3NMYbWe7N4svoOXE7B2jwIv28F8') %%%Google's API key made by nick.matlab.error@gmail.com
            pause(0.1)
            filename1=strcat('Convex_Bound','_',data_label1,'_',string_prop_model,'_',num2str(temp_rel),'%_',num2str(grid_spacing),'km_',num2str(miti_dB),'dB.png');
            saveas(gcf,char(filename1))
            pause(0.1);
            close(f1)
        end
    end
else
    %%%%%Empty
    max_knn_dist=NaN(1,1);
    convex_bound=NaN(1,2);
    max_int_dB=NaN(1,1);
    radial_bound=NaN(1,2);
end

end
function [max_knn_dist,convex_bound,max_int_dB,radial_bound]=plot_zone_miti_reli_radial_multi_geoplot_rev5(app,temp_margin,sim_array_list_bs,base_protection_pts,data_label1,string_prop_model,temp_rel,grid_spacing,miti_dB,temp_multi_pt_margin)


 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Plot Zone Function:
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%plot_zone_miti_reli_radial_rev3
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
                                    %'Need to expand for multiple protection points, specifically the non-convex hull radial'
                                    %'Multiple radials and merge'
                                    [num_pp_pts,~]=size(base_protection_pts);
                                    min_dist_km=1;
                                    cell_radial_bound=cell(num_pp_pts,1);
                                    for pt_idx=1:1:num_pp_pts
                                        temp_pt_margin=temp_multi_pt_margin(:,pt_idx);
                                        idx_pt_keep=find(temp_pt_margin>=0);

                                        multi_keep_grid_pts=sim_array_list_bs(idx_pt_keep,[1,2]);
                                        sim_pt=base_protection_pts(pt_idx,:);
                                        [temp_rad_bound]=radial_bound_rev2(app,sim_pt,multi_keep_grid_pts,min_dist_km);
                                        cell_radial_bound{pt_idx}=temp_rad_bound;
                                    end
                                    %%%%%Then just convexhull this?
                                    temp_latlon=vertcat(cell_radial_bound{:});
                                    con_hull_idx=convhull(temp_latlon(:,2),temp_latlon(:,1)); %%%%%%%%%%%Convex Hull
                                    radial_bound=temp_latlon(con_hull_idx,:);
                                else
                                    point_idx=1
                                    sim_pt=base_protection_pts(point_idx,:);
                                    min_dist_km=1;
                                    [radial_bound]=radial_bound_rev2(app,sim_pt,keep_grid_pts,min_dist_km);
                                end


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
                                        h2=geoplot(convex_bound(:,1),convex_bound(:,2),'-g','LineWidth',3,'DisplayName','Convex Hull Coordination Zone');
                                        hold on;
                                        geoscatter(sort_non_inf_keep_grid_pts(:,1),sort_non_inf_keep_grid_pts(:,2),10,sort_non_inf_round_dbm_data,'filled');
                                        geoplot(base_protection_pts(:,1),base_protection_pts(:,2),'ob','LineWidth',3,'DisplayName','Federal System')
                                        h = colorbar;
                                        ylabel(h, 'Margin [dB]')
                                        h3=geoplot(radial_bound(:,1),radial_bound(:,2),'-k','LineWidth',3,'DisplayName','Concave Coordination Zone')
                                        colormap(f1,color_set)
                                        grid on;
                                        legend([h2,h3])
                                        %xlabel('Longitude')
                                        %ylabel('Latitude')
                                        title({strcat('Coordination Distance:',num2str(max_knn_dist),'km')})
                                        %plot_google_map('maptype','terrain','APIKey','AIzaSyCgnWnM3NMYbWe7N4svoOXE7B2jwIv28F8') %%%Google's API key made by nick.matlab.error@gmail.com
                                        pause(0.1)
                                        %geobasemap landcover
                                        geobasemap streets-light%landcover
                                        f1.Position = [100 100 1200 900];
                                        pause(1)
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
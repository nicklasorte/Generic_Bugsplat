function plot_nationwide_poly_miti_rev2_filename(app,sim_number,cell_poly_merge,array_mitigation,filename_nationwide_multi)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%(This is the figure Nationwide7.)
%%%%'Next step, plot the poly merge with the 11 layers and a color bar on the right'

    %%%%%%%Plot the dB mitigation of the edge of the polyshape.
    tic;
    %%close all;
    f1=figure;
    AxesH = axes;
    [num_bounds,~]=size(cell_poly_merge);
    color_set=plasma(num_bounds);
    for bound_idx=1:1:num_bounds
        temp_polyshape=cell_poly_merge{bound_idx};
        [temp_geo_poly]=convert_polyshape2geopolyshape(app,temp_polyshape);
        % % % % temp_latlon=temp_polyshape.Vertices;
        % % % % %%%%%%%Need to close all the polygons at the NaN
        % % % % nan_idx=find(isnan(temp_latlon(:,1)));
        % % % % if isempty(nan_idx)
        % % % %     temp_lonlat_close=vertcat(temp_latlon,temp_latlon(1,:))
        % % % %     'Need to figure this out.'
        % % % %     pause;
        % % % % else
        % % % %     num_regions=length(nan_idx)+1;
        % % % %     temp_cell_latlon=cell(num_regions,1);
        % % % %     for reg_idx=1:1:num_regions
        % % % %         if reg_idx==1
        % % % %             temp_seg=temp_latlon(1:(nan_idx(reg_idx)-1),:);
        % % % %             temp_close_seg=vertcat(temp_seg,temp_seg(1,:),NaN(1,2));
        % % % %         elseif reg_idx==num_regions
        % % % %             temp_seg=temp_latlon((nan_idx(reg_idx-1)+1):end,:);
        % % % %             temp_close_seg=vertcat(temp_seg,temp_seg(1,:));
        % % % %         else
        % % % %             temp_seg=temp_latlon((nan_idx(reg_idx-1)+1):(nan_idx(reg_idx)-1),:);
        % % % %             temp_close_seg=vertcat(temp_seg,temp_seg(1,:),NaN(1,2));
        % % % %         end
        % % % %         temp_cell_latlon{reg_idx}=temp_close_seg;
        % % % %     end
        % % % %    temp_lonlat_close=vertcat(temp_cell_latlon{:});
        % % % % 
        % % % % end
        % % % %  temp_geo_poly=geopolyshape(temp_lonlat_close(:,2),temp_lonlat_close(:,1));

        %plot(temp_merge,'FaceColor',color_set(bound_idx,:),'EdgeColor',color_set(bound_idx,:))%,'FaceAlpha',bound_idx/num_miti)
        geoplot(temp_geo_poly,'FaceColor',color_set(bound_idx,:),'EdgeColor',color_set(bound_idx,:))%,'FaceAlpha',bound_idx/num_miti)
            hold on;
    end
    toc;
    grid on;
    %%%set(gca,'XTick',[], 'YTick', [])
    pause(0.1)
    num_labels=length(array_mitigation)*2+1;
    cell_bar_label=cell(num_labels,1);
    counter=0;
    for miti_idx=2:2:num_labels
        counter=counter+1;
        cell_bar_label{miti_idx}=strcat(num2str(array_mitigation(counter)),'dB');
    end
    bar_tics=linspace(0,1,num_labels);
    h = colorbar('Location','eastoutside','Ticks',bar_tics,'TickLabels',cell_bar_label);
    colormap(f1,color_set)
    %plot_google_map('maptype','terrain','APIKey','AIzaSyCgnWnM3NMYbWe7N4svoOXE7B2jwIv28F8') %%%Google's API key made by nick.matlab.error@gmail.com

    %%%%geobasemap landcover
    geobasemap streets-light%landcover
    f1.Position = [100 100 1200 900];
    pause(1)
    print(gcf,filename_nationwide_multi,'-dpng','-r300')
    toc;
    pause(1)
    close(f1)

end

%%%strcat('Nationwide7_Multi_Rev',num2str(sim_number),'.png')
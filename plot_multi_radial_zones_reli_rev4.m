function plot_multi_radial_zones_reli_rev4(app,temp_zones,base_protection_pts,data_label1,string_prop_model,temp_rel,grid_spacing)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Plot the multiple circles

%%%%1)Mitigation,
% %%2) Max knn dist,
% %%3)Convex Bound,
% %%4)Max Interference dB,
% %%%5)Prop Reliability

temp_zones=temp_zones(~cellfun('isempty', temp_zones(:,1)),:);
if ~isempty(temp_zones)
    [num_cirlces,~]=size(temp_zones);
    color_set3=plasma(num_cirlces);
    f1=figure;
    AxesH = axes;
    hold on;
    plot(base_protection_pts(:,2),base_protection_pts(:,1),'ob','LineWidth',3,'DisplayName','Federal System')

    if num_cirlces>1
        for i=num_cirlces:-1:1
            temp_bound=temp_zones{i,6};
            if ~isempty(temp_bound)
                temp_miti=temp_zones{i,1};
                plot(temp_bound(:,2),temp_bound(:,1),'-','Color',color_set3(i,:),'LineWidth',3,'DisplayName',strcat(num2str(temp_miti),'dB'))
            end
        end
    elseif num_cirlces==1  %%%%%%%%%%%%Probably don't have to graph if it's just one circle
        temp_bound=temp_zones{6};
        if ~isempty(temp_bound)
            temp_miti=temp_zones{1,1};
            plot(temp_bound(:,2),temp_bound(:,1),'-','Color',color_set3,'LineWidth',3,'DisplayName',strcat(num2str(temp_miti),'dB'))
        end
    end

    grid on;
    legend
    xlabel('Longitude')
    ylabel('Latitude')
    plot_google_map('maptype','terrain','APIKey','AIzaSyCgnWnM3NMYbWe7N4svoOXE7B2jwIv28F8') %%%Google's API key made by nick.matlab.error@gmail.com
    pause(0.1)
    filename1=strcat('Concave_Multi_Circles','_',data_label1,'_',string_prop_model,'_',num2str(temp_rel),'%_',num2str(grid_spacing),'km.png');
    saveas(gcf,char(filename1))
    pause(0.1);
    close(f1)
end

end
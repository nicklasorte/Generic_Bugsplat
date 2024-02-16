function plot_multi_zones_rev2(app,cell_miti_data,base_protection_pts,data_label1,string_prop_model,grid_spacing)

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Plot the multiple circles

                cell_miti_data=cell_miti_data(~cellfun('isempty', cell_miti_data(:,1)),:);
                if ~isempty(cell_miti_data)
                    [num_cirlces,~]=size(cell_miti_data)
                    color_set3=plasma(num_cirlces);
                    f1=figure;
                    AxesH = axes;
                    hold on;
                    plot(base_protection_pts(:,2),base_protection_pts(:,1),'ob','LineWidth',3,'DisplayName','Federal System')

                    if num_cirlces>1
                        for i=num_cirlces:-1:1
                            temp_bound=cell_miti_data{i,4};
                            if ~isempty(temp_bound)
                                temp_miti=cell_miti_data{i,1};
                                plot(temp_bound(:,2),temp_bound(:,1),'-','Color',color_set3(i,:),'LineWidth',3,'DisplayName',strcat(num2str(temp_miti),'dB'))
                            end
                        end
                    elseif num_cirlces==1
                        temp_bound=cell_miti_data{4};
                        if ~isempty(temp_bound)
                            temp_miti=cell_miti_data{i,1};
                            plot(temp_bound(:,2),temp_bound(:,1),'-','Color',color_set3,'LineWidth',3,'DisplayName',strcat(num2str(temp_miti),'dB'))
                        end
                    end

                    grid on;
                    legend
                    %                 if num_cirlces>1
                    %                     legend('Location','eastoutside')
                    %                 end
                    xlabel('Longitude')
                    ylabel('Latitude')
                    plot_google_map('maptype','terrain','APIKey','AIzaSyCgnWnM3NMYbWe7N4svoOXE7B2jwIv28F8') %%%Google's API key made by nick.matlab.error@gmail.com
                    pause(0.1)
                    filename1=strcat('Multi_Circles','_',data_label1,'_',string_prop_model,'_',num2str(grid_spacing),'km.png');
                    saveas(gcf,char(filename1))
                    pause(0.1);
                    close(f1)
                end

end

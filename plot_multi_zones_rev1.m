function plot_multi_zones_rev1(app,data_label1,string_prop_model,cell_propagation_bound,base_protection_pts,array_mitigation)

[num_miti,~]=size(cell_propagation_bound)
                num_circles=num_miti;
                color_set3=plasma(num_circles);

                f1=figure;
                AxesH = axes;
                hold on;
                plot(base_protection_pts(:,2),base_protection_pts(:,1),'ob','LineWidth',3,'DisplayName','Federal System')
                
                if num_circles>1
                    for i=num_circles:-1:1
                        temp_bound=cell_propagation_bound{i,3};
                        temp_miti=array_mitigation(i)

                        if ~isempty(temp_bound)
                            plot(temp_bound(:,2),temp_bound(:,1),'-','Color',color_set3(i,:),'LineWidth',3,'DisplayName',strcat(num2str(temp_miti),'dB'))
                        end
                    end
                elseif num_circles==1
                    temp_bound=cell_propagation_bound{i,3};
                    temp_miti=array_mitigation(i)
                    if ~isempty(temp_bound)
                        plot(temp_bound(:,2),temp_bound(:,1),'-','Color',color_set3,'LineWidth',3,'DisplayName',strcat(num2str(temp_miti),'dB'))
                    end
                end

                %%title({strcat(data_label1)})
                grid on;
                %legend
                if num_circles>1
                    legend('Location','eastoutside')
                end
                xlabel('Longitude')
                ylabel('Latitude')
                plot_google_map('maptype','terrain','APIKey','AIzaSyCgnWnM3NMYbWe7N4svoOXE7B2jwIv28F8') %%%Google's API key made by nick.matlab.error@gmail.com
                pause(0.1)
                filename1=strcat('Multi_Circles','_',data_label1,'_',string_prop_model,'.png');
                saveas(gcf,char(filename1))
                pause(0.1);
                close(f1)

end
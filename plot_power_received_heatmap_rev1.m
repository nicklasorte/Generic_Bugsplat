function plot_power_received_heatmap_rev1(app,sim_array_list_bs,max_pwr_rx_dBm,data_label1,string_prop_model,grid_spacing,base_protection_pts)

%%%%%%%%%%%%%%%%Power Received  Heat Map
mode_color_set_angles=plasma(100);
f1=figure;
AxesH = axes;
hold on;
scatter(sim_array_list_bs(1,2),sim_array_list_bs(1,1),10,ceil(max(max_pwr_rx_dBm)),'filled');
scatter(sim_array_list_bs(1,2),sim_array_list_bs(1,1),10,floor(min(max_pwr_rx_dBm)),'filled');
scatter(sim_array_list_bs(:,2),sim_array_list_bs(:,1),10,max_pwr_rx_dBm,'filled');
plot(base_protection_pts(:,2),base_protection_pts(:,1),'xr','LineWidth',3,'DisplayName','Federal System')
%plot(base_protection_pts(:,2),base_protection_pts(:,1),'ob','LineWidth',3,'DisplayName','Federal System')
cbh = colorbar;
ylabel(cbh, 'Power Received [dBm/100MHz]')
colormap(f1,mode_color_set_angles)
grid on;
xlabel('Longitude')
ylabel('Latitude')
title({strcat('Power Received')})
plot_google_map('maptype','terrain','APIKey','AIzaSyCgnWnM3NMYbWe7N4svoOXE7B2jwIv28F8') %%%Google's API key made by nick.matlab.error@gmail.com
pause(0.1)
filename1=strcat('Power_Received_Heatmap','_',data_label1,'_',string_prop_model,'_',num2str(grid_spacing),'km.png');
saveas(gcf,char(filename1))
pause(0.1);
close(f1)
end
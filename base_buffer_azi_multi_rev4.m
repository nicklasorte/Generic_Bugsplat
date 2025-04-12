function [base_buffer]=base_buffer_azi_multi_rev4(app,azi_required_pathloss,data_label1,base_protection_pts)

disp_TextArea_PastText(app,strcat('base_buffer_azi_multi_rev4: Line 3'))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%STEP 1: Create a buffer around the base
buffer_km=ceil(max(azi_required_pathloss(:,3)))
buffer_filename=strcat(data_label1,'_base_buffer_',num2str(buffer_km),'km.mat');
[var_exist_buffer]=persistent_var_exist_with_corruption(app,buffer_filename);
disp_TextArea_PastText(app,strcat('base_buffer_azi_multi_rev4: Line 8'))
if var_exist_buffer==2
    %%%%%%Load
    retry_load=1;
    while(retry_load==1)
        try
            load(buffer_filename,'base_buffer')
            pause(0.1)
            retry_load=0;
        catch
            retry_load=1;
            pause(1)
        end
    end
    disp_TextArea_PastText(app,strcat('base_buffer_azi_multi_rev4: Line 22'))
elseif var_exist_buffer==0
    %%%%%%%%%%%%%%%%%%%%%%%%bufferm: For a large number of points, this seems  to take a long timE.
    %%%%%%%%%%%%%%%%%%%%%%%%We could revert to the single point and convext.
    disp_TextArea_PastText(app,strcat('base_buffer_azi_multi_rev4: Line 26'))
    disp_progress(app,strcat('Part0 Grid Points: Need to create base_buffer . . .'))
    tic;
    [num_pp_pts,~]=size(base_protection_pts)
    if num_pp_pts>1
        disp_TextArea_PastText(app,strcat('base_buffer_azi_multi_rev4: Line 31'))
        %%%%%Preallocate
        cell_temp_lat_buff=cell(num_pp_pts,1);
        cell_temp_lon_buff=cell(num_pp_pts,1);
        for i=1:1:num_pp_pts
            [temp_lat,temp_lon] = track1(base_protection_pts(i,1),base_protection_pts(i,2),azi_required_pathloss(:,1),km2deg(azi_required_pathloss(:,3)),[],'degrees',1);
            cell_temp_lat_buff{i}=temp_lat;
            cell_temp_lon_buff{i}=temp_lon;
        end
        temp_lat_buff=vertcat(cell_temp_lat_buff{:});
        temp_lon_buff=vertcat(cell_temp_lon_buff{:});
        reshape_lat=reshape(temp_lat_buff,[],1);
        reshape_lon=reshape(temp_lon_buff,[],1);
        con_hull_idx=convhull(reshape_lon,reshape_lat); %%%%%%%%%%%Convex Hull
        base_buffer=horzcat(reshape_lat(con_hull_idx),reshape_lon(con_hull_idx));
        disp_TextArea_PastText(app,strcat('base_buffer_azi_multi_rev4: Line 46'))
    else
        disp_TextArea_PastText(app,strcat('base_buffer_azi_multi_rev4: Line 48'))
        azi_required_pathloss
        base_protection_pts
        [buff_lat,buff_lon] = track1(base_protection_pts(1),base_protection_pts(2),azi_required_pathloss(:,1),km2deg(azi_required_pathloss(:,3)),[],'degrees',1);
        base_buffer=horzcat(buff_lat',buff_lon');
        base_buffer=vertcat(base_buffer,base_buffer(1,:)); %%%%%%%Closing it up just in case
        disp_TextArea_PastText(app,strcat('base_buffer_azi_multi_rev4: Line 54'))
    end
    disp_TextArea_PastText(app,strcat('base_buffer_azi_multi_rev4: Line 56'))

    % f1=figure;
    % AxesH = axes;
    % hold on;
    % plot(base_buffer(:,2),base_buffer(:,1),'-r','Linewidth',3)
    % plot(base_protection_pts(:,2),base_protection_pts(:,1),'xb','LineWidth',3)
    % grid on;
    % %plot_google_map('maptype','terrain','APIKey','AIzaSyCgnWnM3NMYbWe7N4svoOXE7B2jwIv28F8') %%%Google's API key made by nick.matlab.error@gmail.com
    % filename1=strcat('Sim_Area_',data_label1,'.png');
    % pause(0.1)
    % saveas(gcf,char(filename1))
    % pause(0.1);
    % close(f1)
    % toc;  %%%%%%%%%3 seconds

    f1=figure;
    geoplot(base_buffer(:,1),base_buffer(:,2),'-r','Linewidth',3)
    hold on;
    geoplot(base_protection_pts(:,1),base_protection_pts(:,2),'xb','LineWidth',3)
    grid on;
    geobasemap streets-light%landcover
    pause(1)
    filename1=strcat('Sim_Area_',data_label1,'.png');
    pause(0.1)
    saveas(gcf,char(filename1))
    pause(0.1);
    close(f1)
    toc;  %%%%%%%%%3 seconds


    %%%%%%Save
    retry_save=1;
    while(retry_save==1)
        try
            save(buffer_filename,'base_buffer')
            pause(0.1)
            retry_save=0;
        catch
            retry_save=1;
            pause(1)
        end
    end
    disp_TextArea_PastText(app,strcat('base_buffer_azi_multi_rev4: Line 85'))
end
disp_TextArea_PastText(app,strcat('base_buffer_azi_multi_rev4: Line 87'))
end
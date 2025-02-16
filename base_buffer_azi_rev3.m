function [base_buffer]=base_buffer_azi_rev3(app,azi_required_pathloss,data_label1,base_protection_pts)

                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%STEP 1: Create a buffer around the base
                 buffer_km=ceil(max(azi_required_pathloss(:,3)))
                 buffer_filename=strcat(data_label1,'_base_buffer_',num2str(buffer_km),'km.mat');
                 [var_exist_buffer]=persistent_var_exist_with_corruption(app,buffer_filename);
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
                 elseif var_exist_buffer==0
                     %%%%%%%%%%%%%%%%%%%%%%%%bufferm: For a large number of points, this seems  to take a long timE.
                     %%%%%%%%%%%%%%%%%%%%%%%%We could revert to the single point and convext.
                     disp_progress(app,strcat('Part0 Grid Points: Need to create base_buffer . . .'))
                     tic;
                     [num_pp_pts,~]=size(base_protection_pts)
                     if num_pp_pts>1
                         'Need to expand this function to include multi-points'
                         pause;
                     end

                     [buff_lat,buff_lon] = track1(base_protection_pts(1),base_protection_pts(2),azi_required_pathloss(:,1),km2deg(azi_required_pathloss(:,3)),[],'degrees',1);
                     base_buffer=horzcat(buff_lat',buff_lon');
                     base_buffer=vertcat(base_buffer,base_buffer(1,:)); %%%%%%%Closing it up just in case
                     f1=figure;
                     AxesH = axes;
                     hold on;
                     plot(base_buffer(:,2),base_buffer(:,1),'-r','Linewidth',3)
                     plot(base_protection_pts(:,2),base_protection_pts(:,1),'xb','LineWidth',3)
                     grid on;
                     plot_google_map('maptype','terrain','APIKey','AIzaSyCgnWnM3NMYbWe7N4svoOXE7B2jwIv28F8') %%%Google's API key made by nick.matlab.error@gmail.com
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
                end

end
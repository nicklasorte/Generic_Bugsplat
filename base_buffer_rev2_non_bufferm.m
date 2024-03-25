function [base_buffer]=base_buffer_rev2_non_bufferm(app,data_label1,buffer_km,base_polygon)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%STEP 1: Create a buffer around the base
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
            disp_progress(app,strcat('Part0 Grid Points: base_buffer_rev2: Buffering . . .'))
            tic;
            [base_buffer]=geo_buffer_rev1(app,base_polygon,buffer_km);
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
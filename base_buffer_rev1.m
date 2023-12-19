function [base_buffer]=base_buffer_rev1(app,data_label1,min_dist_buff_km,base_polygon)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%STEP 1: Create a buffer around the base
        buffer_filename=strcat(data_label1,'_base_buffer_',num2str(min_dist_buff_km),'km.mat');
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
            
            tic;
            [temp_buff_lat,temp_buff_lon]=bufferm(base_polygon(:,1),base_polygon(:,2),km2deg(min_dist_buff_km),'out',50);
            %%%base_buffer=horzcat(temp_buff_lat,temp_buff_lon);
            toc;  %%%%%%%%%3 seconds
            
            %%%%%%%Polyshape, remove the holes, and turn back into points
            temp_poly_buff=polyshape(temp_buff_lon,temp_buff_lat);
            temp_poly_buff=rmholes(temp_poly_buff);
            base_buffer=temp_poly_buff.Vertices;
            base_buffer=fliplr(vertcat(base_buffer,base_buffer(1,:)));
            
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
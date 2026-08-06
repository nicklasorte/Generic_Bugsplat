function [grid_points]=wrapper_grid_points_rev2_outside_USA(app,data_label1,sim_radius_km,grid_spacing,base_buffer,base_polygon,bs_height)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Step 2: Generate Grid Points
disp_TextArea_PastText(app,strcat('wrapper_grid_points_rev2_outside_USA: Line 4'))
%%%%%%Check for grid points
gridpoints_filename=strcat(data_label1,'_grid_points_',num2str(sim_radius_km),'km',num2str(grid_spacing),'km.mat');
[var_exist_grid]=persistent_var_exist_with_corruption(app,gridpoints_filename);
if var_exist_grid==2
    load(gridpoints_filename,'grid_points')
else
    disp_TextArea_PastText(app,strcat('wrapper_grid_points_rev2_outside_USA: Line 11'))
    %%%%%%%%Find the overlap between the base_buffer and us_cont
    %%%%%%%%%%Filter out the points outside of us_cont
    retry_load=1;
    while(retry_load==1)
        try
            %%%%%%load('polyshape_us_cont_50km.mat','polyshape_us_cont_50km')  %%%%%Us this instead of the us_cont on the grid points
            %%%%load('cut_polyshape_us_cont_50km.mat','cut_polyshape_us_cont_50km')  %%%%%%%No points in Canada or Mexico
            load('ds_poly_us_cont_50km.mat','ds_poly_us_cont_50km')
            pause(0.1)
            retry_load=0;
        catch
            retry_load=1;
            pause(1)
        end
    end
    disp_TextArea_PastText(app,strcat('wrapper_grid_points_rev2_outside_USA: Line 27'))
    pause(0.1)
    
    %%%%%%%%Find the overlap between the base_buffer and us_cont
    circle_poly=polyshape(base_buffer(:,2),base_buffer(:,1));
    circle_poly=rmholes(circle_poly);
    polyout=intersect(circle_poly,ds_poly_us_cont_50km);
    polyout=rmholes(polyout);
    if polyout.NumRegions>1
        polyout = convhull(polyout);
        border_bound=fliplr(polyout.Vertices);
        border_bound=vertcat(border_bound,border_bound(1,:)); %%%%Close the circle
    elseif polyout.NumRegions==1
        border_bound=fliplr(polyout.Vertices);
        border_bound=vertcat(border_bound,border_bound(1,:)); %%%%Close the circle
    elseif polyout.NumRegions==0
        border_bound=base_buffer;
    end
    disp_TextArea_PastText(app,strcat('wrapper_grid_points_rev2_outside_USA: Line 45'))
    
    if all(isempty(border_bound))==1
        border_bound=base_buffer;
    end
    
    tic;
    disp_TextArea_PastText(app,strcat('wrapper_grid_points_rev2_outside_USA: Line 52'))
    %%%%%%%%%%%%%%%%%%[raw_grid_points]=grid_points_app(app,base_buffer,grid_spacing);
    [raw_grid_points]=grid_points_app(app,border_bound,grid_spacing);
    disp_TextArea_PastText(app,strcat('wrapper_grid_points_rev2_outside_USA: Line 55'))
    toc;
    
    
    %%%%%%%%%%%Just in Case, filter out the points in the ds_poly_us_cont_50km
    disp_TextArea_PastText(app,strcat('wrapper_grid_points_rev2_outside_USA: Line 60'))
    tic;
    [num_raw1,~]=size(raw_grid_points)
    tf_inside=NaN(num_raw1,1);
    [inside_hWaitbar,inside_hWaitbarMsgQueue]= ParForWaitbarCreateMH_time('Inside Grid Points: ',num_raw1);    %%%%%%% Create ParFor Waitbar
    tic;
    for i=1:1:num_raw1
        tf_inside(i)=isinterior(ds_poly_us_cont_50km,raw_grid_points(i,2),raw_grid_points(i,1));
        inside_hWaitbarMsgQueue.send(0);
    end
    try
        delete(inside_hWaitbarMsgQueue);
    end
    try
        close(inside_hWaitbar);
    end
    disp_TextArea_PastText(app,strcat('wrapper_grid_points_rev2_outside_USA: Line 68'))
    toc;
    inside_idx=find(tf_inside==1);
    raw_grid_points2=raw_grid_points(inside_idx,:);
    toc;


    disp_TextArea_PastText(app,strcat('wrapper_grid_points_rev2_outside_USA: Line 75'))
    [num_raw_pts1,~]=size(raw_grid_points2)
    if num_raw_pts1==0
        'All is NaN, outside of USA, need to do something else.'
        %%%pause;
        raw_grid_points2=raw_grid_points; %%%%%%%%%Just keep all the points for now.
    end
    
    
    %%%%%%%Just in case, filter out the points in the temp_base_points

    %%%%%%%Don't filter inside the  base_polygon
    disp_TextArea_PastText(app,strcat('wrapper_grid_points_rev2_outside_USA: Line 87'))
    num_raw2=length(raw_grid_points2)
    grid_points=horzcat(raw_grid_points2,NaN(num_raw2,1));
    grid_points(:,3)=bs_height;  %%%%%%%Add Antenna Height=
    disp_TextArea_PastText(app,strcat('wrapper_grid_points_rev2_outside_USA: Line 91'))

% % % %     [num_base_pts,~]=size(base_polygon);
% % % %     tic;
% % % %     if num_base_pts==1
% % % %         %%%%%%Don't filter if there is only 1 point
% % % %         grid_points=raw_grid_points2;
% % % %     else
% % % %         [num_raw_pts,~]=size(raw_grid_points2);
% % % %         idx_outside=NaN(num_raw_pts,1);
% % % %         for i=1:1:num_raw_pts
% % % %             tf_in=inpolygon(raw_grid_points2(i,2),raw_grid_points2(i,1),base_polygon(:,2),base_polygon(:,1));
% % % %             if tf_in==0
% % % %                 idx_outside(i)=i;
% % % %             end
% % % %         end
% % % %         idx_outside=idx_outside(~isnan(idx_outside));
% % % %         
% % % %         grid_points=raw_grid_points2(idx_outside,:);
% % % %     end
% % % %     toc;
    
    'Saving the grid points . . .'
   disp_TextArea_PastText(app,strcat('wrapper_grid_points_rev2_outside_USA: Line 114'))
    retry_save=1;
    while(retry_save==1)
        try
            save(gridpoints_filename,'grid_points')
            pause(0.1)
            retry_save=0;
        catch
            retry_save=1;
            pause(1)
        end
    end
    pause(0.1)
    disp_TextArea_PastText(app,strcat('wrapper_grid_points_rev2_outside_USA: Line 127'))
end
size(grid_points)
disp_TextArea_PastText(app,strcat('wrapper_grid_points_rev2_outside_USA: Line 130'))
end
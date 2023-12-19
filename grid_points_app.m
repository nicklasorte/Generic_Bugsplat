function [filter_pts50]=grid_points_app(app,dpa_bound,step_size)


            
% % %             dpa_bound
% % %             size(dpa_bound)
% % %             
% % %             
% % %             figure;
% % %             hold on;
% % %             plot(dpa_bound(:,2),dpa_bound(:,1),'-ok')
% % %             grid on;
            
if all(isnan(dpa_bound))==1
    filter_pts50=NaN(1,2);
else
    
    [x3,y3]=size(dpa_bound);
    if x3==1  %%%%%%If point DPA
        filter_pts50=dpa_bound;
    else
        dpa_poly=polyshape(dpa_bound(:,2),dpa_bound(:,1));
        no_holes_dpa_poly=rmholes(dpa_poly);
        border_dpa_bound=fliplr(no_holes_dpa_poly.Vertices);
        border_dpa_bound=vertcat(border_dpa_bound,border_dpa_bound(1,:)); %%%%Close the circle
        
        [x10,~]=size(border_dpa_bound);
        dist_steps=NaN(x10-1,1);
        for j=1:1:x10-1
            dist_steps(j)=deg2km(distance(border_dpa_bound(j,1),border_dpa_bound(j,2),border_dpa_bound(j+1,1),border_dpa_bound(j+1,2)));
        end
        seg_dist=nansum(dist_steps);
        line_steps=ceil(seg_dist/(step_size))+1;
        dpa_edge_pt=curvspace_app(app,border_dpa_bound,line_steps);
        
        %%%%%%%%%%%Find min/max of DPA coordinates
        minx=min(border_dpa_bound(:,2));
        maxx=max(border_dpa_bound(:,2));
        miny=min(border_dpa_bound(:,1));
        maxy=max(border_dpa_bound(:,1));
        x_pts=2;
        x_dist=step_size+1;
        while(x_dist>step_size)
            x_array=linspace(minx,maxx,x_pts);
            x_dist=deg2km(distance(miny,x_array(1),miny,x_array(2)));
            x_pts=x_pts+1;
        end
        
        y_pts=2;
        y_dist=step_size+1;
        while(y_dist>step_size)
            y_array=linspace(miny,maxy,y_pts);
            y_dist=deg2km(distance(y_array(1),minx,y_array(2),minx));
            y_pts=y_pts+1;
        end
        %Blazing faster than the circle draw
        [x_grid,y_grid]=meshgrid(x_array,y_array);
        x_grid=reshape(x_grid,[],1);
        y_grid=reshape(y_grid,[],1);
        %length(x_grid)
        
        sample_pts=horzcat(y_grid,x_grid);
        %size(sample_pts)
        
        %%%%%%%%%Only Keep the sample_pts inside the dpa
        %inside_idx=inpolygon(sample_pts(:,2),sample_pts(:,1),dpa_edge_pt(:,2),dpa_edge_pt(:,1));
        
        [x1,y1]=size(sample_pts)
        tf_inside=NaN(x1,1);
        tic;
        for i=1:1:x1
            %disp_sub_progress(app,strcat(num2str(i/x1*100),'%'))
            tf_inside(i)=isinterior(dpa_poly,sample_pts(i,2),sample_pts(i,1));
        end
        toc;
        inside_idx=find(tf_inside==1);
        filter_pts50=vertcat(dpa_edge_pt,sample_pts(inside_idx,:));  %Add DPA edges to sample points
        %filter_pts50=vertcat(sample_pts(inside_idx,:));  %Add DPA edges to sample points
    end
end
end
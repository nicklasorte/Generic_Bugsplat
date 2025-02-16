function [azi_required_pathloss]=calc_azi_pathloss_rev1(app,ant_beamwidth,min_ant_loss,min_azimuth,max_azimuth,required_pathloss,array_dist_pl,sim_scale_factor)

   %%%%%%%%Calculate the pathloss as a function of azimuth
    %%%%%%%%%%Add Radar Antenna Pattern: Offset from 0 degrees and loss in dB
    %%%%%%%%%%%%%%Make this a function: output is merge_full_array_ant
    %'processing . . .'
    %tic;
        if ant_beamwidth==360
            merge_full_array_ant=[0:1:359]';
            merge_full_array_ant(:,2)=0;  %%%%%%%%%Normalized Gain
        else
               %%%%%%%%%%%Note, this is not STATGAIN
            [radar_ant_array]=horizontal_antenna_loss_app(app,ant_beamwidth,min_ant_loss);

            if max(radar_ant_array(:,1))>180
                'Pause error, the antenna pattern will need to be max of overlap'
                pause;
            end

            %%%%%%%%%%Flip and mirror 
            min_theta_step=ant_beamwidth/10;
            theta_step=min(horzcat(min_theta_step,min(diff(radar_ant_array(:,1)))));
            dual_radar_ant_array=vertcat(horzcat(-1*flipud(radar_ant_array(:,1)),flipud(radar_ant_array(:,2))),radar_ant_array);
            min_theta=floor(min(dual_radar_ant_array(:,1)));
            max_theta=ceil(max(dual_radar_ant_array(:,1)));

            %%%%%%%Fill in the back lobe 
            neg_theta=sort([min_theta:-1*theta_step:-180]');
            pos_theta=[max_theta:theta_step:180]';
            neg_theta(:,2)=-1*min_ant_loss;
            pos_theta(:,2)=-1*min_ant_loss;
            if theta_step<0.1
                %'Need to adjust the rounding_digits'
                %pause;
                rounding_digits=2;
            else
                rounding_digits=1;
            end

            full_array_ant=round(vertcat(neg_theta,dual_radar_ant_array,pos_theta),rounding_digits);
            full_array_ant=unique(full_array_ant,'rows');

            tf_sorted=issorted(full_array_ant(:,1));
            if tf_sorted==0
                'Not sorted'
                pause;
            end
            
            % % % figure;
            % % % hold on;
            % % % plot(full_array_ant(:,1),full_array_ant(:,2),'-k')
            % % % grid on;


            %%%%'Need to spread it across all azimuths'
            min_full_array_ant=full_array_ant;
            min_full_array_ant(:,1)=full_array_ant(:,1)+min_azimuth;

            max_full_array_ant=full_array_ant;
            max_full_array_ant(:,1)=full_array_ant(:,1)+max_azimuth;

            %%%%%%%%Mod the Azimuth
            min_full_array_ant(:,1)=mod(min_full_array_ant(:,1),360);
            max_full_array_ant(:,1)=mod(max_full_array_ant(:,1),360);

            %%%%%%%Find 360 and set to Zero
            min_zero_idx=find(min_full_array_ant(:,1)==360);
            max_zero_idx=find(max_full_array_ant(:,1)==360);
            min_full_array_ant(min_zero_idx,1)=0;
            max_full_array_ant(max_zero_idx,1)=0;

            %%%%%%%Sort
            [~,min_sort_idx]=sort(min_full_array_ant(:,1));
            [~,max_sort_idx]=sort(max_full_array_ant(:,1));

            sort_min_full_array_ant=min_full_array_ant(min_sort_idx,:);
            sort_max_full_array_ant=max_full_array_ant(max_sort_idx,:);

            [~,min_uni_idx]=unique(sort_min_full_array_ant(:,1));
            [~,max_uni_idx]=unique(sort_max_full_array_ant(:,1));

            %%%%%%%%%%%%Uniuqe and Re-round
            uni_sort_min_full_array_ant=round(sort_min_full_array_ant(min_uni_idx,:),rounding_digits);
            uni_sort_max_full_array_ant=round(sort_max_full_array_ant(max_uni_idx,:),rounding_digits);        

            if any(uni_sort_min_full_array_ant(:,1)~=uni_sort_max_full_array_ant(:,1))
                mis_idx=find(uni_sort_min_full_array_ant(:,1)~=uni_sort_max_full_array_ant(:,1));
                horzcat(uni_sort_min_full_array_ant(mis_idx,:),uni_sort_max_full_array_ant(mis_idx,:))
                'Azimuth theta misaligned/mismatch'
                pause;
            end

            %%%%%Find the Max of Each and fill in min_azimuth~max_azimuth with max ant gain
            %horzcat(uni_sort_min_full_array_ant,uni_sort_max_full_array_ant)
            merge_full_array_ant=uni_sort_min_full_array_ant;
            merge_full_array_ant(:,2)=max(horzcat(uni_sort_min_full_array_ant(:,2),uni_sort_max_full_array_ant(:,2)),[],2);

            over_min_idx=find(merge_full_array_ant(:,1)>min_azimuth);
            under_max_idx=find(merge_full_array_ant(:,1)<max_azimuth);
            max_gain_sweep_idx=intersect(over_min_idx,under_max_idx);
            max_ant_gain=max(merge_full_array_ant(:,2));
            merge_full_array_ant(max_gain_sweep_idx,2)=max_ant_gain;

            % % % figure;
            % % % hold on;
            % % % plot(uni_sort_min_full_array_ant(:,1),uni_sort_min_full_array_ant(:,2),'-k','LineWidth',3)
            % % % plot(uni_sort_max_full_array_ant(:,1),uni_sort_max_full_array_ant(:,2),'-b','LineWidth',3)
            % % % plot(merge_full_array_ant(:,1),merge_full_array_ant(:,2),'-r')
            % % % grid on;
        end
    
 
        %%%%%%%%%%%%%%Calculate the required pathloss for each azimuth step
        %%%%%%For 0-360 Degrees
        azi_required_pathloss=merge_full_array_ant;
        azi_required_pathloss(:,2)=required_pathloss+merge_full_array_ant(:,2);

       %%%%%%%%%%Check to see if we have enough distance
       if max(array_dist_pl(:,2))<max(azi_required_pathloss)
           'Need longer ITM Area Distance km'
           pause;
       end
        
       % % figure;
       % % hold on;
       % % plot(array_dist_pl(:,1),array_dist_pl(:,2),'-k')
       % % grid on;

       %%%%%%%%Find the distance for each azimuth and take it times the scalling factor, then create a polygon
       nn_idx=nearestpoint_app(app,azi_required_pathloss(:,2),array_dist_pl(:,2),'next');
       %size(azi_required_pathloss)
       %size(nn_idx)
       azi_required_pathloss(:,3)=array_dist_pl(nn_idx,1)*sim_scale_factor;
       

       %%%%%%%%%%%%%Downsample azi_required_pathloss: Need it to be at
       %%%%%%%%%%%%%least just 1 degree steps because this then creates the
       %%%%%%%%%%%%%wide keyhole, which is then used for the base_buffer,
       %%%%%%%%%%%%%which is the simulation area where the grid points are
       %%%%%%%%%%%%%created. The base buffer doesn't extrapolate between
       %%%%%%%%%%%%%azimuths.

       %%%%%%%%%%%Just downsample at the minimum pathloss
       min_pl=min(azi_required_pathloss(:,2));
       min_pl_idx=find(azi_required_pathloss(:,2)==min_pl);
       non_min_pl_idx=find(azi_required_pathloss(:,2)~=min_pl);

       %%%Find the break point
       break_point_idx=find(diff(min_pl_idx)>1);

       if isempty(break_point_idx)
           %'Need to add logic because the break point straddles the 0/360 degree'
           %pause;

           break_point_idx=find(diff(non_min_pl_idx)>1);

           first_part=azi_required_pathloss(non_min_pl_idx(1:1:break_point_idx),:);
            third_part=azi_required_pathloss(non_min_pl_idx([break_point_idx+1]:1:end),:);

           %%%%%%%%%%%Just keep those with a 1 degree step.
           below_ds_azi_required_pathloss=azi_required_pathloss(min_pl_idx,:);
           floor_azi=unique(floor(below_ds_azi_required_pathloss(:,1)));
           ceil_azi=unique(ceil(below_ds_azi_required_pathloss(:,1)));
           int_idx=intersect(floor_azi,ceil_azi);
           nn_below_azi_idx=nearestpoint_app(app,int_idx,azi_required_pathloss(:,1));

           second_part=azi_required_pathloss(nn_below_azi_idx,:);
           second_part(:,1)=round(second_part(:,1));

           ds_azi_required_pathloss=vertcat(first_part,second_part,third_part);
           size(ds_azi_required_pathloss)
           %ds_azi_required_pathloss

           % close all;
           % figure;
           % hold on;
           % plot(azi_required_pathloss(:,1),azi_required_pathloss(:,2),'-k','LineWidth',3)
           % plot(ds_azi_required_pathloss(:,1),ds_azi_required_pathloss(:,2),'or','LineWidth',1)
           % grid on;
           % pause%(0.1)
            

       elseif length(break_point_idx)>1
           'Need to add logic because the break point straddles the 0/360 degree'
           pause;
       else
           below_min_idx=min_pl_idx(1:break_point_idx);
           above_min_idx=min_pl_idx(break_point_idx+1:end);

           below_ds_azi_required_pathloss=azi_required_pathloss(below_min_idx,:);
           above_ds_azi_required_pathloss=azi_required_pathloss(above_min_idx,:);

           %%%%%%%%%%%Just keep those with a 1 degree step.
           floor_azi=unique(floor(below_ds_azi_required_pathloss(:,1)));
           ceil_azi=unique(ceil(above_ds_azi_required_pathloss(:,1)));

           nn_below_azi_idx=nearestpoint_app(app,floor_azi,azi_required_pathloss(:,1));
           nn_above_azi_idx=nearestpoint_app(app,ceil_azi,azi_required_pathloss(:,1));

           first_part=azi_required_pathloss(nn_below_azi_idx,:);
           first_part(:,1)=round(first_part(:,1));

           third_part=azi_required_pathloss(nn_above_azi_idx,:);
           third_part(:,1)=round(third_part(:,1));

           ds_azi_required_pathloss=vertcat(first_part,azi_required_pathloss(non_min_pl_idx,:),third_part);
           size(ds_azi_required_pathloss)
       end



       % % close all;
       % % figure;
       % % hold on;
       % % plot(azi_required_pathloss(:,1),azi_required_pathloss(:,2),'-k','LineWidth',3)
       % % plot(ds_azi_required_pathloss(:,1),ds_azi_required_pathloss(:,2),'or','LineWidth',1)
       % % grid on;
       % % pause%(0.1)

       azi_required_pathloss=ds_azi_required_pathloss; %%%%%%%%Replace
       %toc;



end
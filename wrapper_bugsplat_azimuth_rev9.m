function wrapper_bugsplat_azimuth_rev9(app,rev_folder,parallel_flag,workers,tf_server_status,tf_recalculate)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Now running the simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%App Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
retry_cd=1;
while(retry_cd==1)
    try
        cd(rev_folder)
        pause(0.1);
        retry_cd=0;
    catch
        retry_cd=1;
        pause(0.1)
    end
end

RandStream('mt19937ar','Seed','shuffle')
%%%%%%Create a random number stream using a generator seed based on the current time.
%%%%%%It is usually not desirable to do this more than once per MATLAB session as it may affect the statistical properties of the random numbers MATLAB produces.
%%%%%%%%We do this because the compiled app sets all the random number stream to the same, as it's running on different servers. Then the servers hop to each folder at the same time, which is not what we want.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Check for the Number of Folders to Sim
[sim_number,folder_names,num_folders]=check_rev_folders(app,rev_folder);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%If we have it, start the parpool.
disp_progress(app,strcat(rev_folder,'--> Starting Parallel Workers . . . [This usually takes a little time]'))
tic;
[poolobj,cores]=start_parpool_poolsize_app(app,parallel_flag,workers);
toc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Load all the mat files in the main folder
[reliability]=load_data_reliability(app);
[confidence]=load_data_confidence(app);
[FreqMHz]=load_data_FreqMHz(app);
[Tpol]=load_data_Tpol(app);
[grid_spacing]=load_data_grid_spacing(app);
[cell_sim_data]=load_data_cell_sim_data(app);
[sim_scale_factor]=load_data_sim_scale_factor(app);
[tf_clutter]=load_data_tf_clutter(app);
[mitigation_dB]=load_data_mitigation_dB(app);
[tx_height_m]=load_data_tx_height_m(app);
[max_itm_dist_km]=load_data_max_itm_dist_km(app);
[bs_eirp_reductions]=load_data_bs_eirp_reductions(app);
array_reliability_check=reliability;
if length(array_reliability_check)>1
    array_reliability_check
    'Need to insert logic for this multiple array_reliability_check'
    pause
end
array_mitigation=mitigation_dB;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Step 0: Make the grid points
disp_TextArea_PastText(app,strcat('Entering into Part0'))
part0_grid_pts_azi_pathloss_rev4_server(app,sim_number,folder_names,tx_height_m,bs_eirp_reductions,grid_spacing,rev_folder,tf_server_status)


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Step 1: Propagation Loss
% tf_recalc_pathloss=0
% if tf_calc_rx_angle==1 %%%%%%%%%If we need to do the angles.
%     string_prop_model='TIREM'
%     %%%%TIREM in Parallel Check
%     part1_calc_pathloss_dynamic_num_chunks_rev8(app,rev_folder,folder_names,parallel_flag,sim_number,reliability,confidence,FreqMHz,Tpol,workers,string_prop_model,tf_recalc_pathloss,tf_server_status)
% end

%%%%%%%%%As a point of comparison, ITM --> 9 mins, TIREM --> 3 hours , P2001 --> 5 hours
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Step 1: Propagation Loss (ITM)
string_prop_model='ITM'
%%num_chunks=24;  %%%%%%%%%This number needs to be set right here to not create possible mismatch error.
% %%%%The idea is to set the num_chunks to the maximum number of cores for one server.
%%%%%%But the number can't be based on the actual number of cores for the
%%%%%%server it is running on, because some servers have a different number
%%%%%%of cores, which would change the number of chunks.
tf_recalc_pathloss=0
disp_TextArea_PastText(app,strcat('Entering into Part1'))
part1_calc_pathloss_clutter2108_rev11(app,rev_folder,folder_names,parallel_flag,sim_number,reliability,confidence,FreqMHz,Tpol,workers,string_prop_model,tf_recalc_pathloss,tf_server_status,tf_clutter)
server_status_rev2(app,tf_server_status)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Make the map
tf_tropo_cut=0;
tf_calc_rx_angle=0
tf_rescrap_pathloss=tf_recalc_pathloss
disp_TextArea_PastText(app,strcat('Entering into Part2'))
part2_bugsplat_maps_azimuth_rev10(app,rev_folder,folder_names,sim_number,reliability,string_prop_model,grid_spacing,array_reliability_check,tf_calc_rx_angle,tf_recalculate,tf_tropo_cut,tf_server_status,array_mitigation,tf_rescrap_pathloss)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%part 4 Census Pop Impact
disp_TextArea_PastText(app,strcat('Entering into Part4'))
part4_census_pop_impact_rev6(app,rev_folder,folder_names,sim_number,string_prop_model,grid_spacing,tf_recalculate,array_mitigation,tf_server_status)
scrap_data_excel_pop_rev3(app,folder_names,string_prop_model,grid_spacing,array_mitigation,rev_folder,sim_number)
server_status_rev2(app,tf_server_status)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Output Excel files For Link Budget
%part3_write_excel_rev1(app,rev_folder,folder_names,sim_number,reliability,string_prop_model,grid_spacing,tf_recalculate,tf_tropo_cut)

if  parallel_flag==1
    poolobj=gcp('nocreate');
    delete(poolobj);
end

disp_TextArea_PastText(app,strcat('Sim Done'))
disp_progress(app,strcat('Sim Done'))

end
function wrapper_bugsplat_merge_folders_geoplot_pea_rev14(app,rev_folder,parallel_flag,workers,tf_server_status,tf_recalculate,tf_rescrap_rev_data)


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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Load all the mat files in the main folder
[reliability]=load_data_reliability(app);
[confidence]=load_data_confidence(app);
[FreqMHz]=load_data_FreqMHz(app);
[Tpol]=load_data_Tpol(app);
[grid_spacing]=load_data_grid_spacing(app);
[mitigation_dB]=load_data_mitigation_dB(app);
[tx_height_m]=load_data_tx_height_m(app);
[bs_eirp_reductions]=load_data_bs_eirp_reductions(app);
array_reliability_check=reliability;
if length(array_reliability_check)>1
    array_reliability_check
    'Need to insert logic for this multiple array_reliability_check'
    pause
end
array_mitigation=mitigation_dB;


[sim_number]=get_rev_folder_number(app,rev_folder);
[cell_sim_data]=load_data_cell_sim_data(app);
[sim_scale_factor]=load_data_sim_scale_factor(app);
[tf_clutter]=load_data_tf_clutter(app);

retry_load=1;
while(retry_load==1)
    try
        load(strcat('Rev',num2str(sim_number),'_array_dist_pl.mat'),'array_dist_pl')
        pause(0.1);
        retry_load=0;
    catch
        retry_load=1;
        pause(0.1)
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Step 0: Make the grid points
disp_TextArea_PastText(app,strcat('Entering into Part0: Creating Grid Points'))
part0_grid_pts_azi_pathloss_folders_rev6(app,sim_number,tx_height_m,bs_eirp_reductions,grid_spacing,rev_folder,tf_server_status,cell_sim_data,array_dist_pl,sim_scale_factor,tf_clutter)


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%If we have it, start the parpool.
% disp_progress(app,strcat(rev_folder,'--> Starting Parallel Workers . . . [This usually takes a little time]'))
% tic;
% [poolobj,cores]=start_parpool_poolsize_app(app,parallel_flag,workers);
% toc;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Step 1: Propagation Loss (ITM)
string_prop_model='ITM'
tf_recalc_pathloss=0
disp_TextArea_PastText(app,strcat('Entering into Part1'))
%%%%%%%%part1_calc_pathloss_clutter2108_rev11(app,rev_folder,folder_names,parallel_flag,sim_number,reliability,confidence,FreqMHz,Tpol,workers,string_prop_model,tf_recalc_pathloss,tf_server_status,tf_clutter)
part1_calc_pathloss_clutter2108_folders_rev12(app,rev_folder,parallel_flag,reliability,confidence,FreqMHz,Tpol,workers,string_prop_model,tf_recalc_pathloss,tf_server_status,tf_clutter)
server_status_rev2(app,tf_server_status)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Make the map
tf_tropo_cut=0;
tf_calc_rx_angle=0
tf_rescrap_pathloss=tf_recalc_pathloss
disp_TextArea_PastText(app,strcat('Entering into Part2'))
%%%%%part2_bugsplat_maps_azimuth_radial_multi_rev12(app,rev_folder,folder_names,sim_number,reliability,string_prop_model,grid_spacing,array_reliability_check,tf_calc_rx_angle,tf_recalculate,tf_tropo_cut,tf_server_status,array_mitigation,tf_rescrap_pathloss)
part2_bugsplat_maps_azimuth_radial_multi_pop_geoplot_rev13(app,rev_folder,reliability,string_prop_model,grid_spacing,array_reliability_check,tf_calc_rx_angle,tf_recalculate,tf_tropo_cut,tf_server_status,array_mitigation,tf_rescrap_pathloss)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%part 4 Census Pop Impact
% % % [sim_number,folder_names,~]=check_rev_folders(app,rev_folder);
% % % scrap_data_excel_pop_concave_rev4(app,folder_names,string_prop_model,grid_spacing,array_mitigation,rev_folder,sim_number)
% % % server_status_rev2(app,tf_server_status)
%scrap_data_excel_pop_concave_geo_id_rev5(app,string_prop_model,grid_spacing,array_mitigation,rev_folder,tf_server_status)
scrap_data_excel_pop_geo_id_pea_rev6(app,tf_rescrap_rev_data,sim_number,string_prop_model,grid_spacing,array_mitigation,rev_folder,tf_server_status)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Output Excel files For Link Budget
%part3_write_excel_rev1(app,rev_folder,folder_names,sim_number,reliability,string_prop_model,grid_spacing,tf_recalculate,tf_tropo_cut)

if  parallel_flag==1
    poolobj=gcp('nocreate');
    delete(poolobj);
end

disp_TextArea_PastText(app,strcat('Sim Done'))
disp_progress(app,strcat('Sim Done'))





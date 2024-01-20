function wrapper_bugsplat_rev1(app,rev_folder,parallel_flag)

cd(rev_folder);
pause(0.1)
RandStream('mt19937ar','Seed','shuffle')
%%%%%%Create a random number stream using a generator seed based on the current time.
%%%%%%It is usually not desirable to do this more than once per MATLAB session as it may affect the statistical properties of the random numbers MATLAB produces.
%%%%%%%%We do this because the compiled app sets all the random number stream to the same, as it's running on different servers. Then the servers hop to each folder at the same time, which is not what we want.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Toolbox Check (Sims can run without the Parallel Toolbox)
[workers,parallel_flag]=check_parallel_toolbox(app,parallel_flag);

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
[sim_radius_km]=load_data_sim_radius_km(app);
[grid_spacing]=load_data_grid_spacing(app);
[bs_height]=load_data_bs_height(app);
[array_bs_eirp_reductions]=load_data_array_bs_eirp_reductions(app);
[array_mitigation]=load_data_array_mitigation(app)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Step 0: Make the grid points
part0_grid_pts_rev2_outside_US(app,sim_number,folder_names,sim_radius_km,bs_height,array_bs_eirp_reductions,grid_spacing,rev_folder)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Step 1: Propagation Loss (ITM)
string_prop_model='ITM'
num_chunks=24;  %%%%%%%%%This number needs to be set right here to not create possible mismatch error.
part1_calc_pathloss_itm_or_tirem_angles_rev5(app,rev_folder,folder_names,parallel_flag,sim_number,reliability,confidence,FreqMHz,Tpol,workers,string_prop_model,num_chunks)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Make the map
tf_recalculate=0
tf_tropo_cut=0
part2_bugsplat_maps_multi_point_tropo_cut_rev4(app,rev_folder,folder_names,sim_number,string_prop_model,grid_spacing,tf_recalculate,tf_tropo_cut,array_mitigation)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Output Excel files
part3_write_excel_rev1(app,rev_folder,folder_names,sim_number,reliability,string_prop_model,grid_spacing,tf_recalculate,tf_tropo_cut)
scrap_data_excel_simplified_rev2(app,sim_number,folder_names,grid_spacing)



if  parallel_flag==1
    poolobj=gcp('nocreate');
    delete(poolobj);
end

disp_progress(app,strcat('Sim Done'))

end








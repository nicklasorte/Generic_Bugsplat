function wrapper_bugsplat_DSN_EESS_rev15(app,rev_folder,parallel_flag,workers,tf_server_status,tf_recalculate,tf_rescrap_rev_data,array_mitigation,array_reliability,impact_levels,tf_repull_excel,tf_plot_bugsplat,tf_plot_multi_con,excel_filename_sim_data,tf_repull_sim_data,mat_filename_sim_data)


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
[sim_number,folder_names,~]=check_rev_folders(app,rev_folder)
[cell_sim_data_excel]=load_full_excel_rev1(app,mat_filename_sim_data,excel_filename_sim_data,tf_repull_sim_data)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%Create a random number stream using a generator seed based on the current time.
RandStream('mt19937ar','Seed','shuffle')
%%%%%%It is usually not desirable to do this more than once per MATLAB session as it may affect the statistical properties of the random numbers MATLAB produces.
%%%%%%%%We do this because the compiled app sets all the random number stream to the same, as it's running on different servers. Then the servers hop to each folder at the same time, which is not what we want.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Pull the individual data and make the map
string_prop_model='ITM'
disp_TextArea_PastText(app,strcat('Entering into Part2'))
part2_plot_dsn_eess_rev1(app,rev_folder,string_prop_model,tf_recalculate,tf_server_status,cell_sim_data_excel,impact_levels,tf_repull_excel,tf_plot_bugsplat,tf_plot_multi_con)




% % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%part 4 Census Pop Impact
for rel_idx=1:1:length(array_reliability)
    reliability=array_reliability(rel_idx)
    tf_convex=1
    scrap_data_DSN_EESS_pop_geo_id_pea_rev7(app,tf_rescrap_rev_data,sim_number,string_prop_model,array_mitigation,rev_folder,tf_server_status,reliability,tf_convex)

    tf_convex=0
    scrap_data_DSN_EESS_pop_geo_id_pea_rev7(app,tf_rescrap_rev_data,sim_number,string_prop_model,array_mitigation,rev_folder,tf_server_status,reliability,tf_convex)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if  parallel_flag==1
    poolobj=gcp('nocreate');
    delete(poolobj);
end

disp_TextArea_PastText(app,strcat('Sim Done'))
disp_progress(app,strcat('Sim Done'))

end
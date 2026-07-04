function sub_pop_geo_pea_ua2023_rev10(app,convex_label,string_prop_model,sim_number,reliability,cell_convex_zones,array_mitigation,tf_server_status)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%'Another stage of if we rescrap then we calculate, else load'

filename_cell_poly_merge=strcat('cell_poly_merge_',convex_label,'_',string_prop_model,'_',num2str(sim_number),'_',num2str(min(reliability)),'%.mat');
filename_cell_ind_poly=strcat('cell_ind_poly_',convex_label,'_',string_prop_model,'_',num2str(sim_number),'_',num2str(min(reliability)),'%.mat');
filename_cell_overlap_poly=strcat('cell_overlap_poly_',convex_label,'_',string_prop_model,'_',num2str(sim_number),'_',num2str(min(reliability)),'%.mat');
filename_cell_xor_poly=strcat('cell_xor_poly_',convex_label,'_',string_prop_model,'_',num2str(sim_number),'_',num2str(min(reliability)),'%.mat');
filename_cell_census_poly=strcat('cell_census_poly_',convex_label,'_',string_prop_model,'_',num2str(sim_number),'_',num2str(min(reliability)),'%.mat');
filename_cell_pea_hist_poly=strcat('cell_pea_hist_poly_',convex_label,'_',string_prop_model,'_',num2str(sim_number),'_',num2str(min(reliability)),'%.mat');
filename_cell_ua_hist_poly=strcat('cell_ua_hist_poly_',convex_label,'_',string_prop_model,'_',num2str(sim_number),'_',num2str(min(reliability)),'%.mat');
server_status_rev2(app,tf_server_status)

disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 360'))

    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 363'))
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Polylmerge the cell_convex_zones for each mitigation level
    [cell_poly_merge,cell_ind_poly,cell_overlap_poly,cell_xor_poly]=polymerge_multi_miti_rev1(app,cell_convex_zones,array_mitigation);
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 366'))

    %%%%%Save
    %filename_cell_poly_merge=strcat('cell_poly_merge_',string_prop_model,'_',num2str(sim_number),'_',num2str(grid_spacing),'km.mat');
    retry_save=1;
    while(retry_save==1)
        try
            save(filename_cell_poly_merge,'cell_poly_merge')
            pause(0.1)
            retry_save=0;
        catch
            retry_save=1;
            pause(1)
        end
    end
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 381'))

    %%%%%Save
    %filename_cell_ind_poly=strcat('cell_ind_poly_',string_prop_model,'_',num2str(sim_number),'_',num2str(grid_spacing),'km.mat');
    retry_save=1;
    while(retry_save==1)
        try
            save(filename_cell_ind_poly,'cell_ind_poly')
            pause(0.1)
            retry_save=0;
        catch
            retry_save=1;
            pause(1)
        end
    end
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 396'))

    %%%%%Save
    %filename_cell_overlap_poly=strcat('cell_overlap_poly_',string_prop_model,'_',num2str(sim_number),'_',num2str(grid_spacing),'km.mat');
    retry_save=1;
    while(retry_save==1)
        try
            save(filename_cell_overlap_poly,'cell_overlap_poly')
            pause(0.1)
            retry_save=0;
        catch
            retry_save=1;
            pause(1)
        end
    end
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 411'))

    %%%%%Save
    %filename_cell_xor_poly=strcat('cell_xor_poly_',string_prop_model,'_',num2str(sim_number),'_',num2str(grid_spacing),'km.mat');
    retry_save=1;
    while(retry_save==1)
        try
            save(filename_cell_xor_poly,'cell_xor_poly')
            pause(0.1)
            retry_save=0;
        catch
            retry_save=1;
            pause(1)
        end
    end
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 426'))

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Plot the Overlapping Coordination Zones
    tf_plot_overlap=1%0%1%0%1%0%1%0
    if tf_plot_overlap==1
        %plot_nationwide_single_overlap_rev1(app,sim_number,cell_poly_merge,cell_overlap_poly)
        filename_overlay_plot=strcat('Overlay_Single_',convex_label,'_',num2str(sim_number),'_',num2str(min(reliability)),'%.png')
        plot_nationwide_single_overlap_rev2_filename(app,sim_number,cell_poly_merge,cell_overlap_poly,filename_overlay_plot)


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Just the single
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%coorindation zone
        filename_single_plot=strcat('Single_Nationwide_',convex_label,'_',num2str(sim_number),'_',num2str(min(reliability)),'%.png')
        tic;
        f1=figure;
        %AxesH = axes;
        for bound_idx=1%:1:num_miti
            temp_merge=cell_poly_merge{bound_idx};
            temp_merge
            [temp_geo_poly]=convert_polyshape2geopolyshape(app,temp_merge);
            %plot(temp_merge,'FaceColor','b','EdgeColor','k')
            geoplot(temp_geo_poly,'FaceColor','b','EdgeColor','k')
            hold on;
        end
        grid on;
        pause(0.1)

        %%%%geobasemap landcover
        geobasemap streets-light%landcover
        f1.Position = [100 100 1200 900];
        pause(1)
        print(gcf,filename_single_plot,'-dpng','-r300')
        pause(1)
        close(f1)
        toc;
    end
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 433'))

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%(This is the figure Nationwide7.)
    %%%%'Next step, plot the poly merge with the layers and a color bar on the right'

    tf_plot_nat=1%0%1%0
    if tf_plot_nat==1
        %%%%plot_nationwide_poly_miti_rev1(app,sim_number,cell_poly_merge,array_mitigation)
        filename_nationwide_multi=strcat('Nationwide7_Multi_Rev_',convex_label,'_',num2str(sim_number),'_',num2str(min(reliability)),'%.png')
        plot_nationwide_poly_miti_rev2_filename(app,sim_number,cell_poly_merge,array_mitigation,filename_nationwide_multi)
    end
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 441'))



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%'Census tract impact of overlap and XOR coordination zones'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Urban Area 2023 Impact
    %%%%%Updated to 2023 Census Data
    %%%%[cell_census_poly]=census_xor_poly_miti_rev1(app,array_mitigation,cell_xor_poly,cell_overlap_poly);
    [cell_census_poly]=census2020_xor_poly_miti_rev2(app,array_mitigation,cell_xor_poly,cell_overlap_poly);

    %%%%%1)Xor (single) 2) Overlap (GEO_idx)
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 447'))

    %%%%%Save
    %filename_cell_census_poly=strcat('cell_census_poly_',string_prop_model,'_',num2str(sim_number),'_',num2str(grid_spacing),'km.mat');
    retry_save=1;
    while(retry_save==1)
        try
            save(filename_cell_census_poly,'cell_census_poly')
            pause(0.1)
            retry_save=0;
        catch
            retry_save=1;
            pause(1)
        end
    end
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 462'))


    %%%%%%%%'find the urban area impact similar to the pea impact'
    [cell_ua_hist_poly]=urban_area_impact_overlap_xor_2020_rev2(app,array_mitigation,cell_census_poly);
       retry_save=1;
    while(retry_save==1)
        try
            save(filename_cell_ua_hist_poly,'cell_ua_hist_poly')
            pause(0.1)
            retry_save=0;
        catch
            retry_save=1;
            pause(1)
        end
    end
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 483'))


    %%%%%%%Just all Rows (This is the table in Section 4)
    retry_load=1
    while(retry_load==1)
        try
            load('cell_urbanarea_census_data_2020_2023.mat','cell_ua_census_data_2020')%%%%%%%%Using the 2023 Census Tracts/PEA equivalent
            pause(0.1)
            retry_load=0;
        catch
            retry_load=1;
            pause(1)
        end
    end

    %%%%%%%%%%Simplify
    cell_ua_hist_poly=squeeze(cell_ua_hist_poly)
    array_ua_data=cell2mat(cell_ua_hist_poly(:,[4,5,6]));
    two_col_ua=num2cell(horzcat(array_ua_data(:,1)+array_ua_data(:,2),array_ua_data(:,3)));
    full_cell_ua_data=horzcat(cell_ua_census_data_2020(:,[1,2,4]),two_col_ua);
    table_ua=cell2table(full_cell_ua_data);
    table_ua.Properties.VariableNames={'UA_Name' 'UA_Number' 'UA_Population' 'Encumbered' 'Unencumbered'}
    retry_save=1;
    while(retry_save==1)
        try
            writetable(table_ua,strcat('UrbanArea_2Col_',convex_label,'_',num2str(sim_number),'_',num2str(min(reliability)),'%.xlsx'));
            pause(0.1)
            retry_save=0;
        catch
            retry_save=1;
            pause(1)
        end
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%PEA Table of overlap and XOR coordination zones'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%[cell_pea_hist_poly]=pea_impact_overlap_xor_rev1(app,array_mitigation,cell_census_poly);
    [cell_pea_hist_poly]=pea_impact_overlap_xor_2020_rev2(app,array_mitigation,cell_census_poly); %%%%%%Updated with 2023 census tracts
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 469'))
    %%%%%Save
    %filename_cell_pea_hist_poly=strcat('cell_pea_hist_poly_',string_prop_model,'_',num2str(sim_number),'_',num2str(grid_spacing),'km.mat');
    retry_save=1;
    while(retry_save==1)
        try
            save(filename_cell_pea_hist_poly,'cell_pea_hist_poly')
            pause(0.1)
            retry_save=0;
        catch
            retry_save=1;
            pause(1)
        end
    end
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 483'))

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%NationWide PEA map with the Overlapping
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tf_plot_nat_pea=1%0%1%0
    if tf_plot_nat_pea==1
        %%%%plot_pea_overlap_rev1(app,cell_poly_merge,cell_overlap_poly,cell_pea_hist_poly,array_mitigation)
        filename_PEA_plot=strcat('PEA_Polygon_',convex_label,'_',num2str(sim_number),'_',num2str(min(reliability)),'%.png')
        %%%%%plot_pea_overlap_rev2_filename(app,cell_poly_merge,cell_overlap_poly,cell_pea_hist_poly,filename_PEA_plot)
        plot_pea_overlap_2023_rev3_filename(app,cell_poly_merge,cell_overlap_poly,cell_pea_hist_poly,filename_PEA_plot)
    end
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 492'))

    %%%%%%%Just all Rows (This is the table in Section 4)
    retry_load=1
    while(retry_load==1)
        try
            %%load('cell_pea_census_data.mat','cell_pea_census_data')
            filename_group_cell=strcat('cell_pea_census_data_2020_2023.mat')%%%%%%%%Using the 2023 Census Tracts
            load(filename_group_cell,'cell_pea_census_data_2020')
            pause(0.1)
            retry_load=0;
        catch
            retry_load=1;
            pause(1)
        end
    end

    cell_pea_census_data=cell_pea_census_data_2020;
    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 506'))

    %load('cell_pea_census_data.mat','cell_pea_census_data')
    %%%%%1)PEA Name, 2)PEA Num, 3)PEA {Lat/Lon}, 4)PEA Pop, 5)PEA Centroid, 6)Census {Geo ID}, 7)Census{Population}, 8)Census{NLCD}, 9)Census Centroid

    miti_idx=1
    %temp_dB_miti=array_mitigation(miti_idx)
    temp_cell_pea_hist_poly=squeeze(cell_pea_hist_poly(miti_idx,:,:));
    full_cell_pea_data=horzcat(cell_pea_census_data(:,[1,2,4]),temp_cell_pea_hist_poly(:,[4,5,6]));
    table_pea=cell2table(full_cell_pea_data);
    table_pea.Properties.VariableNames={'PEA_Name' 'PEA_Number' 'PEA_Population' 'XOR_Percentage' 'Overlap_Percentage' 'Available_Percentage'}
    retry_save=1;
    while(retry_save==1)
        try
            writetable(table_pea,strcat('PEA_',convex_label,'_',num2str(sim_number),'_',num2str(min(reliability)),'%.xlsx'));
            pause(0.1)
            retry_save=0;
        catch
            retry_save=1;
            pause(1)
        end
    end


    %%%%%%%%%%Simplify
    array_pea_data=cell2mat(temp_cell_pea_hist_poly(:,[4,5,6]));
    two_col_pea=num2cell(horzcat(array_pea_data(:,1)+array_pea_data(:,2),array_pea_data(:,3)));
    full_cell_pea_data=horzcat(cell_pea_census_data(:,[1,2,4]),two_col_pea);
    table_pea=cell2table(full_cell_pea_data);
    table_pea.Properties.VariableNames={'PEA_Name' 'PEA_Number' 'PEA_Population' 'Encumbered' 'Unencumbered'}
    retry_save=1;
    while(retry_save==1)
        try
            writetable(table_pea,strcat('PEA_2Col_',convex_label,'_',num2str(sim_number),'_',num2str(min(reliability)),'%.xlsx'));
            pause(0.1)
            retry_save=0;
        catch
            retry_save=1;
            pause(1)
        end
    end

    

    array_pop_pea_data=cell2mat(temp_cell_pea_hist_poly(:,[1,2,3]));
    covered_pop=sum(sum(array_pop_pea_data(:,[1,2])))
    free_pop=sum(array_pop_pea_data(:,3))
    total_pop=sum(sum(array_pop_pea_data))

    free_pop/total_pop
    table_pea=array2table(free_pop/total_pop);
    table_pea.Properties.VariableNames={'Percentage_Unencumbered'}
    retry_save=1;
    while(retry_save==1)
        try
            writetable(table_pea,strcat('FREE_',convex_label,'_',num2str(sim_number),'_',num2str(min(reliability)),'%.xlsx'));
            pause(0.1)
            retry_save=0;
        catch
            retry_save=1;
            pause(1)
        end
    end


    disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 528'))

server_status_rev2(app,tf_server_status)
disp_TextArea_PastText(app,strcat('scrap_data_excel_pop_geo_id_pea_rev6: Line 600'))

end
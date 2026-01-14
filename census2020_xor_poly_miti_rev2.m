function [cell_census_poly]=census2020_xor_poly_miti_rev2(app,array_mitigation,cell_xor_poly,cell_overlap_poly)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%'Census tract impact of overlap and XOR coordination zones'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Census Population Impact
%%%%%%%%%%%%%%%%%%%%%%%%Load the Census Pop Data
retry_load=1;
while(retry_load==1)
    try
        %%%%load('Cascade_new_full_census_2010.mat','new_full_census_2010')%%%%%%%Geo Id, Center Lat, Center Lon,  NLCD (1-4), Population
        load('Cascade_new_full_census_2023_UA.mat','new_full_census_2020')%%%%%%%1) %%%%%%%1) Geo Id, 2) Center Lat, 3) Center Lon,  4) Population 5)UA Number
        retry_load=0;
    catch
        'census load fail'
        retry_load=1;
        pause(0.1)
    end
end
% array_geo_idx=new_full_census_2010(:,1);
% mid_lat=new_full_census_2010(:,2);
% mid_lon=new_full_census_2010(:,3);
array_geo_idx=new_full_census_2020(:,1);
mid_lat=new_full_census_2020(:,2);
mid_lon=new_full_census_2020(:,3);

num_miti=length(array_mitigation)
tic;
cell_census_poly=cell(num_miti,2); %%%%%1)Xor (single) 2) Overlap (GEO_idx)
for miti_idx=1:1:num_miti
    horzcat(miti_idx,num_miti)
    temp_overlap_poly=cell_overlap_poly{miti_idx};
    temp_xor_poly=cell_xor_poly{miti_idx};

    %%%%%%%%%%Population Impact (idx) and then total pop
    %%%%%%%%Find the geo_id for each census tract, population, and NLCD value
    tic;
    num_cen=length(mid_lon);
    inside_over_idx=NaN(num_cen,1);
    for k=1:1:num_cen
        if ~isempty(temp_overlap_poly)
            temp_inside_idx=find(isinterior(temp_overlap_poly,mid_lon(k),mid_lat(k)));
            if ~isempty(temp_inside_idx)
                inside_over_idx(k)=k;
            end
        end
    end
    inside_over_idx=inside_over_idx(~isnan(inside_over_idx));
    toc;
    if ~isempty(inside_over_idx)
        cell_census_poly{miti_idx,2}=array_geo_idx(inside_over_idx);
    end

    tic;
    num_cen=length(mid_lon);
    inside_xor_idx=NaN(num_cen,1);
    for k=1:1:num_cen
        if ~isempty(temp_xor_poly)
            temp_inside_idx=find(isinterior(temp_xor_poly,mid_lon(k),mid_lat(k)));
            if ~isempty(temp_inside_idx)
                inside_xor_idx(k)=k;
            end
        end
    end
    inside_xor_idx=inside_xor_idx(~isnan(inside_xor_idx));
    toc;
    if ~isempty(inside_xor_idx) || all(isnan(inside_xor_idx))
        cell_census_poly{miti_idx,1}=array_geo_idx(inside_xor_idx);
    end
end
toc;
end
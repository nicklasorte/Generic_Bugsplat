function [cell_ua_hist_poly]=urban_area_impact_overlap_xor_2020_rev2(app,array_mitigation,cell_census_poly)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%Urban Area Table of overlap and XOR coordination zones'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%cell_census_poly  %%%%%1)Xor (single) 2) Overlap (GEO_idx)


retry_load=1;
while(retry_load==1)
    try
        %%%%%%%%%%load('cell_pea_census_data.mat','cell_pea_census_data')
        %load('cell_pea_census_data_2020_2023.mat','cell_pea_census_data_2020')%%%%%%%%Using the 2023 Census Tracts)
        load('cell_urbanarea_census_data_2020_2023.mat','cell_ua_census_data_2020')%%%%%%%%Using the 2023 Census Tracts/PEA equivalent
        pause(0.1)
        retry_load=0;
    catch
        retry_load=1
        pause(1)
    end
end

  %load('cell_pea_census_data_2020.mat','cell_pea_census_data_2020')% 
  %%%%%1)PEA Name, 2)PEA Num, 3)PEA {Lat/Lon}, 4)PEA Pop 2020, 5)PEA Centroid, 6)Census {Geo ID}, 7)Census{Population}, 8)Census{NLCD}, 9)Census Centroid
         
num_miti=1%length(array_mitigation)
[num_ua,~]=size(cell_ua_census_data_2020)

cell_ua_hist_poly=cell(num_miti,num_ua,6);%%%1)Xor Covered Pop, 2)Overlap Covered Pop, 3)Uncovered Pop, 4)xor Percentage, 5)Overlap Percentage, 6)Avaiable Percentage
tic;
for area_idx=1:num_miti
    area_idx
    temp_xor_census_geo_idx=cell_census_poly{area_idx,1};
    temp_overlap_census_geo_idx=cell_census_poly{area_idx,2};

    for ua_idx=1:1:num_ua
        %%%%%%%%%%%%%%For each UA, check to see which
        round((ua_idx/num_ua)*100)
        ua_census_geo_idx=cell_ua_census_data_2020{ua_idx,6};
        ua_census_pop=cell_ua_census_data_2020{ua_idx,7};     
        num_ua_census=length(ua_census_geo_idx);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%XOR
        temp_xor_match_idx=NaN(num_ua_census,1);
        temp_xor_uncovered_match_idx=NaN(num_ua_census,1);

        for j=1:1:num_ua_census
            temp_idx=find(ua_census_geo_idx(j)==temp_xor_census_geo_idx);
            if isempty(temp_idx)
                temp_xor_uncovered_match_idx(j)=j;
            else
                temp_xor_match_idx(j)=j;
            end
        end
        temp_xor_match_idx=temp_xor_match_idx(~isnan(temp_xor_match_idx));
        %%%temp_xor_uncovered_match_idx=temp_xor_uncovered_match_idx(~isnan(temp_xor_uncovered_match_idx));

        %%%%%%%%%Find the Population Covered in a PEA
        cell_ua_hist_poly{area_idx,ua_idx,1}=sum(ua_census_pop(temp_xor_match_idx));  %%%%%%%Xor

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Overlap
        temp_overlap_match_idx=NaN(num_ua_census,1);
        temp_overlap_uncovered_match_idx=NaN(num_ua_census,1);
        for j=1:1:num_ua_census
            temp_idx=find(ua_census_geo_idx(j)==temp_overlap_census_geo_idx);
            if isempty(temp_idx)
                temp_overlap_uncovered_match_idx(j)=j;
            else
                temp_overlap_match_idx(j)=j;
            end
        end
        temp_overlap_match_idx=temp_overlap_match_idx(~isnan(temp_overlap_match_idx));
        %%%%temp_overlap_uncovered_match_idx=temp_overlap_uncovered_match_idx(~isnan(temp_overlap_uncovered_match_idx));

        %%%%%%%%%Find the Population ua_idx in a PEA
        cell_ua_hist_poly{area_idx,ua_idx,2}=sum(ua_census_pop(temp_overlap_match_idx));  %%%%%%%Overlap

        %%%%%%%%%%%Now find the Uncovered Geo Idx
        temp_union_idx=union(temp_xor_match_idx,temp_overlap_match_idx);
        temp_all_idx=1:1:num_ua_census;
        temp_uncovered_match_idx=setxor(temp_all_idx,temp_union_idx);

        %%%%%%%%%%%Uncovered Population
        cell_ua_hist_poly{area_idx,ua_idx,3}=sum(ua_census_pop(temp_uncovered_match_idx));  %%%%%%Uncovered

        %%%%%%%%%%%%%Xor Percentage
        cell_ua_hist_poly{area_idx,ua_idx,4}=cell_ua_hist_poly{area_idx,ua_idx,1}/sum(ua_census_pop);

        %%%%%%%%%Overlap Percentage
        cell_ua_hist_poly{area_idx,ua_idx,5}=cell_ua_hist_poly{area_idx,ua_idx,2}/sum(ua_census_pop);

        %%%%%%%%Uncovered/Available Percentage
        cell_ua_hist_poly{area_idx,ua_idx,6}=cell_ua_hist_poly{area_idx,ua_idx,3}/sum(ua_census_pop);
    end
end
toc; %%%%1 Seconds

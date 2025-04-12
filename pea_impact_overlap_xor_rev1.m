function [cell_pea_hist_poly]=pea_impact_overlap_xor_rev1(app,array_mitigation,cell_census_poly)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%PEA Table of overlap and XOR coordination zones'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%cell_census_poly  %%%%%1)Xor (single) 2) Overlap (GEO_idx)


retry_load=1;
while(retry_load==1)
    try
        load('cell_pea_census_data.mat','cell_pea_census_data')
        pause(0.1)
        retry_load=0;
    catch
        retry_load=1;
        pause(1)
    end
end

%load('cell_pea_census_data.mat','cell_pea_census_data')
%%%%%1)PEA Name, 2)PEA Num, 3)PEA {Lat/Lon}, 4)PEA Pop, 5)PEA Centroid, 6)Census {Geo ID}, 7)Census{Population}, 8)Census{NLCD}, 9)Census Centroid

num_miti=length(array_mitigation)
[num_peas,~]=size(cell_pea_census_data)

cell_pea_hist_poly=cell(num_miti,num_peas,6);%%%1)Xor Covered Pop, 2)Overlap Covered Pop, 3)Uncovered Pop, 4)xor Percentage, 5)Overlap Percentage, 6)Avaiable Percentage
tic;
for area_idx=1:num_miti
    area_idx

    temp_xor_census_geo_idx=cell_census_poly{area_idx,1};
    temp_overlap_census_geo_idx=cell_census_poly{area_idx,2};

    for pea_idx=1:1:num_peas
        %%%%%%%%%%%%%%For each PEA, check to see which
        round((pea_idx/num_peas)*100)
        pea_census_geo_idx=cell_pea_census_data{pea_idx,6};
        pea_census_pop=cell_pea_census_data{pea_idx,7};
        num_pea_census=length(pea_census_geo_idx);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%XOR
        temp_xor_match_idx=NaN(num_pea_census,1);
        temp_xor_uncovered_match_idx=NaN(num_pea_census,1);

        for j=1:1:num_pea_census
            temp_idx=find(pea_census_geo_idx(j)==temp_xor_census_geo_idx);
            if isempty(temp_idx)
                temp_xor_uncovered_match_idx(j)=j;
            else
                temp_xor_match_idx(j)=j;
            end
        end
        temp_xor_match_idx=temp_xor_match_idx(~isnan(temp_xor_match_idx));
        %%%temp_xor_uncovered_match_idx=temp_xor_uncovered_match_idx(~isnan(temp_xor_uncovered_match_idx));

        %%%%%%%%%Find the Population Covered in a PEA
        cell_pea_hist_poly{area_idx,pea_idx,1}=sum(pea_census_pop(temp_xor_match_idx));  %%%%%%%Xor


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Overlap
        temp_overlap_match_idx=NaN(num_pea_census,1);
        temp_overlap_uncovered_match_idx=NaN(num_pea_census,1);
        for j=1:1:num_pea_census
            temp_idx=find(pea_census_geo_idx(j)==temp_overlap_census_geo_idx);
            if isempty(temp_idx)
                temp_overlap_uncovered_match_idx(j)=j;
            else
                temp_overlap_match_idx(j)=j;
            end
        end
        temp_overlap_match_idx=temp_overlap_match_idx(~isnan(temp_overlap_match_idx));
        %%%%temp_overlap_uncovered_match_idx=temp_overlap_uncovered_match_idx(~isnan(temp_overlap_uncovered_match_idx));

        %%%%%%%%%Find the Population Covered in a PEA
        cell_pea_hist_poly{area_idx,pea_idx,2}=sum(pea_census_pop(temp_overlap_match_idx));  %%%%%%%Overlap

        %%%%%%%%%%%Now find the Uncovered Geo Idx
        temp_union_idx=union(temp_xor_match_idx,temp_overlap_match_idx);
        temp_all_idx=1:1:num_pea_census;
        temp_uncovered_match_idx=setxor(temp_all_idx,temp_union_idx);

        %%%%%%%%%%%Uncovered Population
        cell_pea_hist_poly{area_idx,pea_idx,3}=sum(pea_census_pop(temp_uncovered_match_idx));  %%%%%%Uncovered

        %%%%%%%%%%%%%Xor Percentage
        cell_pea_hist_poly{area_idx,pea_idx,4}=cell_pea_hist_poly{area_idx,pea_idx,1}/sum(pea_census_pop);

        %%%%%%%%%Overlap Percentage
        cell_pea_hist_poly{area_idx,pea_idx,5}=cell_pea_hist_poly{area_idx,pea_idx,2}/sum(pea_census_pop);

        %%%%%%%%Uncovered/Available Percentage
        cell_pea_hist_poly{area_idx,pea_idx,6}=cell_pea_hist_poly{area_idx,pea_idx,3}/sum(pea_census_pop);
    end
end
toc; %%%%13 Seconds

end
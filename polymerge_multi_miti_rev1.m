function [cell_poly_merge,cell_ind_poly,cell_overlap_poly,cell_xor_poly]=polymerge_multi_miti_rev1(app,cell_convex_zones,array_mitigation)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Polylmerge the cell_convex_zones for each mitigation level
% %%%%%%%%Plot cell_poly_merge the mitigation shades
tic;
[num_site,~]=size(cell_convex_zones)
num_miti=length(array_mitigation);
cell_poly_merge=cell(num_miti,1); %%%%%1)Merged Polyshape for that mitigation
cell_ind_poly=cell(num_miti,num_site); %%%%Individual Polygons for each location and mitigation
for bound_idx=1:1:num_miti
    for site_idx=1:num_site
        temp_cell_bounds=cell_convex_zones{site_idx,2};
        [num_temp_rows,~]=size(temp_cell_bounds);
        if num_temp_rows>=bound_idx
            temp_bound=temp_cell_bounds{bound_idx,2};
            temp_poly=polyshape(temp_bound(:,2),temp_bound(:,1));
            %temp_poly=geopolyshape(temp_bound(:,1),temp_bound(:,2));
            cell_ind_poly{bound_idx,site_idx}=temp_poly;

            if site_idx==1
                temp_merge=temp_poly;
            else
                temp_merge=union(temp_merge,temp_poly);
            end
        end
    end
    cell_poly_merge{bound_idx}=temp_merge;
end
toc;

% %     'Next step, find the overlap areas for each set of mitigations'
tic;
num_miti=length(array_mitigation);
[num_site,~]=size(cell_convex_zones);
cell_overlap_poly=cell(num_miti,1);  %%%%The Overlapp
for miti_idx=1:1:num_miti
    %miti_idx
    temp_cell_overlap_poly=cell(num_site,num_site);
    temp_ind_polys=cell_ind_poly(miti_idx,:);
    for i=1:num_site
        i_poly=temp_ind_polys{i};
        if ~isempty(i_poly)
            for j=i:1:num_site
                if i~=j
                    j_poly=temp_ind_polys{j};
                    if ~isempty(j_poly)
                        temp_cell_overlap_poly{i,j}=intersect(i_poly,j_poly);
                    end
                end
            end
        end
    end

    %%%%%%%%Reshape from square to column
    temp_cell_overlap_poly=reshape(temp_cell_overlap_poly,[],1);

    %%%%%%Remove empty cells
    temp_cell_overlap_poly=temp_cell_overlap_poly(~cellfun(@isempty, temp_cell_overlap_poly));

    %%%Binary merge
    cell_overlap_poly{miti_idx,1}=binary_shape_merge_rev1(app,temp_cell_overlap_poly);
end
toc;



   cell_xor_poly=cell(num_miti,1);
    for miti_idx=1:1:num_miti
        temp_overlap_poly=cell_overlap_poly{miti_idx};
        temp_merge_poly=cell_poly_merge{miti_idx};
        temp_xor=xor(temp_merge_poly,temp_overlap_poly);
        cell_xor_poly{miti_idx}=temp_xor;
    end
end
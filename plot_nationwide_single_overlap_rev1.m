function []=plot_nationwide_single_overlap_rev1(app,sim_number,cell_poly_merge,cell_overlap_poly)


tic;
f1=figure;
%AxesH = axes;
for bound_idx=1%:1:num_miti
    temp_merge=cell_poly_merge{bound_idx};
    [temp_geo_poly]=convert_polyshape2geopolyshape(app,temp_merge);
    %plot(temp_merge,'FaceColor','b','EdgeColor','k')
    geoplot(temp_geo_poly,'FaceColor','b','EdgeColor','k')
    hold on;

    temp_overlap_poly=cell_overlap_poly{bound_idx};
    [temp_geo_overlap]=convert_polyshape2geopolyshape(app,temp_overlap_poly);
    %plot(temp_overlap_poly,'FaceColor','r','EdgeColor','k','FaceAlpha',0.7)
    geoplot(temp_geo_overlap,'FaceColor','r','EdgeColor','k','FaceAlpha',0.7)
end
grid on;
pause(0.1)

%%%%geobasemap landcover
geobasemap streets-light%landcover
f1.Position = [100 100 1200 900];
pause(1)
print(gcf,strcat('Overlay_Single_',num2str(sim_number),'.png'),'-dpng','-r300')
pause(1)
close(f1)
toc;
end
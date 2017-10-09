source('lib/myconfig.m');

source('lib/form.m');
source('lib/abaqus.m');
source('lib/flc.m');

model_inp = 'abaqus.inp';
rpt_dir = './frame/';
frame_dir = './gif/';

cache_start();
part = abaqus_load(model_inp);
blank = part.blank;
clear part;
meshgrid = abaqus_mesh(blank.element);
[x0,y0,z0] = qshell(blank.node, meshgrid);
n = 0.10;
flc = [-n 2*n; 0 n; flc_mk(n,0.995)];
flcolor = fld_colormap();
cache_stop();

%figure (1, 'visible', 'off'); 
report = readdir (rpt_dir);
for frame = 3:length(report)
    tic();
    [~,name,~] = fileparts(report{frame});
    png = strcat(frame_dir,name,'.png');
    if(file_exist(png)) continue; endif;
    clf;
    %close all;
    rpt = strcat(rpt_dir,report{frame})
    r = abaqus_report(rpt, 7);
    le = [r(:,6) r(:,4)];
    u = [r(:,1), r(:,2) r(:,3)];
    %
    U = meshgrid_apply(meshgrid, u);
    [u1,u2,u3] = deal(U(:,:,1), U(:,:,2), U(:,:,3));
    [x,y,z] = deal(x0+u1, y0+u2, z0+u3);
    %
    fld = fld_create(le, n, flc, 0.2);
    FLD = meshgrid_apply(meshgrid, fld);
    printf('report %.2f\n', toc())
    %

% MESH
tic();
subplot(1,2,2)
hsurf = surf(x,y,z,FLD);
set(hsurf, 'edgecolor',[.5 .5 .5], 'linewidth',.1, 'linestyle',':')
xlabel('{\it x}');
ylabel('{\it y}');
zlabel('{\it z}');
z = zlabel('{\it z}');
set(z, 'units', 'normalized', 'position', [-0.15 0.44 0]);
grid off
colormap(flcolor);
caxis([1,10]);
view([30 45]);
set (gca (), 'xlim', [0, 30])
set (gca (), 'ylim', [0, 30])
set (gca (), 'zlim', [-5, 15])
pbaspect([1 1 1]);
daspect([1 1 1]);
% FLD
subplot(1,2,1)
hold on
scatter(le(:,1),le(:,2),100, flcolor(fld,:),'.');
fld_plot(n, flc);
caxis([1,10]);
axis tight
set (gca (), 'ylim', [0, 0.4])
pbaspect([1 1 1]);
daspect([1 1 1]);
hold off
%%%
png
print('-dpng', png, '-r300','-Ftimes:2', '-S780,360')
%
printf('print %.2f\n', toc())
endfor
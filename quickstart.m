source('lib/form.m');
source('lib/abaqus.m');
% parse operation are cached (by default off)
cache_start();
source('lib/flc.m');

% parse .inp
part = abaqus_load('abaqus.inp');
% list parts
fieldnames(part)
% load only the metal sheet
blank = part.blank;
clear part;

% mesh creation
meshgrid = abaqus_mesh(blank.element);
[x0,y0,z0] = qshell(blank.node, meshgrid);
% displacement
u = abaqus_report('u.rpt', 3);
U = meshgrid_apply(meshgrid, u);
[u1,u2,u3] = deal(U(:,:,1), U(:,:,2), U(:,:,3));
% final position
[x,y,z] = deal(x0+u1, y0+u2, z0+u3);

% strain report
le = abaqus_report('le.rpt', 4);
% discarding SPOS
le = [le(:,3), le(:,1)];
LE = meshgrid_apply(meshgrid, le);

% strain hardening exponent
n = 0.10;
% forming limit curve
flc = [-n 2*n; 0 n; flc_mk(n,0.995)];
% forming limit diagram
fld = fld_create(le, n, flc, 0.2);
FLD = meshgrid_apply(meshgrid, fld);
% create the colormap as defined in fld_region (form.m)
flcolor = fld_colormap();

% MESH
subplot(1,2,2)
surf(x,y,z,FLD);
colormap(flcolor);
caxis([1,10]);
view([30 45]);
% FLD
subplot(1,2,1)
hold on
scatter(le(:,1),le(:,2),100, flcolor(fld,:),'.');
fld_plot(n, flc);
caxis([1,10]);
fld_legend();
hold off

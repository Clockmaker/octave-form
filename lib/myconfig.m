graphics_toolkit('qt')
more off;
clf; close all hidden;

set(0,'defaultlinelinewidth', 1)
set(0,'defaulttextfontname', 'latin modern math')
set(0,'defaulttextfontsize', 17)
set(0,'defaultaxesfontname', 'cmu serif')
set(0,'defaultaxesfontsize', 14)
%set(0,'defaultaxesbox', 'off')
%set(0,'defaultaxesposition', [0.15, 0.15, 0.75, 0.75]) 
%axes
set(gca,'xcolor', [.8 .8 .8]) 
set(gca,'ycolor', [.8 .8 .8]) 
set(gca,'zcolor', [.8 .8 .8])
set(gca, 'gridcolormode', 'manual')
set(gca, 'gridcolor', [.9 .9 .9])
set(gca, 'gridalphamode', 'manual')
set(gca, 'gridalpha', 1)
%set(0,'defaultaxesxtick',  []) 
%set(0,'defaultaxesytick',  []) 
%set(0,'defaultaxesztick',  []) 

set(0,'defaultaxesxcolor', [.4 .4 .4])
set(0,'defaultaxesycolor', [.4 .4 .4])
set(0,'defaultaxeszcolor', [.4 .4 .4])

set (0, 'defaultfigurepapertype', 'A4');
%set (0, 'defaultfigurepaperunits','centimeters');
%set (0, 'defaultfigurepapersize', [29.7 21.0]);
%set (0, 'defaultfigurepaperposition', [0 0 42 59.4]); 
%set (0, 'defaultfigurepaperpositionmode', 'auto'); 

%set(0,'defaultaxesdataaspectratiomode', 'auto') 
%set(0,'defaultaxesdataaspectratio', [1 1 1]) 
%set(0,'defaultaxesplotboxaspectratiomode', 'auto') 

% Custom Colormap
parula= @(n) mycolormap([
53,42,135;
3,99,225;
20,133,212;
6,167,198;
56,185,158;
146,191,115;
217,186,86;
252,206,46;
249,251,14;
]./255, n);
viridis= @(n) mycolormap([
68,1,84;
71,44,122;
59,81,139;
44,113,142;
33,144,141;
39,173,129;
92,200,99;
170,220,50;
253,231,37;
]./255, n);
RdYlBu= @(n) mycolormap([
69,117,180;
116,173,209;
171,217,233;
224,243,248;
254,224,144;
253,174,97;
244,109,67;
215,48,39;
]./255, n);
RdBu= @(n) mycolormap([
33,102,172;
67,147,195;
146,197,222;
209,229,240;
253,219,199;
244,165,130;
214,96,77;
178,24,43;
]./255, n);
RdGy= @(n) mycolormap([
77,77,77;
135,135,135;
186,186,186;
224,224,224;
253,219,199;
244,165,130;
214,96,77;
178,24,43;
]./255, n);
spectral= @(n) mycolormap([
50,136,189;
102,194,165;
171,221,164;
230,245,152;
254,224,139;
230,245,152;
254,224,139;
253,174,97;
244,109,67;
213,62,79;
]./255, n);
paired= @(n) mycolormap([
166,206,227;
31,120,180;
178,223,138;
51,160,44;
253,191,111;
255,127,0;
251,154,153;
227,26,28;
]./255, n);

function map = mycolormap(color, n)
  y = length(color);
  map = interp1(1:y, color, linspace(1,y,n), 'linear');
end;
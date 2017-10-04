1;

global fld_region;
fld_region = struct(
		'safe', 	struct('id', 2, 'color', [188 188 188]./255),
		'elastic', 	struct('id', 1, 'color', [255 235  59]./255),
		'wrinkle', 	struct('id', 3, 'color', [142  68 173]./255),
		'warp', 	struct('id', 4, 'color', [ 26 188 156]./255),
		%
		'risk', 	struct('id', 8, 'color', [255 152   0]./255),
		'tear', 	struct('id', 9, 'color', [236  64 122]./255), 
		'fracture',	struct('id',10, 'color', [255  57  43]./255)
);

function map = fld_colormap()
	global fld_region;

	list = fieldnames(fld_region);
	% TODO: insertion sort?
	tosort = [];
	for l = 1:length(list)
		tosort = [tosort, fld_region.(list{l}).id];
	endfor;
	[~, index] = sort(tosort);
	map(1:tosort(index(end)),1:3) = ones(tosort(index(end)),3);
	for i = index
		map(fld_region.(list{i}).id,1:3) = fld_region.(list{i}).color;
	endfor
endfunction

function fld_legend()
	global fld_region;
	options = {'markersize',10,'linewidth',1,'color','none'};
	list = fieldnames(fld_region);
	for i = 1:length(list)
		plot(NaN,NaN,strcat('s;',list{i},';'), 'markerfacecolor',fld_region.(list{i}).color, options{:})
	endfor
	legend('orientation','horizontal','location', 'north')
endfunction

function fld_leftside(n, r_m=1,option={})
	plot([-n 0],[n 0], option{:});
	plot([-n 0],[n*(r_m+1)/(r_m) 0], option{:});
endfunction

function fld_limit(n, option={})
	plot([-n 0],[.5*n 0], option{:});
endfunction

function fld_plot(n, flc, r_m=1, %
 line_flc = {'color',[0 0 0],    'linewidth', 1.1}, % 
 line1    = {'color',[0 0 0],    'linewidth', .4  }, %
 line2    = {'color',[.5 .5 .5], 'linewidth', .4, '--'} )
%
	plot(flc(:,1), flc(:,2), line_flc{:});
	fld_limit(n, line1);
	plot([0 flc(end,1)], [0 flc(end,2)], line1{:});
	fld_leftside(n, r_m, line2);
	xlabel('\epsilon_{\rm2}');
	ylabel('\epsilon_{\rm1}');
endfunction


%
% Hard-coded collision detection
%
function fld = fld_create(LE, n, flc, risk_margin=0,e0=4e-3, r_m=1)
	global fld_region;
	o = [0 0];
	for n=1:length(LE)
		e_min = LE(n,1);
		e_maj = LE(n,2);
		e = [e_min, e_maj];
		% safe, until proven otherwise
		state = fld_region.safe.id;
		if( e_min < 0)
			% left side
			% Defects
			if(CCW(o, [-n n*(r_m+1)/(r_m)], e) >= 0)
				state = fld_region.warp.id;
				if(CCW(o, [-n n], e) > 0)
					state = fld_region.wrinkle.id;
				endif
				% having "goto" would be nice.
				fld(n,1) = state;
				continue;
			endif
			% still can be in risk of tearing

		% right side
		% elastic circle 
		% (hypothesis of isotropic elastic domain)
		elseif(e_maj^2 + e_min^2 <= e0^2) 
				state = fld_region.elastic.id;
				fld(n,1) = state;
				continue;
		endif
	  % the slowest task last...
	  % 
	  % detecting if the point is above the curve
	  % "sweep line algorithm" like
		for i=2:length(flc)
			
			if(flc(i,1) > e_min)
				if(CCW(flc(i-1, :), flc(i, :), e) >= 0)
					state = fld_region.fracture.id;
				elseif(risk_margin > 0) 
					if(CCW(flc(i-1,:)*[0; 1-risk_margin], flc(i,:)*[0;1-risk_margin], e) >= 0)
						state = fld_region.risk.id;
						if(e_min < 0)
							% deep drawing split
							state = fld_region.tear.id;
						endif
					endif
				endif
			%fld(n,1) = state;
			break;
			endif
		endfor
	  % TODO: bounding box the flc
	  fld(n,1) = state;
	endfor
endfunction

function cross = CCW(a, b, c)
	u = b - a;
	v = c - b;
	cross = u*[v(2);-v(1)];
endfunction

1;
%{ Abaqus.m 
%   misc utilities to parse .inp files
%}
global abaqus_cfg;
abaqus_cfg.cache = false;
abaqus_cfg.cache_dir = './cache/';

function fid = file_open(file)
	fid = fopen(file, 'r');
	if  ~is_valid_file_id(fid)
		printf('%s file not found.\n',file)
		fclose(fid);
		fid = 0;
		return;
	endif
endfunction

function exist = file_exist(file)
	fid = fopen(file, 'r');
	if  is_valid_file_id(fid)
		exist = true;
		fclose(fid);
	else
		exist = false;
	endif
	return;
endfunction

function file = cache_get(file)
	global abaqus_cfg;
	[path,name,ext] = fileparts(file);
	if(length(abaqus_cfg.cache_dir) != 0) path = abaqus_cfg.cache_dir; endif

	file = strcat(path,name,ext,'.mat');
endfunction

function cache_start()
	global abaqus_cfg;
	abaqus_cfg.cache = true;
	if( length(stat(abaqus_cfg.cache_dir)) == 0 )
		mkdir(abaqus_cfg.cache_dir);
	endif;
endfunction

function cache_stop()
	global abaqus_cfg;
	abaqus_cfg.cache = false;
endfunction
%
% Abaqus' Input Parser
%
function part = abaqus_load(file_inp)
	global abaqus_cfg;
	fid = file_open(file_inp);
	if(fid < 0) return; endif

	%cache
	mfile = cache_get(file_inp);
	if(file_exist(mfile) && abaqus_cfg.cache) 
		load(mfile, 'part');
		return;
	endif

	part = struct();

	while (line = fgetl(fid)) && line > 0
		if substr(line,1,1) == '*'
			if substr(line,2,1) == '*' continue; endif

			if substr(line,2,3) == 'Ins'
				name = strsplit(line, 'part='){1,2};
				part.(name) = struct('node',[],'element', []);
				%skip instance
				line = fgetl(fid);
				while(substr(line,1,1) != '*') line = fgetl(fid); endwhile

				%skip node declaration
				line = fgetl(fid);
					%adding nodes
				while(substr(line,1,1) != '*') && line > 0
					[n, x,y,z] = strread(line, ' %f, %f, %f, %f');
					part.(name).node(n,1:3) = [x, y, z];
					line = fgetl(fid);
				endwhile
				if(substr(line,2,7) == 'Element')
					type = strsplit(line, 'type='){1,2};
					switch type
						case {'S4', 'S4R', 'S8', 'S8R'}
							line = fgetl(fid);
							while(substr(line,1,1) != '*') && line > 0
								[id, v1,v2,v3,v4] = strread(line, ' %f, %f, %f, %f, %f');
								part.(name).element(id,1:4) = [v1,v2,v3,v4];
								line = fgetl(fid);
							endwhile
						%otherwise continue;
					endswitch 
				endif
			endif
		%
		endif
	endwhile
	fclose(fid);

	if abaqus_cfg.cache
		save(mfile,'part');
	endif
endfunction
%
% Abaqus' Field Output Parser
%
function value = abaqus_report(file_rpt, columns, prealloc = false)
	if(prealloc) value(1089, 1:colums)= zeros(1089,1:colums); endif;
	global abaqus_cfg;
	fid = file_open(file_rpt);
	if(fid < 0) return; endif

	%cache
	mfile = cache_get(file_rpt);
	if(file_exist(mfile) && abaqus_cfg.cache) 
		load(mfile, 'value');
		return;
	endif

	format = strjoin({'%f'}(ones(columns+1,1)),' ');
	dash = 0;
	while (1)
		line = fgetl(fid);
		if(length(line)<1) continue; endif;
		if(substr(line,1,1) == '-') 
			dash++;
		endif
		if(dash < 2) continue; endif
		while( (line = fgetl(fid)) )
			[row{1:columns+1}] = strread(line, format);
			row = cell2mat(row);
			value(uint32(row(1,1)), 1:columns) = row(1,2:end);
			row = {};
		endwhile
	break;
	endwhile
	fclose(fid);
	if abaqus_cfg.cache
		save(mfile,'value');
	endif
endfunction
%
% Mesh Tools
%
function meshgrid = abaqus_mesh(element)
	seed = 1; 
	% edge's queue
	queue=[];
	grid=[];

	%rotating cursor
	cursor = [0 0 1 1 0];
	% first
	for(v=1:4) 
		grid = [grid; cursor(v), -cursor(v+1), element(seed, v)];
	endfor;

	curPrevious = [4 1 2 3];
	curNext		= [2 3 4 1];

	while( !isempty(element) )
	  % edge to search
	  queue=[element(seed,[1 2, 3 4]) queue element(seed,[2 3, 4 1])];
	  % pop element
	  element(seed,:)=[];
	  
	  for v=1:2:length(queue)
	    % edge's vertices
	    A=queue(v);
	    B=queue(v+1);

	    [seed, a] = find(element == A); 
	    if( isempty(seed) ) continue; endif;

	    [k, b] = find(element(seed,:)== B,1);
	    if( isempty(k) ) continue; endif;

	     seed = seed(k); 
	    	a = a(k);
	    [A,~] = find(grid(:,3)==A,1);
	    [B,~] = find(grid(:,3)==B,1);
	    
	    if( grid(A,1) == grid(B,1) ) 
	      %horizontal edge (up/down)
	      if( grid(A,2) > grid(B,2) ) 
	      	[A,B,a,b] = deal(B,A,b,a);
	      endif

	      if( a == curNext(b) ) cw = 1; else cw = -1; endif

	      iiA = iiB = grid(A,1) + cw; 
	      jjA = grid(A,2);
	      jjB = grid(B,2);

	      if(cw > 0) 
	      	A=element(seed, curNext(a)); 
	      	B=element(seed, curPrevious(b));
	      else
	      	A=element(seed, curPrevious(a)); 
	      	B=element(seed, curNext(b));
	      endif
	    else 
	      %vertical edge (left/right)
	   	  if(grid(A,1) < grid(B,1))
	   	  	[A,B,a,b] = deal(B,A,b,a);
	   	  endif

	      if (a == curNext(b)) cw = 1; else cw = -1; endif

	      jjA = jjB = grid(A,2) + cw;
	      iiA = grid(A,1); 
	      iiB = grid(B,1);

	      if(cw > 0) 
	      	A = element(seed, curNext(a));
	      	B = element(seed, curPrevious(b)); 
	      else
	      	A = element(seed, curPrevious(a));
	      	B = element(seed, curNext(b)); 
	      endif
	    endif

	    grid = [ grid; ...
	             iiA, jjA, A; ...
	             iiB, jjB, B ];

	    if( !isempty(seed) )break; endif;
	  endfor;
	  % pop
	  queue(1:v+1)=[];
	endwhile;

	% built up
	ii = grid(:,1) + 1 - min(grid(:,1));
	jj = grid(:,2) + 1 - min(grid(:,2));
	kk = grid(:,3);

	mi=max(ii);
	mj=max(jj);

	meshgrid(1:mi,1:mj)=NaN;


	for z=1:length(kk)
	  i=ii(z,1);
	  j=jj(z,1);
	  node = kk(z,1);
	  %
	  meshgrid(i,j) = node;
	endfor;
endfunction
%
function [x, y, z] = qshell(node, meshgrid)
	[w, h] = size(meshgrid);
	x(1:w,1:h) = y(1:w,1:h) = z(1:w,1:h) = NaN;
	for i=1:w;
	  for j=1:h;
		n = meshgrid(i,j); 
		x(i,j) = node(n, 1);
		y(i,j) = node(n, 2);
		z(i,j) = node(n, 3);
	  endfor
	endfor
endfunction
%
function grid = meshgrid_apply(meshgrid, variable)
	[w, h] = size(meshgrid);
	for i=1:w;
	  for j=1:h;
		n = meshgrid(i,j);
		  for v=1:size(variable)(2)
		  	value = variable(n,v);
		  	if(isnan(value)) value = NaN; endif
			grid(i,j,v) = value;
		  endfor
	  endfor
	endfor
endfunction


%
% End abaqus.m
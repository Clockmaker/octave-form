1;
%
% Forming Limit Curve Generator
% Octave 4.0.1
%

%
% Marciniak-Kuczynski's FLC
%
function flc = flc_mk(n, f=0.999, alpha=linspace(.7,1,10),  %
interactive=false, %
m=0, delta=1e-2, fail=1.1, %
% Flow Rule
Ss=@(x) ((x^2-x+1)^.5), %
E1=@(x) ((2-x)/(2*(x^2-x+1)^.5)), %
E2=@(x) ((2*x-1)/(2*(x^2-x+1)^.5)) )
  global abaqus_cfg;
  mkname = strcat('mk_f', num2str(f) ,'-n',num2str(n),'.mat');
  mfile = cache_get(mkname);
  if(file_exist(mfile) && abaqus_cfg.cache) 
    load(mfile, 'flc');
    return;
  endif

  % Domains
  A=B=struct(
    'e', 0, %equivalent strain
    'De',0, %strain increment
    'a', 0  %strain ratio
  );

  % Stop Condition (B.De/A.De)>100
  stop = delta/fail;
  % Plot Setup
  if interactive
    figure
    hold on
    grid on 
    axis('tight'); 
    daspect([1 1 1]);
    pbaspect([1 1 1]); 
  endif
  
  %% Main %%
  for ratio = [alpha]
    if interactive printf('alpha=%1.2f\n', ratio); endif
    % Init
    A.e  = B.e  = 0;
    A.a  = B.a  = ratio;
    A.De = B.De = delta;
    v=(A.De/B.De)^m;
    retry= 0;
    A_De = 0;
    % Necking Condition
    while(A.De > stop)
    %printf('%1.2f/%1.2f *%f =%1.3f\n', B.e*1e3, A.De*1e3, A_De, B.De/A.De) %debug
    
      Ae= A.e+A.De;
      Be= B.e+B.De;
      
      % Guess value from Domain A
      N = ( (Ae/Be)^n )*v;
      L = f*Ss(A.a);
      e1A = E1(A.a)*Ae;
      % Solve MK for alpha^B
      B.a = NR_solver(@(x) N - (L/Ss(x)) * e^( e1A - E1(x)*Be ) , ...
      B.a);
    
      % Solve for Domain B
      e1B = E1(B.a)*Be;
      e1a = E1(A.a);
      L = L/Ss(B.a);
      %
      A_De= NR_solver(@(y) ( ((A.e+y)/(Be))^n )*v - L * e^( e1a*(A.e+y) - e1B ), ...
      A.De);
    
      % Check Trial-Solution
      if(abs(A.De-A_De) < eps)
        retry=0;
        A.e+=A.De;
  	    B.e+=delta;
        if interactive
          scatter([E2(A.a)*A.e],[E1(A.a)*A.e],2,'b','.');
          scatter([E2(B.a)*B.e],[E1(B.a)*B.e],2,'g','.');
          drawnow();
        endif
      else retry++; 
        %printf('%i| %f %f\n',retry, A_De, A.De)
        if(retry > 10) break;
        else A.De-=1e-6; endif;
  	  endif;

    endwhile;
    % Store Max Strain
    flc(end+1, 2) = E1(A.a)*A.e;
    flc(end,   1) = E2(A.a)*A.e;
  endfor;
  %flc(end+1, 1) = n;
  %flc(end,   2) = 0;
  
  if interactive
    scatter(flc(:,2), flc(:,1), 4, 'r', 'o','filled');
    axis('tight'); 
    hold off;
  endif
  if abaqus_cfg.cache
    save(mfile,'flc');
  endif
endfunction;

%% Newton-Raphson %%
function r = NR_solver(f, x0=0, n=50, tol=100, err=eps, dx=1e-6)
  x = zeros(1, n+1); x(1)=x0;
  for i = 1:n
    fx=f(x(i));
    x(i+1)=x(i)-(fx*dx)/(f(x(i)+dx)-fx);
    e=abs(x(i+1)-x(i));
    if(e<err||e>tol) break; endif;
  endfor;
  r = x(i);
  %if(e > tol) disp('Failed to find a solution.'); endif;
endfunction
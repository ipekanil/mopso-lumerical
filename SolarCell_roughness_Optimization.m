function y=SolarCell_roughness_Optimization(delx,w_min,w_error,h)

%Modify thickness1 and thickness2 then run the
%simulation
% fdtdmin=(ceil(3e-6/a/2)/2)*a;
code=strcat('switchtolayout;',...
'select("surface_roughness_simple_bottom");',...
'set("delx",',num2str(delx,16),');',...
'set("w_min",',num2str(w_min,16),');',...
'set("w_error",',num2str(w_error,16),');',...
'run;');
% 'select("source");',...
% 'set("y",',num2str(w_min + 1.2e-6 ,16),');',...

appevalscript(h,code);

%Get the coupled power from T monitor to
%FDTD workspace as variable 'T_avg_FDTD'
% code=strcat('T=getresult("solar_generation","Jsc");');
appevalscript(h,'T=transmission("T");');
appevalscript(h,code);

%Get the average transmission(figure of merit) from FDTD workspace to
%Matlab workspace
T_MatlabFun=appgetvar(h,'T'); %A Matlab command that will retrieve a variable from Lumerical workspace 
...into Matlab workspace via Matlab interoperability API.
y=abs(T_MatlabFun);
% [y fval] = fminunc(@(y)-2*y,15);
%Uncommnet this section to display the optimized parameters and
%figure of merit for each run in FDTD
disp(strcat('delx =  ',num2str(delx,10)));
disp(strcat('w_min =  ',num2str(w_min,10)));
disp(strcat('w_error =  ',num2str(w_error,10)));
disp(strcat('T = ',num2str(y,10)));
end
%
% Copyright (c) 2015, Yarpiz (www.yarpiz.com)
% All rights reserved. Please read the "license.txt" for license terms.
%
% Project Code: YPEA121
% Project Title: Multi-Objective Particle Swarm Optimization (MOPSO)
% Publisher: Yarpiz (www.yarpiz.com)
% 
% Developer: S. Mostapha Kalami Heris (Member of Yarpiz Team)
% 
% Contact Info: sm.kalami@gmail.com, info@yarpiz.com
%

function xnew=Mutate(x,pm,VarMin,VarMax)

   nVar=numel(x);
    j=randi([1 nVar]);

    dx1=pm*(VarMax(1,1)-VarMin(1,1));
    dx2=pm*(VarMax(1,2)-VarMin(1,2));
    dx3=pm*(VarMax(1,3)-VarMin(1,3));
    
    xnew=x;
    
    if j==1
    lb1=x(j)-dx1;
    if lb1<VarMin(1,1)
        lb1=VarMin(1,1);
    end
    
    ub1=x(j)+dx1;
    if ub1>VarMax(1,1)
        ub1=VarMax(1,1);
    end
    xnew(j)=unifrnd(lb1,ub1);
    
    elseif j==2
    
    lb2=x(j)-dx2;
    if lb2<VarMin(1,2)
        lb2=VarMin(1,2);
    end
    
    ub2=x(j)+dx2;
    if ub2>VarMax(1,2)
        ub2=VarMax(1,2);
    end
    xnew(j)= unifrnd(lb2,ub2);
    
    elseif j==3
     lb3=x(j)-dx3;
    if lb3<VarMin(1,3)
        lb3=VarMin(1,3);
    end
    
    ub3=x(j)+dx3;
    if ub3>VarMax(1,3)
        ub3=VarMax(1,3);
    end
    xnew(j)=unifrnd(lb3,ub3);

    end
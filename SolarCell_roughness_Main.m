clear;

%Add Lumerical Matlab API path
path(path,'C:\Program Files\Lumerical\FDTD\api\matlab');
sim_file_path=('C:\Users\AhmetMesutAlpkilic\Desktop\pso'); % update this path to user's folder
sim_file_name=('solar_roughness with Al triangle doubleside.fsp');

%Open FDTD session
h=appopen('fdtd');

%Pass the path variables to FDTD
appputvar(h,'sim_file_path',sim_file_path);
appputvar(h,'sim_file_name',sim_file_name);

%Load the FDTD simulation file and get simulation parameters
code=strcat('cd(sim_file_path);',...
    'load(sim_file_name);',...
    'select("surface_roughness_simple_bottom");',...
    'delx=get("delx");',...
    'w_min=get("w_min");',...
    'w_error=get("w_error");'); 
     
%send the script in 'code' to Lumerical FDTD Solutions
appevalscript(h,code);

%Get variables from FDTD workspace to Matlab
%workspace
delx=appgetvar(h,'delx');
w_min=appgetvar(h,'w_min');
w_error=appgetvar(h,'w_error');

%Function to be optimized x(thickness1)
CostFunction=@(x,y)SolarCell_roughness_Optimization(x(1),x(2),x(3),h);

nVar=3;             % Number of Decision Variables 

VarSize=[1 nVar];   % Size of Decision Variables Matrix

VarMin = [0.1*1e-6 0.1*1e-6 0.1*1e-6];
VarMax = [0.3*1e-6 0.5*1e-6 0.5*1e-6];

%% MOPSO Parameters

MaxIt=2;           % Maximum Number of Iterations

nPop=2;            % Population Size

nRep=5;            % Repository Size

w=0.5;              % Inertia Weight
wdamp=0.99;         % Intertia Weight Damping Rate
c1=1;               % Personal Learning Coefficient
c2=2;               % Global Learning Coefficient

nGrid=7;            % Number of Grids per Dimension
alpha=0.1;          % Inflation Rate

beta=2;             % Leader Selection Pressure
gamma=2;            % Deletion Selection Pressure

mu=0.1;             % Mutation Rate

%% Initialization

empty_particle.Position=[];
empty_particle.Velocity=[];
empty_particle.Cost=[];
empty_particle.Best.Position=[];
empty_particle.Best.Cost=[];
empty_particle.IsDominated=[];
empty_particle.GridIndex=[];
empty_particle.GridSubIndex=[];

pop=repmat(empty_particle,nPop,1);

for i=1:nPop
    
    x1=unifrnd(VarMin(1,1),VarMax(1,1),[1 1]); %initial values
    x2=unifrnd(VarMin(1,2),VarMax(1,2),[1 1]);
    x3=unifrnd(VarMin(1,3),VarMax(1,3),[1 1]);
    pop(i).Position=[x1 x2 x3]; %Continuous uniform random numbers
    
    pop(i).Velocity=zeros(VarSize);
    
    pop(i).Cost=CostFunction(pop(i).Position);
    
    
    % Update Personal Best
    pop(i).Best.Position=pop(i).Position;
    pop(i).Best.Cost=pop(i).Cost;
    
end

% Determine Domination
pop=DetermineDomination(pop);

rep=pop(~[pop.IsDominated]); %populasyonda nondominated 0 olan yerleri buldu

Grid=CreateGrid(rep,nGrid,alpha);

for i=1:numel(rep)
    rep(i)=FindGridIndex(rep(i),Grid);
end


%% MOPSO Main Loop

for it=1:MaxIt
    
    for i=1:nPop
        
        leader=SelectLeader(rep,beta);
        
        pop(i).Velocity = w*pop(i).Velocity ...
            +c1*rand(VarSize).*(pop(i).Best.Position-pop(i).Position) ...
            +c2*rand(VarSize).*(leader.Position-pop(i).Position);
        
        pop(i).Position = pop(i).Position + pop(i).Velocity;
        
        pop(i).Position = max(pop(i).Position, VarMin);
        pop(i).Position = min(pop(i).Position, VarMax);
        
        pop(i).Cost = CostFunction(pop(i).Position);
        
        % Apply Mutation
        pm=(1-(it-1)/(MaxIt-1))^(1/mu);
        if rand<pm
            NewSol.Position=Mutate(pop(i).Position,pm,VarMin,VarMax);
            NewSol.Cost=CostFunction(NewSol.Position);
            if Dominates(NewSol,pop(i))
                pop(i).Position=NewSol.Position;
                pop(i).Cost=NewSol.Cost;

            elseif Dominates(pop(i),NewSol)
                % Do Nothing

            else
                if rand<0.5
                    pop(i).Position=NewSol.Position;
                    pop(i).Cost=NewSol.Cost;
                end
            end
        end
        
        if Dominates(pop(i),pop(i).Best)
            pop(i).Best.Position=pop(i).Position;
            pop(i).Best.Cost=pop(i).Cost;
            
        elseif Dominates(pop(i).Best,pop(i))
            % Do Nothing
            
        else
            if rand<0.5
                pop(i).Best.Position=pop(i).Position;
                pop(i).Best.Cost=pop(i).Cost;
            end
        end
        
    end
    
    % Add Non-Dominated Particles to REPOSITORY
    rep=[rep
         pop(~[pop.IsDominated])]; %#ok
    
    % Determine Domination of New Resository Members
    rep=DetermineDomination(rep);
    
    % Keep only Non-Dminated Memebrs in the Repository
    rep=rep(~[rep.IsDominated]);
    
    % Update Grid
    Grid=CreateGrid(rep,nGrid,alpha);

    % Update Grid Indices
    for i=1:numel(rep)
        rep(i)=FindGridIndex(rep(i),Grid);
    end
    
    % Check if Repository is Full
    if numel(rep)>nRep
        
        Extra=numel(rep)-nRep;
        for e=1:Extra
            rep=DeleteOneRepMemebr(rep,gamma);
        end
        
    end
% % Plot Costs
%     figure(1);
%     hold on;
%     PlotCosts(pop,rep);
%     pause(0.01);
    
    % Show Iteration Information
    disp(['Iteration ' num2str(it) ': Number of Rep Members = ' num2str(numel(rep))]);
    
    % Damping Inertia Weight
    w=w*wdamp;
    
end
for i=1:nPop
    costs(i)=mean(pop(i).Best.Cost(:));
end

result_index=find(costs==min(costs));
result=pop(result_index).Best.Position; %result=[delx w_min w_error]

%Close session
appclose(h);
% save(h,'C:\Users\A&Y\Desktop\ipek\matlab optimization\files\project_namenum2str(it).fsp');% saves the file in a path specified
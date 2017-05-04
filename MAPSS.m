function [InitFunction, CostFunction, FeasibleFunction] = MAPSS

% The following was found by exhaustive search to be the best 20/4 MAPSS sensor set.
% However, this is computer-dependent because of numerical issues in Matlab's DARE routine.
% [1 2 2 2 2 3 3 6 7 7 7 7 8 9 9 9 9 10 10 10]

InitFunction = @MAPSSInit;
CostFunction = @MAPSSCost;
FeasibleFunction = @MAPSSFeasible;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [MaxParValue, MinParValue, Population, OPTIONS] = MAPSSInit(OPTIONS)

global MaxParValue MinParValue NumDups A C Q R P0 alpha
NumDups = 4; % number of duplicates of each sensor that are allowed
alpha = 1; % relative importance of financial cost to estimation error
% Get MAPSS linearized system matrices A, C, Q, and R
load matrices.mat; 
A = Aaug; C = Caug;
% Compute the reference steady state estimation error covariance
P0 = dare(A', C', Q, R, zeros(size(C')), eye(size(A)));
% Initialize population
for popindex = 1 : OPTIONS.popsize
    chrom = randperm(11 * NumDups);
    chrom = chrom(1 : OPTIONS.numVar);
    chrom = mod(chrom, 11);
    chrom(chrom==0) = 11;
    Population(popindex).chrom = chrom;
end
% Chromosome parameter can be any integer between 1 and 11 (sensor numbers)
MinParValue = 1;
MaxParValue = 11;
OPTIONS.OrderDependent = false;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Population] = MAPSSCost(OPTIONS, Population)

% Compute the sensor selection cost function of each member in Population
% Cost = sum(sqrt(P(i,i) / Pref(i,i))) + alpha * FinCost / RefFinCost
% There are 11 unique sensors that can be used in each sensor set.

global MaxParValue MinParValue NumDups A C Q R P0 alpha
popsize = OPTIONS.popsize;
DollarCost = 1000 * ones(11, 1); % dollar cost for initial use of each sensor
AdditionalCost = 750 * ones(11, 1); % dollar cost for duplicate sensors beyond the first of each type
ReferenceCost = sum(DollarCost); % dollar cost if 11 unique sensors are used
for popindex = 1 : popsize
    New_Sensor_Set = Population(popindex).chrom;
    New_Sensor_Set = mod(New_Sensor_Set, 11);
    New_Sensor_Set(New_Sensor_Set==0) = 11;
    New_Sensor_Set = sort(New_Sensor_Set);
    %MANIPULATING C AND R MATRICES BASED ON RANDOMLY GENERATED SENSOR
    %COMBINATION AND MAKING THE REMAINING ROWS ZEROS
    FIN_COST = 0;
    for i = 1 : 11
        SENSOR(i).COUNT = 0;
    end
    for i = 1 : 11
        SENSOR(i).COUNT = length(find(New_Sensor_Set == i));
        if  SENSOR(i).COUNT > 0 
            FIN_COST = FIN_COST + DollarCost(i); % initial sensor cost is defined in DollarCost array
            FIN_COST = FIN_COST + (SENSOR(i).COUNT - 1) * AdditionalCost(i);
        end
    end
    C_NEW = [];
    R_NEW = []; 
    for i = 1 : length(New_Sensor_Set)
        SENSOR_NUM = New_Sensor_Set(i);
        C_NEW(i, :) = C(SENSOR_NUM, :);
        R_NEW(i, :) = R(SENSOR_NUM, SENSOR_NUM);
    end  
    R_NEW = diag(R_NEW);
    % Compute the steady state estimation error covariance based on the sensors that are used
    lastwarn('');
    warning('off', 'control:InaccurateSolution');
    [P_ss, L, G, REPORT] = dare(A', C_NEW', Q, R_NEW, zeros(size(C_NEW')), eye(size(A)), 'report');
    % If a steady state ARE solution does not exist, set the cost to a large number
    if ~isempty(lastwarn) | REPORT == -1 | REPORT == -2
        Population(popindex).cost = 10e10;
        continue;
    end
    % Compute the cost of the sensor set: estimation error variance plus financial cost
    New_cost = 0;
    for i = 4 : 11 % health parameters are indices 4-11 in the augmented state vector
        New_cost = New_cost + sqrt(P_ss(i,i) / P0(i,i));
    end
    New_cost = New_cost + alpha * FIN_COST / ReferenceCost;
    Population(popindex).cost = New_cost;
    if (New_cost <= 0) | ~isreal(New_cost) | (New_cost >= 100)
        New_cost = inf;
    end
    Population(popindex).cost = New_cost;
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Population] = MAPSSFeasible(OPTIONS, Population)

% Make sure each sensor set does not contain more than the allowable number of copies of each sensor.

global MaxParValue MinParValue NumDups A C Q R P0 alpha
% Make sure none of the chromosomes has more than the allowable number of sensors
i = 0;
while i < OPTIONS.popsize
    i = i + 1;
    Chrom = Population(i).chrom;
    for j = 1 : 11
        indices = find(Chrom == j);
        if length(indices) > NumDups
            % The individual has too many copies of a single sensor, so 
            % replace the individual with a random sensor set.
            Chrom = randperm(11 * NumDups);
            Chrom = Chrom(1 : OPTIONS.numVar);
            Population(i).chrom = Chrom;
            i = i - 1; % decrement i so that this new individual can be checked again
            break;
        end
    end
end    
% Make sure each chromosome is an integer between the allowable values
for i = 1 : OPTIONS.popsize
    Chrom = round(Population(i).chrom);
    Chrom = mod(Chrom, 11);
    Chrom(Chrom==0) = 11;
    Chrom = max(Chrom, MinParValue);
    Chrom = min(Chrom, MaxParValue);
    Population(i).chrom = Chrom;
end
return;